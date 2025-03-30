<script lang="ts">
  import { Compass, Plus } from "lucide-svelte";
  import toast from "svelte-french-toast";

  import type { PlayList } from "$lib/db/schema";
  import type { ApiResponse } from "$lib/utils/types";

  import playlistsStore from "$lib/stores/playlists.svelte";
  import userStore from "$lib/stores/user.svelte";
  import queryClient from "$lib/utils/query-client";

  import Library from "./Library.svelte";
  import Button from "./ui/button/button.svelte";

  async function createNewPlaylist() {
    if (!userStore.user) return;

    const createPlaylistResponse = await queryClient<ApiResponse<string>>(
      location.toString(),
      `/api/playlists/user/${userStore.user.email}`,
      { method: "POST" },
    );

    if (!createPlaylistResponse.success) {
      toast.error("Failed to create playlist.");
      return;
    }

    toast.success("Created a new playlist.");

    const playlistsResponse = await queryClient<ApiResponse<PlayList[]>>(
      location.toString(),
      `/api/playlists/user/${userStore.user.email}`,
    );

    if (playlistsResponse.success) playlistsStore.playlists = playlistsResponse.data;
  }
</script>

<aside class="h-full bg-black">
  <div class="pl-4 pt-3">
    <a
      href="/"
      class="flex items-center w-fit p-4 py-2 duration-200 rounded-full hover:bg-primary-foreground"
    >
      <span class="font-black text-5xl">λ</span>
    </a>
  </div>
  <div class="flex flex-col h-full w-full px-3 mt-2 gap-2">
    <Button variant="secondary" href="/playlist">
      <Compass size={20} />
      <span class="ml-1 hidden md:block">Discover Playlists</span>
    </Button>
    {#if userStore.user}
      <Button variant="secondary" onclick={createNewPlaylist}>
        <Plus size={20} />
        <span class="mr-5 hidden md:block">Add Playlist</span>
      </Button>
      <section class="flex flex-col gap-2 h-[67%] w-full">
        <Library />
      </section>
    {/if}
  </div>
</aside>
