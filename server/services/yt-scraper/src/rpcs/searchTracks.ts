import * as grpc from "@grpc/grpc-js";

import type {
  EmbeddedAlbum,
  EmbeddedArtist,
  Track,
} from "@/gen/proto/common.js";
import type {
  SearchTracksRequest,
  SearchTracksResponse,
} from "@/gen/proto/yt_scraper.js";

import { getYtMusicClient } from "@/innertube.js";
import { correctedSearchSuggestions } from "@/schemas/search-suggestion.js";
import { searchedTracksSchema } from "@/schemas/searched-tracks.js";
import { getHighestQualityThumbnail } from "@/utils/thumbnail.js";

export default async function searchTracks(
  call: grpc.ServerUnaryCall<SearchTracksRequest, SearchTracksResponse>,
  callback: grpc.sendUnaryData<SearchTracksResponse>,
) {
  try {
    const music = await getYtMusicClient();
    const { contents } = await music.search(call.request.query, {
      type: "song",
    });

    if (!contents) {
      const status = new grpc.StatusBuilder()
        .withCode(grpc.status.INTERNAL)
        .withDetails("YouTube Music sent an empty response.")
        .build();
      return callback(status);
    }

    let parsedContents = searchedTracksSchema.safeParse(contents[0]);

    if (!parsedContents.success) {
      const attemptQueryCorrectionContents =
        correctedSearchSuggestions.safeParse(contents[0]?.contents?.[0]);
      if (!attemptQueryCorrectionContents.success) {
        console.log(attemptQueryCorrectionContents.error);

        const status = new grpc.StatusBuilder()
          .withCode(grpc.status.INTERNAL)
          .withDetails("YouTube Music sent an invalid response.")
          .build();
        return callback(status);
      }

      const { contents: correctedContents } = await music.search(
        attemptQueryCorrectionContents.data.corrected_query.text,
        {
          type: "song",
        },
      );

      if (!correctedContents) {
        const status = new grpc.StatusBuilder()
          .withCode(grpc.status.INTERNAL)
          .withDetails("YouTube Music sent an empty response.")
          .build();
        return callback(status);
      }
      parsedContents = searchedTracksSchema.safeParse(correctedContents[0]);
    }

    if (!parsedContents.success) {
      const status = new grpc.StatusBuilder()
        .withCode(grpc.status.INTERNAL)
        .withDetails("YouTube Music sent an invalid response.")
        .build();
      return callback(status);
    }

    const tracks: Track[] = [];
    for (const parsedTrack of parsedContents.data.contents) {
      const title = parsedTrack.flex_columns[0]?.title?.text;
      if (!title) continue;

      const subtitle = parsedTrack.flex_columns[1]?.title?.text;
      if (!subtitle) continue;

      const [, , duration] = subtitle.split("•");
      if (!duration) continue;

      const thumbnail = getHighestQualityThumbnail(parsedTrack.thumbnail);
      if (!thumbnail) continue;

      const artists: EmbeddedArtist[] = [];
      for (const artist of parsedTrack.artists) {
        const quickPicksArtists = {
          title: artist.name,
          browseId: artist.channel_id,
        } satisfies EmbeddedArtist;

        artists.push(quickPicksArtists);
      }

      if (!artists.length) continue;

      const track: Track = {
        title: title,
        videoId: parsedTrack.id,
        duration: parsedTrack.duration.seconds,
        thumbnail: thumbnail.url,
        artists,
        isExplicit: !!parsedTrack?.badges?.some(
          (badge) => badge.icon_type === "MUSIC_EXPLICIT_BADGE",
        ),
      };

      if (parsedTrack.album) {
        const quickPickAlbum = {
          browseId: parsedTrack.album.id,
          title: parsedTrack.album.name,
        } satisfies EmbeddedAlbum;

        track.album = quickPickAlbum;
      }

      tracks.push(track);
    }

    return callback(null, { tracks });
  } catch (error) {
    console.error("Tracks search failed: ", error);
    const status = new grpc.StatusBuilder()
      .withCode(grpc.status.INTERNAL)
      .withDetails("Tracks search failed: " + String(error))
      .build();
    callback(status);
  }
}
