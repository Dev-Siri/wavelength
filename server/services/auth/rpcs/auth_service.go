package auth_rpcs

import "github.com/Dev-Siri/wavelength/server/proto/authpb"

type AuthService struct {
	authpb.UnimplementedAuthServiceServer
}

func NewAuthService() *AuthService {
	return &AuthService{}
}
