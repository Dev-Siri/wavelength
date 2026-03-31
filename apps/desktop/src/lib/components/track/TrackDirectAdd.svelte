<script lang="ts">
  import { PlusIcon } from "@lucide/svelte";
  import { createMutation, useQueryClient } from "@tanstack/svelte-query";
  import { toast } from "svelte-sonner";
  import { z } from "zod";

  import type { MusicTrack } from "$lib/schemas/music-track";

  import { svelteMutationKeys, svelteQueryKeys } from "$lib/constants/keys";
  import { musicTrackDurationSchema } from "$lib/schemas/track-length";
  import { backendClient } from "$lib/utils/query-client";
  import Button from "../ui/button/button.svelte";

  const { music, playlistId }: { music: MusicTrack; playlistId: string } = $props();

  const queryClient = useQueryClient();

  const playlistsAddMutation = createMutation(() => ({
    mutationKey: svelteMutationKeys.addToPlaylists,
    async mutationFn(playlistId: string) {
      let duration = music.duration;

      if (!duration) {
        const fetchedDuration = await backendClient(
          `/music/track/${music.videoId}/duration`,
          musicTrackDurationSchema,
        );
        duration = fetchedDuration.durationSeconds.toString();
      }

      return backendClient(`/playlists/playlist/${playlistId}/tracks`, z.string(), {
        method: "POST",
        body: {
          ...music,
          duration,
          videoType: "track",
        },
      });
    },
    onError: () => toast.error("Failed to update playlist."),
    onSuccess(data, playlistId) {
      toast.success(data);
      queryClient.invalidateQueries({ queryKey: svelteQueryKeys.playlistTrack(playlistId) });
      queryClient.invalidateQueries({ queryKey: svelteQueryKeys.playlistTrackLength(playlistId) });
    },
  }));

  function handleDirectTrackAdd(
    e:
      | (MouseEvent & {
          currentTarget: EventTarget & HTMLButtonElement;
        })
      | (MouseEvent & {
          currentTarget: EventTarget & HTMLAnchorElement;
        }),
  ) {
    e.stopPropagation();
    playlistsAddMutation.mutate(playlistId);
  }
</script>

<Button size="icon" variant="secondary" onclick={handleDirectTrackAdd}>
  <PlusIcon />
</Button>
