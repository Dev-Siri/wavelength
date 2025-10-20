<script lang="ts">
  import { EllipsisIcon } from "@lucide/svelte";
  import { useQueryClient } from "@tanstack/svelte-query";

  import type { Playlist } from "$lib/utils/validation/playlists";

  import { svelteQueryKeys } from "$lib/constants/keys";
  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import musicQueueStore from "$lib/stores/music-queue.svelte";
  import { durationify, parseHtmlEntities } from "$lib/utils/format.js";
  import { getThumbnailUrl } from "$lib/utils/url";

  import Image from "./Image.svelte";
  import PlaylistToggleOptions from "./PlaylistToggleOptions.svelte";
  import * as DropdownMenu from "./ui/dropdown-menu";

  const queryClient = useQueryClient();
  const playlists = $derived.by(() =>
    queryClient.getQueryData<Playlist[]>(svelteQueryKeys.userPlaylists),
  );
</script>

{#if musicQueueStore.musicPlayingNow}
  <DropdownMenu.Root>
    <DropdownMenu.Trigger>
      <div class="relative group h-20 w-20 cursor-pointer">
        <EllipsisIcon
          class="absolute bg-black bg-opacity-80 z-99999 rounded-full p-0.5 duration-200 top-2 right-2"
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
    <DropdownMenu.Content class="z-9999" hidden={!playlists?.length}>
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
  <div class="hidden sm:block">
    <p class="text-md ml-2 text-primary">
      {parseHtmlEntities(musicQueueStore.musicPlayingNow.title)}
    </p>
    <p class="text-xs ml-2 text-muted-foreground">{musicQueueStore.musicPlayingNow.author}</p>
  </div>
{:else}
  <div class="h-20 w-20 bg-primary-foreground rounded-md"></div>
{/if}
