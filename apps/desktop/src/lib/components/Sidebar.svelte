<script lang="ts">
  import { LibraryIcon, PlusIcon } from "@lucide/svelte";
  import { createMutation, useQueryClient } from "@tanstack/svelte-query";
  import { toast } from "svelte-sonner";
  import { z } from "zod";

  import { svelteMutationKeys, svelteQueryKeys } from "$lib/constants/keys";
  import userStore from "$lib/stores/user.svelte.js";
  import cn from "$lib/utils/cn";
  import { backendClient } from "$lib/utils/query-client.js";

  import Library from "./Library.svelte";
  import { Button, buttonVariants } from "./ui/button";

  const {
    isCollapsed,
    toggleSidebar,
  }: {
    isCollapsed?: boolean;
    toggleSidebar?: () => void;
  } = $props();

  const queryClient = useQueryClient();

  const createPlaylistMutation = createMutation(() => ({
    mutationKey: svelteMutationKeys.createPlaylist(userStore.user?.email),
    mutationFn: () =>
      backendClient(`/playlists/user/${userStore.user?.email}`, z.string(), {
        method: "POST",
      }),
    onError: () => toast.error("Failed to create playlist."),
    onSuccess() {
      toast.success("Created a new playlist.");
      queryClient.invalidateQueries({ queryKey: svelteQueryKeys.userPlaylists });
    },
  }));
</script>

<aside class="h-full overflow-y-hidden bg-[#111] scrollbar-hidden">
  <div class="flex flex-col h-full w-full px-3 mt-2 gap-2">
    {#if userStore.user}
      <div
        class="flex justify-between gap-1 px-2 items-center {isCollapsed ? 'flex-col' : 'flex-row'}"
      >
        <div
          class="flex items-center cursor-pointer gap-2.5 group"
          role="button"
          tabindex="0"
          onkeydown={toggleSidebar}
          onclick={toggleSidebar}
        >
          <div class={cn(buttonVariants({ variant: "ghost", size: "icon" }))}>
            <LibraryIcon size={30} />
          </div>
          {#if !isCollapsed}
            <h2
              class="text-xl font-semibold select-none duration-200 truncate group-hover:opacity-80"
            >
              Your Library
            </h2>
          {/if}
        </div>
        <Button variant="ghost" size="icon" onclick={() => createPlaylistMutation.mutate()}>
          <PlusIcon size={30} />
        </Button>
      </div>
      <section class="flex flex-col gap-2 h-full w-full">
        <Library {isCollapsed} />
      </section>
    {:else}
      <div class="flex flex-col items-center justify-center h-full w-full gap-4">
        <LibraryIcon size={50} />
        <p class="text-lg font-medium text-center pb-[60%]">
          Sign in to view your library and playlists.
        </p>
      </div>
    {/if}
  </div>
</aside>
