export const WAVELENGTH_PLATFORM_KEY = "wavelength-web";

export const localStorageKeys = {
  volume: "volume",
  authToken: "auth-token",
  authUser: "auth-user",
  openPanel: "open-panel",
} as const;

export const svelteQueryKeys = {
  userPlaylists: ["user-playlists"],
  savedAlbums: ["saved-albums"],
  followedArtists: ["followed-artists"],
  region: ["region"],
  quickPicks: ["quick-picks"],
  likes: ["likes"],
  likesLength: ["likes-length"],
  likeCount: ["like-count"],
  downloads: ["downloads"],
  isTrackLiked: (trackId: string) => ["is-track-liked", trackId],
  album: (albumId: string) => ["album", albumId],
  isAlbumLossless: (albumId: string) => ["is-album-lossless", albumId],
  isAlbumSaved: (albumId: string) => ["is-album-saved", albumId],
  playlist: (playlistId: string) => ["playlist", playlistId],
  playlistTrack: (playlistId: string) => ["playlist-track", playlistId],
  playlistLikedStatus: (playlistId: string) => ["playlist-tracks-liked-status", playlistId],
  playlistTrackLength: (playlistId: string) => ["playlist-track-length", playlistId],
  artist: (browseId: string) => ["artist", browseId],
  search: (query: string, searchType: string) => ["search", searchType, query],
  searchRecommendations: (query: string) => ["search-recommendations", query],
  musicVideoPreview: (title: string, artist: string) => ["music-video-preview", title, artist],
  lyrics: (videoId: string) => ["lyrics", videoId],
  unsyncedLyrics: (videoId: string) => ["unsynced-lyrics", videoId],
  themeColor: (imageUrl: string) => ["theme-color", imageUrl],
  coverEffect: (imageUrl: string) => ["cover-effect", imageUrl],
  musicStats: (videoId: string) => ["music-stats", videoId],
  playlistRecommendedSongs: (playlistId: string) => ["playlist-recommended-songs", playlistId],
  isFollowingArtist: (browseId: string) => ["is-following-artist", browseId],
  albumLiveCover: (videoId: string) => ["album-live-cover", videoId],
} as const;

export const svelteMutationKeys = {
  addToPlaylists: ["add-to-playlists"],
  addUVideoToPlaylist: ["add-uvideo-to-playlist"],
  playlistVisibilityChange: ["playlist-visibility-change"],
  createPlaylist: (email: string | null | undefined) => ["create-playlist", email ?? "guest"],
  updatePlaylist: (playlistId: string) => ["update-playlist", playlistId],
  deletePlaylist: (playlistId: string) => ["delete-playlist", playlistId],
  rearrangePlaylistTracks: (playlistId: string) => ["rearrange-playlist-items", playlistId],
  likeTrack: (trackId: string) => ["like-track", trackId],
  saveAlbum: (albumId: string) => ["save-album", albumId],
  followArtist: (browseId: string) => ["follow-artist", browseId],
} as const;
