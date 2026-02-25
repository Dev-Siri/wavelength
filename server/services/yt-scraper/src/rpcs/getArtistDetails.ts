import * as grpc from "@grpc/grpc-js";
import { YTNodes } from "youtubei.js";

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
import { createErrorResponse } from "@/response.js";
import { parseStringToAlbumType } from "@/utils/parse.js";
import { getHighestQualityThumbnail } from "@/utils/thumbnail.js";

export default async function getArtistDetails(
  call: grpc.ServerUnaryCall<GetArtistDetailsRequest, GetArtistDetailsResponse>,
  callback: grpc.sendUnaryData<GetArtistDetailsResponse>,
) {
  try {
    const music = await getYtMusicClient();
    const artistDetails = await music.getArtist(call.request.browseId);
    const topSongsList = await artistDetails.getAllSongs();

    const parsedArtistDetails = artistDetails.header?.as(
      YTNodes.MusicImmersiveHeader,
    );
    const albumsList = artistDetails.sections[1]?.contents.as(
      YTNodes.MusicTwoRowItem,
    );
    const singlesAndEpsList = artistDetails.sections[2]?.contents.as(
      YTNodes.MusicTwoRowItem,
    );

    if (
      !parsedArtistDetails ||
      !parsedArtistDetails.title.text ||
      !parsedArtistDetails.subscription_button?.channel_id ||
      !parsedArtistDetails.thumbnail ||
      !topSongsList ||
      !albumsList ||
      !singlesAndEpsList
    )
      return callback(
        createErrorResponse("YouTube music sent an invalid response"),
      );

    const thumbnail = getHighestQualityThumbnail(parsedArtistDetails.thumbnail);
    if (!thumbnail)
      return callback(
        createErrorResponse(
          "YouTube music sent an invalid response: Missing thumbnail.",
        ),
      );

    const topSongs: Artist_TopSongTrack[] = [];
    const albums: Artist_ArtistAlbum[] = [];
    const singlesAndEps: Artist_ArtistAlbum[] = [];

    for (const musicResponseListItem of topSongsList.contents) {
      if (!musicResponseListItem.is(YTNodes.MusicResponsiveListItem)) continue;

      const parsedTopSong = musicResponseListItem.as(
        YTNodes.MusicResponsiveListItem,
      );
      if (!parsedTopSong.thumbnail || !parsedTopSong.id || !parsedTopSong.title)
        continue;

      const [, , playCount, albumInfo] = parsedTopSong.flex_columns;

      const albumId = albumInfo?.title.endpoint?.payload.browseId;

      const thumbnail = getHighestQualityThumbnail(parsedTopSong.thumbnail);
      if (
        !playCount?.title.text ||
        !albumInfo?.title.text ||
        !albumId ||
        !parsedTopSong.duration?.seconds ||
        !thumbnail
      )
        continue;

      const artists = parsedTopSong.artists?.map((artist) => ({
        title: artist.name,
        browseId: artist.channel_id ?? "VARIOUS_ARTISTS",
      }));

      const topSongTrack = {
        videoId: parsedTopSong.id,
        title: parsedTopSong.title,
        duration: parsedTopSong.duration.seconds,
        playCount: playCount.title.text,
        album: {
          title: albumInfo.title.text,
          browseId: albumId,
        },
        artists: artists?.length
          ? artists
          : [{ title: "Various Artists", browseId: "VARIOUS_ARTISTS" }],
        thumbnail: thumbnail.url,
        isExplicit: !!parsedTopSong.badges
          ?.as(YTNodes.MusicInlineBadge)
          ?.some((badge) => badge.icon_type === "MUSIC_EXPLICIT_BADGE"),
      } satisfies Artist_TopSongTrack;

      topSongs.push(topSongTrack);
    }

    for (const parsedAlbum of albumsList) {
      if (!parsedAlbum.thumbnail || !parsedAlbum.id || !parsedAlbum.title.text)
        continue;

      const thumbnail = getHighestQualityThumbnail(parsedAlbum.thumbnail);
      const releaseDate = parsedAlbum.year ?? parsedAlbum.subtitle.text;
      if (!thumbnail || !releaseDate) continue;

      const album = {
        albumId: parsedAlbum.id,
        title: parsedAlbum.title.text,
        albumType: AlbumType.ALBUM_TYPE_ALBUM,
        releaseDate,
        thumbnail: thumbnail.url,
      } satisfies Artist_ArtistAlbum;

      albums.push(album);
    }

    for (const parsedSingleOrEp of singlesAndEpsList) {
      if (
        !parsedSingleOrEp.subtitle.text ||
        !parsedSingleOrEp.title.text ||
        !parsedSingleOrEp.id
      )
        continue;

      const [albumTypeStr] = parsedSingleOrEp.subtitle.text.split("•");
      const thumbnail = getHighestQualityThumbnail(parsedSingleOrEp.thumbnail);

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
      title: parsedArtistDetails.title.text,
      description: parsedArtistDetails.description?.text ?? "",
      browseId: parsedArtistDetails.subscription_button?.channel_id,
      audience:
        parsedArtistDetails.subscription_button?.subscribe_accessibility_label
          ?.replace("Subscribe to this channel.", "")
          .trim() ?? "low monthly listeners",
      thumbnail: thumbnail.url,
      topSongs,
      albums,
      singlesAndEps,
    } satisfies Artist;

    return callback(null, { artist });
  } catch (error) {
    console.error("Artist details fetch failed: ", error);
    callback(createErrorResponse(`Artist details fetch failed: ${error}`));
  }
}
