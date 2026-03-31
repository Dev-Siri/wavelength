<script lang="ts">
  import type { LyricsLine } from "$lib/schemas/lyric";

  const { showRomanization, line }: { showRomanization: boolean; line: LyricsLine } = $props();
</script>

<p class="background-vocal-container">
  {#each line.backgroundText as syllable, i (syllable.timestamp)}
    {@const startTimeMs = syllable.timestamp}
    {@const endTimeMs = syllable.endtime}
    {@const durationMs = endTimeMs - startTimeMs}
    <span class="lyrics-word">
      <span class="lyrics-syllable-wrap">
        <span
          class="lyrics-syllable {syllable.lineSynced ? 'line-synced' : ''}"
          data-start-time={startTimeMs}
          data-end-time={endTimeMs}
          data-duration={durationMs}
          data-syllable-index={i}
        >
          {syllable.text}
        </span>
      </span>
      {#if showRomanization && syllable.romanizedText && syllable.romanizedText.trim() !== syllable.text.trim()}
        <span
          class="lyrics-syllable transliteration {syllable.lineSynced ? 'line-synced' : ''}"
          data-start-time={startTimeMs}
          data-end-time={endTimeMs}
          data-duration={durationMs}
          data-syllable-index="0"
          data-wipe-ratio="1"
        >
          {syllable.romanizedText}
        </span>
      {/if}
    </span>
  {/each}
</p>
