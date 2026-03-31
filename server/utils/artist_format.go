package utils

import (
	"strings"

	"github.com/Dev-Siri/wavelength/server/proto/commonpb"
)

func FormatAndJoinArtists(artists []*commonpb.EmbeddedArtist) string {
	artistLen := len(artists)

	if artistLen == 1 {
		return artists[0].Title
	}

	if artistLen == 2 {
		return artists[0].Title + " & " + artists[1].Title
	}

	var artistText strings.Builder
	for i, artist := range artists {
		if i+1 == artistLen {
			artistText.WriteString("& " + artist.Title)
		} else {
			artistText.WriteString(artist.Title + ", ")
		}
	}

	return artistText.String()
}
