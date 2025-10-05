<script lang="ts">
  import { PlusIcon } from "@lucide/svelte";
  import { createMutation, useQueryClient } from "@tanstack/svelte-query";
  import toast from "svelte-french-toast";
  import { z } from "zod";

  import type { MusicTrack } from "$lib/utils/validation/music-track";
  import type { Playlist } from "$lib/utils/validation/playlists";

  import { svelteMutationKeys, svelteQueryKeys } from "$lib/constants/keys";
  import { backendClient } from "$lib/utils/query-client.js";

  import DropdownMenuItem from "./ui/dropdown-menu/dropdown-menu-item.svelte";

  const { music }: { music: MusicTrack } = $props();

  const queryClient = useQueryClient();
  const playlists = $derived.by(() =>
    queryClient.getQueryData<Playlist[]>(svelteQueryKeys.userPlaylists),
  );

  const playlistsAddMutation = createMutation(() => ({
    mutationKey: svelteMutationKeys.addToPlaylists,
    mutationFn: (playlistId: string) =>
      backendClient(`/playlists/playlist/${playlistId}/tracks`, z.string(), {
        method: "POST",
        body: {
          ...music,
          videoType: "track",
        },
      }),
    onError: () => toast.error("Failed to update playlist."),
    onSuccess(data, playlistId) {
      toast.success(data);
      queryClient.invalidateQueries({ queryKey: svelteQueryKeys.playlist(playlistId) });
    },
  }));
</script>

{#if playlists?.length}
  {#each playlists as playlist}
    <DropdownMenuItem
      onclick={() => playlistsAddMutation.mutate(playlist.playlistId)}
      class="flex py-3 gap-2"
    >
      <PlusIcon size={20} /> Toggle from "{playlist.name}"
    </DropdownMenuItem>
  {/each}
{/if}
