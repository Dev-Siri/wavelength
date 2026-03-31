const INSTRUMENTAL_THRESHOLD_MS = 7000; // Show dots for gaps >= 7s

export class AmLyrics extends LitElement {
  @property({ type: String })
  query?: string;

  @property({ type: String })
  musicId?: string;

  @property({ type: String })
  isrc?: string;

  @property({ type: String, attribute: "song-title" })
  songTitle?: string;

  @property({ type: String, attribute: "song-artist" })
  songArtist?: string;

  @property({ type: String, attribute: "song-album" })
  songAlbum?: string;

  @property({ type: Boolean })
  autoScroll = true;

  @property({ type: Boolean })
  interpolate = true;

  private async toggleTranslation() {
    this.showTranslation = !this.showTranslation;
    await this.applyTranslation();
  }

  private async applyTranslation() {
    if (this.showTranslation && this.lyrics) {
      const needsTranslation = this.lyrics.some((l) => !l.translation);
      if (needsTranslation) {
        this.isLoading = true;
        try {
          // Prepare batch: extract text from all lines
          const textToTranslate = this.lyrics.map((line) => {
            if (line.translation) return "";
            return line.text.map((s) => s.text).join("");
          });

          // If all are empty, skip
          if (textToTranslate.every((t) => !t)) {
            this.isLoading = false;
            return;
          }

          const result = await GoogleService.translate(textToTranslate, "en");
          const translations = Array.isArray(result) ? result : [result];

          const newLyrics = this.lyrics.map((line, index) => {
            if (line.translation) return line;
            return {
              ...line,
              translation: translations[index] || undefined,
            };
          });

          this.lyrics = newLyrics;
        } catch (e) {
          // eslint-disable-next-line no-console
          console.error("Translation failed", e);
        } finally {
          this.isLoading = false;
        }
      }
    }
  }

  @property({ type: Number })
  duration?: number;

  private _currentTime = 0;

  @property({ type: Number, attribute: "currenttime", hasChanged: () => false })
  set currentTime(value: number) {
    const oldValue = this._currentTime;
    this._currentTime = value;
    if (oldValue !== value && this.lyrics) {
      this._onTimeChanged(oldValue, value);
    }
  }

  get currentTime(): number {
    return this._currentTime;
  }

  @state()
  private availableSources: { lines: LyricsLine[]; source: string }[] = [];

  private animationFrameId?: number;

  private mainWordAnimations: Map<
    number,
    { startTime: number; duration: number }
  > = new Map();

  private backgroundWordAnimations: Map<
    number,
    { startTime: number; duration: number }
  > = new Map();

  @query(".lyrics-container")
  private lyricsContainer?: HTMLElement;

  private lastInstrumentalIndex: number | null = null;

  private userScrollTimeoutId?: number;

  private clickSeekTimeout?: ReturnType<typeof setTimeout>;

  // Cached DOM elements for animation updates
  private cachedLyricsLines: HTMLElement[] = [];

  // Scroll animation state
  private scrollAnimationState: {
    isAnimating: boolean;
    pendingUpdate: number | null;
  } | null = null;

  private currentScrollOffset = 0;

  private animatingLines: HTMLElement[] = [];

  private scrollUnlockTimeout?: ReturnType<typeof setTimeout>;

  private scrollAnimationTimeout?: ReturnType<typeof setTimeout>;

  connectedCallback() {
    super.connectedCallback();
    this.fetchLyrics();
  }

  disconnectedCallback() {
    super.disconnectedCallback();
    if (this.animationFrameId) {
      cancelAnimationFrame(this.animationFrameId);
    }
    if (this.userScrollTimeoutId) {
      clearTimeout(this.userScrollTimeoutId);
    }
  }

  private async fetchLyrics() {
    this.isLoading = true;
    this.lyrics = undefined;
    this.lyricsSource = null;
    this.availableSources = [];
    this.currentSourceIndex = 0;
    this.isFetchingAlternatives = false;
    this.hasFetchedAllProviders = false;
    try {
      const resolvedMetadata = await this.resolveSongMetadata();

      const isMusicIdOnlyRequest =
        Boolean(this.musicId) &&
        !this.songTitle &&
        !this.songArtist &&
        !this.query;

      if (resolvedMetadata?.metadata && !isMusicIdOnlyRequest) {
        const title = resolvedMetadata.metadata.title?.trim() || "";
        const artist = resolvedMetadata.metadata.artist?.trim() || "";

        const youLyResults = await AmLyrics.fetchLyricsFromYouLyPlus(
          title,
          artist,
          resolvedMetadata.metadata,
        );

        if (youLyResults && youLyResults.length > 0) {
          collectedSources.push(...youLyResults);
        }
      }

      if (collectedSources.length === 0 && resolvedMetadata?.metadata) {
        const tidalResult = await AmLyrics.fetchLyricsFromTidal(
          resolvedMetadata.metadata,
          resolvedMetadata.catalogIsrc,
        );
        if (tidalResult && tidalResult.lines.length > 0) {
          collectedSources.push({
            lines: tidalResult.lines,
            source: "Tidal",
          });
        }
      }

      // Fallback: LRCLIB
      if (collectedSources.length === 0 && resolvedMetadata?.metadata) {
        const lrclibResult = await AmLyrics.fetchLyricsFromLrclib(
          resolvedMetadata.metadata,
        );
        if (lrclibResult && lrclibResult.lines.length > 0) {
          collectedSources.push({
            lines: lrclibResult.lines,
            source: "LRCLIB",
          });
        }
      }

      if (collectedSources.length === 0 && resolvedMetadata?.metadata) {
        const geniusResult = await AmLyrics.fetchLyricsFromGenius(
          resolvedMetadata.metadata,
        );
        if (geniusResult && geniusResult.lines.length > 0) {
          collectedSources.push({
            lines: geniusResult.lines,
            source: "Genius",
          });
        }
      }

      this.hasFetchedAllProviders =
        collectedSources.length === 0 ||
        collectedSources.some(
          (s) =>
            s.source === "LRCLIB" ||
            s.source === "Tidal" ||
            s.source === "Genius",
        );

      if (collectedSources.length > 0) {
        this.availableSources = AmLyrics.mergeAndSortSources(collectedSources);

        this.currentSourceIndex = 0;
        this.lyrics = this.availableSources[0].lines;
        this.lyricsSource = this.availableSources[0].source;
        await this.onLyricsLoaded();
        return;
      }

      this.lyrics = undefined;
      this.lyricsSource = null;
    } finally {
      this.isLoading = false;
    }
  }

  private async onLyricsLoaded() {
    this.activeLineIndices = [];
    this.activeMainWordIndices.clear();
    this.activeBackgroundWordIndices.clear();
    this.mainWordProgress.clear();
    this.backgroundWordProgress.clear();
    this.mainWordAnimations.clear();
    this.backgroundWordAnimations.clear();

    if (this.lyricsContainer) {
      this.isProgrammaticScroll = true;
      this.lyricsContainer.scrollTop = 0;
      window.setTimeout(() => {
        this.isProgrammaticScroll = false;
      }, 100);
    }

    await this.autoProcessLyrics();
  }

  private async autoProcessLyrics() {
    if (this.showRomanization) {
      await this.applyRomanization();
    }
    if (this.showTranslation) {
      await this.applyTranslation();
    }
  }

  private static getRankForCollected(
    sourceLabel: string,
    parsedLines: any[],
  ): number {
    const lower = sourceLabel.toLowerCase();
    const hasWordSync = parsedLines.some(
      (line: any) =>
        line.text && Array.isArray(line.text) && line.text.length > 1,
    );
    const isUnsynced =
      parsedLines.length > 0 &&
      parsedLines.every(
        (line: any) => line.timestamp === 0 && line.endtime === 0,
      );
    const isQQ = lower.includes("qq") || lower.includes("lyricsplus");

    if (lower.includes("apple") && hasWordSync) return 1;
    if (isQQ && hasWordSync) return 2;
    if (lower.includes("musixmatch") && hasWordSync) return 3;
    if (lower.includes("tidal") && hasWordSync) return 4;
    if (lower.includes("lrclib") && hasWordSync) return 5;

    if (lower.includes("apple") && !hasWordSync && !isUnsynced) return 6;
    if (isQQ && !hasWordSync && !isUnsynced) return 7;
    if (lower.includes("musixmatch") && !hasWordSync && !isUnsynced) return 8;
    if (lower.includes("tidal") && !hasWordSync && !isUnsynced) return 9;
    if (lower.includes("lrclib") && !hasWordSync && !isUnsynced) return 10;

    if (lower.includes("apple") && isUnsynced) return 11;
    if (isQQ && isUnsynced) return 12;
    if (lower.includes("musixmatch") && isUnsynced) return 13;
    if (lower.includes("tidal") && isUnsynced) return 14;
    if (lower.includes("lrclib") && isUnsynced) return 15;
    if (lower.includes("genius")) return 16;

    return 20;
  }

  private static mergeAndSortSources(
    collectedSources: { lines: LyricsLine[]; source: string }[],
  ): { lines: LyricsLine[]; source: string }[] {
    const uniqueSourcesMap = new Map<
      string,
      { lines: LyricsLine[]; source: string }
    >();

    for (const source of collectedSources) {
      const normalizedSource = source.source
        .toLowerCase()
        .includes("lyricsplus")
        ? "QQ"
        : source.source;

      if (!uniqueSourcesMap.has(normalizedSource)) {
        uniqueSourcesMap.set(normalizedSource, {
          ...source,
          source: normalizedSource,
        });
      }
    }

    return Array.from(uniqueSourcesMap.values()).sort(
      (a, b) =>
        AmLyrics.getRankForCollected(a.source, a.lines) -
        AmLyrics.getRankForCollected(b.source, b.lines),
    );
  }

