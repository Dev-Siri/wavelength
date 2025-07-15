import { openDB, type DBSchema } from "idb";

import type { PlayList, PlayListTrack } from "./schema";

import {
  DB_INDIVIDUAL_VERSION,
  DB_NAME,
  DB_PLAYLISTS_STORE_NAME,
  DB_TRACKS_STORE_NAME,
} from "$lib/constants/db";

import type { BaseMusicTrack } from "$lib/server/api/interface/types";
import type { Lyric } from "../../routes/api/music/[videoId]/lyrics/types";

export interface WavelengthDB extends DBSchema {
  playlists: {
    key: string;
    value: PlayList;
  };
  tracks: {
    key: string;
    value: PlayListTrack;
    indexes: {
      by_playlistId: string;
    };
  };
  lyrics: {
    key: string;
    value: Lyric &
      Pick<BaseMusicTrack, "videoId"> & {
        lyricId: string;
        order: number;
      };
    indexes: {
      by_videoId: string;
    };
  };
}

export default async function getClientDB() {
  if (navigator.storage && navigator.storage.persist) await navigator.storage.persist();

  return openDB<WavelengthDB>(DB_NAME, DB_INDIVIDUAL_VERSION, {
    upgrade(db) {
      if (!db.objectStoreNames.contains(DB_PLAYLISTS_STORE_NAME))
        db.createObjectStore(DB_PLAYLISTS_STORE_NAME, { keyPath: "playlistId" });

      if (!db.objectStoreNames.contains("lyrics")) {
        const store = db.createObjectStore("lyrics", { keyPath: "lyricId" });
        store.createIndex("by_videoId", "videoId", { unique: false });
      }

      if (!db.objectStoreNames.contains(DB_TRACKS_STORE_NAME)) {
        const store = db.createObjectStore(DB_TRACKS_STORE_NAME, { keyPath: "playlistTrackId" });
        store.createIndex("by_playlistId", "playlistId", { unique: false });
      }
    },
  });
}
