<script lang="ts">
  import { musicPlayer } from "$lib/stream-player/audio/musicPlayer";

  let progressBarElement: HTMLDivElement;
  let isDragging = $state(false);

  let hoverX = $state(0);
  let hoverTime = $state(0);
  let isHovering = $state(false);

  let totalMinutes = $derived(Math.floor((musicPlayer.duration - musicPlayer.currentTime) / 60));
  let totalSeconds = $derived(Math.floor((musicPlayer.duration - musicPlayer.currentTime) % 60));
  let currentMinutes = $derived(Math.floor(musicPlayer.currentTime / 60));
  let currentSeconds = $derived(Math.floor(musicPlayer.currentTime % 60));

  let bufferedProgress = $derived(
    Math.max(
      0,
      Math.min(
        musicPlayer.duration ? (musicPlayer.bufferedTime / musicPlayer.duration) * 100 : 0,
        100,
      ),
    ),
  );

  function seekFromEvent(event: PointerEvent) {
    const rect = progressBarElement.getBoundingClientRect();
    const x = event.clientX - rect.left;
    const percentage = Math.max(0, Math.min(1, x / rect.width));
    const newTime = percentage * musicPlayer.duration;
    musicPlayer.seek(newTime);
  }

  function updateHover(event: PointerEvent) {
    const rect = progressBarElement.getBoundingClientRect();
    const x = event.clientX - rect.left;
    const percentage = Math.max(0, Math.min(1, x / rect.width));
    hoverX = percentage * rect.width;
    hoverTime = percentage * musicPlayer.duration;
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
    updateHover(event);
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
    class="flex flex-col h-1 duration-200 w-full bg-[#404040] group rounded-full relative justify-center cursor-pointer"
    onclick={musicPlayer.queue.playingNow && onProgressBarClick}
    bind:this={progressBarElement}
    onpointerdown={musicPlayer.queue.playingNow && onPointerDown}
    onpointermove={musicPlayer.queue.playingNow && onPointerMove}
    onpointerup={musicPlayer.queue.playingNow && onPointerUp}
    onpointercancel={musicPlayer.queue.playingNow && onPointerUp}
    onpointerenter={() => (isHovering = true)}
    onpointerleave={() => (isHovering = false)}
  >
    <div
      class="h-1 bg-[#515151] rounded-full absolute left-0 top-0"
      style="width: {bufferedProgress}%;"
    ></div>
    <div
      class="h-1 bg-white rounded-full duration-75 relative"
      style="width: {musicPlayer.progress}%;"
    ></div>
    {#if isHovering}
      <div
        class="absolute -top-6 px-1.5 py-0.5 text-[10px] rounded bg-black text-white whitespace-nowrap pointer-events-none"
        style="left: {hoverX}px; transform: translateX(-50%);"
      >
        {Math.floor(hoverTime / 60)}:{Math.floor(hoverTime % 60)
          .toString()
          .padStart(2, "0")}
      </div>
    {/if}

    <div
      class="absolute h-3.5 w-3.5 rounded-full bg-white hidden duration-75 group-hover:inline"
      style="left: {musicPlayer.progress}%; transform: translateX(-50%);"
    ></div>
  </div>
  <p class="text-xs select-none">
    -{totalMinutes}:{totalSeconds.toString().padStart(2, "0")}
  </p>
</div>
