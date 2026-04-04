import * as grpc from "@grpc/grpc-js";

import type {
  GetTrackInfoRequest,
  GetTrackInfoResponse,
} from "@/gen/proto/yt_scraper.js";

import type { Track } from "@/gen/proto/common.js";
import { getYtClient } from "@/innertube.js";
import { createErrorResponse } from "@/response.js";
import { getHighestQualityThumbnail } from "@/utils/thumbnail.js";
import { YTNodes } from "youtubei.js";

export default async function getTrackInfo(
  call: grpc.ServerUnaryCall<GetTrackInfoRequest, GetTrackInfoResponse>,
  callback: grpc.sendUnaryData<GetTrackInfoResponse>,
) {
  try {
    const yt = await getYtClient();
    const {
      basic_info: { title = "", channel },
    } = await yt.getInfo(call.request.videoId);
    const channelName = channel?.name ?? "";

    console.debug("Basic Details.", { title, channelName });
    let query = "";
    if (title && channelName) {
      query = `${title} ${channelName.replace(" - Topic", "")}`;
    } else {
      query = call.request.videoId;
    }

    console.debug("Query", { query });
    const { contents } = await yt.music.search(query, {
      type: "song",
    });

    const searchedSongs = contents?.filter((section) => {
      try {
        const musicShelf = section.as(YTNodes.MusicShelf);
        return musicShelf.title.text?.toLowerCase() === "songs";
      } catch {
        return false;
      }
    })?.[0]?.contents;

    if (!searchedSongs) {
      return callback(
        createErrorResponse("YouTube Music search returned an empty response."),
      );
    }

    const matchingSong = searchedSongs.find((song) => {
      try {
        return (
          song.as(YTNodes.MusicResponsiveListItem).id === call.request.videoId
        );
      } catch {
        return false;
      }
    });

    if (!matchingSong)
      return callback(createErrorResponse("No matching song found."));

    const song = matchingSong.as(YTNodes.MusicResponsiveListItem);

    if (!song.title || !song.artists || !song.duration || !song.album?.id)
      return callback(
        createErrorResponse("YouTube Music sent an invalid response."),
      );

    const thumbnail = getHighestQualityThumbnail(song.thumbnails);
    if (!thumbnail)
      return callback(createErrorResponse("Thumbnail is missing."));

    const track = {
      title: song.title,
      artists: song.artists.map((artist) => ({
        title: artist.name,
        browseId: artist.channel_id ?? "VARIOUS_ARTISTS",
      })),
      duration: song.duration.seconds,
      thumbnail: thumbnail?.url,
      videoId: call.request.videoId,
      album: {
        title: song.album.name,
        browseId: song.album.id,
      },
      isExplicit: song.badges?.some((badge) => {
        try {
          return (
            badge.as(YTNodes.MusicInlineBadge).icon_type ===
            "MUSIC_EXPLICIT_BADGE"
          );
        } catch {
          return false;
        }
      }),
    } satisfies Track;

    return callback(null, { track });
  } catch (error) {
    console.error("Basic track information fetch failed: ", error);
    callback(
      createErrorResponse(`Basic track information fetch failed: ${error}`),
    );
  }
}
