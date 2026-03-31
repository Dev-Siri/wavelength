<script lang="ts">
  import { musicPlayer } from "$lib/stream-player/musicPlayer";

  let progressBarElement: HTMLDivElement;
  let isDragging = $state(false);

  let totalMinutes = $derived(Math.floor((musicPlayer.duration - musicPlayer.currentTime) / 60));
  let totalSeconds = $derived(Math.floor((musicPlayer.duration - musicPlayer.currentTime) % 60));
  let currentMinutes = $derived(Math.floor(musicPlayer.currentTime / 60));
  let currentSeconds = $derived(Math.floor(musicPlayer.currentTime % 60));

  function seekFromEvent(event: PointerEvent) {
    const rect = progressBarElement.getBoundingClientRect();
    const x = event.clientX - rect.left;
    const percentage = Math.max(0, Math.min(1, x / rect.width));
    const newTime = percentage * musicPlayer.duration;
    musicPlayer.seek(newTime);
  }

  async function onProgressBarClick(event: MouseEvent) {
    const percentage = Math.max(0, Math.min(event.offsetX / progressBarElement.clientWidth));
    const newTime = percentage * musicPlayer.duration;
    await musicPlayer.seek(newTime);
  }

  function onPointerDown(event: PointerEvent) {
    isDragging = true;
    progressBarElement.setPointerCapture(event.pointerId);
    seekFromEvent(event);
  }

  function onPointerMove(event: PointerEvent) {
    if (!isDragging) return;
    seekFromEvent(event);
  }

  function onPointerUp(event: PointerEvent) {
    isDragging = false;
    progressBarElement.releasePointerCapture(event.pointerId);
  }
</script>

<div class="flex items-center group justify-center w-full gap-2">
  <p class="text-xs select-none">
    {currentMinutes}:{currentSeconds.toString().padStart(2, "0")}
  </p>
  <!-- svelte-ignore a11y_click_events_have_key_events -->
  <!-- svelte-ignore a11y_no_noninteractive_element_interactions -->
  <div
    role="progressbar"
    class="flex flex-col h-1 group-hover:h-2 duration-200 w-full bg-gray-500 group rounded-full relative justify-center cursor-pointer"
    onclick={musicPlayer.queue.playingNow && onProgressBarClick}
    bind:this={progressBarElement}
    onpointerdown={musicPlayer.queue.playingNow && onPointerDown}
    onpointermove={musicPlayer.queue.playingNow && onPointerMove}
    onpointerup={musicPlayer.queue.playingNow && onPointerUp}
    onpointercancel={musicPlayer.queue.playingNow && onPointerUp}
  >
    <div
      class="h-1 bg-white rounded-full duration-75"
      style="width: {musicPlayer.progress}%;"
    ></div>
    <div
      class="absolute h-3.5 w-3.5 rounded-full bg-white hidden duration-75 group-hover:inline"
      style="left: {musicPlayer.progress}%; transform: translateX(-50%);"
    ></div>
  </div>
  <p class="text-xs select-none">
    -{totalMinutes}:{totalSeconds.toString().padStart(2, "0")}
  </p>
</div>
