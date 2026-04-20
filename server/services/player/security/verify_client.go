package security

import (
	"net/http"
	"slices"
	"strings"
)

const (
	ClientHeaderName   = "X-Wavelength-Client"
	clientReferrerSite = "https://mavelength.vercel.app"
)

var allowedClients = []string{
	"WEB",
	"ANDROID",
	"IOS",
	"TV_CAST",
}

func IsRequestWithBasicTrustHeaders(headers http.Header) bool {
	headerValues := headers.Values(ClientHeaderName)
	if len(headerValues) != 1 {
		return false
	}

	clientHeader := headerValues[0]
	if clientHeader == "" {
		return false
	}

	client := strings.ToUpper(strings.TrimSpace(clientHeader))
	withValidClient := slices.Contains(allowedClients, client)

	return withValidClient &&
		isRequestWithValidReferrerHeaders(client, headers) &&
		isRequestWithValidFetchHeaders(client, headers)
}

func isRequestWithValidReferrerHeaders(client string, headers http.Header) bool {
	referrerHeader := headers.Get("X-Referer")

	if client == "WEB" || client == "TV_CAST" {
		return strings.HasPrefix(referrerHeader, clientReferrerSite)
	}

	return referrerHeader == ""
}

func isRequestWithValidFetchHeaders(client string, headers http.Header) bool {
	fetchSite := headers.Get("X-Sec-Fetch-Site")

	if client == "WEB" || client == "TV_CAST" {
		return fetchSite == "cross-site" ||
			fetchSite == "same-site" ||
			fetchSite == "same-origin"
	}

	return fetchSite == ""
}
