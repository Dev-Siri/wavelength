import * as grpc from "@grpc/grpc-js";
import { YTNodes } from "youtubei.js";

import { SearchArtist } from "@/gen/proto/common.js";
import {
  SearchArtistsResponse,
  type SearchArtistsRequest,
} from "@/gen/proto/yt_scraper.js";
import { getYtMusicClient } from "@/innertube.js";
import { createErrorResponse } from "@/response.js";
import { getHighestQualityThumbnail } from "@/utils/thumbnail.js";

export default async function searchArtists(
  call: grpc.ServerUnaryCall<SearchArtistsRequest, SearchArtistsResponse>,
  callback: grpc.sendUnaryData<SearchArtistsResponse>,
) {
  try {
    const music = await getYtMusicClient();
    const { contents } = await music.search(call.request.query, {
      type: "artist",
    });

    if (!contents)
      return callback(
        createErrorResponse("YouTube Music sent an empty response."),
      );

    const parsedArtists = contents[0]?.contents?.as(
      YTNodes.MusicResponsiveListItem,
    );

    if (!parsedArtists)
      return callback(
        createErrorResponse("YouTube Music sent an invalid response."),
      );

    const artists: SearchArtist[] = [];
    for (const parsedArtist of parsedArtists) {
      if (
        !parsedArtist.subtitle?.text ||
        !parsedArtist.thumbnail ||
        !parsedArtist.name ||
        !parsedArtist.id
      )
        continue;

      const [, audience] = parsedArtist.subtitle.text.split("•");
      if (!audience) continue;

      const thumbnail = getHighestQualityThumbnail(parsedArtist.thumbnail);
      if (!thumbnail) continue;

      const artist = {
        title: parsedArtist.name,
        audience: audience.trim(),
        thumbnail: thumbnail.url,
        browseId: parsedArtist.id,
      } satisfies SearchArtist;

      artists.push(artist);
    }

    return callback(null, { artists });
  } catch (error) {
    console.error("Artists search failed: ", error);
    callback(createErrorResponse(`Artists search failed: ${error}`));
  }
}
