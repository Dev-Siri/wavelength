import { boolean, char, integer, pgEnum, pgTable, text, varchar } from "drizzle-orm/pg-core";

import { JS_UUID_LENGTH } from "../../lib/constants/utils";

export const videoTypeEnum = pgEnum("video_type", ["track", "uvideo"]);

export const playlists = pgTable("playlists", {
  playlistId: char("playlist_id", { length: JS_UUID_LENGTH }).primaryKey(),
  name: varchar("name", { length: 100 }).notNull(),
  authorGoogleEmail: varchar("author_google_email", { length: 255 }).notNull(),
  authorName: varchar("author_name", { length: 255 }).notNull(),
  authorImage: text("author_image").notNull(),
  coverImage: text("cover_image"),
  isPublic: boolean("is_public").notNull().default(false),
});

export const playlistTracks = pgTable("playlist_tracks", {
  playlistTrackId: char("playlist_track_id", { length: JS_UUID_LENGTH }).primaryKey(),
  title: varchar("title", { length: 255 }).notNull(),
  thumbnail: text("thumbnail").notNull(),
  positionInPlaylist: integer("position_in_playlist").notNull(),
  isExplicit: boolean("is_explicit").notNull(),
  author: varchar("author", { length: 255 }).notNull(),
  duration: varchar("duration", { length: 10 }).notNull(),
  videoId: varchar("video_id", { length: 11 }).notNull(),
  videoType: videoTypeEnum("video_type").notNull(),
  playlistId: char("playlist_id", { length: JS_UUID_LENGTH })
    .notNull()
    .references(() => playlists.playlistId),
});

export type PlayList = typeof playlists.$inferSelect;
export type PlayListTrack = typeof playlistTracks.$inferSelect;
export type VideoTypeEnum = (typeof videoTypeEnum.enumValues)[number];
