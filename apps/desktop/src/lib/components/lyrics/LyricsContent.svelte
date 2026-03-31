<script lang="ts" module>
  export interface Gap {
    insertBeforeIndex: number;
    gapStart: number;
    gapEnd: number;
  }
</script>

<script lang="ts">
  import { INSTRUMENTAL_THRESHOLD_MS } from "$lib/constants/lyrics";

  import type { LyricsLine, Syllable } from "$lib/schemas/lyric";

  import BackgroundVocalElement from "./BackgroundVocalElement.svelte";
  import InstrumentalBlock from "./InstrumentalBlock.svelte";
  import MainVocalElement from "./MainVocalElement.svelte";

  const {
    isLoading,
    lyrics,
    showRomanization,
    showTranslation,
    onLineClick,
  }: {
    isLoading: boolean;
    lyrics: LyricsLine[] | null;
    showRomanization: boolean;
    showTranslation: boolean;
    onLineClick: (line: LyricsLine) => void;
  } = $props();

  function createLyricRenderDetails(line: LyricsLine, index: number) {
    const lineId = `lyrics-line-${index}`;
    const lineStartTime = (line.text ?? [])[0]?.timestamp || 0;
    const lineEndTime = (line.text ?? [])[(line.text ?? []).length - 1]?.endtime || 0;
    const hasBackground = line.backgroundText && line.backgroundText.length > 0;
    // Background vocals share the same line.translation and line.romanizedText
    // as the main vocal, so we intentionally do NOT render a separate
    // translation/romanization block for background — it would just duplicate
    // the main line's text.
    // Group syllables by word: when part=true, append to previous word group
    const wordGroups: Syllable[][] = [];
    for (const syllable of line.text ?? []) {
      if (syllable.part && wordGroups.length > 0) {
        // Continuation of previous word
        wordGroups[wordGroups.length - 1].push(syllable);
      } else {
        // New word
        wordGroups.push([syllable]);
      }
    }

    //  Pre-compute isGrowable per "visual word": adjacent groups whose text
    //  doesn't end with whitespace form one visual word (e.g. "a"+"live" = "alive").
    //  We evaluate growable on the combined text/duration, then propagate
    //  the result to each individual group so it renders through the
    //  single-syllable path (which supports char-level glow).
    const groupGrowable: boolean[] = new Array(wordGroups.length).fill(false);

    // Visual word info for growable char-level glow:
    // Each group stores the combined visual word's text, duration, and
    // the char offset of this group within the visual word.
    const vwFullText: string[] = new Array(wordGroups.length).fill("");
    const vwFullDuration: number[] = new Array(wordGroups.length).fill(0);
    const vwCharOffset: number[] = new Array(wordGroups.length).fill(0);
    const vwStartMs: number[] = new Array(wordGroups.length).fill(0);
    const vwEndMs: number[] = new Array(wordGroups.length).fill(0);
    {
      let vwStart = 0;
      while (vwStart < wordGroups.length) {
        let vwEnd = vwStart;
        while (vwEnd < wordGroups.length - 1) {
          const grp = wordGroups[vwEnd];
          const lastText = grp[grp.length - 1].text;
          if (/\s$/.test(lastText)) break;
          vwEnd += 1;
        }

        // Compute combined properties for this visual word
        const combinedText = wordGroups
          .slice(vwStart, vwEnd + 1)
          .flatMap(g => g.map(s => s.text))
          .join("")
          .trim();
        const combinedStart = wordGroups[vwStart][0].timestamp;
        const lastGrp = wordGroups[vwEnd];
        const combinedEnd = lastGrp[lastGrp.length - 1].endtime;
        const combinedDuration = combinedEnd - combinedStart;

        const isCJK = /[\u4e00-\u9fff\u3040-\u309f\u30a0-\u30ff\uac00-\ud7af]/.test(combinedText);
        const isRTL = /[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\u0590-\u05FF]/.test(combinedText);
        const hasHyphen = combinedText.includes("-");
        const isGrowableVW =
          !isCJK &&
          !isRTL &&
          !hasHyphen &&
          combinedText.length <= 7 &&
          combinedText.length > 0 &&
          combinedDuration >= 900 &&
          combinedDuration >= combinedText.length * 300 &&
          (combinedText.length >= 4 || combinedDuration / combinedText.length >= 600);

        let charOff = 0;
        for (let gi = vwStart; gi <= vwEnd; gi += 1) {
          groupGrowable[gi] = isGrowableVW;
          vwFullText[gi] = combinedText;
          vwFullDuration[gi] = combinedDuration;
          vwCharOffset[gi] = charOff;
          vwStartMs[gi] = combinedStart;
          vwEndMs[gi] = combinedEnd;
          const grpText = wordGroups[gi].map(s => s.text).join("");
          charOff += grpText.replace(/\s/g, "").length;
        }

        vwStart = vwEnd + 1;
      }
    }

    return {
      lineId,
      lineStartTime,
      lineEndTime,
      hasBackground,
      wordGroups,
      groupGrowable,
      vwFullText,
      vwFullDuration,
      vwCharOffset,
      vwStartMs,
      vwEndMs,
    };
  }

  function findAllInstrumentalGaps() {
    if (!lyrics || lyrics.length === 0) return [];
    const gaps: Gap[] = [];

    // Start-of-song gap
    const first = lyrics[0];
    if (first.timestamp >= INSTRUMENTAL_THRESHOLD_MS) {
      gaps.push({ insertBeforeIndex: 0, gapStart: 0, gapEnd: first.timestamp });
    }

    // Inter-line gaps
    for (let i = 0; i < lyrics.length - 1; i += 1) {
      const curr = lyrics[i];
      const next = lyrics[i + 1];
      const gapStart = curr.endtime;
      const gapEnd = next.timestamp;
      if (gapEnd - gapStart >= INSTRUMENTAL_THRESHOLD_MS) {
        gaps.push({ insertBeforeIndex: i + 1, gapStart, gapEnd });
      }
    }

    return gaps;
  }

  // Build a lookup map of ALL gaps so they are always in the DOM
  const allGaps = $derived.by(findAllInstrumentalGaps);
  const gapByIndex = $derived(new Map(allGaps.map(g => [g.insertBeforeIndex, g] as const)));
