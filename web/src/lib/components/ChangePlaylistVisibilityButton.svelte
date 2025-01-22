<script lang="ts">
  import { Globe, Lock } from "lucide-svelte";
  import toast from "svelte-french-toast";

  import type { PlayList } from "$lib/db/schema";
  import type { ApiResponse } from "$lib/utils/types";

  import { playlists } from "$lib/stores/playlists";
  import { user } from "$lib/stores/user";
  import queryClient from "$lib/utils/query-client";

  import Button from "./ui/button/button.svelte";

  export let isPublic: boolean;
  export let playlistId: string;

  async function handleVisibilityChange() {
    isPublic = !isPublic;

    const response = await queryClient<ApiResponse<string>>(
      location.toString(),
      `/api/playlists/${playlistId}/visibility`,
      {
        method: "PATCH",
      },
    );

    if (response.success) {
      if (!$user) return;

      const response = await queryClient<ApiResponse<PlayList[]>>(
        location.toString(),
        `/api/playlists/user/${$user.email}`,
      );

      if (response.success) $playlists = response.data;

      return;
    }

    isPublic = !isPublic;
    toast.error("Failed to change visibility of playlist.");
  }
</script>

<Button
  variant="secondary"
  class="flex items-center gap-1 ml-1 mt-0"
  on:click={handleVisibilityChange}
>
  {#if isPublic}
    <Globe size={17} />
    <span>Public</span>
  {:else}
    <Lock size={17} />
    <span>Private</span>
  {/if}
</Button>
