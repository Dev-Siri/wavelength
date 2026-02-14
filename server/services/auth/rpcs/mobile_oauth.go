package auth_rpcs

import (
	"context"

	"github.com/Dev-Siri/wavelength/server/proto/authpb"
	"github.com/Dev-Siri/wavelength/server/services/auth/oauth"
	"github.com/Dev-Siri/wavelength/server/services/auth/session"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (a *AuthService) MobileOAuth(
	ctx context.Context,
	request *authpb.MobileOAuthRequest,
) (*authpb.MobileOAuthResponse, error) {
	oauthToken, err := oauth.OAuth.Exchange(ctx, request.ServerAuthCode)
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

	return &authpb.MobileOAuthResponse{
		AuthCode: authCode,
	}, nil
}
