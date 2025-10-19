<script lang="ts">
  import { EllipsisIcon, PlayIcon } from "@lucide/svelte";

  import type { MusicTrack } from "$lib/utils/validation/music-track";
  import type { VideoType } from "$lib/utils/validation/playlist-track";

  import musicPlayerStore from "$lib/stores/music-player.svelte.js";
  import musicQueueStore, { type QueueableMusic } from "$lib/stores/music-queue.svelte.js";
  import { parseHtmlEntities } from "$lib/utils/format.js";

  import ExplicitIndicator from "./ExplicitIndicator.svelte";
  import Image from "./Image.svelte";
  import PlaylistToggleOptions from "./PlaylistToggleOptions.svelte";
  import { Button } from "./ui/button";
  import * as DropdownMenu from "./ui/dropdown-menu";

  const { music }: { music: MusicTrack & { videoType?: VideoType } } = $props();

  function playSong() {
    const queueableTrack = {
      ...music,
      videoType: music.videoType ?? "track",
    } satisfies QueueableMusic;

    musicQueueStore.addToQueue(queueableTrack);
    musicQueueStore.musicPlayingNow = queueableTrack;
    musicPlayerStore.visiblePanel = "playingNow";
  }
</script>

<DropdownMenu.Root>
  <div
    class="flex rounded-lg items-center duration-200 p-1.5 gap-2 hover:bg-muted w-full pr-4 group cursor-pointer"
  >
    <div
      tabindex={0}
      role="button"
      onclick={playSong}
      onkeydown={e => (e.key === "Enter" || e.key === "Space") && playSong()}
      class="flex gap-2 text-start w-full"
    >
      <div
        class="flex flex-col aspect-square items-center justify-center relative group-hover:rounded-lg h-12 w-12 duration-200"
      >
        <PlayIcon class="absolute hidden group-hover:block z-50" size={18} fill="white" />
        {#key music.thumbnail}
          <Image
            src={music.thumbnail}
            alt="Thumbnail"
            class="rounded-md aspect-square object-cover h-full w-full group-hover:opacity-40"
            height={64}
            width={70}
          />
        {/key}
      </div>
      <div class="flex flex-col gap-2 w-full mt-2">
        <p class="leading-none text-sm">
          {parseHtmlEntities(
            music.title.length > 45 ? `${music.title.slice(0, 44).trim()}...` : music.title,
          )}
        </p>
        <p class="text-sm text-muted-foreground leading-none -mt-1">
          {#if music.isExplicit}
            <ExplicitIndicator />
          {/if}
          {music.author}
        </p>
      </div>
      {#if music.duration}
        <p class="self-center text-sm text-muted-foreground pl-[9%]">
          {music.duration}
        </p>
      {:else}
        <div class="pr-[18%]"></div>
      {/if}
    </div>
    {#if music.duration !== ""}
      <DropdownMenu.Trigger class="h-full">
        <Button variant="ghost" class="flex items-center justify-center px-1 text-muted-foreground">
          <EllipsisIcon />
        </Button>
      </DropdownMenu.Trigger>
    {/if}
  </div>
  <DropdownMenu.Content>
    <PlaylistToggleOptions {music} />
  </DropdownMenu.Content>
</DropdownMenu.Root>
