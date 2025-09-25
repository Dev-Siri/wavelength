<script lang="ts">
  import { EllipsisIcon, PlayIcon } from "@lucide/svelte";

  import type { VideoTypeEnum } from "$lib/db/schema.js";
  import type { MusicTrack } from "$lib/types.js";

  import musicPlayerStore from "$lib/stores/music-player.svelte.js";
  import musicQueueStore, { type QueueableMusic } from "$lib/stores/music-queue.svelte.js";
  import { parseHtmlEntities } from "$lib/utils/format.js";

  import Image from "./Image.svelte";
  import PlaylistToggleOptions from "./PlaylistToggleOptions.svelte";
  import { Button } from "./ui/button";
  import * as DropdownMenu from "./ui/dropdown-menu";
  import * as Tooltip from "./ui/tooltip";

  const { music }: { music: MusicTrack & { videoType?: VideoTypeEnum } } = $props();

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
    class="flex rounded-md items-center duration-200 p-2 gap-2 hover:bg-muted w-full pr-4 group cursor-pointer"
  >
    <div
      tabindex={0}
      role="button"
      onclick={playSong}
      onkeydown={e => (e.key === "Enter" || e.key === "Space") && playSong()}
      class="flex gap-2 text-start w-full"
    >
      <div
        class="flex flex-col aspect-square items-center justify-center relative group-hover:rounded-md h-14 w-[70px] duration-200"
      >
        <PlayIcon class="absolute hidden group-hover:block z-50" size={18} fill="white" />
        <Image
          src={music.thumbnail}
          alt="Thumbnail"
          class="rounded-md aspect-square object-cover h-full w-full group-hover:opacity-40"
          height={64}
          width={70}
        />
      </div>
      <div class="flex flex-col gap-2 w-full mt-2">
        <p class="leading-none">
          {parseHtmlEntities(
            music.title.length > 45 ? `${music.title.slice(0, 44).trim()}...` : music.title,
          )}
        </p>
        <p class="text-sm text-muted-foreground leading-none -mt-1">
          {#if music.isExplicit}
            <Tooltip.Root>
              <Tooltip.Trigger>
                <span
                  class="bg-muted-foreground text-primary-foreground px-[5px] font-bold p-0.5 rounded-sm text-xs"
                >
                  E
                </span>
              </Tooltip.Trigger>
              <Tooltip.Content>
                <p>Explicit</p>
              </Tooltip.Content>
            </Tooltip.Root>
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
