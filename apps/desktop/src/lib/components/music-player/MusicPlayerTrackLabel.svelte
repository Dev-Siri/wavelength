<script lang="ts">
  import { EllipsisIcon } from "@lucide/svelte";

  import useUserPlaylistsQuery from "$lib/queries/userPlaylists";
  import musicInterfaceStore from "$lib/stores/musicInterface.svelte";
  import userStore from "$lib/stores/user.svelte";
  import { musicPlayer } from "$lib/stream-player/musicPlayer";

  import { blur } from "svelte/transition";
  import AlbumLink from "../album/AlbumLink.svelte";
  import ArtistLink from "../artist/ArtistLink.svelte";
  import Image from "../Image.svelte";
  import PlaylistToggleOptions from "../playlist/PlaylistToggleOptions.svelte";
  import * as DropdownMenu from "../ui/dropdown-menu";

  const userPlaylistsQuery = $derived(useUserPlaylistsQuery(userStore.user?.email ?? ""));
</script>

{#if musicPlayer.queue.playingNow}
  {#if musicInterfaceStore.visiblePanel !== "lyrics"}
    <div in:blur out:blur={{ duration: 20 }}>
      <DropdownMenu.Root>
        <DropdownMenu.Trigger class="h-full">
          <div
            class="flex flex-col justify-center relative group py-2 h-full w-full cursor-pointer"
          >
            <EllipsisIcon
              class="absolute bg-secondary bg-opacity-80 z-10 rounded-full p-0.5 duration-200 top-4 right-2"
              color="white"
              size={18}
            />
            {#key musicPlayer.queue.playingNow}
              <Image
                src={musicPlayer.queue.playingNow.thumbnail}
                alt="Cover"
                height={80}
                width={80}
                class="rounded-lg h-20 w-full object-cover aspect-square duration-200 group-hover:brightness-75"
              />
            {/key}
          </div>
        </DropdownMenu.Trigger>
        <DropdownMenu.Content class="z-9999" hidden={!userPlaylistsQuery.data?.playlists}>
          <PlaylistToggleOptions
            ui="dropdown"
            toggle={{ type: "add" }}
            music={{
              ...musicPlayer.queue.playingNow,
              isExplicit: false,
            }}
          />
        </DropdownMenu.Content>
      </DropdownMenu.Root>
    </div>
  {:else}
    <div class="h-24"></div>
  {/if}
  <div class="ml-2 flex-col gap-3 hidden sm:flex">
    <p
      class="text-lg text-primary w-96 text-ellipsis inline font-semibold line-clamp-1 truncate select-none"
    >
      {musicPlayer.queue.playingNow.title}
    </p>
    <div class="flex items-center justify-start gap-1 h-1 -mt-1.5">
      <div class="overflow-hidden w-fit">
        <div class="flex w-max items-center">
          <div class="flex items-center whitespace-nowrap">
            {#each musicPlayer.queue.playingNow.artists as artist, i (`track-label-${artist.browseId}`)}
              <ArtistLink
                {...artist}
                class="text-xs text-gray-300 bg-blend-difference"
                trailingComma={i + 1 !== musicPlayer.queue.playingNow.artists.length}
              />
            {/each}
          </div>
        </div>
      </div>
      {#if musicPlayer.queue.playingNow.album}
        <span class="-mb-0.5">•</span>
        <AlbumLink
          class="text-xs -mb-1 -ml-3 text-gray-300 bg-blend-difference"
          {...musicPlayer.queue.playingNow.album}
        />
      {/if}
    </div>
    <span
      class="select-none text-[11px] font-semibold bg-gradient-to-r transition-all from-white via-gray-300 to-white bg-[length:200%_100%] bg-clip-text text-transparent animate-shimmer {musicPlayer
        .queue.playingNow.videoType !== 'VIDEO_TYPE_UVIDEO' &&
      (musicPlayer.streamMetadata?.bitrate ?? 0) >= 1_200_000
        ? 'opacity-100'
        : 'opacity-0'}"
    >
      Lossless
    </span>
  </div>
{:else}
  <div class="h-20 w-20 bg-primary-foreground rounded-md my-2"></div>
{/if}

<style>
  @keyframes shimmer {
    0% {
      background-position: 200% 0;
    }
    100% {
      background-position: -200% 0;
    }
  }

  .animate-shimmer {
    animation: shimmer 5s linear infinite;
  }
</style>
