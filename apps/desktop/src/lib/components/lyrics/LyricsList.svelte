<script lang="ts">
  // See https://github.com/binimum/apple-music-web-components/blob/main/src/AmLyrics.ts
  // All sub-components have also been sourced from apple-music-web-components.
  /* eslint-disable svelte/prefer-svelte-reactivity */

  import { INSTRUMENTAL_THRESHOLD_MS } from "$lib/constants/lyrics";
  import {
    lyricsSchema,
    romanizedLyricsSchema,
    translatedLyricsSchema,
    type LyricsLine,
  } from "$lib/schemas/lyric";
  import { musicPlayer } from "$lib/stream-player/musicPlayer";
  import { arraysEqual } from "$lib/utils/arrays";
  import { punctuatify } from "$lib/utils/format";
  import { backendClient, reportErrorToBackend } from "$lib/utils/query-client";

  import LyricsContent from "./LyricsContent.svelte";

  let lyricsContainer: HTMLDivElement;

  let showRomanization = $state(false);
  let showTranslation = $state(false);
  let isLoading = $state(false);
  let isUserScrolling = $state(false);

  let lyrics = $state<LyricsLine[] | null>(null);
  let lyricsSource = $state<string | null>(null);

  let isProgrammaticScroll = false;
  let isClickSeeking = false;

  // Syllable animation tracking
  let lastInstrumentalIndex: number | null = null;

  // Active line tracking
  let activeLineIds = new Set<string>();
  let currentPrimaryActiveLine: HTMLElement | null = null;
  let lastPrimaryActiveLine: HTMLElement | null = null;

  let scrollAnimationState: {
    isAnimating: boolean;
    pendingUpdate: number | null;
  } | null = null;
  let animationFrameId: number | null = null;
  let userScrollTimeoutId: number | null = null;
  let animatingLines: HTMLElement[] = [];
  let scrollUnlockTimeout: number | null = null;
  let scrollAnimationTimeout: number | null = null;
  let clickSeekTimeout: number | null = null;

  let activeLineIndices: number[] = [];
  let activeMainWordIndices = new Map<number, number>();
  let activeBackgroundWordIndices = new Map<number, number>();
  let mainWordProgress = new Map<number, number>();
  let backgroundWordProgress = new Map<number, number>();
  let mainWordAnimations = new Map<number, { startTime: number; duration: number }>();
  let backgroundWordAnimations = new Map<number, { startTime: number; duration: number }>();

  let textWidthCanvas: HTMLCanvasElement | undefined;
  let textWidthCtx: CanvasRenderingContext2D | null | undefined;

  function getTextWidth(text: string, font: string): number {
    if (!textWidthCanvas) {
      textWidthCanvas = document.createElement("canvas");
      textWidthCtx = textWidthCanvas.getContext("2d", { willReadFrequently: true });
    }
    if (textWidthCtx) {
      textWidthCtx.font = font;
      return textWidthCtx.measureText(text).width;
    }
    return 0;
  }

  function updateCharTimingData() {
    if (!lyricsContainer) return;

    const referenceSyllable = lyricsContainer.querySelector(".lyrics-syllable");
    if (!referenceSyllable) return;

    const computedStyle = getComputedStyle(referenceSyllable);
    const { font } = computedStyle;
    const fontSize = parseFloat(computedStyle.fontSize);

    const growableWords = lyricsContainer.querySelectorAll(".lyrics-word.growable");

    growableWords.forEach(wordSpan => {
      const syllableWraps = wordSpan.querySelectorAll(".lyrics-syllable-wrap");

      const syllables: HTMLElement[] = [];
      syllableWraps.forEach(wrap => {
        const syl = wrap.querySelector(".lyrics-syllable");
        if (syl) syllables.push(syl as HTMLElement);
      });

      syllables.forEach(sylSpan => {
        const charSpans = sylSpan.querySelectorAll(".char");
        if (charSpans.length === 0) return;

        const chars = Array.from(charSpans).map(span => span.textContent || "");
        const charWidths = chars.map(c => getTextWidth(c, font));
        const totalSyllableWidth = charWidths.reduce((a, b) => a + b, 0);

        const duration = parseFloat((sylSpan as HTMLElement).dataset.duration || "0");
        const velocityPxPerMs = duration > 0 ? totalSyllableWidth / duration : 0;

        const gradientWidthPx = 0.375 * fontSize;
        const gradientDurationMs = velocityPxPerMs > 0 ? gradientWidthPx / velocityPxPerMs : 100;

        let cumulativeCharWidth = 0;

        charSpans.forEach((span, i: number) => {
          const charWidth = charWidths[i];
          if (totalSyllableWidth > 0) {
            const startPercent = cumulativeCharWidth / totalSyllableWidth;
            const durationPercent = charWidth / totalSyllableWidth;

            // @ts-expect-error data-* properties
            span.dataset.wipeStart = startPercent.toFixed(4);
            // @ts-expect-error data-* properties
            span.dataset.wipeDuration = durationPercent.toFixed(4);
            // @ts-expect-error data-* properties
            span.dataset.preWipeArrival = (duration * startPercent).toFixed(2);
            // @ts-expect-error data-* properties
            span.dataset.preWipeDuration = gradientDurationMs.toFixed(2);
          }
          cumulativeCharWidth += charWidth;
        });
      });
    });
  }

  async function toggleRomanization() {
    showRomanization = !showRomanization;
    await applyRomanization();
  }

  async function applyRomanization() {
    if (showRomanization && lyrics) {
      const needsRomanization = lyrics.some(
        l => !l.romanizedText && (!l.text || !l.text.some(s => s.romanizedText)),
      );

      if (needsRomanization) {
        isLoading = true;
        try {
          const { romanizedLines } = await backendClient(
            "/lyrics/romanize",
            romanizedLyricsSchema,
            {
              method: "POST",
              body: { lyrics },
            },
          );
          lyrics = romanizedLines;
        } catch (error) {
          reportErrorToBackend({
            error,
            source: "LyricsList.applyRomanization",
          });
        } finally {
          isLoading = false;
        }
      }
    }
  }

  async function toggleTranslation() {
    showTranslation = !showTranslation;
    await applyTranslation();
  }

  async function applyTranslation() {
    if (showTranslation && lyrics) {
      const needsTranslation = lyrics.some(l => !l.translation);
      if (needsTranslation) {
        isLoading = true;
        try {
          // Prepare batch: extract text from all lines
          const textToTranslate = lyrics.map(line => {
            if (line.translation) return "";
            return (line.text ?? []).map(s => s.text).join("");
          });

          // If all are empty, skip
          if (textToTranslate.every(t => !t)) {
            isLoading = false;
            return;
          }

          const { translations } = await backendClient(
            "/lyrics/translate",
            translatedLyricsSchema,
            {
              method: "POST",
              body: {
                textToTranslate,
                language: "en",
              },
            },
          );

          const newLyrics = lyrics.map((line, index) => {
            if (line.translation) return line;
            return {
              ...line,
              translation: translations[index] || undefined,
            };
          });

          lyrics = newLyrics;
        } catch (error) {
          reportErrorToBackend({
            error,
            source: "LyricsList.applyTranslation",
          });
        } finally {
          isLoading = false;
        }
      }
    }
  }

  async function fetchLyrics() {
    isLoading = true;
    lyrics = null;
    lyricsSource = null;

    if (!musicPlayer.queue.playingNow) return;
    const { title, artists, album, duration, videoId } = musicPlayer.queue.playingNow;

    try {
      const lyricsResponse = await backendClient(`/lyrics/${videoId}`, lyricsSchema, {
        searchParams: {
          title,
          artist: punctuatify(artists.map(artist => artist.title)),
          album: album?.title,
          durationMs: Number(duration) * 1000,
        },
      });

      lyrics = lyricsResponse.lines;
      lyricsSource = lyricsResponse.source;

      await onLyricsLoaded();
    } catch {
      lyrics = null;
      lyricsSource = null;
    } finally {
      isLoading = false;
    }
  }

  async function onLyricsLoaded() {
    activeLineIndices = [];
    activeMainWordIndices.clear();
    activeBackgroundWordIndices.clear();
    mainWordProgress.clear();
    backgroundWordProgress.clear();
    mainWordAnimations.clear();
    backgroundWordAnimations.clear();

    if (lyricsContainer) {
      isProgrammaticScroll = true;
      lyricsContainer.scrollTop = 0;
      window.setTimeout(() => {
        isProgrammaticScroll = false;
      }, 100);
    }

    await autoProcessLyrics();
  }

  function setupAnimations() {
    if (activeLineIndices.length === 0 || !lyrics) {
      mainWordAnimations.clear();
      backgroundWordAnimations.clear();
      return;
    }

    for (const lineIndex of activeLineIndices) {
      const line = lyrics[lineIndex];
      const mainWordIndex = activeMainWordIndices.get(lineIndex) ?? -1;
      const backgroundWordIndex = activeBackgroundWordIndices.get(lineIndex) ?? -1;

      // Main word animation
      if (mainWordIndex !== -1) {
        const word = (line.text ?? [])[mainWordIndex];
        const wordDuration = word.endtime - word.timestamp;
        const elapsedInWord = musicPlayer.currentTime - word.timestamp;
        mainWordAnimations.set(lineIndex, {
          startTime: performance.now() - elapsedInWord,
          duration: wordDuration,
        });
      } else {
        mainWordAnimations.set(lineIndex, { startTime: 0, duration: 0 });
      }

      // Background word animation
      if (backgroundWordIndex !== -1 && line.backgroundText) {
        const word = line.backgroundText[backgroundWordIndex];
        const wordDuration = word.endtime - word.timestamp;
        const elapsedInWord = musicPlayer.currentTime - word.timestamp;
        backgroundWordAnimations.set(lineIndex, {
          startTime: performance.now() - elapsedInWord,
          duration: wordDuration,
        });
      } else {
        backgroundWordAnimations.set(lineIndex, {
          startTime: 0,
          duration: 0,
        });
      }
    }
  }

  async function autoProcessLyrics() {
    if (showRomanization) {
      await applyRomanization();
    }
    if (showTranslation) {
      await applyTranslation();
    }
  }

  function findActiveLineIndices(time: number) {
    if (!lyrics) return [];
    const activeLines: number[] = [];

    for (let i = 0; i < lyrics.length; i += 1) {
      const line = lyrics[i];

      let effectiveEndTime = line.endtime;

      // Extend the "active" highlight window to abut the next line,
      // leaving a 500ms gap for breathing/scrolling
      if (i < lyrics.length - 1) {
        const nextLineStart = lyrics[i + 1].timestamp;
        const gapDuration = nextLineStart - line.endtime;

        // If the gap is large enough to trigger the breathing dots,
        // DO NOT extend the highlight. The text should dim when the dots appear.
        if (gapDuration < INSTRUMENTAL_THRESHOLD_MS) {
          if (effectiveEndTime < nextLineStart) {
            effectiveEndTime = Math.max(effectiveEndTime, nextLineStart - 500);
          }
        }
      }

      if (time >= line.timestamp && time <= effectiveEndTime) {
        activeLines.push(i);
      }
    }

    return activeLines;
  }

  function startAnimationFromTime(time: number) {
    if (animationFrameId) {
      cancelAnimationFrame(animationFrameId);
      animationFrameId = null;
    }

    if (!lyrics) return;

    const foundActiveLineIndices = findActiveLineIndices(time);
    if (!arraysEqual(activeLineIndices, foundActiveLineIndices)) {
      activeLineIndices = foundActiveLineIndices;
    }

    // Clear previous state
    activeMainWordIndices.clear();
    activeBackgroundWordIndices.clear();
    mainWordAnimations.clear();
    backgroundWordAnimations.clear();
    mainWordProgress.clear();
    backgroundWordProgress.clear();

    if (activeLineIndices.length === 0) {
      return;
    }

    // Set up animations for each active line
    for (const lineIndex of activeLineIndices) {
      const line = lyrics[lineIndex];

      // Find main word based on the reset time
      let mainWordIdx = -1;
      for (let i = 0; i < (line.text ?? []).length; i += 1) {
        if (time >= (line.text ?? [])[i].timestamp && time <= (line.text ?? [])[i].endtime) {
          mainWordIdx = i;
          break;
        }
      }
      activeMainWordIndices.set(lineIndex, mainWordIdx);

      // Find background word based on the reset time
      let backWordIdx = -1;
      if (line.backgroundText) {
        for (let i = 0; i < line.backgroundText.length; i += 1) {
          if (time >= line.backgroundText[i].timestamp && time <= line.backgroundText[i].endtime) {
            backWordIdx = i;
            break;
          }
        }
      }
      activeBackgroundWordIndices.set(lineIndex, backWordIdx);
    }

    // With the state correctly set, configure the animation parameters
    setupAnimations();
    // Start the animation loop
    animateProgress();
  }

  function animateProgress() {
    const now = performance.now();
    let running = false;

    if (!lyrics || activeLineIndices.length === 0) {
      if (animationFrameId) {
        cancelAnimationFrame(animationFrameId);
        animationFrameId = null;
      }
      return;
    }

    // Process each active line
    for (const lineIndex of activeLineIndices) {
      const line = lyrics[lineIndex];
      const mainWordAnimation = mainWordAnimations.get(lineIndex);

      // Main text animation
      if (mainWordAnimation && mainWordAnimation.duration > 0) {
        const elapsed = now - mainWordAnimation.startTime;
        if (elapsed >= 0) {
          const progress = Math.min(1, elapsed / mainWordAnimation.duration);
          mainWordProgress.set(lineIndex, progress);

          if (progress < 1) {
            running = true;
          } else {
            // Word animation finished. Look for the next word in the same line.
            const currentMainWordIndex = activeMainWordIndices.get(lineIndex) ?? -1;
            const nextWordIndex = currentMainWordIndex + 1;
            if (currentMainWordIndex !== -1 && nextWordIndex < (line.text ?? []).length) {
              const currentWord = (line.text ?? [])[currentMainWordIndex];
              const nextWord = (line.text ?? [])[nextWordIndex];

              activeMainWordIndices.set(lineIndex, nextWordIndex);
              const gap = nextWord.timestamp - currentWord.endtime;
              const nextWordDuration = nextWord.endtime - nextWord.timestamp;

              mainWordAnimations.set(lineIndex, {
                startTime: performance.now() + gap,
                duration: nextWordDuration,
              });
              running = true;
            } else {
              mainWordAnimations.set(lineIndex, {
                startTime: 0,
                duration: 0,
              });
            }
          }
        } else {
          // Waiting in a gap
          mainWordProgress.set(lineIndex, 0);
          running = true;
        }
      }

      // Background text animation
      const backgroundWordAnimation = backgroundWordAnimations.get(lineIndex);
      if (backgroundWordAnimation && backgroundWordAnimation.duration > 0) {
        const elapsed = now - backgroundWordAnimation.startTime;
        if (elapsed >= 0) {
          const progress = Math.min(1, elapsed / backgroundWordAnimation.duration);
          backgroundWordProgress.set(lineIndex, progress);

          if (progress < 1) {
            running = true;
          } else {
            // Word animation finished. Look for the next word in the same line.
            const currentBackgroundWordIndex = activeBackgroundWordIndices.get(lineIndex) ?? -1;
            if (
              line.backgroundText &&
              currentBackgroundWordIndex !== -1 &&
              currentBackgroundWordIndex < line.backgroundText.length - 1
            ) {
              const nextWordIndex = currentBackgroundWordIndex + 1;
              const currentWord = line.backgroundText[currentBackgroundWordIndex];
              const nextWord = line.backgroundText[nextWordIndex];

              activeBackgroundWordIndices.set(lineIndex, nextWordIndex);
              const gap = nextWord.timestamp - currentWord.endtime;
              const nextWordDuration = nextWord.endtime - nextWord.timestamp;

              backgroundWordAnimations.set(lineIndex, {
                startTime: performance.now() + gap,
                duration: nextWordDuration,
              });
              running = true;
            } else {
              backgroundWordAnimations.set(lineIndex, {
                startTime: 0,
                duration: 0,
              });
            }
          }
        } else {
          // Waiting in a gap
          backgroundWordProgress.set(lineIndex, 0);
          running = true;
        }
      }
    }

    if (running) {
      animationFrameId = requestAnimationFrame(animateProgress);
    } else if (animationFrameId) {
      // Stop animation if no words are running
      cancelAnimationFrame(animationFrameId);
      animationFrameId = null;
    }
  }

  function resetSyllables(line: HTMLElement) {
    if (!line) return;
    // @ts-expect-error Extra metadata.
    line._cachedSyllableElements = null;
    Array.from(line.getElementsByClassName("lyrics-syllable")).forEach(syllable =>
      resetSyllable(syllable as HTMLElement),
    );
  }

  function resetSyllable(syllable: HTMLElement) {
    if (!syllable) return;
    syllable.style.animation = "";
    syllable.style.removeProperty("--pre-wipe-duration");
    syllable.style.removeProperty("--pre-wipe-delay");
    // Force background to secondary and disable transition to prevent lingering white
    syllable.style.transition = "none";
    syllable.style.backgroundColor = "var(--lyplus-text-secondary)";

    // Reset character animations — disable transition so finished chars don't slowly fade
    syllable.querySelectorAll("span.char").forEach(span => {
      const el = span as HTMLElement;
      el.style.animation = "";
      el.style.transition = "none";
      el.style.backgroundColor = "var(--lyplus-text-secondary)";
    });

    // Immediately remove all state classes
    syllable.classList.remove("highlight", "finished", "pre-highlight", "cleanup");

    // In next frame, clear inline styles so CSS transitions can resume for future use
    requestAnimationFrame(() => {
      syllable.style.removeProperty("background-color");
      syllable.style.removeProperty("transition");
      syllable.querySelectorAll("span.char").forEach(span => {
        const el = span as HTMLElement;
        el.style.removeProperty("background-color");
        el.style.removeProperty("transition");
      });
    });
  }

  function onTimeChanged(oldTime: number, newTime: number) {
    const timeDiff = Math.abs(newTime - oldTime);

    const newActiveLines = findActiveLineIndices(newTime);
    const oldActiveLines = activeLineIndices;

    // Reset animation if active lines change or if we skip time.
    // A threshold of 0.5s (500ms) is used to detect a "skip".
    const linesChanged = !arraysEqual(newActiveLines, oldActiveLines);

    if (linesChanged || timeDiff > 0.5) {
      // Imperatively manage 'active' class so that scroll-animate and other
      // imperative classes are never clobbered.
      // Remove 'active' from lines that are no longer active
      for (const lineIndex of oldActiveLines) {
        if (!newActiveLines.includes(lineIndex)) {
          const lineElement = lyricsContainer.querySelector(
            `#lyrics-line-${lineIndex}`,
          ) as HTMLElement;
          if (lineElement) {
            lineElement.classList.remove("active");
            resetSyllables(lineElement);
          }
        }
      }
      // Add 'active' to newly active lines
      for (const lineIndex of newActiveLines) {
        if (!oldActiveLines.includes(lineIndex)) {
          const lineElement = lyricsContainer.querySelector(
            `#lyrics-line-${lineIndex}`,
          ) as HTMLElement;
          if (lineElement) {
            lineElement.classList.add("active");
            lineElement.classList.remove("pre-active"); // Cleanup pre-active when fully active
          }
        }
      }
    }
    startAnimationFromTime(newTime);

    // Update position classes BEFORE scrolling so currentPrimaryActiveLine is current
    if (activeLineIndices.length > 0) {
      const primaryLineIndex = activeLineIndices[0];
      const primaryLine = lyricsContainer.querySelector(
        `#lyrics-line-${primaryLineIndex}`,
      ) as HTMLElement;

      if (primaryLine && primaryLine !== currentPrimaryActiveLine) {
        lastPrimaryActiveLine = currentPrimaryActiveLine;
        currentPrimaryActiveLine = primaryLine;
        updatePositionClasses(primaryLine);
      }

      // Trigger scroll imperatively (was previously in updated() via @state)
      handleActiveLineScroll(oldActiveLines);
    }

    function handleActiveLineScroll(oldActiveIndices: number[]): void {
      if (isUserScrolling || isClickSeeking || activeLineIndices.length === 0) {
        return;
      }

      // Determine what changed: did we gain new lines or just lose old ones?
      const newlyAdded = activeLineIndices.filter(idx => !oldActiveIndices.includes(idx));

      if (newlyAdded.length === 0) {
        // Only lost lines (an overlap resolved) — don't scroll
        return;
      }

      // New lines were added — scroll to the latest newly-added line.
      // Previous overlap logic skipped every other line for songs with tiny
      // timing overlaps between consecutive lines, causing a visible glitch.
      const latestNewIndex = newlyAdded[newlyAdded.length - 1];
      const targetLine = lyricsContainer?.querySelector(
        `#lyrics-line-${latestNewIndex}`,
      ) as HTMLElement;

      if (targetLine) {
        scrollToActiveLineYouLy(targetLine);
      } else if (currentPrimaryActiveLine) {
        scrollToActiveLineYouLy(currentPrimaryActiveLine);
      } else {
        scrollToActiveLine();
      }
    }

    function scrollToActiveLine() {
      if (activeLineIndices.length === 0) {
        return;
      }

      // Scroll to the first active line
      const firstActiveLineIndex = Math.min(...activeLineIndices);
      const activeLineElement = lyricsContainer.querySelector(
        `.lyrics-line:nth-child(${firstActiveLineIndex + 1})`,
      ) as HTMLElement;

      if (activeLineElement) {
        const containerHeight = lyricsContainer.clientHeight;
        const lineTop = activeLineElement.offsetTop;
        const lineHeight = activeLineElement.clientHeight;

        // Check if the line has background text placed before the main text
        const hasBackgroundBefore = activeLineElement.querySelector(".background-text.before");

        // Calculate the offset to center the main text content, accounting for background text placement
        let offsetAdjustment = 0;
        if (hasBackgroundBefore) {
          const backgroundElement = hasBackgroundBefore as HTMLElement;
          offsetAdjustment = backgroundElement.clientHeight / 2; // Adjust to focus on main content
        }

        const top = lineTop - containerHeight / 2 + lineHeight / 2 - offsetAdjustment;

        // Use requestAnimationFrame for smoother iOS performance
        requestAnimationFrame(() => {
          isProgrammaticScroll = true;
          lyricsContainer?.scrollTo({ top, behavior: "smooth" });
          // Reset the flag after a short delay to allow the scroll to complete
          setTimeout(() => {
            isProgrammaticScroll = false;
          }, 100);
        });
      }
    }

    function updatePositionClasses(lineToScroll: HTMLElement): void {
      const positionClasses = [
        "lyrics-activest",
        "post-active-line",
        "next-active-line",
        "prev-1",
        "prev-2",
        "prev-3",
        "prev-4",
        "next-1",
        "next-2",
        "next-3",
        "next-4",
      ];

      // Remove old position classes
      lyricsContainer
        .querySelectorAll(`.${positionClasses.join(", .")}`)
        .forEach(el => el.classList.remove(...positionClasses));

      // Add new position classes
      lineToScroll.classList.add("lyrics-activest");

      const lineElements = Array.from(
        lyricsContainer.querySelectorAll(".lyrics-line"),
      ) as HTMLElement[];
      const scrollLineIndex = lineElements.indexOf(lineToScroll);

      for (
        let i = Math.max(0, scrollLineIndex - 4);
        i <= Math.min(lineElements.length - 1, scrollLineIndex + 4);
        i += 1
      ) {
        const position = i - scrollLineIndex;
        if (position !== 0) {
          const element = lineElements[i];
          if (position === -1) element.classList.add("post-active-line");
          else if (position === 1) element.classList.add("next-active-line");
          else if (position < 0) element.classList.add(`prev-${Math.abs(position)}`);
          else element.classList.add(`next-${position}`);
        }
      }
    }

    // YouLyPlus-style syllable animation updates
    // Update syllables in active lines
    for (const lineIndex of activeLineIndices) {
      const lineElement = lyricsContainer.querySelector(`#lyrics-line-${lineIndex}`) as HTMLElement;
      if (lineElement) {
        updateSyllablesForLine(lineElement, newTime);
      }
    }

    // Also update syllables in active gap lines (breathing dots)
    const activeGaps = lyricsContainer.querySelectorAll(".lyrics-gap.active");
    activeGaps.forEach(gapLine => {
      updateSyllablesForLine(gapLine as HTMLElement, newTime);
    });

    // Imperatively manage gap active state (template doesn't re-render on time changes)
    const allGaps = lyricsContainer.querySelectorAll(".lyrics-gap");
    allGaps.forEach(gap => {
      const gapStartTime = parseFloat(gap.getAttribute("data-start-time") || "0");
      const gapEndTime = parseFloat(gap.getAttribute("data-end-time") || "0");
      const shouldBeActive = newTime >= gapStartTime && newTime < gapEndTime;
      const isActive = gap.classList.contains("active");
      const isExiting = gap.classList.contains("gap-exiting");
      // Start exit animation early so it completes before the next lyric
      const exitLeadMs = 600;
      const shouldStartExiting = isActive && !isExiting && newTime >= gapEndTime - exitLeadMs;

      if (shouldBeActive && !isActive && !isExiting) {
        // Entering gap: remove any leftover exit state, add active
        gap.classList.remove("gap-exiting");
        gap.classList.add("active");
        // Mark any dots whose time has already passed as finished
        // (prevents skipping the first dot when lyrics load mid-gap)
        const dotSyllables = gap.querySelectorAll(".lyrics-syllable");
        dotSyllables.forEach(dot => {
          const dotEnd = parseFloat(dot.getAttribute("data-end-time") || "0");
          if (newTime > dotEnd) {
            dot.classList.add("finished");
          }
        });
      } else if (shouldStartExiting) {
        // Exiting gap: keep visible while dots animate out
        gap.classList.add("gap-exiting");
        gap.classList.remove("active");
        // After exit animation completes, remove gap-exiting to collapse
        setTimeout(() => {
          gap.classList.remove("gap-exiting");
        }, 800);
      } else if (isActive && !shouldBeActive) {
        // NEW: Immediate cleanup if we seeked out of valid range
        gap.classList.remove("active");
        gap.classList.remove("gap-exiting");
      } else if (isExiting && newTime < gapEndTime - exitLeadMs) {
        // NEW: Cleanup exiting state if we seeked backwards before exit window
        gap.classList.remove("gap-exiting");
      }
    });

    // Track instrumental gap state
    const currentGap = findInstrumentalGapAt(newTime);
    if (currentGap) {
      lastInstrumentalIndex = currentGap.insertBeforeIndex;
    } else if (lastInstrumentalIndex !== null) {
      lastInstrumentalIndex = null;
    }

    // Update position classes for YouLyPlus blur/opacity effect
    // (only needed when lines didn't change — when they DID change,
    // position classes are already updated above before scrolling)
    if (!linesChanged && activeLineIndices.length > 0) {
      const primaryLineIndex = activeLineIndices[0];
      const primaryLine = lyricsContainer.querySelector(
        `#lyrics-line-${primaryLineIndex}`,
      ) as HTMLElement;

      if (primaryLine && primaryLine !== currentPrimaryActiveLine) {
        lastPrimaryActiveLine = currentPrimaryActiveLine;
        currentPrimaryActiveLine = primaryLine;
        updatePositionClasses(primaryLine);
      }

      // Pre-scroll: scroll to upcoming line ~0.5s before it starts
      if (!isUserScrolling && !isClickSeeking && lyrics) {
        const preScrollLeadMs = 500; // 500ms lead time

        // Condition: ONLY pre-scroll if no other lyric is currently playing.
        // If a lyric is playing, we must wait for it to finish (handled by updated()).
        if (activeLineIndices.length === 0) {
          for (let i = 0; i < lyrics.length; i += 1) {
            const line = lyrics[i];
            const timeUntilStart = line.timestamp - newTime;

            const nextLineEl = lyricsContainer.querySelector(`#lyrics-line-${i}`) as HTMLElement;

            if (timeUntilStart > 0 && timeUntilStart <= preScrollLeadMs) {
              // Time to pre-scroll and pre-activate!
              if (nextLineEl) {
                // Apply unblur & zoom effect ahead of lyric start
                nextLineEl.classList.add("pre-active");

                // Only trigger scroll if we aren't already targeting this line
                if (nextLineEl !== currentPrimaryActiveLine) {
                  scrollToActiveLineYouLy(nextLineEl);
                }
              }
              break;
            } else if (nextLineEl) {
              // Ensure lines outside the pre-scroll window don't stay pre-active
              nextLineEl.classList.remove("pre-active");
            }
          }
        }
      }
    }
  }

  function scrollToActiveLineYouLy(activeLine: HTMLElement, forceScroll = false): void {
    if (!activeLine || !lyricsContainer) return;

    const paddingTop = getScrollPaddingTop();
    const targetTranslateY = paddingTop - activeLine.offsetTop;

    const scrollContainerTop = lyricsContainer.getBoundingClientRect().top;

    // Skip if already at target position
    if (
      !forceScroll &&
      Math.abs(activeLine.getBoundingClientRect().top - scrollContainerTop - paddingTop) < 1
    ) {
      return;
    }

    // Skip scroll if near the bottom of content (prevents footer jitter)
    if (!forceScroll) {
      const parent = lyricsContainer;
      const atBottom = parent.scrollTop + parent.clientHeight >= parent.scrollHeight - 50;
      if (atBottom) {
        return;
      }
    }

    lyricsContainer.classList.remove("not-focused", "user-scrolling");
    isProgrammaticScroll = true;
    isUserScrolling = false;

    if (userScrollTimeoutId) {
      clearTimeout(userScrollTimeoutId);
      userScrollTimeoutId = null;
    }

    setTimeout(() => {
      isProgrammaticScroll = false;
    }, 600);

    animateScrollYouLy(targetTranslateY, forceScroll);
  }

  function animateScrollYouLy(newTranslateY: number, forceScroll = false): void {
    if (!lyricsContainer) return;
    const parent = lyricsContainer;

    if (!scrollAnimationState) {
      scrollAnimationState = {
        isAnimating: false,
        pendingUpdate: null,
      };
      animatingLines = [];
    }

    const animState = scrollAnimationState;

    if (animState.isAnimating && !forceScroll) {
      animState.pendingUpdate = newTranslateY;
      return;
    }

    if (scrollUnlockTimeout) {
      clearTimeout(scrollUnlockTimeout);
      scrollUnlockTimeout = null;
    }

    if (scrollAnimationTimeout) {
      clearTimeout(scrollAnimationTimeout);
      scrollAnimationTimeout = null;
    }

    const targetTop = Math.max(0, -newTranslateY);
    // Always use actual scroll position - don't fall back to stale currentScrollOffset
    // The || operator treats 0 as falsy, which caused bounce when scrollTop was 0
    const prevOffset = -parent.scrollTop;
    const delta = prevOffset - newTranslateY;

    // Skip animation if already at the target position (e.g., first lines at top)
    if (Math.abs(parent.scrollTop - targetTop) < 1 && Math.abs(delta) < 1) {
      animState.isAnimating = false;
      animState.pendingUpdate = null;
      return;
    }

    if (forceScroll) {
      // Clean up any lingering scroll animations before smooth scroll
      for (const line of animatingLines) {
        line.classList.remove("scroll-animate");
        line.style.removeProperty("--scroll-delta");
        line.style.removeProperty("--lyrics-line-delay");
      }
      animatingLines.length = 0;
      parent.scrollTo({ top: targetTop, behavior: "smooth" });
      animState.isAnimating = false;
      animState.pendingUpdate = null;
      return;
    }

    // --- Step 1: Remove scroll-animate from ALL previously animating lines ---
    for (const line of animatingLines) {
      line.classList.remove("scroll-animate");
    }
    animatingLines.length = 0;

    // Get lines for staggered animation
    const lineElements = lyricsContainer.querySelectorAll(".lyrics-line");
    const lineArray = Array.from(lineElements) as HTMLElement[];

    const referenceLine = currentPrimaryActiveLine || lastPrimaryActiveLine || lineArray[0];

    if (!referenceLine) return;

    const referenceIndex = lineArray.indexOf(referenceLine);
    if (referenceIndex === -1) return;

    const delayIncrement = 30;
    const lookBehind = 10;
    const lookAhead = 15;
    const len = lineArray.length;

    const start = Math.max(0, referenceIndex - lookBehind);
    const end = Math.min(len, referenceIndex + lookAhead);

    let maxAnimationDuration = 0;
    let delayCounter = 0;

    // --- Step 2: Set CSS custom properties on target lines ---
    const newAnimatingLines: HTMLElement[] = [];

    for (let i = start; i < end; i += 1) {
      const line = lineArray[i];
      if (i >= referenceIndex) delayCounter += 1;
      const delay = i >= referenceIndex ? (delayCounter - 1) * delayIncrement : 0;

      line.style.setProperty("--scroll-delta", `${delta}px`);
      line.style.setProperty("--lyrics-line-delay", `${delay}ms`);

      newAnimatingLines.push(line);

      const lineDuration = 400 + delay;
      if (lineDuration > maxAnimationDuration) {
        maxAnimationDuration = lineDuration;
      }
    }

    // --- Step 3: Force reflow so the browser sees the class removal ---
    // This guarantees the animation restarts reliably, unlike the
    // CSS-variable-toggle approach which doesn't restart in all browsers.
    parent.getBoundingClientRect(); // force synchronous reflow

    // --- Step 4: Re-add scroll-animate class to start fresh animations ---
    for (const line of newAnimatingLines) {
      line.classList.add("scroll-animate");
      animatingLines.push(line);
    }

    animState.isAnimating = true;
    const BASE_DURATION = 400;

    scrollUnlockTimeout = setTimeout(() => {
      animState.isAnimating = false;

      if (animState.pendingUpdate !== null) {
        const pendingValue = animState.pendingUpdate;
        animState.pendingUpdate = null;
        animateScrollYouLy(pendingValue, false);
      }
    }, BASE_DURATION);

    scrollAnimationTimeout = setTimeout(() => {
      for (let i = 0; i < animatingLines.length; i += 1) {
        const line = animatingLines[i];
        line.classList.remove("scroll-animate");
        line.style.removeProperty("--scroll-delta");
        line.style.removeProperty("--lyrics-line-delay");
      }
      animatingLines.length = 0;
      scrollAnimationTimeout = null;
    }, maxAnimationDuration + 50);

    parent.scrollTo({ top: targetTop, behavior: "instant" });
  }

  function updateSyllablesForLine(line: HTMLElement, currentTimeMs: number): void {
    // @ts-expect-error Custom metadata
    let syllables: HTMLElement[] = line._cachedSyllableElements;
    if (!syllables) {
      syllables = Array.from(line.querySelectorAll(".lyrics-syllable")) as HTMLElement[];

      // @ts-expect-error Custom metadata
      line._cachedSyllableElements = syllables;
    }

    for (let i = 0; i < syllables.length; i += 1) {
      const syllable = syllables[i];
      const startTime = parseFloat(syllable.getAttribute("data-start-time") || "0");
      const endTime = parseFloat(syllable.getAttribute("data-end-time") || "0");

      if (startTime) {
        const { classList } = syllable;
        const hasHighlight = classList.contains("highlight");
        const hasFinished = classList.contains("finished");
        const hasPreHighlight = classList.contains("pre-highlight");
        const hasActiveState = hasHighlight || hasFinished || hasPreHighlight;

        // Early exit check
        if (!(currentTimeMs < startTime - 1000 && !hasActiveState)) {
          let preHighlightReset = false;

          // Pre-highlight reset logic
          if (hasPreHighlight && i > 0) {
            const prevSyllable = syllables[i - 1];
            if (!prevSyllable.classList.contains("highlight")) {
              classList.remove("pre-highlight");
              syllable.style.removeProperty("--pre-wipe-duration");
              syllable.style.removeProperty("--pre-wipe-delay");
              syllable.style.animation = "";
              preHighlightReset = true;
            }
          }

          if (!preHighlightReset) {
            if (currentTimeMs >= startTime && currentTimeMs <= endTime) {
              // Currently active
              if (!hasHighlight) {
                updateSyllableAnimation(syllable);
              }
              if (hasFinished) {
                classList.remove("finished");
              }
            } else if (currentTimeMs > endTime) {
              // Finished
              if (!hasFinished) {
                if (!hasHighlight) {
                  updateSyllableAnimation(syllable);
                }
                classList.add("finished");
              }
            } else if (hasHighlight || hasFinished) {
              // Not yet started
              resetSyllable(syllable);
            }
          }
        }
      }
    }
  }

  function findInstrumentalGapAt(
    time: number,
  ): { insertBeforeIndex: number; gapStart: number; gapEnd: number } | null {
    if (!lyrics || lyrics.length === 0) return null;

    // Start-of-song gap: from 0 to first line timestamp
    const first = lyrics[0];
    if (time >= 0 && time < first.timestamp) {
      const gapStart = 0;
      const gapEnd = first.timestamp;
      if (gapEnd - gapStart >= INSTRUMENTAL_THRESHOLD_MS) {
        return { insertBeforeIndex: 0, gapStart, gapEnd };
      }
      return null;
    }

    // Find consecutive pair (i, i+1) that bounds the current time
    for (let i = 0; i < lyrics.length - 1; i += 1) {
      const curr = lyrics[i];
      const next = lyrics[i + 1];
      const gapStart = curr.endtime;
      const gapEnd = next.timestamp;
      if (time > gapStart && time < gapEnd) {
        if (gapEnd - gapStart >= INSTRUMENTAL_THRESHOLD_MS) {
          return { insertBeforeIndex: i + 1, gapStart, gapEnd };
        }
        return null;
      }
    }

    return null;
  }

  function updateSyllableAnimation(syllable: HTMLElement): void {
    if (syllable.classList.contains("highlight")) return;

    const { classList } = syllable;
    const isRTL = classList.contains("rtl-text");
    const charSpans = Array.from(syllable.querySelectorAll("span.char")) as HTMLElement[];
    const wordElement = syllable.parentElement?.parentElement; // syllable-wrap -> word
    const allWordCharSpans = wordElement
      ? (Array.from(wordElement.querySelectorAll("span.char")) as HTMLElement[])
      : [];
    const isGrowable = wordElement?.classList.contains("growable");
    const isFirstSyllable = syllable.getAttribute("data-syllable-index") === "0";
    const isFirstInContainer = isFirstSyllable; // Simplified
    const isGap = syllable.closest(".lyrics-gap") !== null;

    // Get duration from data attribute
    const syllableDurationMs = parseFloat(syllable.getAttribute("data-duration") || "0") || 300;
    const wordDurationMs =
      parseFloat(
        syllable.getAttribute("data-word-duration") ||
          syllable.getAttribute("data-duration") ||
          "0",
      ) || syllableDurationMs;

    // Use a Map to collect animations like YouLyPlus
    const charAnimationsMap = new Map<HTMLElement, string>();
    const styleUpdates: Array<{
      element: HTMLElement;
      property: string;
      value: string;
    }> = [];

    // Step 1: Grow Pass - apply grow-dynamic to ALL word chars on first syllable
    if (isGrowable && isFirstSyllable && allWordCharSpans.length > 0) {
      const finalDuration = wordDurationMs;
      const baseDelayPerChar = finalDuration * 0.09;
      const growDurationMs = finalDuration * 1.5;

      allWordCharSpans.forEach(span => {
        const horizontalOffset = parseFloat(span.dataset.horizontalOffset || "0");
        // Use syllableCharIndex like YouLyPlus, not loop index
        const charIndex = parseFloat(span.dataset.syllableCharIndex || "0");
        const growDelay = baseDelayPerChar * charIndex;

        // READ DATA ATTRIBUTES for style values
        const maxScale = span.dataset.maxScale || "1.1";
        const shadowIntensity = span.dataset.shadowIntensity || "0.6";
        const translateYPeak = span.dataset.translateYPeak || "-2";

        charAnimationsMap.set(
          span,
          `grow-dynamic ${growDurationMs}ms ease-in-out ${growDelay}ms forwards`,
        );

        // Push style updates to be applied imperatively
        styleUpdates.push({
          element: span,
          property: "--char-offset-x",
          value: `${horizontalOffset}`, // Fixed: removed px suitable for matrix3d
        });
        styleUpdates.push({
          element: span,
          property: "--max-scale",
          value: maxScale,
        });
        styleUpdates.push({
          element: span,
          property: "--shadow-intensity",
          value: shadowIntensity,
        });
        styleUpdates.push({
          element: span,
          property: "--translate-y-peak",
          value: `${translateYPeak}`, // Fixed: removed % because matrix3d expects raw number
        });
      });
    }

    // Step 2: Wipe Pass
    if (charSpans.length > 0) {
      // Per-character wipe for growable words (matching YouLyPlus)
      charSpans.forEach((span, charIndex) => {
        const startPct = parseFloat(span.dataset.wipeStart || "0");
        const durationPct = parseFloat(span.dataset.wipeDuration || "0");

        const wipeDelay = syllableDurationMs * startPct;
        const wipeDuration = syllableDurationMs * durationPct;

        const useStartAnimation = isFirstInContainer && charIndex === 0;
        let charWipeAnimation: string;
        if (useStartAnimation) {
          charWipeAnimation = isRTL ? "start-wipe-rtl" : "start-wipe";
        } else {
          charWipeAnimation = isRTL ? "wipe-rtl" : "wipe";
        }

        // Get existing animation from map (grow-dynamic) and combine with wipe
        const existingAnimation = charAnimationsMap.get(span) || span.style.animation || "";
        const animationParts: string[] = [];

        if (existingAnimation && existingAnimation.includes("grow-dynamic")) {
          animationParts.push(existingAnimation.split(",")[0].trim());
        }

        if (wipeDuration > 0) {
          animationParts.push(
            `${charWipeAnimation} ${wipeDuration}ms linear ${wipeDelay}ms forwards`,
          );
        }

        charAnimationsMap.set(span, animationParts.join(", "));
      });
    } else {
      // Syllable-level wipe for regular (non-growable) words
      const wipeRatio = parseFloat(syllable.getAttribute("data-wipe-ratio") || "1");
      const visualDuration = syllableDurationMs * wipeRatio;

      let wipeAnimation: string;
      if (isFirstInContainer) {
        wipeAnimation = isRTL ? "start-wipe-rtl" : "start-wipe";
      } else {
        wipeAnimation = isRTL ? "wipe-rtl" : "wipe";
      }

      if (syllable.classList.contains("line-synced")) {
        // If line-synced, just add the class for CSS animation, or ensure valid state
        // The CSS rule .lyrics-syllable.line-synced handles the fade
        return;
      }

      const currentWipeAnimation = isGap ? "fade-gap" : wipeAnimation;
      const syllableAnimation = `${currentWipeAnimation} ${visualDuration}ms ${isGap ? "ease-out" : "linear"} forwards`;

      syllable.style.animation = syllableAnimation;
    }

    // --- WRITE PHASE ---
    classList.remove("pre-highlight");
    classList.add("highlight");

    for (const [span, animationString] of charAnimationsMap.entries()) {
      span.style.animation = animationString;
    }

    // Apply style updates
    for (const update of styleUpdates) {
      update.element.style.setProperty(update.property, update.value);
    }
  }

  function handleUserScroll() {
    // Ignore programmatic scrolls and click-seek scrolls
    if (isProgrammaticScroll || isClickSeeking) {
      return;
    }

    // Mark that user is currently scrolling
    isUserScrolling = true;
    lyricsContainer?.classList.add("user-scrolling");

    // Clear any existing timeout
    if (userScrollTimeoutId) {
      clearTimeout(userScrollTimeoutId);
    }

    // Set timeout to re-enable auto-scroll after 2 seconds of no scrolling
    userScrollTimeoutId = window.setTimeout(() => {
      isUserScrolling = false;
      userScrollTimeoutId = null;

      // Optionally scroll back to current active line when re-enabling auto-scroll
      if (activeLineIndices.length > 0) {
        scrollToActiveLine();
      }
    }, 2000);
  }

  function scrollToActiveLine() {
    if (!lyricsContainer || activeLineIndices.length === 0) {
      return;
    }

    // Scroll to the first active line
    const firstActiveLineIndex = Math.min(...activeLineIndices);
    const activeLineElement = lyricsContainer.querySelector(
      `.lyrics-line:nth-child(${firstActiveLineIndex + 1})`,
    ) as HTMLElement;

    if (activeLineElement) {
      const containerHeight = lyricsContainer.clientHeight;
      const lineTop = activeLineElement.offsetTop;
      const lineHeight = activeLineElement.clientHeight;

      // Check if the line has background text placed before the main text
      const hasBackgroundBefore = activeLineElement.querySelector(".background-text.before");

      // Calculate the offset to center the main text content, accounting for background text placement
      let offsetAdjustment = 0;
      if (hasBackgroundBefore) {
        const backgroundElement = hasBackgroundBefore as HTMLElement;
        offsetAdjustment = backgroundElement.clientHeight / 2; // Adjust to focus on main content
      }

      const top = lineTop - containerHeight / 2 + lineHeight / 2 - offsetAdjustment;

      // Use requestAnimationFrame for smoother iOS performance
      requestAnimationFrame(() => {
        isProgrammaticScroll = true;
        lyricsContainer?.scrollTo({ top, behavior: "smooth" });
        // Reset the flag after a short delay to allow the scroll to complete
        setTimeout(() => {
          isProgrammaticScroll = false;
        }, 100);
      });
    }
  }

  function getScrollPaddingTop() {
    if (!lyricsContainer) return 0;
    const style = getComputedStyle(lyricsContainer);
    const paddingTopValue = style.getPropertyValue("--lyrics-scroll-padding-top") || "25%";
    if (paddingTopValue.includes("%")) {
      return lyricsContainer.clientHeight * (parseFloat(paddingTopValue) / 100);
    }
    return parseFloat(paddingTopValue) || 0;
  }

  function handleLineClick(line: LyricsLine) {
    if (lyricsContainer) {
      const allLines = lyricsContainer.querySelectorAll(".lyrics-line");
      allLines.forEach(lineEl => {
        resetSyllables(lineEl as HTMLElement);
        lineEl.classList.remove("scroll-animate");
        (lineEl as HTMLElement).style.removeProperty("--scroll-delta");
        (lineEl as HTMLElement).style.removeProperty("--lyrics-line-delay");
      });
      lyricsContainer.classList.remove("wheel-scrolling");
    }
    if (scrollAnimationState) {
      scrollAnimationState.isAnimating = false;
      scrollAnimationState.pendingUpdate = null;
    }
    if (scrollUnlockTimeout) {
      clearTimeout(scrollUnlockTimeout);
      scrollUnlockTimeout = null;
    }
    if (scrollAnimationTimeout) {
      clearTimeout(scrollAnimationTimeout);
      scrollAnimationTimeout = null;
    }
    if (userScrollTimeoutId) {
      clearTimeout(userScrollTimeoutId);
      userScrollTimeoutId = null;
    }
    isUserScrolling = false;
    currentPrimaryActiveLine = null;
    lastPrimaryActiveLine = null;
    activeLineIds.clear();
    animatingLines = [];
    const clickedLineElement = lyricsContainer?.querySelector(
      `.lyrics-line[data-start-time="${line.timestamp * 1000}"]`,
    ) as HTMLElement | null;
    if (clickedLineElement && lyricsContainer) {
      currentPrimaryActiveLine = clickedLineElement;
      isClickSeeking = true;
      if (clickSeekTimeout) clearTimeout(clickSeekTimeout);
      clickSeekTimeout = setTimeout(() => {
        isClickSeeking = false;
      }, 800);
      scrollToActiveLineYouLy(clickedLineElement, true);
    }
    musicPlayer.seek(line.timestamp / 1000);
  }

  const sourceLabel = $derived(lyricsSource ?? "Unavailable");
  const isUnsynced = $derived(
    lyrics && lyrics.length > 0 ? lyrics.every(l => l.timestamp === 0 && l.endtime === 0) : false,
  );

  $effect(() => {
    lyricsContainer.addEventListener("wheel", handleUserScroll, {
      passive: true,
    });
    lyricsContainer.addEventListener("touchmove", handleUserScroll, {
      passive: true,
    });

    return () => {
      lyricsContainer.removeEventListener("wheel", handleUserScroll);
      lyricsContainer.removeEventListener("touchmove", handleUserScroll);
    };
  });

  $effect(() => {
    fetchLyrics();
    return () => {
      if (animationFrameId) {
        cancelAnimationFrame(animationFrameId);
      }
      if (userScrollTimeoutId) {
        clearTimeout(userScrollTimeoutId);
      }
    };
  });

  $effect(() => {
    updateCharTimingData();

    // Apply 'active' classes imperatively after lyrics first render,
    // since the template no longer binds the 'active' class (to avoid
    // clobbering imperative scroll-animate classes on re-render).
    if (lyricsContainer && lyrics) {
      const activeLines = findActiveLineIndices(musicPlayer.currentTime * 1000);
      for (const lineIndex of activeLines) {
        const lineEl = lyricsContainer.querySelector(`#lyrics-line-${lineIndex}`) as HTMLElement;
        if (lineEl) lineEl.classList.add("active");
      }
    }
  });

  let lastTime = 0;

  $effect(() => {
    const currentTime = musicPlayer.currentTime * 1000;
    onTimeChanged(lastTime, currentTime);
    lastTime = currentTime;
  });