  private static async fetchLyricsFromYouLyPlus(
    title: string,
    artist: string,
    metadata: { durationMs?: number; album?: string } = {},
  ): Promise<YouLyPlusLyricsResult[]> {
    if (!title || !artist) return [];

    const params = new URLSearchParams({ title, artist });

    if (metadata.album) {
      params.append("album", metadata.album);
    }

    if (metadata.durationMs && metadata.durationMs > 0) {
      params.append(
        "duration",
        Math.round(metadata.durationMs / 1000).toString(),
      );
    }

    params.append("source", DEFAULT_KPOE_SOURCE_ORDER);

    const getRank = (sourceLabel: string, parsedLines: any[]): number => {
      const lower = sourceLabel.toLowerCase();
      const hasWordSync = parsedLines.some(
        (line: any) =>
          line.text && Array.isArray(line.text) && line.text.length > 1,
      );

      const isUnsynced =
        parsedLines.length > 0 &&
        parsedLines.every(
          (line: any) => line.timestamp === 0 && line.endtime === 0,
        );

      const isQQ = lower.includes("qq") || lower.includes("lyricsplus");

      if (lower.includes("apple") && hasWordSync) return 1;
      if (isQQ && hasWordSync) return 2;
      if (lower.includes("musixmatch") && hasWordSync) return 3;

      if (lower.includes("apple") && !hasWordSync && !isUnsynced) return 4;
      if (isQQ && !hasWordSync && !isUnsynced) return 5;
      if (lower.includes("musixmatch") && !hasWordSync && !isUnsynced) return 6;

      if (lower.includes("apple") && isUnsynced) return 7;
      if (isQQ && isUnsynced) return 8;
      if (lower.includes("musixmatch") && isUnsynced) return 9;

      return 10;
    };

    const allResults: YouLyPlusLyricsResult[] = [];

    // Try cache API first
    try {
      const cacheParams = new URLSearchParams({
        track: title,
        artist,
      });
      if (metadata.album) {
        cacheParams.append("album", metadata.album);
      }
      if (metadata.durationMs && metadata.durationMs > 0) {
        cacheParams.append(
          "duration",
          Math.round(metadata.durationMs / 1000).toString(),
        );
      }

      const cacheUrl = `https://lyrics-api.binimum.org/?${cacheParams.toString()}`;
      const cacheRes = await fetch(cacheUrl);
      if (cacheRes.ok) {
        const cacheData = await cacheRes.json();
        if (cacheData.results && cacheData.results.length > 0) {
          const result = cacheData.results[0];
          if (result.timing_type === "word" && result.lyricsUrl) {
            const ttmlRes = await fetch(result.lyricsUrl);
            if (ttmlRes.ok) {
              const ttmlText = await ttmlRes.text();
              const lines = AmLyrics.parseTTML(ttmlText);
              if (lines && lines.length > 0) {
                allResults.push({ lines, source: "BiniLyrics" });
                return allResults;
              }
            }
          } else {
            // Not word type, try QQ
            const qqParams = new URLSearchParams(params);
            qqParams.set("source", "qq");
            const qqUrl = `https://lyricsplus.binimum.org/v2/lyrics/get?${qqParams.toString()}`;
            try {
              const qqRes = await fetch(qqUrl);
              if (qqRes.ok) {
                const payload = await qqRes.json();
                const lines = AmLyrics.convertKPoeLyrics(payload);
                const hasWordSync = lines?.some(
                  (line: any) =>
                    line.text &&
                    Array.isArray(line.text) &&
                    line.text.length > 1,
                );
                if (lines && lines.length > 0 && hasWordSync) {
                  allResults.push({ lines, source: "QQ" });
                  return allResults;
                }
              }
            } catch (qqError) {
              // Ignore QQ fetch error
            }

            // If QQ fails or has no word sync, fall back to bini lyrics
            if (result.lyricsUrl) {
              const ttmlRes = await fetch(result.lyricsUrl);
              if (ttmlRes.ok) {
                const ttmlText = await ttmlRes.text();
                const lines = AmLyrics.parseTTML(ttmlText);
                if (lines && lines.length > 0) {
                  allResults.push({
                    lines,
                    source: "BiniLyrics",
                  });
                  return allResults;
                }
              }
            }
          }
        }
      }
    } catch (e) {
      // eslint-disable-next-line no-console
      console.error("Cache API failed", e);
    }

    // Shuffle servers so we pick a random one first, with all others as fallback
    // Limit to 2 servers to prevent unnecessary API spam when Apple lyrics are missing
    const shuffledServers = [...KPOE_SERVERS]
      .sort(() => Math.random() - 0.5)
      .slice(0, 2);

    for (const base of shuffledServers) {
      const normalizedBase = base.endsWith("/") ? base.slice(0, -1) : base;
      const url = `${normalizedBase}/v2/lyrics/get?${params.toString()}`;

      let payload: any = null;

      try {
        // eslint-disable-next-line no-await-in-loop
        const response = await fetch(url);
        if (response.ok) {
          // eslint-disable-next-line no-await-in-loop
          payload = await response.json();
        }
      } catch (error) {
        payload = null;
      }

      if (payload) {
        const lines = AmLyrics.convertKPoeLyrics(payload);
        if (lines && lines.length > 0) {
          const sourceLabel =
            payload?.metadata?.source ||
            payload?.metadata?.provider ||
            "LyricsPlus (KPoe)";

          const rank = getRank(sourceLabel, lines);
          const result = { lines, source: sourceLabel };

          allResults.push(result);

          // If source is Apple synced, we have the best so we can just immediately break the sweep
          if (rank === 1) {
            break;
          }
        }
      }
    }

    // If we haven't found a completely synced Apple/QQ result (rank 1 or 2) among the servers,
    // force an explicit query against lyricsplus.binimum.org looking for QQ
    const hasHighRankResult = allResults.some(
      (r) => getRank(r.source, r.lines) <= 2,
    );

    if (!hasHighRankResult) {
      try {
        const qqParams = new URLSearchParams(params);
        qqParams.set("source", "qq");
        const url = `https://lyricsplus.binimum.org/v2/lyrics/get?${qqParams.toString()}`;
        const response = await fetch(url);
        if (response.ok) {
          const payload = await response.json();
          if (payload) {
            const lines = AmLyrics.convertKPoeLyrics(payload);
            const sourceLabel =
              payload?.metadata?.source ||
              payload?.metadata?.provider ||
              "LyricsPlus (KPoe)";
            if (lines && lines.length > 0) {
              allResults.push({ lines, source: sourceLabel });
            }
          }
        }
      } catch (error) {
        // Explicit QQ fallback failed, ignore
      }
    }

    return allResults;
  }

  /**
   * Parse LRC subtitle format into LyricsLine[].
   * Handles "[mm:ss.xx] text" lines.
   */
  private static parseLrcSubtitles(lrc: string): LyricsLine[] {
    if (!lrc || typeof lrc !== "string") return [];

    const lines: LyricsLine[] = [];
    const rawLines = lrc.split("\n");
    const parsed: { timestamp: number; text: string }[] = [];

    for (const raw of rawLines) {
      const match = raw.match(/^\[(\d{1,3}):(\d{2})\.(\d{2,3})\]\s?(.*)$/);
      if (!match) {
        // Skip non-timestamped lines (headers like [ti:], [ar:], etc.)
        // eslint-disable-next-line no-continue
        // eslint-disable-next-line no-continue
        continue;
      }
      const minutes = parseInt(match[1], 10);
      const seconds = parseInt(match[2], 10);
      let centiseconds = parseInt(match[3], 10);
      // Handle both mm:ss.xx (centiseconds) and mm:ss.xxx (milliseconds)
      if (match[3].length === 3) {
        centiseconds = Math.round(centiseconds / 10);
      }
      const timestamp = (minutes * 60 + seconds) * 1000 + centiseconds * 10;
      const text = match[4] || "";
      parsed.push({ timestamp, text });
    }

    for (let i = 0; i < parsed.length; i += 1) {
      const { timestamp, text } = parsed[i];
      // Endtime is the start of the next line, or timestamp + 5s for the last line
      const endtime =
        i + 1 < parsed.length ? parsed[i + 1].timestamp : timestamp + 5000;

      // Skip empty lines (instrumental gaps)
      if (!text.trim()) {
        // eslint-disable-next-line no-continue
        // eslint-disable-next-line no-continue
        continue;
      }

      const syllable: Syllable = {
        text,
        part: false,
        timestamp,
        endtime,
        lineSynced: true,
      };

      lines.push({
        text: [syllable],
        background: false,
        backgroundText: [],
        oppositeTurn: false,
        timestamp,
        endtime,
        isWordSynced: false,
      });
    }

    return lines;
  }

