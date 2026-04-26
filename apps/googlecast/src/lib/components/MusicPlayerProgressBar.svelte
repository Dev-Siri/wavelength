<script lang="ts">
  const duration = 239;
  const currentTime = 0;

  const currentMinutes = 0;
  const currentSeconds = 0;

  const totalMinutes = 3;
  const totalSeconds = 59;
</script>

<div class="flex flex-col items-center group justify-center w-full gap-2">
  <div class="relative w-full">
    <input
      type="range"
      min="0"
      max={duration || 0}
      step="0.1"
      value={currentTime}
      class="slider block h-1 appearance-none bg-[#404040] rounded-full outline-none w-full cursor-pointer"
      style="--progress: {duration ? (currentTime / duration) * 100 : 0}%"
    />
  </div>
  <div class="flex w-full justify-between">
    <p class="text-xs select-none">
      {currentMinutes}:{currentSeconds.toString().padStart(2, "0")}
    </p>
    <p class="text-xs select-none">
      -{totalMinutes}:{totalSeconds.toString().padStart(2, "0")}
    </p>
  </div>
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
