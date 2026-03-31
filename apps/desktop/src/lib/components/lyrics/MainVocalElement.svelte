<script lang="ts">
  /* eslint-disable svelte/no-useless-mustaches */
  import type { Syllable } from "$lib/schemas/lyric";

  const {
    wordGroups,
    groupGrowable,
    vwFullText,
    vwFullDuration,
    vwCharOffset,
    vwStartMs,
    vwEndMs,
    showRomanization,
  }: {
    wordGroups: Syllable[][];
    groupGrowable: boolean[];
    vwFullText: string[];
    vwFullDuration: number[];
    vwCharOffset: number[];
    vwStartMs: number[];
    vwEndMs: number[];
    showRomanization: boolean;
  } = $props();

  function calculateLyricAnimationDetails(
    wordDuration: number,
    numChars: number,
    groupIndex: number,
  ) {
    // Collect all text from groups in this visual word
    // by scanning forward while vwCharOffset is consecutive
    let combinedRawText = "";
    for (let gi = groupIndex; gi < wordGroups.length; gi += 1) {
      if (gi > groupIndex && vwCharOffset[gi] === 0) break;
      if (gi > groupIndex && !groupGrowable[gi]) break;
      combinedRawText += wordGroups[gi].map(s => s.text).join("");
    }

    return combinedRawText.split("").map((char, charIndex) => {
      if (char === " ") return;

      const charStartPercent = charIndex / numChars;

      const minDuration = 1000;
      const maxDuration = 5000;
      const easingPower = 3;
      const progress = Math.min(
        1,
        Math.max(0, (wordDuration - minDuration) / (maxDuration - minDuration)),
      );
      const easedProgress = progress ** easingPower;

      const isLongWord = numChars > 5;
      const isShortDuration = wordDuration < 1500;
      let maxDecayRate = 0;
      if (isLongWord || isShortDuration) {
        let decayStrength = 0;
        if (isLongWord) decayStrength += Math.min((numChars - 5) / 3, 1.0) * 0.4;
        if (isShortDuration) decayStrength += Math.max(0, 1.0 - (wordDuration - 1000) / 500) * 0.4;
        maxDecayRate = Math.min(decayStrength, 0.85);
      }

      const positionInWord = numChars > 1 ? charIndex / (numChars - 1) : 0;
      const decayFactor = 1.0 - positionInWord * maxDecayRate;
      const charProgress = easedProgress * decayFactor;

      const baseGrowth = numChars <= 3 ? 0.07 : 0.05;
      const charMaxScale = 1.0 + baseGrowth + charProgress * 0.1;
      const charShadowIntensity = 0.4 + charProgress * 0.4;
      const normalizedGrowth = (charMaxScale - 1.0) / 0.13;
      const charTranslateYPeak = -normalizedGrowth * 6;

      const position = (charIndex + 0.5) / numChars;
      const horizontalOffset = (position - 0.5) * 2 * ((charMaxScale - 1.0) * 25);

      return {
        charIndex,
        char,
        wipeStart: charStartPercent.toFixed(4),
        wipeDuration: (1 / numChars).toFixed(4),
        horizontalOffset: horizontalOffset.toFixed(2),
        maxScale: charMaxScale.toFixed(3),
        shadowIntensity: charShadowIntensity.toFixed(3),
        translateYPeak: charTranslateYPeak.toFixed(3),
      };
    });
  }

  function calculateGlowableLyricAnimationDetails(text: string, durationMs: number) {
    const trimmedText = text.trim();
    return text.split("").map((char, charIndex) => {
      if (char === " ") return;

      const numChars = trimmedText.length;
      const charStartPercent = charIndex / text.length;

      const minDuration = 1000;
      const maxDuration = 5000;
      const easingPower = 3;
      const progress = Math.min(
        1,
        Math.max(0, (durationMs - minDuration) / (maxDuration - minDuration)),
      );
      const easedProgress = progress ** easingPower;

      const isLongWord = numChars > 5;
      const isShortDuration = durationMs < 1500;
      let maxDecayRate = 0;
      if (isLongWord || isShortDuration) {
        let decayStrength = 0;
        if (isLongWord) decayStrength += Math.min((numChars - 5) / 3, 1.0) * 0.4;
        if (isShortDuration) decayStrength += Math.max(0, 1.0 - (durationMs - 1000) / 500) * 0.4;
        maxDecayRate = Math.min(decayStrength, 0.85);
      }

      const positionInWord = numChars > 1 ? charIndex / (numChars - 1) : 0;
      const decayFactor = 1.0 - positionInWord * maxDecayRate;
      const charProgress = easedProgress * decayFactor;

      const baseGrowth = numChars <= 3 ? 0.07 : 0.05;
      const charMaxScale = 1.0 + baseGrowth + charProgress * 0.1;
      const charShadowIntensity = 0.4 + charProgress * 0.4;
      const normalizedGrowth = (charMaxScale - 1.0) / 0.13;
      const charTranslateYPeak = -normalizedGrowth * 6;

      const position = (charIndex + 0.5) / numChars;
      const horizontalOffset = (position - 0.5) * 2 * ((charMaxScale - 1.0) * 25);

      return {
        charIndex,
        char,
        wipeStart: charStartPercent.toFixed(4),
        wipeDuration: (1 / text.length).toFixed(4),
        horizontalOffset: horizontalOffset.toFixed(2),
        maxScale: charMaxScale.toFixed(3),
        shadowDensity: charShadowIntensity.toFixed(3),
        charTranslateYPeak: charTranslateYPeak.toFixed(3),
      };
    });
  }
