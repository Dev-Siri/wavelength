import type { Playlist } from "$lib/types";

class PlaylistsStore {
  playlists = $state<Playlist[]>([]);
}

const playlistsStore = new PlaylistsStore();

export default playlistsStore;
