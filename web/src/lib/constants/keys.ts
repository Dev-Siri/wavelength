export const WAVELENGTH_PLATFORM_KEY = "wavelength-web";

export const localStorageKeys = {
  volume: "volume",
} as const;

export const cookieKeys = {
  authToken: "auth-token",
} as const;

export const svelteQueryKeys = {
  userPlaylists: ["user-playlists"],
  region: ["region"],
  quickPicks: ["quick-picks"],
  album: (albumId: string) => ["album", albumId],
  playlist: (playlistId: string) => ["playlist", playlistId],
  playlistTrack: (playlistId: string) => ["playlist-track", playlistId],
  playlistTrackLength: (playlistId: string) => ["playlist-track-length", playlistId],
  artist: (browseId: string) => ["artist", browseId],
  artistExtra: (browseId: string) => ["artist-extra", browseId],
  search: (query: string, searchType: string) => ["search", searchType, query],
  musicVideoPreview: (title: string, artist: string) => ["music-video-preview", title, artist],
  lyrics: (videoId: string) => ["lyrics", videoId],
  themeColor: (imageUrl: string) => ["theme-color", imageUrl],
  musicStats: (videoId: string) => ["music-stats", videoId],
} as const;

export const svelteMutationKeys = {
  addToPlaylists: ["add-to-playlists"],
  addUVideoToPlaylist: ["add-uvideo-to-playlist"],
  playlistVisibilityChange: ["playlist-visibility-change"],
  createPlaylist: (email: string | null | undefined) => ["create-playlist", email ?? "guest"],
  updatePlaylist: (playlistId: string) => ["update-playlist", playlistId],
  deletePlaylist: (playlistId: string) => ["delete-playlist", playlistId],
  rearrangePlaylistTracks: (playlistId: string) => ["rearrange-playlist-items", playlistId],
} as const;
