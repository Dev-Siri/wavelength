import { createQuery } from "@tanstack/svelte-query";

import type { EmbeddedArtist } from "$lib/schemas/embedded";
import type { PlaylistVideoType } from "$lib/schemas/playlist";

import { svelteQueryKeys } from "$lib/constants/keys";
import { musicVideoPreviewSchema } from "$lib/schemas/music-video-preview";
import { punctuatify } from "$lib/utils/format";
import { backendClient } from "$lib/utils/query-client";

export default function useMusicVideoPreviewQuery({
  title,
  artists,
  videoType,
}: {
  title: string;
  artists: EmbeddedArtist[];
  videoType: PlaylistVideoType;
}) {
  return createQuery(() => ({
    queryKey: svelteQueryKeys.musicVideoPreview(
      title,
      punctuatify(artists.map(artist => artist.title)),
    ),
    async queryFn() {
      if (videoType === "VIDEO_TYPE_UVIDEO") return null;

      return backendClient("/music/music-video-preview", musicVideoPreviewSchema, {
        searchParams: {
          title,
          artist: punctuatify(artists.map(artist => artist.title)),
        },
      });
    },
  }));
}
