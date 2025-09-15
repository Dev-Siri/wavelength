package api

import api_interface "wavelength/api/interface"

var YouTubeClient *api_interface.YouTubeMusicClient

func InitializeYouTubeClient() {
	YouTubeClient = &api_interface.YouTubeMusicClient{}
}
