package api_interface

import (
	"net/http"
	"net/url"
	"wavelength/constants"
	"wavelength/env"
)

var ytHttpClient = &http.Client{}

func rapidApiFetch(path string, queryParams map[string]string) (*http.Response, error) {
	base, err := url.Parse(constants.RapidApiUrl)

	if err != nil {
		return nil, err
	}

	base.Path, err = url.JoinPath(base.Path, path)

	if err != nil {
		return nil, err
	}

	q := base.Query()

	for k, v := range queryParams {
		if v != "" {
			q.Set(k, v)
		}
	}

	base.RawQuery = q.Encode()

	print(base.String())

	request, err := http.NewRequest(http.MethodGet, base.String(), nil)

	if err != nil {
		return nil, err
	}

	rapidApiKey, rapidApiHost := env.GetRapidApiKeys()

	request.Header.Set("X-RapidAPI-Key", rapidApiKey)
	request.Header.Set("X-RapidAPI-Host", rapidApiHost)

	return ytHttpClient.Do(request)
}
