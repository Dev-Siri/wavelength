<script lang="ts">
  import { CompassIcon, PlusIcon } from "@lucide/svelte";
  import toast from "svelte-french-toast";

  import type { ApiResponse, Playlist } from "$lib/types.js";

  import playlistsStore from "$lib/stores/playlists.svelte.js";
  import userStore from "$lib/stores/user.svelte.js";
  import { backendClient } from "$lib/utils/query-client.js";

  import Library from "./Library.svelte";
  import Button from "./ui/button/button.svelte";

  const { paneWidth }: { paneWidth: number } = $props();

  async function createNewPlaylist() {
    if (!userStore.user) return;

    const createPlaylistResponse = await backendClient<ApiResponse<string>>(
      `/playlists/user/${userStore.user.email}`,
      { method: "POST" },
    );

    if (!createPlaylistResponse.success) {
      toast.error("Failed to create playlist.");
      return;
    }

    toast.success("Created a new playlist.");

    const playlistsResponse = await backendClient<ApiResponse<Playlist[]>>(
      `/playlists/user/${userStore.user.email}`,
    );

    if (playlistsResponse.success) playlistsStore.playlists = playlistsResponse.data;
  }
</script>

<aside class="h-full bg-black">
  <div class="pl-4 pt-3">
    <a
      href="/app"
      class="flex items-center w-fit p-4 py-2 duration-200 rounded-full hover:bg-primary-foreground"
    >
      <span class="font-black text-5xl select-none">λ</span>
    </a>
  </div>
  <div class="flex flex-col h-full w-full px-3 mt-2 gap-2">
    <Button variant="secondary" href="/app/playlist">
      <CompassIcon size={20} />
      {#if paneWidth > 17}
        <span class="ml-1 hidden md:block">Discover Playlists</span>
      {/if}
    </Button>
    {#if userStore.user}
      <Button variant="secondary" onclick={createNewPlaylist}>
        <PlusIcon size={20} />
        {#if paneWidth > 17}
          <span class="mr-5 hidden md:block">Add Playlist</span>
        {/if}
      </Button>
      <section class="flex flex-col gap-2 h-[67%] w-full">
        <Library {paneWidth} />
      </section>
    {/if}
  </div>
</aside>
