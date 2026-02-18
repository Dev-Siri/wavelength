import * as grpc from "@grpc/grpc-js";
import { YTNodes } from "youtubei.js";

import type { Album, AlbumTrack, EmbeddedArtist } from "@/gen/proto/common.js";
import type {
  GetAlbumDetailsRequest,
  GetAlbumDetailsResponse,
} from "@/gen/proto/yt_scraper.js";

import { getYtMusicClient } from "@/innertube.js";
import { parseStringToAlbumType } from "@/utils/parse.js";
import { getHighestQualityThumbnail } from "@/utils/thumbnail.js";

export default async function getAlbumDetails(
  call: grpc.ServerUnaryCall<GetAlbumDetailsRequest, GetAlbumDetailsResponse>,
  callback: grpc.sendUnaryData<GetAlbumDetailsResponse>,
) {
  try {
    const music = await getYtMusicClient();
    const { header, contents } = await music.getAlbum(call.request.albumId);

    if (!header || !contents) {
      const status = new grpc.StatusBuilder()
        .withCode(grpc.status.INTERNAL)
        .withDetails("YouTube Music sent an empty response.")
        .build();
      return callback(status);
    }

    const musicResponseHeader = header.as(YTNodes.MusicResponsiveHeader);

    if (
      !musicResponseHeader.subtitle.text ||
      !musicResponseHeader.second_subtitle.text ||
      !musicResponseHeader.title.text ||
      !musicResponseHeader.subtitle.text ||
      !musicResponseHeader.strapline_text_one.text
    ) {
      const status = new grpc.StatusBuilder()
        .withCode(grpc.status.INTERNAL)
        .withDetails("YouTube Music sent an empty response.")
        .build();
      return callback(status);
    }

    const musicList = contents.as(YTNodes.MusicResponsiveListItem);

    if (!musicResponseHeader.thumbnail) return;

    const thumbnail = getHighestQualityThumbnail(musicResponseHeader.thumbnail);
    if (!thumbnail) {
      const status = new grpc.StatusBuilder()
        .withCode(grpc.status.INTERNAL)
        .withDetails("YouTube Music sent an invalid response.")
        .build();
      return callback(status);
    }

    const [albumType, release] = musicResponseHeader.subtitle.text.split(" • ");
    if (!albumType || !release) {
      const status = new grpc.StatusBuilder()
        .withCode(grpc.status.INTERNAL)
        .withDetails("YouTube Music sent an invalid response.")
        .build();
      return callback(status);
    }

    const [, totalDuration] =
      musicResponseHeader.second_subtitle.text.split("•");
    if (!totalDuration) {
      const status = new grpc.StatusBuilder()
        .withCode(grpc.status.INTERNAL)
        .withDetails("YouTube Music sent an invalid response.")
        .build();
      return callback(status);
    }

    const albumTracks: AlbumTrack[] = [];
    for (let i = 0; i < musicList.length; i++) {
      const track = musicList[i];
      if (!track || !track.title || !track.duration || !track.id) continue;

      const positionInArray = i + 1;
      const parsedArtistsField: EmbeddedArtist[] =
        track.artists?.map((artist) => ({
          title: artist.name,
          browseId: artist.channel_id ?? "VARIOUS_ARTISTS",
        })) ?? [];

      const artists = parsedArtistsField.length
        ? parsedArtistsField
        : [
            {
              title:
                track.flex_columns[1]?.as(
                  YTNodes.MusicResponsiveListItemFlexColumn,
                ).title.text ?? "VARIOUS_ARTISTS",
              browseId: "VARIOUS_ARTISTS",
            },
          ];

      const isExplicit = !!track?.badges?.some(
        (badge) =>
          badge.as(YTNodes.MusicInlineBadge).icon_type ===
          "MUSIC_EXPLICIT_BADGE",
      );

      const albumTrack = {
        title: track.title,
        positionInAlbum: Number(track.index?.text ?? positionInArray),
        duration: track.duration.seconds,
        videoId: track.id,
        isExplicit,
        artists,
      } satisfies AlbumTrack;

      albumTracks.push(albumTrack);
    }

    const album = {
      title: musicResponseHeader.title.text,
      description: musicResponseHeader.description?.description?.text ?? "",
      cover: thumbnail.url,
      albumType: parseStringToAlbumType(albumType),
      release,
      totalDuration: totalDuration.trim(),
      artist: {
        title: musicResponseHeader.strapline_text_one.text,
        browseId:
          musicResponseHeader.strapline_text_one.endpoint?.payload.browseId ??
          "VARIOUS_ARTISTS",
      },
      totalSongCount: albumTracks.length,
      albumTracks,
    } satisfies Album;

    return callback(null, { album });
  } catch (error) {
    console.error("Album details fetch failed.", error);
    const status = new grpc.StatusBuilder()
      .withCode(grpc.status.INTERNAL)
      .withDetails("Album details fetch failed: " + String(error))
      .build();
    callback(status);
  }
}
