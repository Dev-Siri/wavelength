<script lang="ts">
  import { CheckIcon, PlusIcon } from "@lucide/svelte";
  import { createMutation, useQueryClient } from "@tanstack/svelte-query";
  import { toast } from "svelte-sonner";
  import { blur } from "svelte/transition";

  import { svelteMutationKeys, svelteQueryKeys } from "$lib/constants/keys";
  import useIsAlbumSavedQuery from "$lib/queries/isAlbumSaved";
  import { albumSaveResponseSchema } from "$lib/schemas/album";
  import { backendClient } from "$lib/utils/query-client";

  import Button from "$lib/components/ui/button/button.svelte";

  const { albumId }: { albumId: string } = $props();
  const isAlbumSavedQuery = $derived(useIsAlbumSavedQuery(albumId));

  let isSaved = $derived(isAlbumSavedQuery.data?.isSaved);

  const queryClient = useQueryClient();

  const albumSaveMutation = createMutation(() => ({
    mutationKey: svelteMutationKeys.saveAlbum(albumId),
    mutationFn: () =>
      backendClient(`/albums/album/${albumId}/save`, albumSaveResponseSchema, {
        method: "POST",
      }),
    onMutate: () => (isSaved = !isSaved),
    onError() {
      toast.error("Saving album failed.");
      isSaved = !isSaved;
    },
    onSuccess(data) {
      if (data.saveType === "ALBUM_SAVE_TYPE_ADD_SAVE") {
        toast.success("Saved album to library.");
      } else {
        toast.success("Removed album from library.");
      }

      queryClient.refetchQueries({ queryKey: svelteQueryKeys.savedAlbums });
      isAlbumSavedQuery.refetch();
    },
  }));
</script>

<Button variant="ghost" size="icon" onclick={() => albumSaveMutation.mutate()}>
  {#if isSaved}
    <div in:blur>
      <CheckIcon />
    </div>
  {:else}
    <div in:blur>
      <PlusIcon />
    </div>
  {/if}
</Button>
