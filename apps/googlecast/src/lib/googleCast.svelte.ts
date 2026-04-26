import Hls from "hls.js";

import type { MediaStatusEvent } from "chromecast-caf-receiver/cast.framework.events";

const SEGMENT_RETRY_LIMIT = 5;

export interface LoadedTrack {
  title: string;
  artist: string;
  albumName: string;
}

export type PlayerStatus =
  | { type: "loading" }
  | { type: "error"; message: string };

export default class GoogleCast {
  playerState = $state(cast.framework.messages.PlayerState.IDLE);
  track = $state<LoadedTrack | null>(null);
  status = $state<PlayerStatus | null>(null);

  private hls?: Hls;

  constructor(private audioPlayer: HTMLAudioElement) {
    const context = cast.framework.CastReceiverContext.getInstance();
    const options = new cast.framework.CastReceiverOptions();

    options.skipPlayersLoad = true;
    options.disableIdleTimeout = true;

    options.supportedCommands = cast.framework.messages.Command.ALL_BASIC_MEDIA;

    this.setupPlayer();

    context.start(options);
  }

  private handleMediaStatusEvent = ({ mediaStatus }: MediaStatusEvent) => {
    if (!mediaStatus) return;

    const { media } = mediaStatus;
    if (!media?.metadata) return;

    this.playerState = mediaStatus.playerState;

    if (
      !(
        media.metadata instanceof
        cast.framework.messages.MusicTrackMediaMetadata
      )
    )
      return;

    this.track = {
      title: media.metadata.title ?? "",
      artist: media.metadata.artist ?? "",
      albumName: media.metadata.albumName ?? "",
    };
  };

  private setupPlayer() {
    const context = cast.framework.CastReceiverContext.getInstance();
    const playerManager = context.getPlayerManager();

    this.audioPlayer.addEventListener(
      "loadeddata",
      () => (this.status = { type: "loading" }),
    );

    playerManager.setMessageInterceptor(
      cast.framework.messages.MessageType.LOAD,
      (event) => {
        if (!event.media.entity) {
          event.media.entity = event.media.contentId;
        }

        const reqId = event.requestId;
        // @ts-expect-error untyped by lib.
        const sender = event.senderId;

        this.status = { type: "loading" };

        return new Promise((resolve, _) => {
          if (this.hls) {
            this.hls.destroy();
            this.hls = undefined;
          }

          this.hls = new Hls();
          this.hls.attachMedia(this.audioPlayer);

          this.hls.once(Hls.Events.MEDIA_ATTACHED, () => {
            if (event.media.entity) this.hls?.loadSource(event.media.entity);
            this.audioPlayer.play();
          });

          this.hls.once(Hls.Events.MANIFEST_PARSED, () => resolve(event));

          this.hls.on(Hls.Events.ERROR, (e, data) => {
            if (!data.fatal) return;
            switch (data.type) {
              case Hls.ErrorTypes.NETWORK_ERROR:
                const error = new cast.framework.messages.ErrorData(
                  cast.framework.messages.ErrorType.LOAD_FAILED,
                );
                error.reason =
                  cast.framework.messages.ErrorReason.GENERIC_LOAD_ERROR;
                this.hls?.destroy();
                this.status = { type: "error", message: "Network Error." };
                return resolve(error);
              case Hls.ErrorTypes.MEDIA_ERROR:
                this.hls?.recoverMediaError();
                break;
              default:
                playerManager.sendError(
                  sender,
                  reqId,
                  cast.framework.messages.ErrorType.LOAD_FAILED,
                );
                this.status = {
                  type: "error",
                  message: "Unrecoverable Error.",
                };
                this.hls?.destroy();
                break;
            }
          });
        });
      },
    );

    this.handleMediaStatusEvent = this.handleMediaStatusEvent.bind(this);

    playerManager.addEventListener(
      cast.framework.events.EventType.MEDIA_STATUS,
      this.handleMediaStatusEvent,
    );

    const changePlaybackStatus = (shouldPlay: boolean) => (m: any) => {
      this.audioPlayer[shouldPlay ? "play" : "pause"]();
      playerManager.broadcastStatus(true);
      return m;
    };

    playerManager.setMessageInterceptor(
      cast.framework.messages.MessageType.PAUSE,
      changePlaybackStatus(false),
    );
    playerManager.setMessageInterceptor(
      cast.framework.messages.MessageType.PLAY,
      changePlaybackStatus(true),
    );
  }

  dispose() {
    const context = cast.framework.CastReceiverContext.getInstance();
    const playerManager = context.getPlayerManager();

    playerManager.removeEventListener(
      cast.framework.events.EventType.MEDIA_STATUS,
      this.handleMediaStatusEvent,
    );

    try {
      this.audioPlayer.pause();
      this.audioPlayer.removeAttribute("src");
      this.audioPlayer.load();
    } catch {}

    if (this.hls) {
      this.hls.destroy();
      this.hls = undefined;
    }

    this.track = null;
    this.status = null;
    this.playerState = cast.framework.messages.PlayerState.IDLE;
  }
}
