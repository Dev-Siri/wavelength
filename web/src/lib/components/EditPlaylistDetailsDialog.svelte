<script lang="ts">
  import { LoaderCircleIcon } from "@lucide/svelte";
  import { createMutation, useQueryClient } from "@tanstack/svelte-query";
  import { UploadButton } from "@uploadthing/svelte";
  import toast from "svelte-french-toast";
  import { z } from "zod";

  import type { Playlist } from "$lib/utils/validation/playlists";

  import { svelteMutationKeys, svelteQueryKeys } from "$lib/constants/keys";
  import { backendClient } from "$lib/utils/query-client.js";
  import { createUploader } from "$lib/utils/uploadthing.js";

  import { Button } from "./ui/button";
  import * as Dialog from "./ui/dialog";
  import { Input } from "./ui/input";
  import { Label } from "./ui/label";

  const { initialPlaylist }: { initialPlaylist: Playlist } = $props();

  let isLoading = $state(false);
  let playlistTitle = $state(initialPlaylist.name);
  let playlistCoverImage = $state(initialPlaylist.coverImage);

  const queryClient = useQueryClient();
  const uploader = createUploader("imageUploader", {
    onClientUploadComplete(res) {
      playlistCoverImage = res[0].ufsUrl;
    },
  });

  const playlistUpdateMutation = createMutation(() => ({
    mutationKey: svelteMutationKeys.updatePlaylist(initialPlaylist.playlistId),
    mutationFn: () =>
      backendClient(`/playlists/playlist/${initialPlaylist.playlistId}`, z.string(), {
        method: "PUT",
        body: {
          name: playlistTitle,
          coverImage: playlistCoverImage,
        },
      }),
    onError: () => toast.error("Failed to update playlist details."),
    onSuccess() {
      toast.success("Updated playlist details successfully.");
      queryClient.refetchQueries({
        queryKey: [
          ...svelteQueryKeys.userPlaylists,
          svelteQueryKeys.playlist(initialPlaylist.playlistId),
        ],
      });
    },
  }));

  async function handleSubmit(
    event: SubmitEvent & { currentTarget: EventTarget & HTMLFormElement },
  ) {
    event.preventDefault();
    playlistUpdateMutation.mutate();
  }
</script>

<Dialog.Header>
  <form method="POST" onsubmit={handleSubmit}>
    <Dialog.Title>Edit Playlist Details</Dialog.Title>
    <div class="flex flex-col py-3 gap-3">
      <div class="flex flex-col gap-2 items-center">
        {#if playlistCoverImage}
          <img
            src={playlistCoverImage}
            alt="Cover for Playlist"
            height={256}
            width={256}
            class="rounded-2xl aspect-square object-cover"
          />
        {/if}
        <UploadButton {uploader} />
      </div>
      <div class="flex flex-col gap-2">
        <Label for="name">Title</Label>
        <Input id="name" bind:value={playlistTitle} />
      </div>
    </div>
    <Dialog.Footer>
      <Button type="submit" disabled={isLoading}>
        {#if isLoading}
          <LoaderCircleIcon class="mr-2 h-4 w-4 animate-spin" />
        {/if}
        Save changes
      </Button>
    </Dialog.Footer>
  </form>
</Dialog.Header>
