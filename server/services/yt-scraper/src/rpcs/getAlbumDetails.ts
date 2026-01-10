import * as grpc from "@grpc/grpc-js";

import { Album, AlbumTrack, EmbeddedArtist } from "../gen/proto/common_pb";
import {
  GetAlbumDetailsResponse,
  type GetAlbumDetailsRequest,
} from "../gen/proto/yt_scraper_pb";
import { music } from "../innertube";
import { albumContents, albumHeaderSchema } from "../schemas/album";
import { parseStringToAlbumType } from "../utils/parse";
import { getHighestQualityThumbnail } from "../utils/thumbnail";

export default async function getAlbumDetails(
  call: grpc.ServerUnaryCall<GetAlbumDetailsRequest, GetAlbumDetailsResponse>,
  callback: grpc.sendUnaryData<GetAlbumDetailsResponse>
) {
  const albumId = call.request.getAlbumId();

  try {
    const { header, contents } = await music.getAlbum(albumId);

    if (!contents) {
      const status = new grpc.StatusBuilder()
        .withCode(grpc.status.INTERNAL)
        .withDetails("YouTube Music sent an empty response.")
        .build();
      return callback(status);
    }

    const parsedDetails = albumHeaderSchema.safeParse(header);
    if (!parsedDetails.success) {
      const status = new grpc.StatusBuilder()
        .withCode(grpc.status.INTERNAL)
        .withDetails("YouTube Music sent an invalid response.")
        .build();
      return callback(status);
    }

    const parsedTracks = albumContents.safeParse(contents);
    if (!parsedTracks.success) {
      const status = new grpc.StatusBuilder()
        .withCode(grpc.status.INTERNAL)
        .withDetails("YouTube Music sent an invalid response.")
        .build();
      return callback(status);
    }

    const album = new Album();

    album.setTitle(parsedDetails.data.title.text);

    const artist = new EmbeddedArtist();
    artist.setTitle(parsedDetails.data.strapline_text_one.text);
    artist.setBrowseId(
      parsedDetails.data.strapline_text_one.endpoint.payload.browseId
    );
    album.setArtist(artist);

    const thumbnail = getHighestQualityThumbnail(parsedDetails.data.thumbnail);
    if (!thumbnail) {
      const status = new grpc.StatusBuilder()
        .withCode(grpc.status.INTERNAL)
        .withDetails("YouTube Music sent an invalid response.")
        .build();
      return callback(status);
    }

    album.setCover(thumbnail.url);

    const [albumType, release] = parsedDetails.data.subtitle.text.split(" • ");
    if (!albumType || !release) {
      const status = new grpc.StatusBuilder()
        .withCode(grpc.status.INTERNAL)
        .withDetails("YouTube Music sent an invalid response.")
        .build();
      return callback(status);
    }

    album.setAlbumType(parseStringToAlbumType(albumType));
    album.setRelease(release);

    const [, totalDuration] =
      parsedDetails.data.second_subtitle.text.split("•");
    if (!totalDuration) {
      const status = new grpc.StatusBuilder()
        .withCode(grpc.status.INTERNAL)
        .withDetails("YouTube Music sent an invalid response.")
        .build();
      return callback(status);
    }

    album.setTotalDuration(totalDuration.trim());

    const albumTracks: AlbumTrack[] = [];
    for (const parsedTrack of parsedTracks.data) {
      const albumTrack = new AlbumTrack();

      albumTrack.setTitle(parsedTrack.title);
      albumTrack.setPositionInAlbum(Number(parsedTrack.index.text));
      albumTrack.setDuration(parsedTrack.duration.seconds);
      albumTrack.setVideoId(parsedTrack.id);

      const isExplicit = !!parsedTrack?.badges?.some(
        (badge) => badge.icon_type === "MUSIC_EXPLICIT_BADGE"
      );
      albumTrack.setIsExplicit(isExplicit);
      albumTracks.push(albumTrack);
    }

    album.setTotalSongCount(albumTracks.length);
    album.setAlbumTracksList(albumTracks);

    const response = new GetAlbumDetailsResponse();
    response.setAlbum(album);

    callback(null, response);
  } catch (error: unknown) {
    const status = new grpc.StatusBuilder()
      .withCode(grpc.status.INTERNAL)
      .withDetails(String(error))
      .build();
    callback(status);
  }
}
