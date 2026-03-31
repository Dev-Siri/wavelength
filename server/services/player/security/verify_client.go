package security

import (
	"net/http"
	"slices"
	"strings"
)

const (
	clientHeaderName   = "X-Wavelength-Client"
	clientReferrerSite = "https://mavelength.vercel.app"
)

var allowedClients = []string{
	"WEB",
	"ANDROID",
	"IOS",
}

func IsRequestWithBasicTrustHeaders(headers http.Header) bool {
	headerValues := headers.Values(clientHeaderName)
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

	if client == "WEB" {
		return strings.HasPrefix(referrerHeader, clientReferrerSite)
	}

	return referrerHeader == ""
}

func isRequestWithValidFetchHeaders(client string, headers http.Header) bool {
	fetchSite := headers.Get("X-Sec-Fetch-Site")

	if client == "WEB" {
		return fetchSite == "cross-site" ||
			fetchSite == "same-site" ||
			fetchSite == "same-origin"
	}

	return fetchSite == ""
}
