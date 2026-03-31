<script lang="ts">
  import type { Gap } from "./LyricsContent.svelte";

  const { gap, lineIndex }: { gap: Gap; lineIndex: number } = $props();

  const dotDuration = $derived((gap.gapEnd - gap.gapStart) / 3);
</script>

<div
  id="gap-{lineIndex}"
  class="lyrics-line lyrics-gap"
  data-start-time={gap.gapStart}
  data-end-time={gap.gapEnd}
>
  <div class="lyrics-line-container">
    <p class="main-vocal-container">
      <span class="lyrics-word">
        <span class="lyrics-syllable-wrap">
          <span
            class="lyrics-syllable"
            data-start-time={gap.gapStart}
            data-end-time={gap.gapStart + dotDuration}
            data-duration={dotDuration}
            data-wipe-ratio="1"
            data-syllable-index="0"
          ></span>
        </span>
        <span class="lyrics-syllable-wrap">
          <span
            class="lyrics-syllable"
            data-start-time={gap.gapStart + dotDuration}
            data-end-time={gap.gapStart + dotDuration * 2}
            data-duration={dotDuration}
            data-wipe-ratio="1"
            data-syllable-index="1"
          ></span>
        </span>
        <span class="lyrics-syllable-wrap">
          <span
            class="lyrics-syllable"
            data-start-time={gap.gapStart + dotDuration * 2}
            data-end-time={gap.gapEnd}
            data-duration={dotDuration}
            data-wipe-ratio="1"
            data-syllable-index="2"
          ></span>
        </span>
      </span>
    </p>
  </div>
</div>
