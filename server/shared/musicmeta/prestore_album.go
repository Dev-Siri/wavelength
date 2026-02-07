package shared_musicmeta

import (
	"context"
	"wavelength/proto/albumpb"
	"wavelength/proto/commonpb"
	shared_clients "wavelength/shared/clients"
)

func PrestoreAlbum(videoId string, album *commonpb.EmbeddedAlbum) error {
	if album == nil {
		return nil
	}

	_, err := shared_clients.AlbumClient.CreateTrackAlbum(context.Background(), &albumpb.CreateTrackAlbumRequest{
		TrackId:  videoId,
		BrowseId: album.BrowseId,
		Title:    album.Title,
	})
	return err
}
