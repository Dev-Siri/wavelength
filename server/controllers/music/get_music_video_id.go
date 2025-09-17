package music_controllers

import "github.com/gofiber/fiber/v2"

// NOTE:
/*
  The "Music Video ID Route" is at best, a guesser. It can only try to accurately
  match the song name or artist name to get the actual music video. But there are many times it
  may not be accurate. So a wrong music video or even a short can get selected. Since YouTube doesn't provide any
  filters (music video, track or normal video) whatsoever for these use cases.
*/
func GetMusicVideoId(ctx *fiber.Ctx) error {
	return nil
}