</script>

{#if isLoading}
  <!-- Render stylized skeleton lines -->
  <div class="skeleton-line"></div>
  <div class="skeleton-line"></div>
  <div class="skeleton-line"></div>
  <div class="skeleton-line"></div>
  <div class="skeleton-line"></div>
  <div class="skeleton-line"></div>
  <div class="skeleton-line"></div>
{:else if !lyrics || lyrics.length === 0}
  <div class="no-lyrics mt-[30%]">No lyrics found.</div>
{:else}
  {#each lyrics as line, i (i)}
    {@const {
      lineId,
      lineStartTime,
      lineEndTime,
      hasBackground,
      wordGroups,
      groupGrowable,
      vwFullText,
      vwFullDuration,
      vwCharOffset,
      vwStartMs,
      vwEndMs,
    } = createLyricRenderDetails(line, i)}
    {@const gapForLine = gapByIndex.get(i)}
    {@const fullLineText = (line.text ?? [])
      .map(s => s.text)
      .join("")
      .trim()}
    {#if gapForLine}
      <InstrumentalBlock gap={gapForLine} lineIndex={i} />
    {/if}
    <div
      id={lineId}
      role="button"
      class="lyrics-line {line.alignment === 'ALIGNMENT_DIRECTION_END'
        ? 'singer-right'
        : 'singer-left'}"
      data-start-time={lineStartTime}
      data-end-time={lineEndTime}
      onclick={() => onLineClick(line)}
      tabindex="0"
      onkeydown={(e: KeyboardEvent) => {
        if (e.key === "Enter" || e.key === " ") onLineClick(line);
      }}
    >
      <div class="lyrics-line-container">
        <MainVocalElement
          {wordGroups}
          {groupGrowable}
          {vwFullText}
          {vwFullDuration}
          {vwCharOffset}
          {vwStartMs}
          {vwEndMs}
          {showRomanization}
        />
        {#if hasBackground}
          <BackgroundVocalElement {line} {showRomanization} />
        {/if}
        {#if showTranslation && line.translation && line.translation.trim()}
          <div class="lyrics-translation-container">
            {line.translation}
          </div>
        {/if}
        {#if showRomanization && line.romanizedText && !(line.text ?? []).some(s => s.romanizedText) && line.romanizedText.trim() !== fullLineText}
          <div class="lyrics-romanization-container">
            {line.romanizedText}
          </div>
        {/if}
      </div>
    </div>
  {/each}
{/if}
