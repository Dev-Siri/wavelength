package routes

import (
	music_controllers "wavelength/controllers/music"
	"wavelength/middleware"

	"github.com/gofiber/fiber/v2"
)

func registerMusicRoutes(app *fiber.App) {
	app.Get("/music/quick-picks", music_controllers.GetQuickPicks)
	app.Get("/music/search", music_controllers.SearchMusicTracks)
	app.Get("/music/search/uvideos", music_controllers.SearchYouTubeVideos)
	app.Get("/music/music-video-preview", music_controllers.GetMusicVideoPreviewId)
	app.Get("/music/track/:videoId/lyrics", music_controllers.GetTrackLyrics)
	app.Get("/music/track/:videoId/stats", music_controllers.GetMusicTrackStats)
	app.Get("/music/track/:videoId/duration", music_controllers.GetMusicDuration)
	app.Get("/music/track/:videoId/thumbnail", music_controllers.GetTrackThumbnail)
	app.Get("/music/search/search-recommendations", music_controllers.GetMusicSearchRecommendations)
	app.Get("/music/track/likes", middleware.JwtAuthMiddleware, music_controllers.GetLikedTracks)
	app.Get("/music/track/likes/count", middleware.JwtAuthMiddleware, music_controllers.GetLikedTrackCount)
	app.Get("/music/track/likes/:videoId/is-liked", middleware.JwtAuthMiddleware, music_controllers.IsTrackLiked)
	app.Get("/music/track/likes/length", middleware.JwtAuthMiddleware, music_controllers.GetLikedTracksLength)
	app.Patch("/music/track/likes", middleware.JwtAuthMiddleware, music_controllers.LikeTrack)
}
