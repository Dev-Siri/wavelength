import * as grpc from "@grpc/grpc-js";

import {
  GetQuickPicksResponse,
  type GetQuickPicksRequest,
} from "@/gen/proto/yt_scraper.js";

import { DEFAULT_CLIENT } from "@/config.js";
import {
  EmbeddedAlbum,
  EmbeddedArtist,
  QuickPick,
} from "@/gen/proto/common.js";
import { getYtMusicClient } from "@/innertube.js";
import { quickPicksSchema } from "@/schemas/quick-picks.js";
import { getHighestQualityThumbnail } from "@/utils/thumbnail.js";

export default async function getQuickPicks(
  call: grpc.ServerUnaryCall<GetQuickPicksRequest, GetQuickPicksResponse>,
  callback: grpc.sendUnaryData<GetQuickPicksResponse>
) {
  try {
    const music = await getYtMusicClient(call.request.gl || DEFAULT_CLIENT);
    const { sections } = await music.getHomeFeed();

    if (!sections) {
      const status = new grpc.StatusBuilder()
        .withCode(grpc.status.INTERNAL)
        .withDetails("YouTube Music sent an empty response.")
        .build();
      return callback(status);
    }

    const [quickPicks] = sections;
    const parsedQuickPicks = quickPicksSchema.safeParse(quickPicks);

    if (!parsedQuickPicks.success) {
      const status = new grpc.StatusBuilder()
        .withCode(grpc.status.INTERNAL)
        .withDetails("Quick Picks response is invalid.")
        .build();
      return callback(status);
    }

    const responseQuickPicks: QuickPick[] = [];

    for (const parsedQuickPick of parsedQuickPicks.data.contents) {
      const thumbnail = getHighestQualityThumbnail(parsedQuickPick.thumbnail);
      if (!thumbnail) continue;

      const artists: EmbeddedArtist[] = [];
      for (const artist of parsedQuickPick.artists) {
        const quickPicksArtists = {
          title: artist.name,
          browseId: artist.channel_id,
        } satisfies EmbeddedArtist;

        artists.push(quickPicksArtists);
      }

      if (!artists.length) continue;

      const responseQuickPick: QuickPick = {
        videoId: parsedQuickPick.id,
        title: parsedQuickPick.title,
        artists,
        thumbnail: thumbnail.url,
      };

      if (parsedQuickPick.album) {
        const quickPickAlbum = {
          browseId: parsedQuickPick.album.id,
          title: parsedQuickPick.album.name,
        } satisfies EmbeddedAlbum;

        responseQuickPick.album = quickPickAlbum;
      }

      responseQuickPicks.push(responseQuickPick);
    }

    return callback(null, { quickPicks: responseQuickPicks });
  } catch (error) {
    console.error("Quick picks fetch failed: ", error);
    const status = new grpc.StatusBuilder()
      .withCode(grpc.status.INTERNAL)
      .withDetails("Quick picks fetch failed: " + String(error))
      .build();
    callback(status);
  }
}
