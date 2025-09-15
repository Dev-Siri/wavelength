package api

import api_interface "wavelength/api/interface"

var YoutubeClient *api_interface.YoutubeMusicClient

func InitializeYoutubeClient() {
	YoutubeClient = &api_interface.YoutubeMusicClient{}
}
