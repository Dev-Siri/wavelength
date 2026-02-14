package oauth

import (
	shared_env "github.com/Dev-Siri/wavelength/server/shared/env"
	"golang.org/x/oauth2"
	"golang.org/x/oauth2/google"
)

var OAuth *oauth2.Config

func getRedirectURL() string {
	appURL := shared_env.GetAppURL()
	return appURL + "/auth/callback/google"
}

func InitOauth() error {
	clientId, clientSecret, err := shared_env.GetGoogleSecrets()
	if err != nil {
		return err
	}

	config := &oauth2.Config{
		ClientID:     clientId,
		ClientSecret: clientSecret,
		Scopes:       []string{"email", "profile"},
		RedirectURL:  getRedirectURL(),
		Endpoint:     google.Endpoint,
	}

	OAuth = config
	return nil
}
