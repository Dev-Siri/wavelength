import * as grpc from "@grpc/grpc-js";
import { ClientType, YTNodes } from "youtubei.js";

import type { Track } from "@/gen/proto/common.js";
import type {
  GetTrackInfoRequest,
  GetTrackInfoResponse,
} from "@/gen/proto/yt_scraper.js";

import { getYtMusicClient } from "@/innertube.js";
import { redis } from "@/redis/client.js";
import { createErrorResponse } from "@/response.js";
import { getHighestQualityThumbnail } from "@/utils/thumbnail.js";

export default async function getTrackInfo(
  call: grpc.ServerUnaryCall<GetTrackInfoRequest, GetTrackInfoResponse>,
  callback: grpc.sendUnaryData<GetTrackInfoResponse>,
) {
  const cacheKey = `trackInfo:${call.request.videoId}`;

  try {
    const cachedTrack = await redis.json.get<Track>(cacheKey);
    if (cachedTrack) {
      return callback(null, { track: cachedTrack });
    }

    const music = await getYtMusicClient(undefined, {
      client_type: ClientType.ANDROID_VR,
    });
    const {
      basic_info: { title = "", author },
    } = await music.getInfo(call.request.videoId);

    const channelName = author ?? "";

    console.debug("Basic Details.", { title, channelName });
    let query = "";
    if (title && channelName) {
      query = `${title} ${channelName.replace(" - Topic", "")}`;
    } else {
      query = call.request.videoId;
    }

    console.debug("Query", { query });
    const { songs } = await music.search(query, {
      type: "song",
    });

    if (!songs) {
      return callback(
        createErrorResponse("YouTube Music search returned an empty response."),
      );
    }

    let matchingSong = songs.contents.find((song) => {
      try {
        return (
          song.as(YTNodes.MusicResponsiveListItem).id === call.request.videoId
        );
      } catch {
        return false;
      }
    });

    if (!matchingSong) {
      matchingSong = songs.contents.find((song) => {
        try {
          const listItem = song.as(YTNodes.MusicResponsiveListItem);
          return (
            listItem.title === title &&
            listItem.artists?.[0]?.name === channelName
          );
        } catch {
          return false;
        }
      });
    }

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

    redis.json.set(cacheKey, "$", track);
    return callback(null, { track });
  } catch (error) {
    console.error("Basic track information fetch failed: ", error);
    callback(
      createErrorResponse(`Basic track information fetch failed: ${error}`),
    );
  }
}
