/** Shared API to interact with the stream player. */
export abstract class StreamPlayer extends EventTarget {
  abstract dispose(): Promise<void>;
  abstract load(videoId: string, startingSeconds?: number): Promise<void>;
  abstract play(): Promise<void>;
  abstract pause(): Promise<void>;
  abstract mute(): Promise<void>;
  abstract unMute(): Promise<void>;
  abstract seek(to: number): Promise<void>;
  abstract getDuration(): Promise<number>;
  abstract getCurrentTime(): Promise<number>;
  /** @param newVolume Volume of the stream in the range 0.00 to 1.00 */
  abstract setVolume(newVolume: number): Promise<void>;

  // Some people call this polymorphism.
  createEvent<K extends PlayerEventName>(
    type: K,
    ...args: StreamPlayerEventMap[K] extends void ? [] : [StreamPlayerEventMap[K]]
  ): PlayerEvent<K> {
    return new CustomEvent(type, { detail: args[0] });
  }

  on<K extends PlayerEventName>(
    type: K,
    listener: (event: PlayerEvent<K>) => void,
    options?: boolean | AddEventListenerOptions,
  ) {
    super.addEventListener(type, listener as EventListener, options);
    return () => this.off(type, listener, options);
  }

  off<K extends PlayerEventName>(
    type: K,
    listener: (event: PlayerEvent<K>) => void,
    options?: boolean | EventListenerOptions,
  ) {
    super.removeEventListener(type, listener as EventListener, options);
  }
}

export interface StreamPlayerEventMap {
  loaded: void;
  playing: void;
  paused: void;
  ended: void;
  timeupdate: {
    duration: number;
    currentTime: number;
  };
}

export type PlayerEventName = keyof StreamPlayerEventMap;
export type PlayerEvent<K extends PlayerEventName> = CustomEvent<StreamPlayerEventMap[K]>;
