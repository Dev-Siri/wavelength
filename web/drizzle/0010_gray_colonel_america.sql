DO $$ BEGIN
 CREATE TYPE "public"."video_type" AS ENUM('track', 'uvideo');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
ALTER TABLE "playlist_tracks" ADD COLUMN "video_type" "video_type" NOT NULL;