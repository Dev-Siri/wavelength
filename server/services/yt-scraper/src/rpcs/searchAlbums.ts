import * as grpc from "@grpc/grpc-js";
import { YTNodes } from "youtubei.js";

import type { SearchAlbum } from "@/gen/proto/common.js";
import type {
  SearchAlbumsRequest,
  SearchAlbumsResponse,
} from "@/gen/proto/yt_scraper.js";

import { getYtMusicClient } from "@/innertube.js";
import { createErrorResponse } from "@/response.js";
import { parseStringToAlbumType } from "@/utils/parse.js";
import { getHighestQualityThumbnail } from "@/utils/thumbnail.js";

export default async function searchAlbums(
  call: grpc.ServerUnaryCall<SearchAlbumsRequest, SearchAlbumsResponse>,
  callback: grpc.sendUnaryData<SearchAlbumsResponse>,
) {
  try {
    const music = await getYtMusicClient();
    const { contents } = await music.search(call.request.query, {
      type: "album",
    });

    if (!contents)
      return callback(
        createErrorResponse("YouTube Music sent an empty response."),
      );

    const parsedContents = contents[0]?.contents?.as(
      YTNodes.MusicResponsiveListItem,
    );

    if (!parsedContents)
      return callback(
        createErrorResponse("YouTube Music sent an empty response."),
      );

    const albums: SearchAlbum[] = [];

    for (const album of parsedContents) {
      if (
        !album.title ||
        !album.year ||
        !album.author ||
        !album.thumbnail ||
        !album.id
      )
        continue;

      const subtitle =
        album.flex_columns[1]?.title.text || album.subtitle?.text;

      if (!subtitle) continue;

      const albumType = (subtitle.split("•")[0] ?? "").trim();
      const thumbnail = getHighestQualityThumbnail(album.thumbnail);

      if (!thumbnail) continue;

      const searchAlbum = {
        title: album.title,
        releaseDate: album.year,
        albumId: album.id,
        artist: {
          title: album.author.name ?? "Various Artists",
          browseId: album.author.channel_id ?? "VARIOUS_ARTISTS",
        },
        albumType: parseStringToAlbumType(albumType),
        thumbnail: thumbnail.url,
      } satisfies SearchAlbum;

      albums.push(searchAlbum);
    }

    return callback(null, { albums });
  } catch (error) {
    console.error("Albums search failed: ", error);
    callback(createErrorResponse(`Albums search failed: ${error}`));
  }
}
