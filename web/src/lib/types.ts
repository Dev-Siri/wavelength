export interface ThemeColor {
  r: number;
  g: number;
  b: number;
}

export interface MusicTrackStats {
  viewCount: number;
  likeCount: number;
  commentCount: number;
}

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

export interface Artist extends Omit<BaseMusicTrack, "videoId"> {
  browseId: string;
  subscriberText: string;
  isExplicit: boolean;
}

export interface Lyric {
  text: string;
  startMs: number;
  durMs: number;
}

export interface PlaylistTracksLength {
  songCount: number;
  songDurationSecond: number;
}

interface SearchResponse<T> {
  result: T[];
  nextPageToken: string;
}

export type MusicSearchResponse = SearchResponse<MusicTrack>;
export type ArtistSearchResponse = SearchResponse<Artist>;

export interface YouTubeVideo {
  videoId: string;
  title: string;
  thumbnail: string;
  author: string;
}

export interface QuickPicksResponse {
  error: boolean;
  results: BaseMusicTrack[];
}

export type ApiResponse<T> =
  | {
      success: true;
      data: T;
    }
  | {
      success: false;
      message: string;
    };

export interface ArtistResponse {
  title: string;
  description: string;
  thumbnail: string;
  subscriberCount: string;
  songs:
    | {
        browseId: string;
        titleHeader: string;
        contents: ArtistSong[];
      }
    | undefined;
}

export interface Playlist {
  playlistId: string;
  name: string;
  authorGoogleEmail: string;
  authorName: string;
  authorImage: string;
  coverImage: string | null;
  isPublic: boolean;
}

export type VideoType = "track" | "uvideo";

export interface PlaylistTrack {
  playlistId: string;
  playlistTrackId: string;
  title: string;
  thumbnail: string;
  positionInPlaylist: number;
  isExplicit: boolean;
  author: string;
  duration: string;
  videoId: string;
  videoType: VideoType;
}
