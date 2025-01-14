export interface BaseMusicTrack {
  videoId: string;
  title: string;
  thumbnail: string;
  author: string;
}

export interface MusicTrack extends BaseMusicTrack {
  duration: string;
  isExplicit: boolean;
}

export interface ArtistSong extends BaseMusicTrack {
  isExplicit: boolean;
}

// The API for some reason structures even an "Artist" to be extendable from BaseMusicTrack (minus "videoId").
export interface Artist extends Omit<BaseMusicTrack, "videoId"> {
  browseId: string;
  subscriberText: string;
  isExplicit: boolean;
}

export type { BaseMusicTrack as QuickPickMusic };
