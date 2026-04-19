<script lang="ts">
  import { musicPlayer } from "$lib/stream-player/audio/musicPlayer";

  let totalMinutes = $derived(Math.floor((musicPlayer.duration - musicPlayer.currentTime) / 60));
  let totalSeconds = $derived(Math.floor((musicPlayer.duration - musicPlayer.currentTime) % 60));
  let currentMinutes = $derived(Math.floor(musicPlayer.currentTime / 60));
  let currentSeconds = $derived(Math.floor(musicPlayer.currentTime % 60));

  let hoverX = $state(0);
  let hoverTime = $state(0);
  let isHovering = $state(false);
  let sliderElement: HTMLInputElement;

  function updateHover(event: MouseEvent) {
    const rect = sliderElement.getBoundingClientRect();
    const x = event.clientX - rect.left;
    const percentage = Math.max(0, Math.min(1, x / rect.width));
    hoverX = percentage * rect.width;
    hoverTime = percentage * musicPlayer.duration;
  }
</script>

<div class="flex items-center group justify-center w-full gap-2">
  <p class="text-xs select-none">
    {currentMinutes}:{currentSeconds.toString().padStart(2, "0")}
  </p>
  <div class="relative w-full">
    <input
      type="range"
      min="0"
      max={musicPlayer.duration || 0}
      step="0.1"
      value={musicPlayer.currentTime}
      bind:this={sliderElement}
      class="slider block h-1 appearance-none bg-[#404040] rounded-full outline-none w-full cursor-pointer"
      style="--progress: {musicPlayer.duration
        ? (musicPlayer.currentTime / musicPlayer.duration) * 100
        : 0}%"
      onmousemove={updateHover}
      onmouseenter={() => (isHovering = true)}
      onmouseleave={() => (isHovering = false)}
      onchange={e => musicPlayer.seek(e.currentTarget.valueAsNumber)}
    />

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
  </div>
  <p class="text-xs select-none">
    -{totalMinutes}:{totalSeconds.toString().padStart(2, "0")}
  </p>
</div>

<style>
  .slider::-webkit-slider-thumb {
    -webkit-appearance: none;
    appearance: none;
    width: 12px;
    height: 12px;
    background: white;
    border-radius: 50%;
    cursor: pointer;
    margin-top: -4px;
  }

  .slider::-webkit-slider-runnable-track {
    height: 4px;
    background: linear-gradient(
      to right,
      white 0%,
      white var(--progress, 0%),
      #404040 var(--progress, 0%),
      #404040 100%
    );
    border-radius: 9999px;
  }

  .slider::-moz-range-thumb {
    width: 12px;
    height: 12px;
    background: white;
    border: none;
    border-radius: 50%;
    cursor: pointer;
  }

  .slider::-moz-range-track {
    height: 4px;
    background: #404040;
    border-radius: 9999px;
  }
</style>
