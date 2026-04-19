<script lang="ts">
  import { PlayIcon } from "@lucide/svelte";

  import { musicPlayer } from "$lib/stream-player/audio/musicPlayer";

  import Image from "../Image.svelte";
  import NowPlayingAnimation from "../NowPlayingAnimation.svelte";

  const {
    videoId,
    thumbnail,
    onClick,
    positionExists,
  }: { videoId: string; thumbnail: string; onClick?: () => void; positionExists?: boolean } =
    $props();

  const isTrackPlaying = $derived(musicPlayer.queue.playingNow?.videoId === videoId);
  const coverVisibility = $derived(
    isTrackPlaying && !positionExists ? "opacity-40" : "group-hover:opacity-40",
  );
</script>

<div
  role="button"
  tabindex="0"
  onclick={() => !positionExists && onClick?.()}
  onkeydown={e => (e.key === "Enter" || e.key === "Space") && !positionExists && onClick?.()}
  class="flex flex-col aspect-square items-center justify-center relative h-11 w-11 duration-200"
>
  {#if !positionExists}
    {#if isTrackPlaying}
      <div class="absolute z-50">
        <NowPlayingAnimation />
      </div>
    {:else}
      <PlayIcon class="absolute hidden group-hover:block z-50" size={18} fill="white" />
    {/if}
  {/if}
  {#key thumbnail}
    <Image
      src={thumbnail}
      alt="Thumbnail"
      class="rounded-sm aspect-square object-cover h-full w-full {coverVisibility}"
      height={64}
      width={70}
    />
  {/key}
</div>
