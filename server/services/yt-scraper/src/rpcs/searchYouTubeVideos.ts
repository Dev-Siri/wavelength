import * as grpc from "@grpc/grpc-js";

import { getYtClient } from "@/innertube.js";

import type { YouTubeVideo } from "@/gen/proto/common.js";
import type {
  SearchYouTubeVideosRequest,
  SearchYouTubeVideosResponse,
} from "@/gen/proto/yt_scraper.js";
import { YTNodes } from "youtubei.js";

export default async function searchYouTubeVideos(
  call: grpc.ServerUnaryCall<
    SearchYouTubeVideosRequest,
    SearchYouTubeVideosResponse
  >,
  callback: grpc.sendUnaryData<SearchYouTubeVideosResponse>,
) {
  try {
    const client = await getYtClient();
    const { videos } = await client.search(call.request.query, {
      type: "video",
    });

    const parsedVideos: YouTubeVideo[] = [];

    for (const video of videos) {
      const youtubeVideo = video.as(YTNodes.Video);

      const thumbnail = youtubeVideo.thumbnails[0];
      if (
        !youtubeVideo.title.text ||
        typeof youtubeVideo.author.endpoint?.payload?.browseId !== "string" ||
        !thumbnail
      )
        continue;

      const parsedVideo = {
        videoId: youtubeVideo.video_id,
        title: youtubeVideo.title.text,
        author: youtubeVideo.author.name,
        authorChannelId: youtubeVideo.author.endpoint.payload.browseId,
        thumbnail: thumbnail.url,
      } satisfies YouTubeVideo;

      parsedVideos.push(parsedVideo);
    }

    return callback(null, { videos: parsedVideos });
  } catch (error) {
    console.error("YouTube videos search failed: ", error);
    const status = new grpc.StatusBuilder()
      .withCode(grpc.status.INTERNAL)
      .withDetails("YouTube videos search failed: " + String(error))
      .build();
    callback(status);
  }
}
