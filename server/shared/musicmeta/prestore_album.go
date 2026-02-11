package shared_musicmeta

import (
	"context"

	"github.com/Dev-Siri/wavelength/server/proto/albumpb"
	"github.com/Dev-Siri/wavelength/server/proto/commonpb"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
)

func PrestoreAlbum(videoId string, album *commonpb.EmbeddedAlbum) error {
	if album == nil {
		return nil
	}

	_, err := clients.AlbumClient.CreateTrackAlbum(context.Background(), &albumpb.CreateTrackAlbumRequest{
		TrackId:  videoId,
		BrowseId: album.BrowseId,
		Title:    album.Title,
	})
	return err
}
