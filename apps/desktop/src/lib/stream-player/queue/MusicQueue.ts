import type { MusicTrack } from "$lib/schemas/music-track";
import type { PlaylistVideoType } from "$lib/schemas/playlist";

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type DistributiveOmit<T, K extends PropertyKey> = T extends any ? Omit<T, K> : never;

export type MusicPlaylistContextSource =
  | { type: "none" }
  | ({ sourceName?: string } & (
      | { type: "downloads" }
      | {
          type: "album";
          browseId: string;
          offlineTracks?: QueueableMusic[];
        }
      | {
          type: "artistTopSongs";
          browseId: string;
          offlineTracks?: QueueableMusic[];
        }
      | {
          type: "likes";
          email: string;
          offlineTracks?: QueueableMusic[];
        }
      | {
          type: "playlist";
          playlistId: string;
          automixedTracks?: QueueableMusic[];
          offlineTracks?: QueueableMusic[];
        }
    ));

type ContextWithoutOfflineTracks = DistributiveOmit<MusicPlaylistContextSource, "offlineTracks">;

export interface QueueableMusic extends Omit<MusicTrack, "isExplicit"> {
  videoType: PlaylistVideoType;
}

export interface MusicPlaylistContext {
  source: ContextWithoutOfflineTracks;
  queue: QueueableMusic[];
}

export interface AutomixContext {
  automixedVideoId: string;
  queue: QueueableMusic[];
}

export type MusicRepeatMode = "none" | "all" | "one";
export type PickDirection = "next" | "previous";

export interface MusicQueue {
  playingNow?: QueueableMusic | null;
  queue: QueueableMusic[];
  repeatMode: MusicRepeatMode;
  /** Enabling shuffle randomizes playback in queue. */
  shuffleEnabled: boolean;
  nextTracks: QueueableMusic[];
  /** The queue switches to the shuffled/normal one based on shuffle mode. Any accesses to `playlistContext.queue` should be done via this. */
  readyContextQueue: QueueableMusic[];
  playingNowIndex: number;
  playlistContextSource: MusicPlaylistContextSource;
  cycleRepeatMode: () => void;
  enableShuffle: () => void;
  disableShuffle: () => void;
  loadContext: (source: MusicPlaylistContextSource) => void;
  addToQueue: (track: QueueableMusic) => void;
  removeFromQueue: (videoId: string) => void;
  skipToPrevious: () => void;
  skipToNext: () => void;
  pickNext: () => void;
}
