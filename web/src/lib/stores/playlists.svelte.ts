import type { PlayList } from "$lib/db/schema";

class PlaylistsStore {
  playlists = $state<PlayList[]>([]);
}

const playlistsStore = new PlaylistsStore();

export default playlistsStore;
