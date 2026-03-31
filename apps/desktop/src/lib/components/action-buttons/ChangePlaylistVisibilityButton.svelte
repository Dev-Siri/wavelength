<script lang="ts">
  import { GlobeIcon, LockIcon } from "@lucide/svelte";
  import { createMutation, useQueryClient } from "@tanstack/svelte-query";
  import { toast } from "svelte-sonner";
  import { z } from "zod";

  import { svelteMutationKeys, svelteQueryKeys } from "$lib/constants/keys";
  import { backendClient } from "$lib/utils/query-client.js";

  import { Button } from "../ui/button";

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
  title={isPublic ? "Public" : "Private"}
  variant="ghost"
  size="sm"
  onclick={() => visibilityChangeMutation.mutate()}
>
  {#if isPublic}
    <GlobeIcon size={17} />
  {:else}
    <LockIcon size={17} />
  {/if}
</Button>
