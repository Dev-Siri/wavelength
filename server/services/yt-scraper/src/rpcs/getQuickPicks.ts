import * as grpc from "@grpc/grpc-js";
import { YTNodes } from "youtubei.js";

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
import { createErrorResponse } from "@/response.js";
import { getHighestQualityThumbnail } from "@/utils/thumbnail.js";

export default async function getQuickPicks(
  call: grpc.ServerUnaryCall<GetQuickPicksRequest, GetQuickPicksResponse>,
  callback: grpc.sendUnaryData<GetQuickPicksResponse>,
) {
  try {
    const music = await getYtMusicClient(call.request.gl || DEFAULT_CLIENT);
    const { sections } = await music.getHomeFeed();

    if (!sections)
      return callback(
        createErrorResponse("YouTube Music sent an empty response."),
      );

    const quickPicks = sections[0]?.as(YTNodes.MusicCarouselShelf);
    if (!quickPicks)
      return callback(
        createErrorResponse("YouTube Music sent an invalid response."),
      );

    const responseQuickPicks: QuickPick[] = [];

    for (const quickPick of quickPicks.contents) {
      if (!quickPick.is(YTNodes.MusicResponsiveListItem)) continue;

      const parsedQuickPick = quickPick.as(YTNodes.MusicResponsiveListItem);

      if (
        !parsedQuickPick.thumbnail ||
        !parsedQuickPick.artists ||
        !parsedQuickPick.id ||
        !parsedQuickPick.title ||
        !parsedQuickPick.album?.id
      )
        continue;

      const thumbnail = getHighestQualityThumbnail(parsedQuickPick.thumbnail);
      if (!thumbnail) continue;

      const artists: EmbeddedArtist[] = [];
      for (const artist of parsedQuickPick.artists) {
        const quickPicksArtists = {
          title: artist.name,
          browseId: artist.channel_id ?? "VARIOUS_ARTISTS",
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
    callback(createErrorResponse(`Quick picks fetch failed: ${error}`));
  }
}
