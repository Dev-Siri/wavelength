ALTER TABLE "playlist_tracks" ALTER COLUMN "name" SET NOT NULL;--> statement-breakpoint
ALTER TABLE "playlist_tracks" ALTER COLUMN "cover_image" SET NOT NULL;--> statement-breakpoint
ALTER TABLE "playlist_tracks" ALTER COLUMN "playlist_id" SET NOT NULL;--> statement-breakpoint
ALTER TABLE "playlists" ALTER COLUMN "name" SET NOT NULL;--> statement-breakpoint
ALTER TABLE "playlists" ALTER COLUMN "author_google_email" SET NOT NULL;