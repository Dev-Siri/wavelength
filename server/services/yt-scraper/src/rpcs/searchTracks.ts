import * as grpc from "@grpc/grpc-js";

import { EmbeddedAlbum, EmbeddedArtist, Track } from "../gen/proto/common_pb";
import {
  SearchTracksResponse,
  type SearchTracksRequest,
} from "../gen/proto/yt_scraper_pb";
import { music } from "../innertube";
import { searchedTracksSchema } from "../schemas/searched-tracks";
import { getHighestQualityThumbnail } from "../utils/thumbnail";

export default async function searchTracks(
  call: grpc.ServerUnaryCall<SearchTracksRequest, SearchTracksResponse>,
  callback: grpc.sendUnaryData<SearchTracksResponse>
) {
  const query = call.request.getQuery();
  const { contents } = await music.search(query, {
    type: "song",
  });

  if (!contents) {
    const status = new grpc.StatusBuilder()
      .withCode(grpc.status.INTERNAL)
      .withDetails("YouTube Music sent an empty response.")
      .build();
    return callback(status);
  }

  const parsedContents = searchedTracksSchema.safeParse(contents[0]);

  if (!parsedContents.success) {
    const status = new grpc.StatusBuilder()
      .withCode(grpc.status.INTERNAL)
      .withDetails("YouTube Music sent an invalid response.")
      .build();
    return callback(status);
  }

  const tracksList: Track[] = [];
  for (const parsedTrack of parsedContents.data.contents) {
    const title = parsedTrack.flex_columns[0]?.title?.text;
    if (!title) continue;

    const subtitle = parsedTrack.flex_columns[1]?.title?.text;
    if (!subtitle) continue;

    const [, , duration] = subtitle.split("•");
    if (!duration) continue;

    const track = new Track();

    track.setTitle(title);
    track.setVideoId(parsedTrack.id);
    track.setDuration(parsedTrack.duration.seconds);

    const thumbnail = getHighestQualityThumbnail(parsedTrack.thumbnail);
    if (thumbnail) track.setThumbnail(thumbnail.url);

    const artists = [];
    for (const artist of parsedTrack.artists) {
      const quickPicksArtists = new EmbeddedArtist();
      quickPicksArtists.setTitle(artist.name);
      quickPicksArtists.setBrowseId(artist.channel_id);

      artists.push(quickPicksArtists);
    }

    if (!artists.length) continue;
    track.setArtistsList(artists);

    if (parsedTrack.album) {
      const quickPickAlbum = new EmbeddedAlbum();
      quickPickAlbum.setBrowseId(parsedTrack.album.id);
      quickPickAlbum.setTitle(parsedTrack.album.name);

      track.setAlbum(quickPickAlbum);
    }

    const isExplicit = !!parsedTrack?.badges?.some(
      (badge) => badge.icon_type === "MUSIC_EXPLICIT_BADGE"
    );
    track.setIsExplicit(isExplicit);

    tracksList.push(track);
  }

  const response = new SearchTracksResponse();
  response.setTracksList(tracksList);
  callback(null, response);
}
