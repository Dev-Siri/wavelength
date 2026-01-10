import * as grpc from "@grpc/grpc-js";

import { SearchArtist } from "../gen/proto/common_pb";
import {
  SearchArtistsResponse,
  type SearchArtistsRequest,
} from "../gen/proto/yt_scraper_pb";
import { music } from "../innertube";
import { searchArtistSchema } from "../schemas/artist";
import { getHighestQualityThumbnail } from "../utils/thumbnail";

export default async function searchArtists(
  call: grpc.ServerUnaryCall<SearchArtistsRequest, SearchArtistsResponse>,
  callback: grpc.sendUnaryData<SearchArtistsResponse>
) {
  const query = call.request.getQuery();
  const { contents } = await music.search(query, {
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
    const artist = new SearchArtist();

    artist.setTitle(parsedArtist.name);

    const [, audience] = parsedArtist.subtitle.text.split("•");

    if (!audience) continue;
    artist.setAudience(audience.trim());

    const thumbnail = getHighestQualityThumbnail(parsedArtist.thumbnail);
    if (thumbnail) artist.setThumbnail(thumbnail.url);

    artist.setBrowseId(parsedArtist.id);
    artists.push(artist);
  }

  const response = new SearchArtistsResponse();
  response.setArtistsList(artists);

  callback(null, response);
}
