import * as grpc from "@grpc/grpc-js";

import type {
  GetArtistDetailsRequest,
  GetArtistDetailsResponse,
} from "@/gen/proto/yt_scraper.js";

import {
  AlbumType,
  type Artist,
  type Artist_ArtistAlbum,
  type Artist_TopSongTrack,
} from "@/gen/proto/common.js";
import { getYtMusicClient } from "@/innertube.js";
import {
  artistDetailsResponseAlbumsSchema,
  artistDetailsResponseHeaderSchema,
  artistDetailsResponseTopSongsSchema,
} from "@/schemas/artist.js";
import { parseStringToAlbumType } from "@/utils/parse.js";
import { getHighestQualityThumbnail } from "@/utils/thumbnail.js";

export default async function getArtistDetails(
  call: grpc.ServerUnaryCall<GetArtistDetailsRequest, GetArtistDetailsResponse>,
  callback: grpc.sendUnaryData<GetArtistDetailsResponse>
) {
  try {
    const music = await getYtMusicClient();
    const { header, sections } = await music.getArtist(call.request.browseId);

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

    const thumbnail = getHighestQualityThumbnail(
      parsedArtistDetails.data.thumbnail
    );
    if (!thumbnail) {
      const status = new grpc.StatusBuilder()
        .withCode(grpc.status.INTERNAL)
        .withDetails("YouTube music sent an invalid response.")
        .build();
      return callback(status, null);
    }

    const topSongs: Artist_TopSongTrack[] = [];
    const albums: Artist_ArtistAlbum[] = [];
    const singlesAndEps: Artist_ArtistAlbum[] = [];

    for (const parsedTopSong of parsedTopSongs.data) {
      const [, , playCount, albumInfo] = parsedTopSong.flex_columns;
      const albumBrowseId =
        albumInfo?.title.runs[0]?.endpoint?.payload?.browseId;

      const thumbnail = getHighestQualityThumbnail(parsedTopSong.thumbnail);
      if (!playCount || !albumInfo || !albumBrowseId || !thumbnail) continue;

      const topSongTrack = {
        videoId: parsedTopSong.id,
        title: parsedTopSong.title,
        playCount: playCount.title.text,
        album: {
          title: albumInfo.title.text,
          browseId: albumBrowseId,
        },
        thumbnail: thumbnail.url,
        isExplicit: !!parsedTopSong.badges?.some(
          (badge) => badge.icon_type === "MUSIC_EXPLICIT_BADGE"
        ),
      } satisfies Artist_TopSongTrack;

      topSongs.push(topSongTrack);
    }

    for (const parsedAlbum of parsedAlbums.data) {
      const thumbnail = getHighestQualityThumbnail({
        type: "MusicThumbnail",
        contents: parsedAlbum.thumbnail,
      });

      if (!thumbnail) continue;

      const album = {
        albumId: parsedAlbum.id,
        title: parsedAlbum.title.text,
        albumType: AlbumType.ALBUM_TYPE_ALBUM,
        releaseDate: parsedAlbum.year ?? parsedAlbum.subtitle.text,
        thumbnail: thumbnail.url,
      } satisfies Artist_ArtistAlbum;

      albums.push(album);
    }

    for (const parsedSingleOrEp of parsedSinglesAndEps.data) {
      const [albumTypeStr] = parsedSingleOrEp.subtitle.text.split("•");
      const thumbnail = getHighestQualityThumbnail({
        type: "MusicThumbnail",
        contents: parsedSingleOrEp.thumbnail,
      });

      if (!albumTypeStr || !thumbnail) continue;

      const album = {
        title: parsedSingleOrEp.title.text,
        albumId: parsedSingleOrEp.id,
        releaseDate: parsedSingleOrEp.year ?? parsedSingleOrEp.subtitle.text,
        // Default for EPs and singles
        albumType:
          parseStringToAlbumType(albumTypeStr.trim()) ||
          AlbumType.ALBUM_TYPE_EP,
        thumbnail: thumbnail.url,
      } satisfies Artist_ArtistAlbum;

      singlesAndEps.push(album);
    }

    const artist = {
      title: parsedArtistDetails.data.title.text,
      description: parsedArtistDetails.data?.description?.text ?? "",
      browseId: parsedArtistDetails.data.subscription_button.channel_id,
      audience:
        parsedArtistDetails.data.subscription_button.subscribe_accessibility_label
          .replace("Subscribe to this channel.", "")
          .trim(),
      thumbnail: thumbnail.url,
      topSongs,
      albums,
      singlesAndEps,
    } satisfies Artist;

    return callback(null, { artist });
  } catch (error) {
    console.error("Artist details fetch failed: ", error);
    const status = new grpc.StatusBuilder()
      .withCode(grpc.status.INTERNAL)
      .withDetails("Artist details fetch failed: " + String(error))
      .build();
    callback(status);
  }
}
