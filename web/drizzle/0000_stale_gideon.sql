CREATE TABLE IF NOT EXISTS "playlist_tracks" (
	"playlist_track_id" char(36) PRIMARY KEY NOT NULL,
	"name" varchar(255),
	"cover_image" text,
	"is_explicit" boolean,
	"duration" varchar(10),
	"playlist_id" char(36)
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "playlists" (
	"playlist_id" char(36) PRIMARY KEY NOT NULL,
	"name" varchar(100),
	"cover_image" text
);
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "playlist_tracks" ADD CONSTRAINT "playlist_tracks_playlist_id_playlists_playlist_id_fk" FOREIGN KEY ("playlist_id") REFERENCES "public"."playlists"("playlist_id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
