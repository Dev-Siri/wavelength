<script lang="ts">
  import { invalidateAll } from "$app/navigation";
  import { UploadButton } from "@uploadthing/svelte";
  import { LoaderCircle } from "lucide-svelte";
  import toast from "svelte-french-toast";

  import type { PlayList } from "$lib/db/schema";
  import type { ApiResponse } from "$lib/utils/types";

  import playlistsStore from "$lib/stores/playlists.svelte";
  import userStore from "$lib/stores/user.svelte";
  import { createUploader } from "$lib/utils/uploadthing";

  import queryClient from "$lib/utils/query-client";
  import { Button } from "./ui/button";
  import * as Dialog from "./ui/dialog";
  import { Input } from "./ui/input";
  import { Label } from "./ui/label";

  const { initialPlaylist }: { initialPlaylist: PlayList } = $props();

  let isLoading = $state(false);
  let playlistTitle = $state(initialPlaylist.name);
  let playlistCoverImage = $state(initialPlaylist.coverImage);

  const uploader = createUploader("imageUploader", {
    onClientUploadComplete(res) {
      playlistCoverImage = res[0].url;
    },
  });

  async function handleSubmit(
    event: SubmitEvent & { currentTarget: EventTarget & HTMLFormElement },
  ) {
    event.preventDefault();

    isLoading = true;

    const playlistEditResponse = await queryClient<ApiResponse<string>>(
      location.toString(),
      `/api/playlists/${initialPlaylist.playlistId}`,
      {
        method: "PUT",
        body: {
          name: playlistTitle,
          coverImage: playlistCoverImage,
        },
      },
    );

    isLoading = false;

    if (!playlistEditResponse.success) return toast.error("Failed to update playlist details.");

    toast.success("Updated playlist details successfully.");

    invalidateAll();

    if (!userStore.user) return;

    const response = await queryClient<ApiResponse<PlayList[]>>(
      location.toString(),
      `/api/playlists/user/${userStore.user.email}`,
    );

    if (response.success) playlistsStore.playlists = response.data;
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
          <LoaderCircle class="mr-2 h-4 w-4 animate-spin" />
        {/if}
        Save changes
      </Button>
    </Dialog.Footer>
  </form>
</Dialog.Header>
