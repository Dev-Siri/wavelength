import * as grpc from "@grpc/grpc-js";
import { YTNodes } from "youtubei.js";

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
import { createErrorResponse } from "@/response.js";
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

    if (!contents)
      callback(createErrorResponse("YouTube Music sent an empty response."));

    let parsedContents = contents?.[0]?.as(YTNodes.MusicShelf);

    if (!parsedContents) {
      const maybeCorrection = contents?.[0]?.contents?.[0];
      if (
        !maybeCorrection ||
        !maybeCorrection.is(YTNodes.DidYouMean) ||
        !maybeCorrection.is(YTNodes.ShowingResultsFor) ||
        !maybeCorrection.corrected_query.text
      )
        return callback(
          createErrorResponse("YouTube Music sent an invalid response."),
        );

      const { contents: correctedContents } = await music.search(
        maybeCorrection.corrected_query.text,
        { type: "song" },
      );

      if (!correctedContents)
        return callback(
          createErrorResponse("YouTube Music sent an empty response."),
        );

      parsedContents = correctedContents[0]?.as(YTNodes.MusicShelf);
    }

    if (!parsedContents)
      return callback(
        createErrorResponse("YouTube Music sent an invalid response."),
      );

    const tracks: Track[] = [];
    for (const parsedTrack of parsedContents.contents) {
      const title = parsedTrack.flex_columns[0]?.title?.text;
      if (!title) continue;

      const subtitle = parsedTrack.flex_columns[1]?.title?.text;
      if (!subtitle) continue;

      const [, , duration] = subtitle.split("•");
      if (
        !duration ||
        !parsedTrack.thumbnail ||
        !parsedTrack.artists ||
        !parsedTrack.duration ||
        !parsedTrack.id
      )
        continue;

      const thumbnail = getHighestQualityThumbnail(parsedTrack.thumbnail);
      if (!thumbnail) continue;

      const artists: EmbeddedArtist[] = [];
      for (const artist of parsedTrack.artists) {
        const quickPicksArtists = {
          title: artist.name,
          browseId: artist.channel_id ?? "VARIOUS_ARTISTS",
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
        isExplicit: !!parsedTrack?.badges
          ?.as(YTNodes.MusicInlineBadge)
          .some((badge) => badge.icon_type === "MUSIC_EXPLICIT_BADGE"),
      };

      if (parsedTrack.album && parsedTrack.album.id) {
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
    callback(createErrorResponse(`Tracks search failed: ${error}`));
  }
}
