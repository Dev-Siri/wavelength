package shared_musicmeta

import (
	"context"
	"wavelength/proto/artistpb"
	"wavelength/proto/commonpb"
	shared_clients "wavelength/shared/clients"
)

func PrestoreArtists(videoId string, artists []*commonpb.EmbeddedArtist) error {
	for _, artist := range artists {
		_, err := shared_clients.ArtistClient.CreateAuthoredTrackArtist(context.Background(), &artistpb.CreateAuthoredTrackArtistRequest{
			AuthoredTrackId: videoId,
			BrowseId:        artist.BrowseId,
			Title:           artist.Title,
		})

		if err != nil {
			return err
		}
	}

	return nil
}
