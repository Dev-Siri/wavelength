<script lang="ts">
  import { LoaderCircleIcon, PencilIcon } from "@lucide/svelte";
  import { createMutation, useQueryClient } from "@tanstack/svelte-query";
  import { UploadButton } from "@uploadthing/svelte";
  import { toast } from "svelte-sonner";
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
      queryClient.refetchQueries({
        queryKey: [
          ...svelteQueryKeys.userPlaylists,
          svelteQueryKeys.playlist(initialPlaylist.playlistId),
        ],
      });
      document.querySelector<HTMLButtonElement>("#close-dialog > [data-dialog-close]")?.click();
    },
  }));

  async function handleSubmit(
    event: SubmitEvent & { currentTarget: EventTarget & HTMLFormElement },
  ) {
    event.preventDefault();
    playlistUpdateMutation.mutate();
  }

  // Peak engineering right here.
  const callFilePicker = () =>
    document.querySelector<HTMLInputElement>("#upload-button > div > label > input")?.click();
</script>

<Dialog.Content>
  <form method="POST" onsubmit={handleSubmit}>
    <Dialog.Header>
      <Dialog.Title>Edit details</Dialog.Title>
      <div id="close-dialog">
        <Dialog.Close></Dialog.Close>
      </div>
    </Dialog.Header>
    <div class="flex py-3 gap-6 mt-2">
      <div class="relative group flex w-1/2 flex-col gap-2 items-center justify-center">
        <div
          class="absolute cursor-pointer -mt-18 group-hover:flex hidden gap-4 bg-black/30 w-full duration-200 flex-col items-center h-full select-none justify-center"
          role="button"
          tabindex="0"
          onkeydown={callFilePicker}
          onclick={callFilePicker}
        >
          <PencilIcon size={50} />
          <p class="text-sm">Change photo</p>
        </div>
        {#if playlistCoverImage}
          <img
            src={playlistCoverImage}
            alt="Cover for Playlist"
            height={256}
            width={256}
            class="rounded-2xl aspect-square object-cover"
          />
        {:else}
          <div class="rounded-2xl aspect-square h-full w-full bg-muted"></div>
        {/if}
        <div class="opacity-0 select-none cursor-default" id="upload-button">
          <UploadButton {uploader} />
        </div>
      </div>
      <div class="flex w-1/2 flex-col gap-2">
        <Label for="name">Title</Label>
        <Input id="name" bind:value={playlistTitle} />
      </div>
    </div>
    <Dialog.Footer>
      <Button type="submit" disabled={playlistUpdateMutation.isPending}>
        {#if playlistUpdateMutation.isPending}
          <LoaderCircleIcon class="mr-2 h-4 w-4 animate-spin" />
        {/if}
        Save changes
      </Button>
    </Dialog.Footer>
  </form>
</Dialog.Content>
