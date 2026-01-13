import * as grpc from "@grpc/grpc-js";

import { SearchArtist } from "@/gen/proto/common.js";
import {
  SearchArtistsResponse,
  type SearchArtistsRequest,
} from "@/gen/proto/yt_scraper.js";
import { getYtMusicClient } from "@/innertube.js";
import { searchArtistSchema } from "@/schemas/artist.js";
import { getHighestQualityThumbnail } from "@/utils/thumbnail.js";

export default async function searchArtists(
  call: grpc.ServerUnaryCall<SearchArtistsRequest, SearchArtistsResponse>,
  callback: grpc.sendUnaryData<SearchArtistsResponse>
) {
  try {
    const music = await getYtMusicClient();
    const { contents } = await music.search(call.request.query, {
      type: "artist",
    });

    if (!contents) {
      const status = new grpc.StatusBuilder()
        .withCode(grpc.status.INTERNAL)
        .withDetails("YouTube Music sent an empty response.")
        .build();
      return callback(status);
    }

    const parsedArtists = searchArtistSchema.safeParse(contents[0]?.contents);

    if (!parsedArtists.success) {
      const status = new grpc.StatusBuilder()
        .withCode(grpc.status.INTERNAL)
        .withDetails("YouTube Music sent an invalid response.")
        .build();
      return callback(status);
    }

    const artists: SearchArtist[] = [];
    for (const parsedArtist of parsedArtists.data) {
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
    const status = new grpc.StatusBuilder()
      .withCode(grpc.status.INTERNAL)
      .withDetails("Artists search failed: " + String(error))
      .build();
    callback(status);
  }
}
