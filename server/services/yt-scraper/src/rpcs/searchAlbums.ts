import * as grpc from "@grpc/grpc-js";

import type { SearchAlbum } from "@/gen/proto/common.js";
import type {
  SearchAlbumsRequest,
  SearchAlbumsResponse,
} from "@/gen/proto/yt_scraper.js";

import { getYtMusicClient } from "@/innertube.js";
import { searchAlbumSchema } from "@/schemas/album.js";
import { parseStringToAlbumType } from "@/utils/parse.js";
import { getHighestQualityThumbnail } from "@/utils/thumbnail.js";

export default async function searchAlbums(
  call: grpc.ServerUnaryCall<SearchAlbumsRequest, SearchAlbumsResponse>,
  callback: grpc.sendUnaryData<SearchAlbumsResponse>
) {
  try {
    const music = await getYtMusicClient();
    const { contents } = await music.search(call.request.query, {
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
      const [, subtitle] = parsedAlbum.flex_columns;

      if (!parsedAlbum.author || !subtitle) continue;

      const albumType = (subtitle.title.text.split("•")[0] ?? "").trim();
      const thumbnail = getHighestQualityThumbnail(parsedAlbum.thumbnail);

      if (!thumbnail) continue;

      const album = {
        title: parsedAlbum.title,
        releaseDate: parsedAlbum.year,
        albumId: parsedAlbum.id,
        artist: {
          title: parsedAlbum.author.name,
          browseId: parsedAlbum.author.channel_id,
        },
        albumType: parseStringToAlbumType(albumType),
        thumbnail: thumbnail.url,
      } satisfies SearchAlbum;

      albums.push(album);
    }

    return callback(null, { albums });
  } catch (error) {
    console.error("Albums search failed: ", error);
    const status = new grpc.StatusBuilder()
      .withCode(grpc.status.INTERNAL)
      .withDetails("Albums search failed: " + String(error))
      .build();
    callback(status);
  }
}