  /**
   * Fetch lyrics from Tidal API.
   * Picks 2 random servers, tries search + lyrics on each.
   */
  private static async fetchLyricsFromTidal(
    metadata: SongMetadata,
    isrc?: string,
  ): Promise<YouLyPlusLyricsResult | null> {
    const title = metadata.title?.trim();
    const artist = metadata.artist?.trim();

    if (!title || !artist) return null;

    // Pick 2 random unique servers
    const shuffled = [...TIDAL_SERVERS].sort(() => Math.random() - 0.5);
    const serversToTry = shuffled.slice(0, 2);

    for (const base of serversToTry) {
      try {
        const normalizedBase = base.endsWith("/") ? base.slice(0, -1) : base;

        // Step 1: Search for the track
        const searchQuery = `${title} ${artist}`;
        const searchParams = new URLSearchParams({ s: searchQuery });
        // eslint-disable-next-line no-await-in-loop
        const searchResponse = await fetch(
          `${normalizedBase}/search/?${searchParams.toString()}`,
        );

        if (!searchResponse.ok) {
          // eslint-disable-next-line no-continue
          // eslint-disable-next-line no-continue
          continue;
        }

        // eslint-disable-next-line no-await-in-loop
        const searchData = await searchResponse.json();
        const items = searchData?.data?.items;

        if (!Array.isArray(items) || items.length === 0) {
          // eslint-disable-next-line no-continue
          // eslint-disable-next-line no-continue
          continue;
        }

        // Find best match: prefer ISRC match, then first result
        let bestTrack = items[0];
        if (isrc) {
          const isrcMatch = items.find(
            (item: any) =>
              item.isrc && item.isrc.toLowerCase() === isrc.toLowerCase(),
          );
          if (isrcMatch) {
            bestTrack = isrcMatch;
          }
        }

        const trackId = bestTrack?.id;
        if (!trackId) {
          // eslint-disable-next-line no-continue
          // eslint-disable-next-line no-continue
          continue;
        }

        // Step 2: Fetch lyrics
        // eslint-disable-next-line no-await-in-loop
        const lyricsResponse = await fetch(
          `${normalizedBase}/lyrics/?id=${trackId}`,
        );

        if (!lyricsResponse.ok) {
          // eslint-disable-next-line no-continue
          // eslint-disable-next-line no-continue
          continue;
        }

        // eslint-disable-next-line no-await-in-loop
        const lyricsData = await lyricsResponse.json();
        const subtitles = lyricsData?.lyrics?.subtitles;

        if (subtitles && typeof subtitles === "string") {
          const lines = AmLyrics.parseLrcSubtitles(subtitles);
          if (lines.length > 0) {
            const provider = lyricsData?.lyrics?.lyricsProvider || "Tidal";
            return {
              lines,
              source: `Tidal (${provider})`,
            };
          }
        }
      } catch {
        // Try next server
      }
    }

    return null;
  }

  /**
   * Fetch lyrics from LRCLIB.
   * Uses search endpoint, prefers synced lyrics.
   */
  private static async fetchLyricsFromLrclib(
    metadata: SongMetadata,
  ): Promise<YouLyPlusLyricsResult | null> {
    const title = metadata.title?.trim();
    const artist = metadata.artist?.trim();

    if (!title || !artist) return null;

    try {
      const searchQuery = `${artist} ${title}`;
      const params = new URLSearchParams({ q: searchQuery });
      const response = await fetch(
        `https://lrclib.net/api/search?${params.toString()}`,
        {
          headers: {
            "User-Agent": `apple-music-web-components/${VERSION}`,
          },
        },
      );

      if (!response.ok) return null;

      const results = await response.json();
      if (!Array.isArray(results) || results.length === 0) return null;

      // Prefer results with synced lyrics
      const withSynced = results.find(
        (r: any) => r.syncedLyrics && typeof r.syncedLyrics === "string",
      );
      const bestMatch = withSynced || results[0];

      // Try synced lyrics first
      if (bestMatch.syncedLyrics) {
        const lines = AmLyrics.parseLrcSubtitles(bestMatch.syncedLyrics);
        if (lines.length > 0) {
          return { lines, source: "LRCLIB" };
        }
      }

      // Fall back to plain lyrics (unsynced)
      if (bestMatch.plainLyrics && typeof bestMatch.plainLyrics === "string") {
        const plainLines = bestMatch.plainLyrics
          .split("\n")
          .filter((l: string) => l.trim());
        if (plainLines.length > 0) {
          const lines: LyricsLine[] = plainLines.map(
            (text: string): LyricsLine => ({
              text: [
                {
                  text,
                  part: false,
                  timestamp: 0,
                  endtime: 0,
                },
              ],
              background: false,
              backgroundText: [],
              oppositeTurn: false,
              timestamp: 0,
              endtime: 0,
              isWordSynced: false,
            }),
          );
          return { lines, source: "LRCLIB (unsynced)" };
        }
      }
    } catch {
      // LRCLIB fetch failed
    }

    return null;
  }

  private static async fetchLyricsFromGenius(
    metadata: SongMetadata,
  ): Promise<YouLyPlusLyricsResult | null> {
    const title = metadata.title?.trim();
    const artist = metadata.artist?.trim();

    if (!title || !artist) return null;

    try {
      const params = new URLSearchParams({ title, artist });
      const response = await fetch(`${GENIUS_WORKER_URL}?${params.toString()}`);

      if (!response.ok) return null;
      const data = await response.json();

      if (data.lyrics) {
        const plainLines = data.lyrics
          .split("\n")
          .map((l: string) => l.trim())
          .filter((l: string) => l && !l.startsWith("["));

        if (plainLines.length > 0) {
          const lines: LyricsLine[] = plainLines.map(
            (text: string): LyricsLine => ({
              text: [
                {
                  text,
                  part: false,
                  timestamp: 0,
                  endtime: 0,
                },
              ],
              background: false,
              backgroundText: [],
              oppositeTurn: false,
              timestamp: 0,
              endtime: 0,
              isWordSynced: false,
            }),
          );
          return { lines, source: "Genius" };
        }
      }
    } catch {
      // eslint-disable-next-line no-console
      console.error("No Genius lyrics found");
    }

    return null;
  }

  private static calculateLineAlignments(
    lineSingers: (string | undefined)[],
    agentTypes: Record<string, string>,
  ): ("start" | "end" | undefined)[] {
    const lineSideAssignments = new Array(lineSingers.length).fill(undefined);
    let currentSideIsLeft = true;
    let lastPersonSingerId: string | null = null;
    let rightCount = 0;
    let totalCount = 0;

    lineSingers.forEach((singerId, index) => {
      let sideClass: "start" | "end" | undefined;

      if (singerId) {
        let type = agentTypes[singerId];
        if (!type) {
          if (singerId === "v1000") {
            type = "group";
          } else if (singerId === "v2000") {
            type = "other";
          } else {
            type = "person";
          }
        }

        if (type === "group") {
          sideClass = "start";
        } else {
          if (lastPersonSingerId === null) {
            if (type === "other") {
              currentSideIsLeft = false;
            } else {
              currentSideIsLeft = true;
            }
          } else if (singerId !== lastPersonSingerId) {
            currentSideIsLeft = !currentSideIsLeft;
          }

          sideClass = currentSideIsLeft ? "start" : "end";
          lastPersonSingerId = singerId;
        }
      }

      if (sideClass) {
        totalCount += 1;
        if (sideClass === "end") rightCount += 1;
      }

      lineSideAssignments[index] = sideClass;
    });

    if (totalCount > 0 && Math.round((rightCount / totalCount) * 100) >= 85) {
      const flip = (s: "start" | "end" | undefined) => {
        if (s === "start") return "end";
        if (s === "end") return "start";
        return s;
      };

      for (let i = 0; i < lineSideAssignments.length; i += 1) {
        lineSideAssignments[i] = flip(lineSideAssignments[i]);
      }
    }

    return lineSideAssignments;
  }

  private static parseTTML(ttmlString: string) {
    const parser = new DOMParser();
    const doc = parser.parseFromString(ttmlString, "text/xml");

    const translations: Record<string, string> = {};
    const transliterations: Record<string, string> = {};
    const agentMap: Record<string, string> = {};

    const agents = doc.getElementsByTagName("ttm:agent");
    for (let i = 0; i < agents.length; i += 1) {
      const agent = agents[i];
      const id = agent.getAttribute("xml:id");
      const type = agent.getAttribute("type");
      if (id && type) {
        agentMap[id] = type;
      }
    }

    const translationNodes = doc.getElementsByTagName("translation");
    for (let i = 0; i < translationNodes.length; i += 1) {
      const texts = translationNodes[i].getElementsByTagName("text");
      for (let j = 0; j < texts.length; j += 1) {
        const textNode = texts[j];
        const key = textNode.getAttribute("for");
        if (key && textNode.textContent) {
          translations[key] = textNode.textContent;
        }
      }
    }

    const transliterationNodes = doc.getElementsByTagName("transliteration");
    for (let i = 0; i < transliterationNodes.length; i += 1) {
      const texts = transliterationNodes[i].getElementsByTagName("text");
      for (let j = 0; j < texts.length; j += 1) {
        const textNode = texts[j];
        const key = textNode.getAttribute("for");
        if (key && textNode.textContent) {
          transliterations[key] = textNode.textContent
            .trim()
            .replace(/\s+/g, " ");
        }
      }
    }

    const lines: LyricsLine[] = [];
    const pNodes = doc.getElementsByTagName("p");

    const lineSingers: (string | undefined)[] = [];
    for (let i = 0; i < pNodes.length; i += 1) {
      lineSingers.push(pNodes[i].getAttribute("ttm:agent") || undefined);
    }
    const alignments = AmLyrics.calculateLineAlignments(lineSingers, agentMap);

    for (let i = 0; i < pNodes.length; i += 1) {
      const p = pNodes[i];
      const key = p.getAttribute("itunes:key");
      const beginMs = timeToMs(p.getAttribute("begin"));
      const endMs = timeToMs(p.getAttribute("end"));

      let songPart: string | undefined;
      if (p.parentNode && (p.parentNode as Element).tagName === "div") {
        songPart =
          (p.parentNode as Element).getAttribute("itunes:songPart") ||
          undefined;
      }

      const mainSyllables: Syllable[] = [];
      const bgSyllables: Syllable[] = [];

      const spans = p.getElementsByTagName("span");
      if (spans.length > 0) {
        for (let j = 0; j < spans.length; j += 1) {
          const span = spans[j];

          if (span.getAttribute("ttm:role") === "x-bg") {
            const bgInnerSpans = span.getElementsByTagName("span");
            for (let k = 0; k < bgInnerSpans.length; k += 1) {
              const bgSpan = bgInnerSpans[k];
              let bgText = bgSpan.textContent || "";
              const nextNode = bgSpan.nextSibling;
              if (
                nextNode &&
                nextNode.nodeType === 3 &&
                /^\s/.test(nextNode.textContent || "") &&
                !bgText.endsWith(" ")
              ) {
                bgText += " ";
              }
              bgSyllables.push({
                text: bgText,
                timestamp: timeToMs(bgSpan.getAttribute("begin")),
                endtime: timeToMs(bgSpan.getAttribute("end")),
                part: false,
              });
            }
            // eslint-disable-next-line no-continue
            continue;
          }

          if (
            span.parentNode &&
            (span.parentNode as Element).getAttribute?.("ttm:role") === "x-bg"
          ) {
            // eslint-disable-next-line no-continue
            continue;
          }

          let text = span.textContent || "";
          const nextNode = span.nextSibling;
          if (
            nextNode &&
            nextNode.nodeType === 3 &&
            /^\s/.test(nextNode.textContent || "") &&
            !text.endsWith(" ")
          ) {
            text += " ";
          }
          mainSyllables.push({
            text,
            timestamp: timeToMs(span.getAttribute("begin")),
            endtime: timeToMs(span.getAttribute("end")),
            part: false,
          });
        }
      } else {
        mainSyllables.push({
          text: p.textContent?.trim() || "",
          timestamp: beginMs,
          endtime: endMs,
          part: false,
          lineSynced: true,
        });
      }

      const alignment = alignments[i];

      lines.push({
        text: mainSyllables,
        background: bgSyllables.length > 0,
        backgroundText: bgSyllables,
        timestamp: beginMs,
        endtime: endMs,
        isWordSynced: spans.length > 0,
        alignment,
        songPart,
        translation: key ? translations[key] : undefined,
        romanizedText: key ? transliterations[key] : undefined,
        oppositeTurn: alignment === "end",
      });
    }

    return lines;
  }

