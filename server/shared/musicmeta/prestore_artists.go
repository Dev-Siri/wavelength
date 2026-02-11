package shared_musicmeta

import (
	"context"

	"github.com/Dev-Siri/wavelength/server/proto/artistpb"
	"github.com/Dev-Siri/wavelength/server/proto/commonpb"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
)

func PrestoreArtists(videoId string, artists []*commonpb.EmbeddedArtist) error {
	for _, artist := range artists {
		_, err := clients.ArtistClient.CreateAuthoredTrackArtist(context.Background(), &artistpb.CreateAuthoredTrackArtistRequest{
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
