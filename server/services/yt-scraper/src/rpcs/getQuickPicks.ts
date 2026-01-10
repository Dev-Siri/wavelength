import * as grpc from "@grpc/grpc-js";

import {
  GetQuickPicksResponse,
  type GetQuickPicksRequest,
} from "../gen/proto/yt_scraper_pb";

import { DEFAULT_CLIENT } from "../config";
import {
  EmbeddedAlbum,
  EmbeddedArtist,
  QuickPick,
} from "../gen/proto/common_pb";
import { musicPref } from "../innertube";
import { quickPicksSchema } from "../schemas/quick-picks";
import { getHighestQualityThumbnail } from "../utils/thumbnail";

export default async function getQuickPicks(
  call: grpc.ServerUnaryCall<GetQuickPicksRequest, GetQuickPicksResponse>,
  callback: grpc.sendUnaryData<GetQuickPicksResponse>
) {
  const region = call.request.getGl() || DEFAULT_CLIENT;

  const music = await musicPref(region);
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

  const response = new GetQuickPicksResponse();
  const responseQuickPicks: QuickPick[] = [];

  for (const parsedQuickPick of parsedQuickPicks.data.contents) {
    const responseQuickPick = new QuickPick();
    responseQuickPick.setVideoId(parsedQuickPick.id);
    responseQuickPick.setTitle(parsedQuickPick.title);

    const thumbnail = getHighestQualityThumbnail(parsedQuickPick.thumbnail);
    if (thumbnail) responseQuickPick.setThumbnail(thumbnail.url);

    const artists: EmbeddedArtist[] = [];
    for (const artist of parsedQuickPick.artists) {
      const quickPicksArtists = new EmbeddedArtist();
      quickPicksArtists.setTitle(artist.name);
      quickPicksArtists.setBrowseId(artist.channel_id);

      artists.push(quickPicksArtists);
    }

    if (!artists.length) continue;

    responseQuickPick.setArtistsList(artists);

    if (parsedQuickPick.album) {
      const quickPickAlbum = new EmbeddedAlbum();
      quickPickAlbum.setBrowseId(parsedQuickPick.album.id);
      quickPickAlbum.setTitle(parsedQuickPick.album.name);

      responseQuickPick.setAlbum(quickPickAlbum);
    }

    responseQuickPicks.push(responseQuickPick);
  }

  response.setQuickPicksList(responseQuickPicks);
  callback(null, response);
}
