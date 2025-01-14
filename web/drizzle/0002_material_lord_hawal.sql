ALTER TABLE "playlists" ADD COLUMN "author_google_email" varchar(255);--> statement-breakpoint
ALTER TABLE "playlist_tracks" DROP COLUMN IF EXISTS "author_google_email";