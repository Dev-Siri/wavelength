<script lang="ts">
  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import musicQueueStore from "$lib/stores/music-queue.svelte";

  let progressBarElement: HTMLDivElement;

  let totalDuration = $state(0);
  let currentTime = $state(0);

  let totalMinutes = $derived(Math.floor((totalDuration - currentTime) / 60));
  let totalSeconds = $derived(Math.floor((totalDuration - currentTime) % 60));
  let currentMinutes = $derived(Math.floor(currentTime / 60));
  let currentSeconds = $derived(Math.floor(currentTime % 60));

  $effect(() => {
    musicPlayerStore.progress;
    async function fetchDurations() {
      const fetchedTotalDuration = (await musicPlayerStore.musicPlayer?.getDuration()) ?? 0;
      const fetchedCurrentTime = (await musicPlayerStore.musicPlayer?.getCurrentTime()) ?? 0;

      totalDuration = Math.round(fetchedTotalDuration);
      currentTime = Math.round(fetchedCurrentTime);
    }

    fetchDurations();
  });

  async function onProgressBarClick(event: MouseEvent) {
    if (!progressBarElement || !musicPlayerStore.musicPlayer) return;

    const { left, width } = progressBarElement.getBoundingClientRect();

    const clickPositionX = event.clientX - left;
    const clickPercentage = (clickPositionX / width) * 100;

    const duration = await musicPlayerStore.musicPlayer.getDuration();

    const newTime = (clickPercentage / 100) * duration;

    currentTime = Math.round(newTime);

    await musicPlayerStore.musicPlayer.seekTo(newTime, true);

    if (musicQueueStore.musicPlayingNow?.videoType === "uvideo")
      await musicPlayerStore.musicPreviewPlayer?.seekTo(newTime, true);

    musicPlayerStore.progress = (newTime / duration) * 100;
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
      class="h-1 bg-primary rounded-full duration-200"
      style="width: {musicPlayerStore.progress}%;"
    ></div>
    <div
      class="absolute h-4 w-4 rounded-full bg-muted-foreground hidden duration-200 border border-muted group-hover:inline"
      style="margin-left: {musicPlayerStore.progress - 3}%;"
    ></div>
  </div>
  <p class="text-sm text-muted-foreground">
    -{totalMinutes}:{totalSeconds.toString().padStart(2, "0")}
  </p>
</div>
