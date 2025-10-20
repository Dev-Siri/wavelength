<script lang="ts">
  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import musicQueueStore from "$lib/stores/music-queue.svelte";

  let progressBarElement: HTMLDivElement;

  let totalMinutes = $derived(
    Math.floor((musicPlayerStore.duration - musicPlayerStore.currentTime) / 60),
  );
  let totalSeconds = $derived(
    Math.floor((musicPlayerStore.duration - musicPlayerStore.currentTime) % 60),
  );
  let currentMinutes = $derived(Math.floor(musicPlayerStore.currentTime / 60));
  let currentSeconds = $derived(Math.floor(musicPlayerStore.currentTime % 60));
  let musicPlayerProgress = $state(0);

  $effect(() => {
    const progress = (musicPlayerStore.currentTime / musicPlayerStore.duration) * 100;
    musicPlayerProgress = isNaN(progress) ? 0 : progress;
  });

  async function onProgressBarClick(event: MouseEvent) {
    if (!progressBarElement) return;

    const { left, width } = progressBarElement.getBoundingClientRect();

    const clickPositionX = event.clientX - left;
    const clickPercentage = (clickPositionX / width) * 100;

    const newTime = (clickPercentage / 100) * musicPlayerStore.duration;

    musicPlayerStore.seek(newTime);

    if (
      musicQueueStore.musicPlayingNow?.videoType === "uvideo" &&
      musicPlayerStore.musicPreviewPlayer
    )
      musicPlayerStore.musicPreviewPlayer.currentTime = newTime;

    const newProgress = (newTime / musicPlayerStore.duration) * 100;
    musicPlayerProgress = isNaN(newProgress) ? 0 : newProgress;
  }
</script>

<div class="flex items-center justify-center w-full gap-2">
  <p class="text-sm text-muted-foreground">
    {currentMinutes}:{currentSeconds.toString().padStart(2, "0")}
  </p>
  <!-- svelte-ignore a11y_click_events_have_key_events -->
  <!-- svelte-ignore a11y_no_noninteractive_element_interactions -->
  <div
    role="progressbar"
    class="flex flex-col h-1 w-full bg-muted group rounded-full relative justify-center cursor-pointer"
    onclick={onProgressBarClick}
    bind:this={progressBarElement}
  >
    <div
      class="h-1 bg-primary rounded-full duration-100"
      style="width: {musicPlayerProgress}%;"
    ></div>
    <div
      class="absolute h-4 w-4 rounded-full bg-primary hidden duration-100 border border-muted group-hover:inline"
      style="margin-left: {musicPlayerProgress - 3}%;"
    ></div>
  </div>
  <p class="text-sm text-muted-foreground">
    -{totalMinutes}:{totalSeconds.toString().padStart(2, "0")}
  </p>
</div>
