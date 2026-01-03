<script lang="ts">
  import { MinusIcon, PlusIcon } from "@lucide/svelte";
  import { createMutation, useQueryClient } from "@tanstack/svelte-query";
  import toast from "svelte-french-toast";
  import { z } from "zod";

  import type { MusicTrack } from "$lib/utils/validation/music-track";
  import type { Playlist } from "$lib/utils/validation/playlists";

  import { svelteMutationKeys, svelteQueryKeys } from "$lib/constants/keys";
  import { backendClient } from "$lib/utils/query-client.js";
  import { musicTrackDurationSchema } from "$lib/utils/validation/track-length";

  import DropdownMenuItem from "./ui/dropdown-menu/dropdown-menu-item.svelte";

  const {
    music,
    toggle,
  }: {
    music: MusicTrack;
    toggle:
      | {
          type: "add";
        }
      | {
          type: "remove";
          from: Playlist;
        };
  } = $props();

  const queryClient = useQueryClient();
  const playlists = $derived.by(() =>
    queryClient.getQueryData<Playlist[]>(svelteQueryKeys.userPlaylists),
  );

  const playlistsAddMutation = createMutation(() => ({
    mutationKey: svelteMutationKeys.addToPlaylists,
    async mutationFn(playlistId: string) {
      let duration = music.duration;

      if (duration === "") {
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
      queryClient.invalidateQueries({ queryKey: svelteQueryKeys.playlist(playlistId) });
    },
  }));
</script>

{#if toggle.type === "add"}
  {#if playlists?.length}
    {#each playlists as playlist}
      <DropdownMenuItem
        onclick={() => playlistsAddMutation.mutate(playlist.playlistId)}
        class="flex py-3 gap-2"
      >
        <PlusIcon size={20} /> Add to {playlist.name}
      </DropdownMenuItem>
    {/each}
  {/if}
{:else}
  <DropdownMenuItem
    onclick={() => playlistsAddMutation.mutate(toggle.from.playlistId)}
    class="flex py-3 gap-2 text-red-500"
  >
    <MinusIcon size={20} /> Remove from playlist.
  </DropdownMenuItem>
{/if}
