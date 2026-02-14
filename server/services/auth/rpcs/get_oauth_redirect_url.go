package auth_rpcs

import (
	"context"

	"github.com/Dev-Siri/wavelength/server/proto/authpb"
	"github.com/Dev-Siri/wavelength/server/services/auth/oauth"
	"github.com/Dev-Siri/wavelength/server/services/auth/session"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	"go.uber.org/zap"
	"golang.org/x/oauth2"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (a *AuthService) GetOAuthRedirectUrl(
	ctx context.Context,
	request *authpb.GetOAuthRedirectUrlRequest,
) (*authpb.GetOAuthRedirectUrlResponse, error) {
	oauthSessionID, err := session.CreateOAuthSession(ctx, request.RedirectUri)
	if err != nil {
		logging.Logger.Error("OAuth session creation failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "OAuth session creation failed.")
	}

	url := oauth.OAuth.AuthCodeURL(oauthSessionID, oauth2.AccessTypeOffline)
	return &authpb.GetOAuthRedirectUrlResponse{
		OauthUri: url,
	}, nil
}
