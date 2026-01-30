<script lang="ts">
  import { LibraryIcon, PlusIcon } from "@lucide/svelte";
  import { createMutation, useQueryClient } from "@tanstack/svelte-query";
  import toast from "svelte-french-toast";
  import { z } from "zod";

  import { svelteMutationKeys, svelteQueryKeys } from "$lib/constants/keys";
  import userStore from "$lib/stores/user.svelte.js";
  import { backendClient } from "$lib/utils/query-client.js";

  import cn from "$lib/utils/cn";
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

<aside class="h-full overflow-y-auto bg-black">
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
          <div class={cn(buttonVariants({ variant: "ghost" }), "px-2.5")}>
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
        <Button
          variant="ghost"
          class="rounded-full px-3"
          onclick={() => createPlaylistMutation.mutate()}
        >
          <PlusIcon size={30} />
        </Button>
      </div>
      <section class="flex flex-col gap-2 h-full w-full">
        <Library {isCollapsed} />
      </section>
    {/if}
  </div>
</aside>
