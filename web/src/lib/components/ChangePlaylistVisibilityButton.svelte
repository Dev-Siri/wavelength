<script lang="ts">
  import { GlobeIcon, LockIcon } from "@lucide/svelte";
  import toast from "svelte-french-toast";

  import type { PlayList } from "$lib/db/schema.js";
  import type { ApiResponse } from "$lib/utils/types.js";

  import playlistsStore from "$lib/stores/playlists.svelte";
  import userStore from "$lib/stores/user.svelte";
  import queryClient from "$lib/utils/query-client.js";

  import Button from "./ui/button/button.svelte";

  let {
    isPublic,
    playlistId,
  }: {
    isPublic: boolean;
    playlistId: string;
  } = $props();

  async function handleVisibilityChange() {
    if (!userStore.user) return;

    isPublic = !isPublic;

    const response = await queryClient<ApiResponse<string>>(
      location.toString(),
      `/api/playlists/${playlistId}/visibility`,
      {
        method: "PATCH",
      },
    );

    if (response.success) {
      const response = await queryClient<ApiResponse<PlayList[]>>(
        location.toString(),
        `/api/playlists/user/${userStore.user.email}`,
      );

      if (response.success) playlistsStore.playlists = response.data;

      return;
    }

    isPublic = !isPublic;
    toast.error("Failed to change visibility of playlist.");
  }
</script>

<Button
  variant="secondary"
  class="flex items-center gap-1 ml-1 mt-0"
  onclick={handleVisibilityChange}
>
  {#if isPublic}
    <GlobeIcon size={17} />
    <span>Public</span>
  {:else}
    <LockIcon size={17} />
    <span>Private</span>
  {/if}
</Button>
