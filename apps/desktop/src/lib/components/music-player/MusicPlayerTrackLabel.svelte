<script lang="ts">
  import { EllipsisIcon } from "@lucide/svelte";
  import { createQuery } from "@tanstack/svelte-query";

  import { playlistsSchema } from "$lib/utils/validation/playlists";

  import { svelteQueryKeys } from "$lib/constants/keys";
  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import musicQueueStore from "$lib/stores/music-queue.svelte";
  import userStore from "$lib/stores/user.svelte";
  import { durationify } from "$lib/utils/format.js";
  import { backendClient } from "$lib/utils/query-client";
  import { getThumbnailUrl } from "$lib/utils/url";

  import ArtistLink from "../artist/ArtistLink.svelte";
  import Image from "../Image.svelte";
  import PlaylistToggleOptions from "../playlist/PlaylistToggleOptions.svelte";
  import * as DropdownMenu from "../ui/dropdown-menu";

  const playlistsQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.userPlaylists,
    async queryFn() {
      if (!userStore.user) return;

      return backendClient(`/playlists/user/${userStore.user.email}`, playlistsSchema);
    },
  }));
</script>

{#if musicQueueStore.musicPlayingNow}
  <DropdownMenu.Root>
    <DropdownMenu.Trigger>
      <div class="relative group h-full w-full cursor-pointer">
        <EllipsisIcon
          class="absolute bg-black bg-opacity-80 z-10 rounded-full p-0.5 duration-200 top-2 right-2"
          color="white"
          size={20}
        />
        {#key musicQueueStore.musicPlayingNow}
          <Image
            src={getThumbnailUrl(musicQueueStore.musicPlayingNow.videoId)}
            alt="Cover"
            height={80}
            width={80}
            class="rounded-md object-cover aspect-square duration-200 group-hover:brightness-75"
          />
        {/key}
      </div>
    </DropdownMenu.Trigger>
    <DropdownMenu.Content class="z-9999" hidden={!playlistsQuery.data?.playlists}>
      <PlaylistToggleOptions
        toggle={{ type: "add" }}
        music={{
          ...musicQueueStore.musicPlayingNow,
          isExplicit: false,
          duration: durationify(musicPlayerStore.duration),
        }}
      />
    </DropdownMenu.Content>
  </DropdownMenu.Root>
  <div class="ml-2 hidden sm:block">
    <p class="text-md text-primary">
      {musicQueueStore.musicPlayingNow.title}
    </p>
    {#each musicQueueStore.musicPlayingNow.artists as artist, i}
      <ArtistLink
        {...artist}
        class="text-xs"
        trailingComma={i + 1 !== musicQueueStore.musicPlayingNow.artists.length}
      />
    {/each}
  </div>
{:else}
  <div class="h-20 w-20 bg-primary-foreground rounded-md"></div>
{/if}
