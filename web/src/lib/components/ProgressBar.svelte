<script lang="ts">
  import { musicPlayer, musicPlayerProgress, musicPreviewPlayer } from "$lib/stores/music-player";
  import { musicPlayingNow } from "$lib/stores/music-queue";

  let progressBarElement: HTMLDivElement;

  let totalDuration = $state(0);
  let currentTime = $state(0);

  let totalMinutes = $derived(Math.floor((totalDuration - currentTime) / 60));
  let totalSeconds = $derived(Math.floor((totalDuration - currentTime) % 60));
  let currentMinutes = $derived(Math.floor(currentTime / 60));
  let currentSeconds = $derived(Math.floor(currentTime % 60));

  $effect(() => {
    $musicPlayerProgress;
    async function fetchDurations() {
      const fetchedTotalDuration = (await $musicPlayer?.getDuration()) ?? 0;
      const fetchedCurrentTime = (await $musicPlayer?.getCurrentTime()) ?? 0;

      totalDuration = Math.round(fetchedTotalDuration);
      currentTime = Math.round(fetchedCurrentTime);
    }

    fetchDurations();
  });

  async function onProgressBarClick(event: MouseEvent) {
    if (!progressBarElement || !$musicPlayer) return;

    const { left, width } = progressBarElement.getBoundingClientRect();

    const clickPositionX = event.clientX - left;
    const clickPercentage = (clickPositionX / width) * 100;

    const duration = await $musicPlayer.getDuration();

    const newTime = (clickPercentage / 100) * duration;

    currentTime = Math.round(newTime);

    await $musicPlayer.seekTo(newTime, true);

    if ($musicPlayingNow?.videoType === "uvideo") await $musicPreviewPlayer?.seekTo(newTime, true);

    $musicPlayerProgress = (newTime / duration) * 100;
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
      style="width: {$musicPlayerProgress}%;"
    ></div>
    <div
      class="absolute h-4 w-4 rounded-full bg-muted-foreground hidden duration-200 border border-muted group-hover:inline"
      style="margin-left: {$musicPlayerProgress - 3}%;"
    ></div>
  </div>
  <p class="text-sm text-muted-foreground">
    -{totalMinutes}:{totalSeconds.toString().padStart(2, "0")}
  </p>
</div>
