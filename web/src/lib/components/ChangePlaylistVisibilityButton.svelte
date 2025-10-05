<script lang="ts">
  import { GlobeIcon, LockIcon } from "@lucide/svelte";
  import { createMutation, useQueryClient } from "@tanstack/svelte-query";
  import toast from "svelte-french-toast";
  import { z } from "zod";

  import { svelteMutationKeys, svelteQueryKeys } from "$lib/constants/keys";
  import { backendClient } from "$lib/utils/query-client.js";

  import { Button } from "./ui/button";

  let {
    isPublic,
    playlistId,
  }: {
    isPublic: boolean;
    playlistId: string;
  } = $props();

  const queryClient = useQueryClient();

  const visibilityChangeMutation = createMutation(() => ({
    mutationKey: svelteMutationKeys.playlistVisibilityChange,
    onMutate: () => (isPublic = !isPublic),
    mutationFn: () =>
      backendClient(`/playlists/playlist/${playlistId}/visibility`, z.string(), {
        method: "PATCH",
      }),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: svelteQueryKeys.userPlaylists }),
    onError() {
      isPublic = !isPublic;
      toast.error("Failed to change visibility of playlist.");
    },
  }));
</script>

<Button
  variant="secondary"
  class="flex items-center gap-1 ml-1 mt-0"
  onclick={() => visibilityChangeMutation.mutate()}
>
  {#if isPublic}
    <GlobeIcon size={17} />
    <span>Public</span>
  {:else}
    <LockIcon size={17} />
    <span>Private</span>
  {/if}
</Button>
