<script lang="ts">
  import { invalidate } from "$app/navigation";
  import { Plus } from "lucide-svelte";
  import toast from "svelte-french-toast";

  import type { MusicTrack } from "$lib/server/api/interface/types";
  import type { ApiResponse } from "$lib/utils/types";

  import playlistsStore from "$lib/stores/playlists.svelte";
  import queryClient from "$lib/utils/query-client";

  import DropdownMenuItem from "./ui/dropdown-menu/dropdown-menu-item.svelte";

  const { music }: { music: MusicTrack } = $props();

  async function addToPlaylist(playlistId: string) {
    const response = await queryClient<ApiResponse<string>>(
      location.toString(),
      `/api/playlists/${playlistId}/tracks`,
      {
        method: "POST",
        body: {
          ...music,
          videoType: "track",
        },
      },
    );

    if (response.success) {
      toast.success(response.data);
      invalidate(url => url.pathname.startsWith("/playlist"));
      return;
    }

    toast.error("Failed to update playlist.");
  }
</script>

{#each playlistsStore.playlists as playlist}
  <DropdownMenuItem onclick={() => addToPlaylist(playlist.playlistId)} class="flex py-3 gap-2">
    <Plus size={20} /> Toggle from "{playlist.name}"
  </DropdownMenuItem>
{/each}
