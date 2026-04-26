import type { MediaStatusEvent } from "chromecast-caf-receiver/cast.framework.events";

const SEGMENT_RETRY_LIMIT = 5;

export interface LoadedTrack {
  title: string;
  artist: string;
  albumName: string;
}

class GoogleCast {
  playerState = $state(cast.framework.messages.PlayerState.IDLE);
  track = $state<LoadedTrack | null>(null);

  constructor() {
    const context = cast.framework.CastReceiverContext.getInstance();
    const options = new cast.framework.CastReceiverOptions();

    options.useShakaForHls = true;

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
    const playbackConfig = new cast.framework.PlaybackConfig();
    playbackConfig.segmentRequestRetryLimit = SEGMENT_RETRY_LIMIT;
    playbackConfig.manifestRequestHandler = (requestInfo) => {
      requestInfo.withCredentials = true;
    };

    const playerManager =
      cast.framework.CastReceiverContext.getInstance().getPlayerManager();
    playerManager.setMediaPlaybackInfoHandler(
      (loadRequestData, playbackConfig) => {},
    );

    playerManager.addEventListener(
      cast.framework.events.EventType.MEDIA_STATUS,
      this.handleMediaStatusEvent,
    );
  }

  dispose() {
    const playerManager =
      cast.framework.CastReceiverContext.getInstance().getPlayerManager();

    playerManager.removeEventListener(
      cast.framework.events.EventType.MEDIA_STATUS,
      this.handleMediaStatusEvent,
    );
  }
}

export const googleCast = new GoogleCast();
