package routes

import (
	music_controllers "github.com/Dev-Siri/wavelength/server/services/gateway/controllers/music"
	"github.com/Dev-Siri/wavelength/server/services/gateway/middleware"

	"github.com/gofiber/fiber/v2"
)

func registerMusicRoutes(app *fiber.App) {
	music := app.Group("/music")

	music.Get("/quick-picks", music_controllers.GetQuickPicks)
	music.Get("/search", music_controllers.SearchMusicTracks)
	music.Get("/search/uvideos", music_controllers.SearchYouTubeVideos)
	music.Get("/music-video-preview", music_controllers.GetMusicVideoPreviewId)
	music.Get("/track/:videoId/lyrics", music_controllers.GetTrackLyrics)
	music.Get("/track/:videoId/stats", music_controllers.GetMusicTrackStats)
	music.Get("/track/:videoId/duration", music_controllers.GetMusicDuration)
	music.Get("/track/:videoId/thumbnail", music_controllers.GetTrackThumbnail)
	music.Get("/search/search-recommendations", music_controllers.GetMusicSearchRecommendations)
	music.Get("/track/likes", middleware.JwtAuthMiddleware, music_controllers.GetLikedTracks)
	music.Get("/track/likes/count", middleware.JwtAuthMiddleware, music_controllers.GetLikedTrackCount)
	music.Get("/track/likes/:videoId/is-liked", middleware.JwtAuthMiddleware, music_controllers.IsTrackLiked)
	music.Get("/track/likes/length", middleware.JwtAuthMiddleware, music_controllers.GetLikedTracksLength)
	music.Patch("/track/likes", middleware.JwtAuthMiddleware, music_controllers.LikeTrack)
}
