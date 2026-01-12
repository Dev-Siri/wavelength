import * as grpc from "@grpc/grpc-js";

import { AlbumType, Artist, EmbeddedAlbum } from "../gen/proto/common_pb";
import {
  GetArtistDetailsResponse,
  type GetArtistDetailsRequest,
} from "../gen/proto/yt_scraper_pb";
import { music } from "../innertube";
import {
  artistDetailsResponseAlbumsSchema,
  artistDetailsResponseHeaderSchema,
  artistDetailsResponseTopSongsSchema,
} from "../schemas/artist";
import { parseStringToAlbumType } from "../utils/parse";
import { getHighestQualityThumbnail } from "../utils/thumbnail";

export default async function getArtistDetails(
  call: grpc.ServerUnaryCall<GetArtistDetailsRequest, GetArtistDetailsResponse>,
  callback: grpc.sendUnaryData<GetArtistDetailsResponse>
) {
  try {
    const browseId = call.request.getBrowseId();
    const { header, sections } = await music.getArtist(browseId);

    const parsedArtistDetails =
      artistDetailsResponseHeaderSchema.safeParse(header);

    const parsedTopSongs = artistDetailsResponseTopSongsSchema.safeParse(
      sections[0]?.contents
    );

    const parsedAlbums = artistDetailsResponseAlbumsSchema.safeParse(
      sections[1]?.contents
    );

    const parsedSinglesAndEps = artistDetailsResponseAlbumsSchema.safeParse(
      sections[2]?.contents
    );

    if (
      !parsedArtistDetails.success ||
      !parsedTopSongs.success ||
      !parsedAlbums.success ||
      !parsedSinglesAndEps.success
    ) {
      const status = new grpc.StatusBuilder()
        .withCode(grpc.status.INTERNAL)
        .withDetails("YouTube music sent an invalid response.")
        .build();
      return callback(status, null);
    }

    const artist = new Artist();

    artist.setTitle(parsedArtistDetails.data.title.text);
    artist.setDescription(parsedArtistDetails.data?.description?.text ?? "");
    artist.setBrowseId(parsedArtistDetails.data.subscription_button.channel_id);
    artist.setAudience(
      parsedArtistDetails.data.subscription_button.subscribe_accessibility_label
        .replace("Subscribe to this channel.", "")
        .trim()
    );

    const thumbnail = getHighestQualityThumbnail(
      parsedArtistDetails.data.thumbnail
    );

    if (thumbnail) artist.setThumbnail(thumbnail.url);

    const topSongs: Artist.TopSongTrack[] = [];
    const albums: Artist.ArtistAlbum[] = [];
    const singlesAndEps: Artist.ArtistAlbum[] = [];

    for (const parsedTopSong of parsedTopSongs.data) {
      const topSongTrack = new Artist.TopSongTrack();
      topSongTrack.setVideoId(parsedTopSong.id);
      topSongTrack.setTitle(parsedTopSong.title);

      const [, , playCount, albumInfo] = parsedTopSong.flex_columns;
      const albumBrowseId =
        albumInfo?.title.runs[0]?.endpoint?.payload?.browseId;

      if (!playCount || !albumInfo || !albumBrowseId) continue;

      topSongTrack.setPlayCount(playCount.title.text);

      const album = new EmbeddedAlbum();

      album.setTitle(albumInfo.title.text);
      album.setBrowseId(albumBrowseId);

      topSongTrack.setAlbum(album);

      const thumbnail = getHighestQualityThumbnail(parsedTopSong.thumbnail);
      if (thumbnail) topSongTrack.setThumbnail(thumbnail.url);

      const isExplicit = !!parsedTopSong.badges?.some(
        (badge) => badge.icon_type === "MUSIC_EXPLICIT_BADGE"
      );
      topSongTrack.setIsExplicit(isExplicit);

      topSongs.push(topSongTrack);
    }

    for (const parsedAlbum of parsedAlbums.data) {
      const album = new Artist.ArtistAlbum();

      album.setTitle(parsedAlbum.title.text);
      album.setAlbumId(parsedAlbum.id);
      album.setAlbumType(AlbumType.ALBUM_TYPE_ALBUM);
      album.setReleaseDate(parsedAlbum.year ?? parsedAlbum.subtitle.text);

      const thumbnail = getHighestQualityThumbnail({
        type: "MusicThumbnail",
        contents: parsedAlbum.thumbnail,
      });
      if (thumbnail) album.setThumbnail(thumbnail.url);

      albums.push(album);
    }

    for (const parsedSingleOrEp of parsedSinglesAndEps.data) {
      const album = new Artist.ArtistAlbum();

      album.setTitle(parsedSingleOrEp.title.text);
      album.setAlbumId(parsedSingleOrEp.id);
      album.setReleaseDate(
        parsedSingleOrEp.year ?? parsedSingleOrEp.subtitle.text
      );

      const [albumTypeStr] = parsedSingleOrEp.subtitle.text.split("•");
      if (!albumTypeStr) continue;

      album.setAlbumType(parseStringToAlbumType(albumTypeStr.trim()));

      const thumbnail = getHighestQualityThumbnail({
        type: "MusicThumbnail",
        contents: parsedSingleOrEp.thumbnail,
      });
      if (thumbnail) album.setThumbnail(thumbnail.url);

      // Default for EPs and singles
      if (!album.getAlbumType()) album.setAlbumType(AlbumType.ALBUM_TYPE_EP);

      singlesAndEps.push(album);
    }

    artist.setTopSongsList(topSongs);
    artist.setAlbumsList(albums);
    artist.setSinglesAndEpsList(singlesAndEps);

    const response = new GetArtistDetailsResponse();
    response.setArtist(artist);

    callback(null, response);
  } catch (error) {
    console.error("Artist details fetch failed: ", error);
    const status = new grpc.StatusBuilder()
      .withCode(grpc.status.INTERNAL)
      .withDetails("Artist details fetch failed.")
      .build();
    callback(status);
  }
}
