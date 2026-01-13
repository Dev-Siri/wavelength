import * as grpc from "@grpc/grpc-js";

import type { Album, AlbumTrack } from "@/gen/proto/common.js";
import type {
  GetAlbumDetailsRequest,
  GetAlbumDetailsResponse,
} from "@/gen/proto/yt_scraper.js";

import { getYtMusicClient } from "@/innertube.js";
import { albumContents, albumHeaderSchema } from "@/schemas/album.js";
import { parseStringToAlbumType } from "@/utils/parse.js";
import { getHighestQualityThumbnail } from "@/utils/thumbnail.js";

export default async function getAlbumDetails(
  call: grpc.ServerUnaryCall<GetAlbumDetailsRequest, GetAlbumDetailsResponse>,
  callback: grpc.sendUnaryData<GetAlbumDetailsResponse>
) {
  try {
    const music = await getYtMusicClient();
    const { header, contents } = await music.getAlbum(call.request.albumId);

    if (!contents) {
      const status = new grpc.StatusBuilder()
        .withCode(grpc.status.INTERNAL)
        .withDetails("YouTube Music sent an empty response.")
        .build();
      return callback(status);
    }

    const parsedDetails = albumHeaderSchema.safeParse(header);
    if (!parsedDetails.success) {
      const status = new grpc.StatusBuilder()
        .withCode(grpc.status.INTERNAL)
        .withDetails("YouTube Music sent an invalid response.")
        .build();
      return callback(status);
    }

    const parsedTracks = albumContents.safeParse(contents);
    if (!parsedTracks.success) {
      const status = new grpc.StatusBuilder()
        .withCode(grpc.status.INTERNAL)
        .withDetails("YouTube Music sent an invalid response.")
        .build();
      return callback(status);
    }

    const thumbnail = getHighestQualityThumbnail(parsedDetails.data.thumbnail);
    if (!thumbnail) {
      const status = new grpc.StatusBuilder()
        .withCode(grpc.status.INTERNAL)
        .withDetails("YouTube Music sent an invalid response.")
        .build();
      return callback(status);
    }

    const [albumType, release] = parsedDetails.data.subtitle.text.split(" • ");
    if (!albumType || !release) {
      const status = new grpc.StatusBuilder()
        .withCode(grpc.status.INTERNAL)
        .withDetails("YouTube Music sent an invalid response.")
        .build();
      return callback(status);
    }

    const [, totalDuration] =
      parsedDetails.data.second_subtitle.text.split("•");
    if (!totalDuration) {
      const status = new grpc.StatusBuilder()
        .withCode(grpc.status.INTERNAL)
        .withDetails("YouTube Music sent an invalid response.")
        .build();
      return callback(status);
    }

    const albumTracks: AlbumTrack[] = [];
    for (const parsedTrack of parsedTracks.data) {
      const albumTrack = {
        title: parsedTrack.title,
        positionInAlbum: Number(parsedTrack.index.text),
        duration: parsedTrack.duration.seconds,
        videoId: parsedTrack.id,
        isExplicit: !!parsedTrack?.badges?.some(
          (badge) => badge.icon_type === "MUSIC_EXPLICIT_BADGE"
        ),
      } satisfies AlbumTrack;

      albumTracks.push(albumTrack);
    }

    const album = {
      title: parsedDetails.data.title.text,
      cover: thumbnail.url,
      albumType: parseStringToAlbumType(albumType),
      release,
      totalDuration: totalDuration.trim(),
      artist: {
        title: parsedDetails.data.strapline_text_one.text,
        browseId:
          parsedDetails.data.strapline_text_one.endpoint.payload.browseId,
      },
      totalSongCount: albumTracks.length,
      albumTracks: albumTracks,
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