</script>

<p class="main-vocal-container">
  {#each wordGroups as group, i (i)}
    {@const isGrowable = groupGrowable[i]}
    {#if !(isGrowable && vwCharOffset[i] > 0)}
      <!-- Check if ANY syllable in group is line-synced  -->
      {@const groupLineSynced = group.some(s => s.lineSynced)}
      {@const wordText = vwFullText[i]}
      {@const wordDuration = vwFullDuration[i]}
      {@const startTimeMs = vwStartMs[i]}
      {@const endTimeMs = vwEndMs[i]}
      {#if isGrowable && wordText.length > 0}
        {@const animatedLyricNodes = calculateLyricAnimationDetails(
          wordDuration,
          wordText.length,
          i,
        )}
        <span class="lyrics-word growable">
          <span class="lyrics-syllable-wrap">
            <span
              class="lyrics-syllable {groupLineSynced ? 'line-synced' : ''}"
              data-start-time={startTimeMs}
              data-end-time={endTimeMs}
              data-duration={wordDuration}
              data-syllable-index="0"
              data-wipe-ratio="1"
            >
              {#each animatedLyricNodes as lyricNode, i (i)}
                {#if lyricNode}
                  {@const {
                    charIndex,
                    char,
                    wipeStart,
                    wipeDuration,
                    horizontalOffset,
                    maxScale,
                    shadowIntensity,
                    translateYPeak,
                  } = lyricNode}
                  <span
                    class="char"
                    data-char-index={charIndex}
                    data-syllable-char-index={charIndex}
                    data-wipe-start={wipeStart}
                    data-wipe-duration={wipeDuration}
                    data-horizontal-offset={horizontalOffset}
                    data-max-scale={maxScale}
                    data-shadow-intensity={shadowIntensity}
                    data-translate-y-peak={translateYPeak}
                  >
                    {char}
                  </span>
                {:else}
                  {" "}
                {/if}
              {/each}
            </span>
          </span>
        </span>
      {:else if group.length === 1}
        {@const syllable = group[0]}
        {@const startTimeMs = syllable.timestamp}
        {@const endTimeMs = syllable.endtime}
        {@const durationMs = endTimeMs - startTimeMs}
        {@const text = syllable.text || ""}
        {@const glowableLyricAnimationDetails = calculateGlowableLyricAnimationDetails(
          text,
          durationMs,
        )}

        <span class="lyrics-word {isGrowable ? 'growable' : ''}">
          <span class="lyrics-syllable-wrap">
            <span
              class="lyrics-syllable {syllable.lineSynced ? 'line-synced' : ''}"
              data-start-time={startTimeMs}
              data-end-time={endTimeMs}
              data-duration={durationMs}
              data-syllable-index="0"
              data-wipe-ratio="1"
            >
              {#each glowableLyricAnimationDetails as animationDetail, i (i)}
                {#if animationDetail}
                  {@const {
                    charIndex,
                    char,
                    charTranslateYPeak,
                    horizontalOffset,
                    maxScale,
                    shadowDensity,
                    wipeDuration,
                    wipeStart,
                  } = animationDetail}
                  <span
                    class="char"
                    data-char-index={charIndex}
                    data-syllable-char-index={charIndex}
                    data-wipe-start={wipeStart}
                    data-wipe-duration={wipeDuration}
                    data-horizontal-offset={horizontalOffset}
                    data-max-scale={maxScale}
                    data-shadow-intensity={shadowDensity}
                    data-translate-y-peak={charTranslateYPeak}
                  >
                    {char}
                  </span>
                {:else}
                  {" "}
                {/if}
              {/each}
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
        </span>
      {:else}
        <!-- Multi-syllable group (part=true): render all syllables inside one lyrics-word -->
        <span class="lyrics-word {isGrowable ? 'growable' : ''} allow-break">
          {#each group as syllable, i (i)}
            <span class="lyrics-syllable-wrap">
              <span
                class="lyrics-syllable {groupLineSynced ? 'line-synced' : ''}"
                data-start-time={syllable.timestamp}
                data-end-time={syllable.endtime}
                data-duration={syllable.endtime - syllable.timestamp}
                data-syllable-index={i}
                data-wipe-ratio="1"
              >
                {syllable.text}
              </span>
              {#if showRomanization && syllable.romanizedText && syllable.romanizedText.trim() !== syllable.text.trim()}
                <span
                  class="lyrics-syllable transliteration {groupLineSynced ? 'line-synced' : ''}"
                  data-start-time={syllable.timestamp}
                  data-end-time={syllable.endtime}
                  data-duration={syllable.endtime - syllable.timestamp}
                  data-syllable-index="0"
                  data-wipe-ratio="1"
                >
                  {syllable.romanizedText}
                </span>
              {/if}
            </span>
          {/each}
        </span>
      {/if}
    {/if}
  {/each}
</p>
