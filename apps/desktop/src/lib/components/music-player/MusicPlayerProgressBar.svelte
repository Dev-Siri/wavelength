<script lang="ts">
  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import musicQueueStore from "$lib/stores/music-queue.svelte";

  let progressBarElement: HTMLDivElement;
  let isDragging = $state(false);

  async function seekFromClientX(clientX: number) {
    if (!progressBarElement || !musicPlayerStore.musicPlayer) return;

    const { left, width } = progressBarElement.getBoundingClientRect();
    const clampedX = Math.max(0, Math.min(clientX - left, width));
    const percentage = clampedX / width;

    const duration = await musicPlayerStore.musicPlayer.getDuration();
    const newTime = percentage * duration;

    currentTime = Math.round(newTime);
    musicPlayerStore.progress = percentage * 100;

    await musicPlayerStore.musicPlayer.seekTo(newTime, true);

    if (musicQueueStore.musicPlayingNow?.videoType === "VIDEO_TYPE_UVIDEO")
      await musicPlayerStore.musicPreviewPlayer?.seekTo(newTime, true);
  }

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
    await seekFromClientX(event.clientX);
  }

  function onPointerDown(event: PointerEvent) {
    isDragging = true;
    progressBarElement.setPointerCapture(event.pointerId);
    seekFromClientX(event.clientX);
  }

  function onPointerMove(event: PointerEvent) {
    if (!isDragging) return;
    seekFromClientX(event.clientX);
  }

  function onPointerUp(event: PointerEvent) {
    isDragging = false;
    progressBarElement.releasePointerCapture(event.pointerId);
  }
</script>

<div class="flex items-center group justify-center w-full gap-2">
  <p class="text-xs text-muted-foreground">
    {currentMinutes}:{currentSeconds.toString().padStart(2, "0")}
  </p>
  <!-- svelte-ignore a11y_click_events_have_key_events -->
  <!-- svelte-ignore a11y_no_noninteractive_element_interactions -->
  <div
    role="progressbar"
    class="flex flex-col h-1 group-hover:h-2 duration-200 w-full bg-muted group rounded-full relative justify-center cursor-pointer"
    onclick={musicQueueStore.musicPlayingNow && onProgressBarClick}
    bind:this={progressBarElement}
    onpointerdown={musicQueueStore.musicPlayingNow && onPointerDown}
    onpointermove={musicQueueStore.musicPlayingNow && onPointerMove}
    onpointerup={musicQueueStore.musicPlayingNow && onPointerUp}
    onpointercancel={musicQueueStore.musicPlayingNow && onPointerUp}
  >
    <div
      class="h-1 bg-primary rounded-full duration-75"
      style="width: {musicPlayerStore.progress}%;"
    ></div>
    <div
      class="absolute h-3.5 w-3.5 rounded-full bg-white hidden duration-75 group-hover:inline"
      style="margin-left: {musicPlayerStore.progress}%;"
    ></div>
  </div>
  <p class="text-xs text-muted-foreground">
    -{totalMinutes}:{totalSeconds.toString().padStart(2, "0")}
  </p>
</div>
