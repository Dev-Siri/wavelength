import type { PlayList } from "$lib/db/schema.js";

class PlaylistsStore {
  playlists = $state<PlayList[]>([]);
}

const playlistsStore = new PlaylistsStore();

export default playlistsStore;
