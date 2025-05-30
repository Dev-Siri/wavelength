<script lang="ts">
  import { Play } from "lucide-svelte";
  import { fly } from "svelte/transition";

  import type { BaseMusicTrack } from "$lib/server/api/interface/types";

  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import musicQueueStore, { type QueueableMusic } from "$lib/stores/music-queue.svelte";

  import Button from "$lib/components/ui/button/button.svelte";
  import * as Tooltip from "$lib/components/ui/tooltip";
  import Image from "./Image.svelte";

  const { music }: { music: BaseMusicTrack } = $props();

  let isHoveringCard = $state(false);

  function playSong() {
    const queueableTrack = { ...music, videoType: "track" } satisfies QueueableMusic;

    musicQueueStore.addToQueue(queueableTrack);
    musicQueueStore.musicPlayingNow = queueableTrack;
    musicPlayerStore.visiblePanel = "playingNow";
  }
</script>

<div
  class="relative flex flex-col p-2 items-center duration-200 hover:bg-muted rounded-2xl cursor-pointer group"
  tabindex={0}
  role="button"
  onclick={playSong}
  onkeydown={e => (e.key === "Enter" || e.key === "Space") && playSong()}
  onmouseenter={() => (isHoveringCard = true)}
  onmouseleave={() => (isHoveringCard = false)}
>
  <div class="h-3/4 w-full p-3 relative rounded-2xl">
    <div class="h-full w-full rounded-2xl relative inline-block thumbnail-cover">
      <Image
        src={music.thumbnail}
        alt="Thumbnail"
        height={192}
        width={192}
        class="object-cover shadow-2xl shadow-black h-full w-full rounded-2xl"
      />
    </div>
    {#if isHoveringCard}
      <div class="right-5 top-[70%] absolute">
        <div in:fly={{ y: 10, x: 0 }}>
          <Button class="rounded-full h-14 w-14">
            <Play class="text-primary-foreground" fill="black" />
          </Button>
        </div>
      </div>
    {/if}
  </div>
  {#if music.title}
    <Tooltip.Root>
      <Tooltip.Trigger>
        <p class="text-ellipsis mt-2 text-secondary-foreground text-sm text-balance w-52">
          {music.title} - {music.author}
        </p>
      </Tooltip.Trigger>
      <Tooltip.Content>
        <p>{music.title}</p>
      </Tooltip.Content>
    </Tooltip.Root>
  {/if}
</div>