  private static convertKPoeLyrics(payload: any): LyricsLine[] | null {
    if (!payload) {
      return null;
    }

    let rawLyrics: any[] | null = null;
    if (Array.isArray(payload?.lyrics)) {
      rawLyrics = payload.lyrics;
    } else if (Array.isArray(payload?.data?.lyrics)) {
      rawLyrics = payload.data.lyrics;
    } else if (Array.isArray(payload?.data)) {
      rawLyrics = payload.data;
    }

    if (!rawLyrics || rawLyrics.length === 0) {
      return null;
    }

    const sanitizedEntries = rawLyrics.filter((item: any) => Boolean(item));
    const lines: LyricsLine[] = [];

    // If type is 'Line', we revert to line-by-line highlighting by skipping syllabus parsing
    const isLineType = payload.type === "Line" || payload.type === "line";

    // Convert metadata.agents to type map
    const agentTypes: Record<string, string> = {};
    if (payload.metadata?.agents) {
      Object.entries(payload.metadata.agents).forEach(
        ([key, agent]: [string, any]) => {
          const mappedKey = agent.alias || key;
          agentTypes[mappedKey] = agent.type;
        },
      );
    }

    const lineSingers = sanitizedEntries.map(
      (entry: any) => entry.element?.singer,
    );
    const alignments = AmLyrics.calculateLineAlignments(
      lineSingers,
      agentTypes,
    );

    for (let i = 0; i < sanitizedEntries.length; i += 1) {
      const entry = sanitizedEntries[i];
      const start = AmLyrics.toMilliseconds(entry.time);
      const duration = AmLyrics.toMilliseconds(entry.duration);

      const alignment = alignments[i];
      const lineText = typeof entry.text === "string" ? entry.text : "";
      const lineStart = AmLyrics.toMilliseconds(entry.time);
      const lineDuration = AmLyrics.toMilliseconds(entry.duration);
      const explicitEnd = AmLyrics.toMilliseconds(entry.endTime);
      const lineEnd = explicitEnd || lineStart + (lineDuration || 0);

      const syllabus = Array.isArray(entry.syllabus)
        ? entry.syllabus.filter((s: any) => Boolean(s))
        : [];
      const mainSyllables: Syllable[] = [];
      const backgroundSyllables: Syllable[] = [];

      if (!isLineType && syllabus.length > 0) {
        for (const syl of syllabus) {
          const sylStart = AmLyrics.toMilliseconds(syl.time, lineStart);
          const sylDuration = AmLyrics.toMilliseconds(syl.duration);

          // If there's only 1 syllable and duration is 0, it's likely a line-synced fallback.
          // Otherwise, it's an instantaneous boundary (like a space or comma) and should not span the line.
          const sylEnd =
            sylDuration === 0 && syllabus.length === 1
              ? lineEnd
              : sylStart + sylDuration;

          const syllable: Syllable = {
            text: typeof syl.text === "string" ? syl.text : "",
            part: Boolean(syl.part),
            timestamp: sylStart,
            endtime: sylEnd,
          };

          if (syl.isBackground) {
            backgroundSyllables.push(syllable);
          } else {
            mainSyllables.push(syllable);
          }
        }
      }

      if (mainSyllables.length === 0 && lineText) {
        mainSyllables.push({
          text: lineText,
          part: false,
          timestamp: lineStart,
          endtime: lineEnd || lineStart,
          lineSynced: isLineType, // Mark as line-synced
        });
      }

      const hasWordSync =
        mainSyllables.length > 0 || backgroundSyllables.length > 0;

      const { transliteration } = entry;
      let romanizedTextFromPayload: string | undefined;

      if (transliteration) {
        romanizedTextFromPayload = transliteration.text;
        // If syllabus data matches, map it to main syllables
        if (
          Array.isArray(transliteration.syllabus) &&
          transliteration.syllabus.length === mainSyllables.length
        ) {
          transliteration.syllabus.forEach((s: any, idx: number) => {
            mainSyllables[idx].romanizedText = s.text;
          });
        }
      }

      // Extract translation from KPoe API if available
      const translationText = entry.translation?.text;

      const lineResult: LyricsLine = {
        text: mainSyllables,
        background: backgroundSyllables.length > 0,
        backgroundText: backgroundSyllables,
        oppositeTurn:
          alignment === "end" ||
          (Array.isArray(entry.element)
            ? entry.element.includes("opposite") ||
              entry.element.includes("right")
            : false),
        timestamp: lineStart,
        endtime: start + duration,
        isWordSynced: isLineType ? false : hasWordSync,
        alignment,
        songPart: entry.element?.songPart,
        romanizedText: romanizedTextFromPayload,
        translation: translationText,
      };

      lines.push(lineResult);
    }

    return lines;
  }

  private static toMilliseconds(value: unknown, fallback = 0): number {
    const num = Number(value);
    if (!Number.isFinite(num) || Number.isNaN(num)) {
      return fallback;
    }

    if (!Number.isInteger(num)) {
      return Math.round(num * 1000);
    }

    return Math.max(0, Math.round(num));
  }

  firstUpdated() {
    // Set up scroll event listener for user scroll detection
    // Use wheel/touchmove which are guaranteed to be user initiated,
    // unlike 'scroll' which fires for both user and programmatic/inertia
    if (this.lyricsContainer) {
      this.lyricsContainer.addEventListener(
        "wheel",
        this.handleUserScroll.bind(this),
        { passive: true },
      );
      this.lyricsContainer.addEventListener(
        "touchmove",
        this.handleUserScroll.bind(this),
        { passive: true },
      );
    }
  }