</script>

<div
  bind:this={lyricsContainer}
  class="lyrics-container {isUnsynced ? 'is-unsynced' : 'blur-inactive-enabled'} {isUserScrolling
    ? 'user-scrolling'
    : ''}"
>
  {#if !isLoading && lyrics && lyrics.length > 0}
    <div class="lyrics-header">
      <div class="header-controls">
        <button
          class="download-button {showRomanization ? 'active' : ''}"
          onclick={toggleRomanization}
          title="Toggle Romanization"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="16"
            height="16"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
            class="lucide lucide-speech-icon lucide-speech"
          >
            <path
              d="M8.8 20v-4.1l1.9.2a2.3 2.3 0 0 0 2.164-2.1V8.3A5.37 5.37 0 0 0 2 8.25c0 2.8.656 3.054 1 4.55a5.77 5.77 0 0 1 .029 2.758L2 20"
            />
            <path d="M19.8 17.8a7.5 7.5 0 0 0 .003-10.603" />
            <path d="M17 15a3.5 3.5 0 0 0-.025-4.975" />
          </svg>
        </button>
        <button
          class="download-button {showTranslation ? 'active' : ''}"
          onclick={toggleTranslation}
          title="Toggle Translation"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="16"
            height="16"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
            class="lucide lucide-languages-icon lucide-languages"
          >
            <path d="m5 8 6 6" />
            <path d="m4 14 6-6 2-3" />
            <path d="M2 5h12" />
            <path d="M7 2h1" />
            <path d="m22 22-5-10-5 10" />
            <path d="M14 18h6" />
          </svg>
        </button>
      </div>
    </div>
  {/if}
  <LyricsContent
    {lyrics}
    {isLoading}
    {showRomanization}
    {showTranslation}
    onLineClick={handleLineClick}
  />
  {#if !isLoading}
    <footer class="lyrics-footer">
      <div class="footer-content">
        <span class="source-info" style="display: flex; align-items: center; gap: 8px;">
          Source: {sourceLabel}
        </span>
      </div>
    </footer>
  {/if}
</div>
