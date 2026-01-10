import * as grpc from "@grpc/grpc-js";

import { EmbeddedArtist, SearchAlbum } from "../gen/proto/common_pb";
import {
  SearchAlbumsResponse,
  type SearchAlbumsRequest,
} from "../gen/proto/yt_scraper_pb";
import { music } from "../innertube";
import { searchAlbumSchema } from "../schemas/album";
import { parseStringToAlbumType } from "../utils/parse";
import { getHighestQualityThumbnail } from "../utils/thumbnail";

export default async function searchAlbums(
  call: grpc.ServerUnaryCall<SearchAlbumsRequest, SearchAlbumsResponse>,
  callback: grpc.sendUnaryData<SearchAlbumsResponse>
) {
  const query = call.request.getQuery();
  const { contents } = await music.search(query, {
    type: "album",
  });

  if (!contents) {
    const status = new grpc.StatusBuilder()
      .withCode(grpc.status.INTERNAL)
      .withDetails("YouTube Music sent an empty response.")
      .build();
    return callback(status);
  }

  const parsedAlbums = searchAlbumSchema.safeParse(contents[0]?.contents);

  if (!parsedAlbums.success) {
    const status = new grpc.StatusBuilder()
      .withCode(grpc.status.INTERNAL)
      .withDetails("YouTube Music sent an invalid response.")
      .build();
    return callback(status);
  }

  const albums: SearchAlbum[] = [];
  for (const parsedAlbum of parsedAlbums.data) {
    const album = new SearchAlbum();
    album.setTitle(parsedAlbum.title);
    album.setReleaseDate(parsedAlbum.year);
    album.setAlbumId(parsedAlbum.id);

    if (!parsedAlbum.author) continue;

    const artist = new EmbeddedArtist();

    artist.setTitle(parsedAlbum.author.name);
    artist.setBrowseId(parsedAlbum.author.channel_id);

    album.setArtist(artist);

    const [, subtitle] = parsedAlbum.flex_columns;
    if (!subtitle) continue;

    const albumType = (subtitle.title.text.split("•")[0] ?? "").trim();
    album.setAlbumType(parseStringToAlbumType(albumType));

    const thumbnail = getHighestQualityThumbnail(parsedAlbum.thumbnail);
    if (thumbnail) album.setThumbnail(thumbnail.url);

    albums.push(album);
  }

  const response = new SearchAlbumsResponse();
  response.setAlbumsList(albums);

  callback(null, response);
}