  /**
   * Handle currentTime changes imperatively, bypassing Lit's render cycle.
   * This prevents the template from re-rendering on every frame, which would
   * reset imperative animation classes (highlight, finished, etc.) set by
   * updateSyllablesForLine.
   */
  private _onTimeChanged(oldTime: number, newTime: number): void {
    const timeDiff = Math.abs(newTime - oldTime);

    const newActiveLines = this.findActiveLineIndices(newTime);
    const oldActiveLines = this.activeLineIndices;

    // Reset animation if active lines change or if we skip time.
    // A threshold of 0.5s (500ms) is used to detect a "skip".
    const linesChanged = !AmLyrics.arraysEqual(newActiveLines, oldActiveLines);

    if (linesChanged || timeDiff > 0.5) {
      // Imperatively manage 'active' class so that scroll-animate and other
      // imperative classes are never clobbered.
      if (this.lyricsContainer) {
        // Remove 'active' from lines that are no longer active
        for (const lineIndex of oldActiveLines) {
          if (!newActiveLines.includes(lineIndex)) {
            const lineElement = this.lyricsContainer.querySelector(
              `#lyrics-line-${lineIndex}`,
            ) as HTMLElement;
            if (lineElement) {
              lineElement.classList.remove("active");
              AmLyrics.resetSyllables(lineElement);
            }
          }
        }
        // Add 'active' to newly active lines
        for (const lineIndex of newActiveLines) {
          if (!oldActiveLines.includes(lineIndex)) {
            const lineElement = this.lyricsContainer.querySelector(
              `#lyrics-line-${lineIndex}`,
            ) as HTMLElement;
            if (lineElement) {
              lineElement.classList.add("active");
              lineElement.classList.remove("pre-active"); // Cleanup pre-active when fully active
            }
          }
        }
      }
      this.startAnimationFromTime(newTime);

      // Update position classes BEFORE scrolling so currentPrimaryActiveLine is current
      if (this.lyricsContainer && this.activeLineIndices.length > 0) {
        const primaryLineIndex = this.activeLineIndices[0];
        const primaryLine = this.lyricsContainer.querySelector(
          `#lyrics-line-${primaryLineIndex}`,
        ) as HTMLElement;

        if (primaryLine && primaryLine !== this.currentPrimaryActiveLine) {
          this.lastPrimaryActiveLine = this.currentPrimaryActiveLine;
          this.currentPrimaryActiveLine = primaryLine;
          this.updatePositionClasses(primaryLine);
        }
      }

      // Trigger scroll imperatively (was previously in updated() via @state)
      this._handleActiveLineScroll(oldActiveLines);
    }

    // YouLyPlus-style syllable animation updates
    if (this.lyricsContainer) {
      // Update syllables in active lines
      for (const lineIndex of this.activeLineIndices) {
        const lineElement = this.lyricsContainer.querySelector(
          `#lyrics-line-${lineIndex}`,
        ) as HTMLElement;
        if (lineElement) {
          AmLyrics.updateSyllablesForLine(lineElement, newTime);
        }
      }

      // Also update syllables in active gap lines (breathing dots)
      const activeGaps =
        this.lyricsContainer.querySelectorAll(".lyrics-gap.active");
      activeGaps.forEach((gapLine) => {
        AmLyrics.updateSyllablesForLine(gapLine as HTMLElement, newTime);
      });

      // Imperatively manage gap active state (template doesn't re-render on time changes)
      const allGaps = this.lyricsContainer.querySelectorAll(".lyrics-gap");
      allGaps.forEach((gap) => {
        const gapStartTime = parseFloat(
          gap.getAttribute("data-start-time") || "0",
        );
        const gapEndTime = parseFloat(gap.getAttribute("data-end-time") || "0");
        const shouldBeActive = newTime >= gapStartTime && newTime < gapEndTime;
        const isActive = gap.classList.contains("active");
        const isExiting = gap.classList.contains("gap-exiting");
        // Start exit animation early so it completes before the next lyric
        const exitLeadMs = 600;
        const shouldStartExiting =
          isActive && !isExiting && newTime >= gapEndTime - exitLeadMs;

        if (shouldBeActive && !isActive && !isExiting) {
          // Entering gap: remove any leftover exit state, add active
          gap.classList.remove("gap-exiting");
          gap.classList.add("active");
          // Mark any dots whose time has already passed as finished
          // (prevents skipping the first dot when lyrics load mid-gap)
          const dotSyllables = gap.querySelectorAll(".lyrics-syllable");
          dotSyllables.forEach((dot) => {
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
      const currentGap = this.findInstrumentalGapAt(newTime);
      if (currentGap) {
        this.lastInstrumentalIndex = currentGap.insertBeforeIndex;
      } else if (this.lastInstrumentalIndex !== null) {
        this.lastInstrumentalIndex = null;
      }

      // Update position classes for YouLyPlus blur/opacity effect
      // (only needed when lines didn't change — when they DID change,
      // position classes are already updated above before scrolling)
      if (!linesChanged && this.activeLineIndices.length > 0) {
        const primaryLineIndex = this.activeLineIndices[0];
        const primaryLine = this.lyricsContainer.querySelector(
          `#lyrics-line-${primaryLineIndex}`,
        ) as HTMLElement;

        if (primaryLine && primaryLine !== this.currentPrimaryActiveLine) {
          this.lastPrimaryActiveLine = this.currentPrimaryActiveLine;
          this.currentPrimaryActiveLine = primaryLine;
          this.updatePositionClasses(primaryLine);
        }
      }

      // Pre-scroll: scroll to upcoming line ~0.5s before it starts
      if (
        this.autoScroll &&
        !this.isUserScrolling &&
        !this.isClickSeeking &&
        this.lyrics
      ) {
        const preScrollLeadMs = 500; // 500ms lead time

        // Condition: ONLY pre-scroll if no other lyric is currently playing.
        // If a lyric is playing, we must wait for it to finish (handled by updated()).
        if (this.activeLineIndices.length === 0) {
          for (let i = 0; i < this.lyrics.length; i += 1) {
            const line = this.lyrics[i];
            const timeUntilStart = line.timestamp - newTime;

            const nextLineEl = this.lyricsContainer.querySelector(
              `#lyrics-line-${i}`,
            ) as HTMLElement;

            if (timeUntilStart > 0 && timeUntilStart <= preScrollLeadMs) {
              // Time to pre-scroll and pre-activate!
              if (nextLineEl) {
                // Apply unblur & zoom effect ahead of lyric start
                nextLineEl.classList.add("pre-active");

                // Only trigger scroll if we aren't already targeting this line
                if (nextLineEl !== this.currentPrimaryActiveLine) {
                  this.scrollToActiveLineYouLy(nextLineEl);
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

  updated(changedProperties: Map<string | number | symbol, unknown>) {
    if (changedProperties.has("lyrics")) {
      // Recalculate timing data for accurate animations whenever lyrics change
      this._updateCharTimingData();

      // Apply 'active' classes imperatively after lyrics first render,
      // since the template no longer binds the 'active' class (to avoid
      // clobbering imperative scroll-animate classes on re-render).
      if (this.lyricsContainer && this.lyrics) {
        const activeLines = this.findActiveLineIndices(this.currentTime);
        for (const lineIndex of activeLines) {
          const lineEl = this.lyricsContainer.querySelector(
            `#lyrics-line-${lineIndex}`,
          ) as HTMLElement;
          if (lineEl) lineEl.classList.add("active");
        }
      }
    }

    // Handle duration reset (-1 stops playback and resets currentTime to 0)
    if (changedProperties.has("duration") && this.duration === -1) {
      this.currentTime = 0;
      this.activeLineIndices = [];
      this.activeMainWordIndices.clear();
      this.activeBackgroundWordIndices.clear();
      this.mainWordProgress.clear();
      this.backgroundWordProgress.clear();
      this.mainWordAnimations.clear();
      this.backgroundWordAnimations.clear();
      this.isUserScrolling = false;

      // Cancel any running animations
      if (this.animationFrameId) {
        cancelAnimationFrame(this.animationFrameId);
        this.animationFrameId = undefined;
      }

      // Clear user scroll timeout
      if (this.userScrollTimeoutId) {
        clearTimeout(this.userScrollTimeoutId);
        this.userScrollTimeoutId = undefined;
      }

      // Scroll to top
      if (this.lyricsContainer) {
        this.lyricsContainer.scrollTop = 0;
      }

      return; // Exit early, don't process other changes
    }

    if (
      (changedProperties.has("query") ||
        changedProperties.has("musicId") ||
        changedProperties.has("isrc") ||
        changedProperties.has("songTitle") ||
        changedProperties.has("songArtist") ||
        changedProperties.has("songAlbum") ||
        changedProperties.has("songDurationMs")) &&
      !changedProperties.has("currentTime")
    ) {
      this.fetchLyrics();
    }

    if (changedProperties.has("currentTime") && this.lyrics) {
      // currentTime changes are now handled by the custom setter (_onTimeChanged)
      // This block intentionally left empty — only here for backwards compat with
      // any subclasses that might check changedProperties
    }
  }

  /**
   * Handle scrolling when active line indices change.
   * Called imperatively from _onTimeChanged instead of from updated().
   */
  private _handleActiveLineScroll(oldActiveIndices: number[]): void {
    if (
      !this.autoScroll ||
      this.isUserScrolling ||
      this.isClickSeeking ||
      this.activeLineIndices.length === 0
    ) {
      return;
    }

    // Determine what changed: did we gain new lines or just lose old ones?
    const newlyAdded = this.activeLineIndices.filter(
      (idx) => !oldActiveIndices.includes(idx),
    );

    if (newlyAdded.length === 0) {
      // Only lost lines (an overlap resolved) — don't scroll
      return;
    }

    // New lines were added — scroll to the latest newly-added line.
    // Previous overlap logic skipped every other line for songs with tiny
    // timing overlaps between consecutive lines, causing a visible glitch.
    const latestNewIndex = newlyAdded[newlyAdded.length - 1];
    const targetLine = this.lyricsContainer?.querySelector(
      `#lyrics-line-${latestNewIndex}`,
    ) as HTMLElement;

    if (targetLine) {
      this.scrollToActiveLineYouLy(targetLine);
    } else if (this.currentPrimaryActiveLine) {
      this.scrollToActiveLineYouLy(this.currentPrimaryActiveLine);
    } else {
      this.scrollToActiveLine();
    }
  }

  private _textWidthCanvas: HTMLCanvasElement | undefined;

  private _textWidthCtx: CanvasRenderingContext2D | null | undefined;

  private _getTextWidth(text: string, font: string): number {
    if (!this._textWidthCanvas) {
      this._textWidthCanvas = document.createElement("canvas");
      this._textWidthCtx = this._textWidthCanvas.getContext("2d", {
        willReadFrequently: true,
      });
    }
    if (this._textWidthCtx) {
      this._textWidthCtx.font = font;
      return this._textWidthCtx.measureText(text).width;
    }
    return 0;
  }

  private _updateCharTimingData() {
    if (!this.shadowRoot) return;

    // Get the computed font from the first syllable to ensure accuracy
    const referenceSyllable = this.shadowRoot.querySelector(".lyrics-syllable");
    if (!referenceSyllable) return;

    const computedStyle = getComputedStyle(referenceSyllable);
    const { font } = computedStyle; // Full font string
    const fontSize = parseFloat(computedStyle.fontSize);

    const growableWords = this.shadowRoot.querySelectorAll(
      ".lyrics-word.growable",
    );
    if (!growableWords) return;

    growableWords.forEach((wordSpan: any) => {
      const syllableWraps = wordSpan.querySelectorAll(".lyrics-syllable-wrap");

      // Flatten syllables
      const syllables: HTMLElement[] = [];
      syllableWraps.forEach((wrap: HTMLElement) => {
        const syl = wrap.querySelector(".lyrics-syllable");
        if (syl) syllables.push(syl as HTMLElement);
      });

      syllables.forEach((sylSpan) => {
        const charSpans = sylSpan.querySelectorAll(".char");
        if (charSpans.length === 0) return;

        // Logic from YouLyPlus renderCharWipes:
        // Use textContent from spans to ensure we measure what is rendered
        const chars = Array.from(charSpans).map(
          (span) => span.textContent || "",
        );
        const charWidths = chars.map((c) => this._getTextWidth(c, font));
        const totalSyllableWidth = charWidths.reduce((a, b) => a + b, 0);

        const duration = parseFloat(sylSpan.dataset.duration || "0");
        const velocityPxPerMs =
          duration > 0 ? totalSyllableWidth / duration : 0;

        // Gradient width in pixels = 0.375 * fontSize
        // This matches YouLyPlus visual gradient size
        const gradientWidthPx = 0.375 * fontSize;
        const gradientDurationMs =
          velocityPxPerMs > 0 ? gradientWidthPx / velocityPxPerMs : 100;

        let cumulativeCharWidth = 0;

        charSpans.forEach((spanArg: any, i: number) => {
          const charWidth = charWidths[i];
          const span = spanArg;

          if (totalSyllableWidth > 0) {
            const startPercent = cumulativeCharWidth / totalSyllableWidth;
            const durationPercent = charWidth / totalSyllableWidth;

            span.dataset.wipeStart = startPercent.toFixed(4);
            span.dataset.wipeDuration = durationPercent.toFixed(4);

            // The critical missing piece:
            span.dataset.preWipeArrival = (duration * startPercent).toFixed(2);
            span.dataset.preWipeDuration = gradientDurationMs.toFixed(2);
          }

          cumulativeCharWidth += charWidth;
        });
      });
    });
  }

  private static arraysEqual(a: number[], b: number[]): boolean {
    return a.length === b.length && a.every((val, i) => val === b[i]);
  }

  private handleUserScroll() {
    // Ignore programmatic scrolls and click-seek scrolls
    if (this.isProgrammaticScroll || this.isClickSeeking) {
      return;
    }

    // Mark that user is currently scrolling
    this.isUserScrolling = true;
    this.lyricsContainer?.classList.add("user-scrolling");

    // Clear any existing timeout
    if (this.userScrollTimeoutId) {
      clearTimeout(this.userScrollTimeoutId);
    }

    // Set timeout to re-enable auto-scroll after 2 seconds of no scrolling
    this.userScrollTimeoutId = window.setTimeout(() => {
      this.isUserScrolling = false;
      this.userScrollTimeoutId = undefined;

      // Optionally scroll back to current active line when re-enabling auto-scroll
      if (this.activeLineIndices.length > 0) {
        this.scrollToActiveLine();
      }
    }, 2000);
  }

  private findActiveLineIndices(time: number): number[] {
    if (!this.lyrics) return [];
    const activeLines: number[] = [];
    for (let i = 0; i < this.lyrics.length; i += 1) {
      const line = this.lyrics[i];
      let effectiveEndTime = line.endtime;

      // Extend the "active" highlight window to abut the next line,
      // leaving a 500ms gap for breathing/scrolling
      if (i < this.lyrics.length - 1) {
        const nextLineStart = this.lyrics[i + 1].timestamp;
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

  private findInstrumentalGapAt(
    time: number,
  ): { insertBeforeIndex: number; gapStart: number; gapEnd: number } | null {
    if (!this.lyrics || this.lyrics.length === 0) return null;

    // Start-of-song gap: from 0 to first line timestamp
    const first = this.lyrics[0];
    if (time >= 0 && time < first.timestamp) {
      const gapStart = 0;
      const gapEnd = first.timestamp;
      if (gapEnd - gapStart >= INSTRUMENTAL_THRESHOLD_MS) {
        return { insertBeforeIndex: 0, gapStart, gapEnd };
      }
      return null;
    }

    // Find consecutive pair (i, i+1) that bounds the current time
    for (let i = 0; i < this.lyrics.length - 1; i += 1) {
      const curr = this.lyrics[i];
      const next = this.lyrics[i + 1];
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

  /**
   * Find ALL instrumental gaps in the song, regardless of current time.
   * Used by the template to always render gap elements in the DOM.
   */
  private findAllInstrumentalGaps(): Array<{
    insertBeforeIndex: number;
    gapStart: number;
    gapEnd: number;
  }> {
    if (!this.lyrics || this.lyrics.length === 0) return [];
    const gaps: Array<{
      insertBeforeIndex: number;
      gapStart: number;
      gapEnd: number;
    }> = [];

    // Start-of-song gap
    const first = this.lyrics[0];
    if (first.timestamp >= INSTRUMENTAL_THRESHOLD_MS) {
      gaps.push({ insertBeforeIndex: 0, gapStart: 0, gapEnd: first.timestamp });
    }

    // Inter-line gaps
    for (let i = 0; i < this.lyrics.length - 1; i += 1) {
      const curr = this.lyrics[i];
      const next = this.lyrics[i + 1];
      const gapStart = curr.endtime;
      const gapEnd = next.timestamp;
      if (gapEnd - gapStart >= INSTRUMENTAL_THRESHOLD_MS) {
        gaps.push({ insertBeforeIndex: i + 1, gapStart, gapEnd });
      }
    }

    return gaps;
  }

  private startAnimationFromTime(time: number) {
    if (this.animationFrameId) {
      cancelAnimationFrame(this.animationFrameId);
      this.animationFrameId = undefined;
    }

    if (!this.lyrics) return;

    const activeLineIndices = this.findActiveLineIndices(time);
    if (!AmLyrics.arraysEqual(activeLineIndices, this.activeLineIndices)) {
      this.activeLineIndices = activeLineIndices;
    }

    // Clear previous state
    this.activeMainWordIndices.clear();
    this.activeBackgroundWordIndices.clear();
    this.mainWordAnimations.clear();
    this.backgroundWordAnimations.clear();
    this.mainWordProgress.clear();
    this.backgroundWordProgress.clear();

    if (activeLineIndices.length === 0) {
      return;
    }

    // Set up animations for each active line
    for (const lineIndex of activeLineIndices) {
      const line = this.lyrics[lineIndex];

      // Find main word based on the reset time
      let mainWordIdx = -1;
      for (let i = 0; i < line.text.length; i += 1) {
        if (time >= line.text[i].timestamp && time <= line.text[i].endtime) {
          mainWordIdx = i;
          break;
        }
      }
      this.activeMainWordIndices.set(lineIndex, mainWordIdx);

      // Find background word based on the reset time
      let backWordIdx = -1;
      if (line.backgroundText) {
        for (let i = 0; i < line.backgroundText.length; i += 1) {
          if (
            time >= line.backgroundText[i].timestamp &&
            time <= line.backgroundText[i].endtime
          ) {
            backWordIdx = i;
            break;
          }
        }
      }
      this.activeBackgroundWordIndices.set(lineIndex, backWordIdx);
    }

    // With the state correctly set, configure the animation parameters
    this.setupAnimations();

    // Start the animation loop
    if (this.interpolate) {
      this.animateProgress();
    }
  }

  private updateActiveLineAndWords() {
    if (!this.lyrics) return;

    const activeLineIndices = this.findActiveLineIndices(this.currentTime);
    if (!AmLyrics.arraysEqual(activeLineIndices, this.activeLineIndices)) {
      this.activeLineIndices = activeLineIndices;
    }

    // Clear previous state
    this.activeMainWordIndices.clear();
    this.activeBackgroundWordIndices.clear();

    for (const lineIdx of activeLineIndices) {
      const line = this.lyrics[lineIdx];
      let mainWordIdx = -1;
      for (let i = 0; i < line.text.length; i += 1) {
        if (
          this.currentTime >= line.text[i].timestamp &&
          this.currentTime <= line.text[i].endtime
        ) {
          mainWordIdx = i;
          break;
        }
      }
      this.activeMainWordIndices.set(lineIdx, mainWordIdx);

      let backWordIdx = -1;
      if (line.backgroundText) {
        for (let i = 0; i < line.backgroundText.length; i += 1) {
          if (
            this.currentTime >= line.backgroundText[i].timestamp &&
            this.currentTime <= line.backgroundText[i].endtime
          ) {
            backWordIdx = i;
            break;
          }
        }
      }
      this.activeBackgroundWordIndices.set(lineIdx, backWordIdx);
    }
  }

  private setupAnimations() {
    if (this.activeLineIndices.length === 0 || !this.lyrics) {
      this.mainWordAnimations.clear();
      this.backgroundWordAnimations.clear();
      return;
    }

    for (const lineIndex of this.activeLineIndices) {
      const line = this.lyrics[lineIndex];
      const mainWordIndex = this.activeMainWordIndices.get(lineIndex) ?? -1;
      const backgroundWordIndex =
        this.activeBackgroundWordIndices.get(lineIndex) ?? -1;

      // Main word animation
      if (mainWordIndex !== -1) {
        const word = line.text[mainWordIndex];
        const wordDuration = word.endtime - word.timestamp;
        const elapsedInWord = this.currentTime - word.timestamp;
        this.mainWordAnimations.set(lineIndex, {
          startTime: performance.now() - elapsedInWord,
          duration: wordDuration,
        });
      } else {
        this.mainWordAnimations.set(lineIndex, { startTime: 0, duration: 0 });
      }

      // Background word animation
      if (backgroundWordIndex !== -1 && line.backgroundText) {
        const word = line.backgroundText[backgroundWordIndex];
        const wordDuration = word.endtime - word.timestamp;
        const elapsedInWord = this.currentTime - word.timestamp;
        this.backgroundWordAnimations.set(lineIndex, {
          startTime: performance.now() - elapsedInWord,
          duration: wordDuration,
        });
      } else {
        this.backgroundWordAnimations.set(lineIndex, {
          startTime: 0,
          duration: 0,
        });
      }
    }
  }

  private handleLineClick(line: LyricsLine) {
    // Reset all syllables to prevent highlighting conflicts during seek
    if (this.lyricsContainer) {
      const allLines = this.lyricsContainer.querySelectorAll(".lyrics-line");
      allLines.forEach((lineEl) => {
        AmLyrics.resetSyllables(lineEl as HTMLElement);
        // Remove scroll-animate class and properties to stop any scroll animations
        lineEl.classList.remove("scroll-animate");
        (lineEl as HTMLElement).style.removeProperty("--scroll-delta");
        (lineEl as HTMLElement).style.removeProperty("--lyrics-line-delay");
      });
      // Ensure container state is clean
      this.lyricsContainer.classList.remove("wheel-scrolling");
    }

    // Cancel any ongoing scroll animations
    if (this.scrollAnimationState) {
      this.scrollAnimationState.isAnimating = false;
      this.scrollAnimationState.pendingUpdate = null;
    }

    // Clear scroll animation timeouts
    if (this.scrollUnlockTimeout) {
      clearTimeout(this.scrollUnlockTimeout);
      this.scrollUnlockTimeout = undefined;
    }
    if (this.scrollAnimationTimeout) {
      clearTimeout(this.scrollAnimationTimeout);
      this.scrollAnimationTimeout = undefined;
    }

    // Also clear user scroll timeout to prevent stale scrollToActiveLine
    if (this.userScrollTimeoutId) {
      clearTimeout(this.userScrollTimeoutId);
      this.userScrollTimeoutId = undefined;
    }
    this.isUserScrolling = false;

    // Reset active line tracking to prevent scroll fighting
    this.currentPrimaryActiveLine = null;
    this.lastPrimaryActiveLine = null;
    this.activeLineIds.clear();
    this.animatingLines = [];

    // Find the clicked line element and scroll to it with forceScroll (like YouLyPlus)
    const clickedLineElement = this.lyricsContainer?.querySelector(
      `.lyrics-line[data-start-time="${line.timestamp * 1000}"]`,
    ) as HTMLElement | null;

    if (clickedLineElement && this.lyricsContainer) {
      // Update active line reference to the clicked line
      this.currentPrimaryActiveLine = clickedLineElement;

      // Reset currentScrollOffset to actual scroll position to prevent stale delta
      this.currentScrollOffset = -this.lyricsContainer.scrollTop;

      // Set click-seek cooldown to prevent updated() scroll from fighting
      this.isClickSeeking = true;
      if (this.clickSeekTimeout) clearTimeout(this.clickSeekTimeout);
      this.clickSeekTimeout = setTimeout(() => {
        this.isClickSeeking = false;
      }, 800);

      this.scrollToActiveLineYouLy(clickedLineElement, true);
    }

    const event = new CustomEvent("line-click", {
      detail: {
        timestamp: line.timestamp,
      },
      bubbles: true,
      composed: true,
    });
    this.dispatchEvent(event);
  }

  private static getBackgroundTextPlacement(
    line: LyricsLine,
  ): "before" | "after" {
    if (
      !line.backgroundText ||
      line.backgroundText.length === 0 ||
      line.text.length === 0
    ) {
      return "after"; // Default to after if no comparison is possible
    }

    // Compare the start times of the first syllables
    const mainTextStartTime = line.text[0].timestamp;
    const backgroundTextStartTime = line.backgroundText[0].timestamp;

    return backgroundTextStartTime < mainTextStartTime ? "before" : "after";
  }

  private scrollToActiveLine() {
    if (!this.lyricsContainer || this.activeLineIndices.length === 0) {
      return;
    }

    // Scroll to the first active line
    const firstActiveLineIndex = Math.min(...this.activeLineIndices);
    const activeLineElement = this.lyricsContainer.querySelector(
      `.lyrics-line:nth-child(${firstActiveLineIndex + 1})`,
    ) as HTMLElement;

    if (activeLineElement) {
      const containerHeight = this.lyricsContainer.clientHeight;
      const lineTop = activeLineElement.offsetTop;
      const lineHeight = activeLineElement.clientHeight;

      // Check if the line has background text placed before the main text
      const hasBackgroundBefore = activeLineElement.querySelector(
        ".background-text.before",
      );

      // Calculate the offset to center the main text content, accounting for background text placement
      let offsetAdjustment = 0;
      if (hasBackgroundBefore) {
        const backgroundElement = hasBackgroundBefore as HTMLElement;
        offsetAdjustment = backgroundElement.clientHeight / 2; // Adjust to focus on main content
      }

      const top =
        lineTop - containerHeight / 2 + lineHeight / 2 - offsetAdjustment;

      // Use requestAnimationFrame for smoother iOS performance
      requestAnimationFrame(() => {
        this.isProgrammaticScroll = true;
        this.lyricsContainer?.scrollTo({ top, behavior: "smooth" });
        // Reset the flag after a short delay to allow the scroll to complete
        setTimeout(() => {
          this.isProgrammaticScroll = false;
        }, 100);
      });
    }
  }

  private scrollToInstrumental(insertBeforeIndex: number) {
    if (!this.lyricsContainer) return;

    // Find the gap element by ID instead of nth-child
    const gapTarget = this.lyricsContainer.querySelector(
      `#gap-${insertBeforeIndex}`,
    ) as HTMLElement | null;

    if (gapTarget) {
      // Use same scroll position as lyrics (scroll-padding-top from top), not center
      // This matches YouLyPlus behavior where gaps don't scroll to a different position
      const paddingTop = this.getScrollPaddingTop();
      const targetTranslateY = paddingTop - gapTarget.offsetTop;

      this.isProgrammaticScroll = true;
      this.animateScrollYouLy(targetTranslateY, false);

      setTimeout(() => {
        this.isProgrammaticScroll = false;
      }, 250);
    }
  }

  // === YouLyPlus-style Animation Methods ===

  /**
   * Get the scroll padding top value from CSS variable
   */
  private getScrollPaddingTop(): number {
    if (!this.lyricsContainer) return 0;
    const style = getComputedStyle(this);
    const paddingTopValue =
      style.getPropertyValue("--lyrics-scroll-padding-top") || "25%";
    if (paddingTopValue.includes("%")) {
      return (
        this.lyricsContainer.clientHeight * (parseFloat(paddingTopValue) / 100)
      );
    }
    return parseFloat(paddingTopValue) || 0;
  }

  /**
   * Animate scroll with staggered delay for smooth YouLyPlus-style scrolling
   */
  private animateScrollYouLy(newTranslateY: number, forceScroll = false): void {
    if (!this.lyricsContainer) return;
    const parent = this.lyricsContainer;

    if (!this.scrollAnimationState) {
      this.scrollAnimationState = {
        isAnimating: false,
        pendingUpdate: null,
      };
      this.animatingLines = [];
    }

    const animState = this.scrollAnimationState;

    if (animState.isAnimating && !forceScroll) {
      animState.pendingUpdate = newTranslateY;
      return;
    }

    if (this.scrollUnlockTimeout) {
      clearTimeout(this.scrollUnlockTimeout);
      this.scrollUnlockTimeout = undefined;
    }

    if (this.scrollAnimationTimeout) {
      clearTimeout(this.scrollAnimationTimeout);
      this.scrollAnimationTimeout = undefined;
    }

    const { animatingLines } = this;

    const targetTop = Math.max(0, -newTranslateY);
    // Always use actual scroll position - don't fall back to stale currentScrollOffset
    // The || operator treats 0 as falsy, which caused bounce when scrollTop was 0
    const prevOffset = -parent.scrollTop;
    const delta = prevOffset - newTranslateY;
    this.currentScrollOffset = newTranslateY;

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
    const lineElements = this.lyricsContainer.querySelectorAll(".lyrics-line");
    const lineArray = Array.from(lineElements) as HTMLElement[];

    const referenceLine =
      this.currentPrimaryActiveLine ||
      this.lastPrimaryActiveLine ||
      lineArray[0];

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
      const delay =
        i >= referenceIndex ? (delayCounter - 1) * delayIncrement : 0;

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

    this.scrollUnlockTimeout = setTimeout(() => {
      animState.isAnimating = false;

      if (animState.pendingUpdate !== null) {
        const pendingValue = animState.pendingUpdate;
        animState.pendingUpdate = null;
        this.animateScrollYouLy(pendingValue, false);
      }
    }, BASE_DURATION);

    this.scrollAnimationTimeout = setTimeout(() => {
      for (let i = 0; i < animatingLines.length; i += 1) {
        const line = animatingLines[i];
        line.classList.remove("scroll-animate");
        line.style.removeProperty("--scroll-delta");
        line.style.removeProperty("--lyrics-line-delay");
      }
      animatingLines.length = 0;
      this.scrollAnimationTimeout = undefined;
    }, maxAnimationDuration + 50);

    parent.scrollTo({ top: targetTop, behavior: "instant" });
  }

  /**
   * Update position classes for YouLyPlus-style opacity/blur gradients
   */
  private updatePositionClasses(lineToScroll: HTMLElement): void {
    if (!this.lyricsContainer) return;

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
    this.lyricsContainer
      .querySelectorAll(`.${positionClasses.join(", .")}`)
      .forEach((el) => el.classList.remove(...positionClasses));

    // Add new position classes
    lineToScroll.classList.add("lyrics-activest");

    const lineElements = Array.from(
      this.lyricsContainer.querySelectorAll(".lyrics-line"),
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
        else if (position < 0)
          element.classList.add(`prev-${Math.abs(position)}`);
        else element.classList.add(`next-${position}`);
      }
    }
  }

  /**
   * Scroll to active line with YouLyPlus-style animation
   */
  private scrollToActiveLineYouLy(
    activeLine: HTMLElement,
    forceScroll = false,
  ): void {
    if (!activeLine || !this.lyricsContainer) return;

    const paddingTop = this.getScrollPaddingTop();
    const targetTranslateY = paddingTop - activeLine.offsetTop;

    const scrollContainerTop = this.lyricsContainer.getBoundingClientRect().top;

    // Skip if already at target position
    if (
      !forceScroll &&
      Math.abs(
        activeLine.getBoundingClientRect().top -
          scrollContainerTop -
          paddingTop,
      ) < 1
    ) {
      return;
    }

    // Skip scroll if near the bottom of content (prevents footer jitter)
    if (!forceScroll) {
      const parent = this.lyricsContainer;
      const atBottom =
        parent.scrollTop + parent.clientHeight >= parent.scrollHeight - 50;
      if (atBottom) {
        return;
      }
    }

    this.lyricsContainer.classList.remove("not-focused", "user-scrolling");
    this.isProgrammaticScroll = true;
    this.isUserScrolling = false;

    if (this.userScrollTimeoutId) {
      clearTimeout(this.userScrollTimeoutId);
      this.userScrollTimeoutId = undefined;
    }

    setTimeout(() => {
      this.isProgrammaticScroll = false;
    }, 600);

    this.animateScrollYouLy(targetTranslateY, forceScroll);
  }

  /**
   * Update syllable highlight animation - apply CSS wipe animation
   * (Exact copy from YouLyPlus _updateSyllableAnimation)
   */
  private static updateSyllableAnimation(syllable: HTMLElement): void {
    if (syllable.classList.contains("highlight")) return;

    const { classList } = syllable;
    const isRTL = classList.contains("rtl-text");
    const charSpans = Array.from(
      syllable.querySelectorAll("span.char"),
    ) as HTMLElement[];
    const wordElement = syllable.parentElement?.parentElement; // syllable-wrap -> word
    const allWordCharSpans = wordElement
      ? (Array.from(wordElement.querySelectorAll("span.char")) as HTMLElement[])
      : [];
    const isGrowable = wordElement?.classList.contains("growable");
    const isFirstSyllable =
      syllable.getAttribute("data-syllable-index") === "0";
    const isFirstInContainer = isFirstSyllable; // Simplified
    const isGap = syllable.closest(".lyrics-gap") !== null;

    // Get duration from data attribute
    const syllableDurationMs =
      parseFloat(syllable.getAttribute("data-duration") || "0") || 300;
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

      allWordCharSpans.forEach((span) => {
        const horizontalOffset = parseFloat(
          span.dataset.horizontalOffset || "0",
        );
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
        const existingAnimation =
          charAnimationsMap.get(span) || span.style.animation || "";
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
      const wipeRatio = parseFloat(
        syllable.getAttribute("data-wipe-ratio") || "1",
      );
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
      // eslint-disable-next-line no-param-reassign
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

  /**
   * Reset syllable animation state
   */
  private static resetSyllable(syllable: HTMLElement): void {
    if (!syllable) return;
    // eslint-disable-next-line no-param-reassign
    syllable.style.animation = "";
    syllable.style.removeProperty("--pre-wipe-duration");
    syllable.style.removeProperty("--pre-wipe-delay");
    // Force background to secondary and disable transition to prevent lingering white
    // eslint-disable-next-line no-param-reassign
    syllable.style.transition = "none";
    // eslint-disable-next-line no-param-reassign
    syllable.style.backgroundColor = "var(--lyplus-text-secondary)";

    // Reset character animations — disable transition so finished chars don't slowly fade
    syllable.querySelectorAll("span.char").forEach((span) => {
      const el = span as HTMLElement;
      el.style.animation = "";
      el.style.transition = "none";
      el.style.backgroundColor = "var(--lyplus-text-secondary)";
    });

    // Immediately remove all state classes
    syllable.classList.remove(
      "highlight",
      "finished",
      "pre-highlight",
      "cleanup",
    );

    // In next frame, clear inline styles so CSS transitions can resume for future use
    requestAnimationFrame(() => {
      syllable.style.removeProperty("background-color");
      syllable.style.removeProperty("transition");
      syllable.querySelectorAll("span.char").forEach((span) => {
        const el = span as HTMLElement;
        el.style.removeProperty("background-color");
        el.style.removeProperty("transition");
      });
    });
  }

  /**
   * Reset all syllables in a line
   */
  private static resetSyllables(line: HTMLElement): void {
    if (!line) return;
    // eslint-disable-next-line no-param-reassign
    (line as any)._cachedSyllableElements = null;
    Array.from(line.getElementsByClassName("lyrics-syllable")).forEach(
      (syllable) => AmLyrics.resetSyllable(syllable as HTMLElement),
    );
  }

  /**
   * Update syllables based on current time
   * Uses DOM caching and pre-highlight reset for smooth transitions
   */
  private static updateSyllablesForLine(
    line: HTMLElement,
    currentTimeMs: number,
  ): void {
    // DOM cache: avoid querySelectorAll on every frame
    let syllables: HTMLElement[] = (line as any)._cachedSyllableElements;
    if (!syllables) {
      syllables = Array.from(
        line.querySelectorAll(".lyrics-syllable"),
      ) as HTMLElement[];
      // eslint-disable-next-line no-param-reassign
      (line as any)._cachedSyllableElements = syllables;
    }

    for (let i = 0; i < syllables.length; i += 1) {
      const syllable = syllables[i];
      const startTime = parseFloat(
        syllable.getAttribute("data-start-time") || "0",
      );
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
                AmLyrics.updateSyllableAnimation(syllable);
              }
              if (hasFinished) {
                classList.remove("finished");
              }
            } else if (currentTimeMs > endTime) {
              // Finished
              if (!hasFinished) {
                if (!hasHighlight) {
                  AmLyrics.updateSyllableAnimation(syllable);
                }
                classList.add("finished");
              }
            } else if (hasHighlight || hasFinished) {
              // Not yet started
              AmLyrics.resetSyllable(syllable);
            }
          }
        }
      }
    }
  }

  private animateProgress() {
    const now = performance.now();
    let running = false;

    if (!this.lyrics || this.activeLineIndices.length === 0) {
      if (this.animationFrameId) {
        cancelAnimationFrame(this.animationFrameId);
        this.animationFrameId = undefined;
      }
      return;
    }

    // Process each active line
    for (const lineIndex of this.activeLineIndices) {
      const line = this.lyrics[lineIndex];
      const mainWordAnimation = this.mainWordAnimations.get(lineIndex);

      // Main text animation
      if (mainWordAnimation && mainWordAnimation.duration > 0) {
        const elapsed = now - mainWordAnimation.startTime;
        if (elapsed >= 0) {
          const progress = Math.min(1, elapsed / mainWordAnimation.duration);
          this.mainWordProgress.set(lineIndex, progress);

          if (progress < 1) {
            running = true;
          } else {
            // Word animation finished. Look for the next word in the same line.
            const currentMainWordIndex =
              this.activeMainWordIndices.get(lineIndex) ?? -1;
            const nextWordIndex = currentMainWordIndex + 1;
            if (
              currentMainWordIndex !== -1 &&
              nextWordIndex < line.text.length
            ) {
              const currentWord = line.text[currentMainWordIndex];
              const nextWord = line.text[nextWordIndex];

              this.activeMainWordIndices.set(lineIndex, nextWordIndex);
              const gap = nextWord.timestamp - currentWord.endtime;
              const nextWordDuration = nextWord.endtime - nextWord.timestamp;

              this.mainWordAnimations.set(lineIndex, {
                startTime: performance.now() + gap,
                duration: nextWordDuration,
              });
              running = true;
            } else {
              this.mainWordAnimations.set(lineIndex, {
                startTime: 0,
                duration: 0,
              });
            }
          }
        } else {
          // Waiting in a gap
          this.mainWordProgress.set(lineIndex, 0);
          running = true;
        }
      }

      // Background text animation
      const backgroundWordAnimation =
        this.backgroundWordAnimations.get(lineIndex);
      if (backgroundWordAnimation && backgroundWordAnimation.duration > 0) {
        const elapsed = now - backgroundWordAnimation.startTime;
        if (elapsed >= 0) {
          const progress = Math.min(
            1,
            elapsed / backgroundWordAnimation.duration,
          );
          this.backgroundWordProgress.set(lineIndex, progress);

          if (progress < 1) {
            running = true;
          } else {
            // Word animation finished. Look for the next word in the same line.
            const currentBackgroundWordIndex =
              this.activeBackgroundWordIndices.get(lineIndex) ?? -1;
            if (
              line.backgroundText &&
              currentBackgroundWordIndex !== -1 &&
              currentBackgroundWordIndex < line.backgroundText.length - 1
            ) {
              const nextWordIndex = currentBackgroundWordIndex + 1;
              const currentWord =
                line.backgroundText[currentBackgroundWordIndex];
              const nextWord = line.backgroundText[nextWordIndex];

              this.activeBackgroundWordIndices.set(lineIndex, nextWordIndex);
              const gap = nextWord.timestamp - currentWord.endtime;
              const nextWordDuration = nextWord.endtime - nextWord.timestamp;

              this.backgroundWordAnimations.set(lineIndex, {
                startTime: performance.now() + gap,
                duration: nextWordDuration,
              });
              running = true;
            } else {
              this.backgroundWordAnimations.set(lineIndex, {
                startTime: 0,
                duration: 0,
              });
            }
          }
        } else {
          // Waiting in a gap
          this.backgroundWordProgress.set(lineIndex, 0);
          running = true;
        }
      }
    }

    if (running) {
      this.animationFrameId = requestAnimationFrame(
        this.animateProgress.bind(this),
      );
    } else if (this.animationFrameId) {
      // Stop animation if no words are running
      cancelAnimationFrame(this.animationFrameId);
      this.animationFrameId = undefined;
    }
  }

  private static formatTimestampLRC(ms: number): string {
    const totalSeconds = ms / 1000;
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = Math.floor(totalSeconds % 60);
    const hundredths = Math.floor((ms % 1000) / 10);

    const pad = (n: number) => n.toString().padStart(2, "0");
    return `${pad(minutes)}:${pad(seconds)}.${pad(hundredths)}`;
  }

  private static formatTimestampTTML(ms: number): string {
    // TTML standard format: HH:MM:SS.mmm
    const totalSeconds = ms / 1000;
    const hours = Math.floor(totalSeconds / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    const seconds = Math.floor(totalSeconds % 60);
    const milliseconds = Math.floor(ms % 1000);

    const pad = (n: number, width = 2) => n.toString().padStart(width, "0");
    return `${pad(hours)}:${pad(minutes)}:${pad(seconds)}.${pad(milliseconds, 3)}`;
  }

  render() {
    if (this.fontFamily) {
      this.style.fontFamily = this.fontFamily;
    }

    // Set both old internal CSS variables (for backward compatibility)
    // and new public CSS variables (which take precedence)
    this.style.setProperty(
      "--hover-background-color",
      this.hoverBackgroundColor,
    );
    this.style.setProperty("--highlight-color", this.highlightColor);

    const sourceLabel = this.lyricsSource ?? "Unavailable";

    const isUnsynced =
      this.lyrics && this.lyrics.length > 0
        ? this.lyrics.every((l) => l.timestamp === 0 && l.endtime === 0)
        : false;
  }
}
