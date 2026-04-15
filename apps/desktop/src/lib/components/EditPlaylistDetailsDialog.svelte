<script lang="ts">
  import { dev } from "$app/environment";
  import { PUBLIC_BACKEND_URL, PUBLIC_DEV_BACKEND_URL } from "$env/static/public";
  import { LoaderCircleIcon, PencilIcon } from "@lucide/svelte";
  import { createMutation, useQueryClient } from "@tanstack/svelte-query";
  import { toast } from "svelte-sonner";
  import { z } from "zod";

  import type { Playlist } from "$lib/schemas/playlist";

  import { svelteMutationKeys, svelteQueryKeys } from "$lib/constants/keys";
  import { backendClient } from "$lib/utils/query-client.js";

  import { Button } from "./ui/button";
  import * as Dialog from "./ui/dialog";
  import { Input } from "./ui/input";
  import { Label } from "./ui/label";

  const { initialPlaylist }: { initialPlaylist: Playlist } = $props();

  let selectedCoverFile = $state<File | null>(null);
  let playlistTitle = $state(initialPlaylist.name);

  const queryClient = useQueryClient();

  const playlistUpdateMutation = createMutation(() => ({
    mutationKey: svelteMutationKeys.updatePlaylist(initialPlaylist.playlistId),
    retry: 3,
    async mutationFn() {
      let uploadCover = initialPlaylist.coverImage;

      if (selectedCoverFile) {
        const res = await fetch(
          `${dev ? PUBLIC_DEV_BACKEND_URL : PUBLIC_BACKEND_URL}/image/manual-upload`,
          {
            method: "POST",
            body: selectedCoverFile,
            headers: {
              "Content-Type": selectedCoverFile.type || "application/octet-stream",
            },
          },
        );

        const uploadedFile = await res.json();
        uploadCover = uploadedFile.data.url;
      }

      return backendClient(`/playlists/playlist/${initialPlaylist.playlistId}`, z.string(), {
        method: "PUT",
        body: {
          name: playlistTitle,
          coverImage: uploadCover,
        },
      });
    },
    onError: () => toast.error("Failed to update playlist details."),
    onSuccess() {
      queryClient.invalidateQueries({ queryKey: svelteQueryKeys.userPlaylists });
      queryClient.invalidateQueries({
        queryKey: svelteQueryKeys.playlist(initialPlaylist.playlistId),
      });
      document.querySelector<HTMLButtonElement>("#close-dialog > [data-dialog-close]")?.click();
      selectedCoverFile = null;
    },
  }));

  async function handleSubmit(
    event: SubmitEvent & { currentTarget: EventTarget & HTMLFormElement },
  ) {
    event.preventDefault();
    playlistUpdateMutation.mutate();
  }

  function handleFileChange(event: Event) {
    const input = event.target as HTMLInputElement;
    const file = input.files?.[0];

    if (!file) return;

    if (!file.type.startsWith("image/")) {
      toast.error("Only images are allowed as playlist covers.");
      input.value = "";
      return;
    }

    selectedCoverFile = file;
  }
</script>

<Dialog.Content>
  <form method="POST" onsubmit={handleSubmit}>
    <Dialog.Header>
      <Dialog.Title>Edit details</Dialog.Title>
      <div id="close-dialog">
        <Dialog.Close></Dialog.Close>
      </div>
    </Dialog.Header>
    <div class="flex gap-6 -mt-4">
      <div class="relative group flex w-1/2 flex-col gap-2 items-center justify-center">
        <label
          for="coverUpload"
          class="absolute bg-black/30 gap-2 inset-0 group-hover:flex hidden flex-col items-center justify-center transition-all cursor-pointer"
        >
          <PencilIcon size={35} />
          <p class="text-sm">Change photo</p>
        </label>
        <input
          type="file"
          id="coverUpload"
          name="coverUpload"
          accept="image/*"
          class="hidden"
          onchange={handleFileChange}
        />
        {#if initialPlaylist.coverImage || selectedCoverFile}
          <img
            src={selectedCoverFile
              ? URL.createObjectURL(selectedCoverFile)
              : initialPlaylist.coverImage}
            alt="Cover for Playlist"
            height={256}
            width={256}
            class="rounded-sm aspect-square object-cover"
          />
        {:else}
          <div class="rounded-sm aspect-square h-full w-full bg-muted"></div>
        {/if}
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
