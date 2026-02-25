import * as grpc from "@grpc/grpc-js";
import { YTNodes } from "youtubei.js";

import type { Track } from "@/gen/proto/common.js";
import type {
  GetUpNextRequest,
  GetUpNextResponse,
} from "@/gen/proto/yt_scraper.js";

import { getYtMusicClient } from "@/innertube.js";
import { createErrorResponse } from "@/response.js";
import { getHighestQualityThumbnail } from "@/utils/thumbnail.js";

export default async function getUpNext(
  call: grpc.ServerUnaryCall<GetUpNextRequest, GetUpNextResponse>,
  callback: grpc.sendUnaryData<GetUpNextResponse>,
) {
  try {
    const music = await getYtMusicClient();
    const track = await music.getInfo(call.request.videoId);
    const upNext = await track.getUpNext();

    const tracks: Track[] = [];

    for (const nextTrack of upNext.contents) {
      if (!nextTrack.is(YTNodes.PlaylistPanelVideo)) continue;

      const thumbnail = getHighestQualityThumbnail(nextTrack.thumbnail);

      if (
        !nextTrack.title.text ||
        !nextTrack.artists?.length ||
        !thumbnail ||
        !nextTrack.album?.name ||
        !nextTrack.album.id
      )
        continue;

      const track = {
        title: nextTrack.title.text,
        duration: nextTrack.duration.seconds,
        thumbnail: thumbnail.url,
        videoId: nextTrack.video_id,
        isExplicit: !!nextTrack.badges
          .as(YTNodes.MusicInlineBadge)
          .some((badge) => badge.icon_type === "MUSIC_EXPLICIT_BADGE"),
        album: {
          title: nextTrack.album.name,
          browseId: nextTrack.album.id,
        },
        artists: nextTrack.artists.map((artist) => ({
          title: artist.name,
          browseId: artist.channel_id ?? "VARIOUS_ARTISTS",
        })),
      } satisfies Track;
      tracks.push(track);
    }

    return callback(null, {
      continuationToken: upNext.continuation,
      tracks,
    });
  } catch (error) {
    console.error("Up-next fetch failed: ", error);
    callback(createErrorResponse(`Up-next fetch failed: ${error}`));
  }
}
