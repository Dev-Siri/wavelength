package auth_rpcs

import (
	"context"

	"github.com/Dev-Siri/wavelength/server/proto/authpb"
	"github.com/Dev-Siri/wavelength/server/services/auth/session"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (a *AuthService) ConsumeAuthToken(
	ctx context.Context,
	request *authpb.ConsumeAuthTokenRequest,
) (*authpb.ConsumeAuthTokenResponse, error) {
	authToken, err := session.ConsumeAuthCode(ctx, request.AuthCode)
	if err != nil {
		logging.Logger.Error("Auth token consumption failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Auth token consumption failed.")
	}

	return &authpb.ConsumeAuthTokenResponse{
		AuthToken: authToken,
	}, nil
}
