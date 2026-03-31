package spotify

import (
	"net/http"

	shared_env "github.com/Dev-Siri/wavelength/server/shared/env"
)

type spotifyTransport struct {
	apiHost string
}

func (t *spotifyTransport) RoundTrip(req *http.Request) (*http.Response, error) {
	key, err := shared_env.GetRapidApiKey()
	if err != nil {
		return nil, err
	}

	req.Header.Add("x-rapidapi-key", key)
	req.Header.Add("x-rapidapi-host", t.apiHost)

	return http.DefaultTransport.RoundTrip(req)
}
