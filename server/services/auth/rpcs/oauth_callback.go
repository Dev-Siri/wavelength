package auth_rpcs

import (
	"context"
	"database/sql"
	"encoding/json"
	"net/url"

	"github.com/Dev-Siri/wavelength/server/proto/authpb"
	"github.com/Dev-Siri/wavelength/server/services/auth/models"
	"github.com/Dev-Siri/wavelength/server/services/auth/oauth"
	"github.com/Dev-Siri/wavelength/server/services/auth/session"
	shared_db "github.com/Dev-Siri/wavelength/server/shared/db"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	"github.com/google/uuid"
	"go.uber.org/zap"
	"golang.org/x/oauth2"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

const googleUserInfoURL = "https://www.googleapis.com/oauth2/v2/userinfo"

func (a *AuthService) OAuthCallback(
	ctx context.Context,
	request *authpb.OAuthCallbackRequest,
) (*authpb.OAuthCallbackResponse, error) {
	redirectURI, err := session.ConsumeOAuthSessionData(ctx, request.State)
	if err != nil {
		logging.Logger.Error("OAuth session data read failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "OAuth session data read failed.")
	}

	oauthToken, err := oauth.OAuth.Exchange(ctx, request.Code)
	if err != nil {
		logging.Logger.Error("OAuth token exchange failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "OAuth token exchange failed.")
	}

	userInfo, err := getOAuthUserInfo(ctx, oauthToken)
	if err != nil {
		logging.Logger.Error("Google user info fetch failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Google user info fetch failed.")
	}

	userID, err := saveUser(userInfo)
	if err != nil {
		logging.Logger.Error("User save failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "User save failed.")
	}

	authToken, err := session.CreateNewJWTToken(userID, userInfo.Email, userInfo.Name, userInfo.Picture)
	if err != nil {
		logging.Logger.Error("Auth token creation failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Auth token creation failed.")
	}

	authCode, err := session.CreateAuthCode(ctx, authToken)
	if err != nil {
		logging.Logger.Error("Auth code creation failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Auth code creation failed.")
	}

	signedURI, err := signRedirectURI(redirectURI, authCode)
	if err != nil {
		logging.Logger.Error("Redirect URI signing failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Redirect URI signing failed.")
	}

	return &authpb.OAuthCallbackResponse{
		SignedUri: signedURI,
	}, nil
}

func getOAuthUserInfo(ctx context.Context, token *oauth2.Token) (*models.GoogleUser, error) {
	client := oauth.OAuth.Client(ctx, token)

	response, err := client.Get(googleUserInfoURL)
	if err != nil {
		return nil, err
	}

	defer response.Body.Close()

	var user models.GoogleUser
	if err := json.NewDecoder(response.Body).Decode(&user); err != nil {
		return nil, err
	}

	return &user, nil
}

// Saves user to the database and returns the User ID.
func saveUser(user *models.GoogleUser) (string, error) {
	row := shared_db.Database.QueryRow(`
		SELECT user_id FROM "users"
		WHERE email = $1;
	`, user.Email)

	var userID string
	err := row.Scan(&userID)

	if err != nil && err != sql.ErrNoRows {
		return "", err
	}

	// Exit if already in database.
	if err != sql.ErrNoRows {
		return userID, nil
	}

	newUserID := uuid.NewString()

	_, err = shared_db.Database.Exec(`
		INSERT INTO "users" (
			user_id,
			email,
			email_verified,
			auth_provider,
			display_name,
			picture_url
		) VALUES ( $1, $2, $3, $4, $5, $6 );
	`, newUserID, user.Email, true, "google", user.Name, user.Picture)
	return newUserID, err
}

func signRedirectURI(redirectURI, authCode string) (string, error) {
	signedRedirectURI, err := url.Parse(redirectURI)
	if err != nil {
		return "", err
	}

	queryParams := signedRedirectURI.Query()
	queryParams.Add("code", authCode)

	signedRedirectURI.RawQuery = queryParams.Encode()
	return signedRedirectURI.String(), nil
}
