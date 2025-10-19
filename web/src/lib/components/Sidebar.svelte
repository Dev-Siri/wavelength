<script lang="ts">
  import { PlusIcon } from "@lucide/svelte";
  import { createMutation, useQueryClient } from "@tanstack/svelte-query";
  import toast from "svelte-french-toast";
  import { z } from "zod";

  import { svelteMutationKeys, svelteQueryKeys } from "$lib/constants/keys";
  import userStore from "$lib/stores/user.svelte.js";
  import { backendClient } from "$lib/utils/query-client.js";

  import Library from "./Library.svelte";
  import { Button } from "./ui/button";

  const { sidebarWidth }: { sidebarWidth: number } = $props();

  const queryClient = useQueryClient();

  const createPlaylistMutation = createMutation(() => ({
    mutationKey: svelteMutationKeys.createPlaylist(userStore.user?.email),
    mutationFn: () =>
      backendClient(`/playlists/user/${userStore.user?.email}`, z.string(), {
        method: "POST",
        searchParams: {
          authorName: userStore.user?.name,
          authorImage: userStore.user?.image,
        },
      }),
    onError: () => toast.error("Failed to create playlist."),
    onSuccess() {
      toast.success("Created a new playlist.");
      queryClient.invalidateQueries({ queryKey: svelteQueryKeys.userPlaylists });
    },
  }));
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
    {#if userStore.user}
      <Button variant="secondary" onclick={() => createPlaylistMutation.mutate()}>
        <PlusIcon size={20} />
        {#if sidebarWidth > 17}
          <span class="mr-5 hidden md:block">Add Playlist</span>
        {/if}
      </Button>
      <section class="flex flex-col gap-2 h-[67%] w-full">
        <Library {sidebarWidth} />
      </section>
    {/if}
  </div>
</aside>
