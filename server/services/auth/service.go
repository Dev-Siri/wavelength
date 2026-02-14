package main

import (
	"log"
	"net"

	"github.com/Dev-Siri/wavelength/server/proto/authpb"
	"github.com/Dev-Siri/wavelength/server/services/auth/oauth"
	auth_rpcs "github.com/Dev-Siri/wavelength/server/services/auth/rpcs"
	shared_db "github.com/Dev-Siri/wavelength/server/shared/db"
	shared_env "github.com/Dev-Siri/wavelength/server/shared/env"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

	"go.uber.org/zap"
	"google.golang.org/grpc"
)

func main() {
	if err := logging.InitLogger(); err != nil {
		log.Fatalf("Failed to initialize logger: %s", err.Error())
	}

	if err := shared_env.InitEnv(); err != nil {
		logging.Logger.Error("Failed to initialize environment variables.", zap.Error(err))
	}

	if err := shared_db.Connect(); err != nil {
		logging.Logger.Error("Failed to initialize Postgres connection.", zap.Error(err))
	}

	if shared_db.Database != nil {
		defer func() {
			if err := shared_db.Database.Close(); err != nil {
				logging.Logger.Fatal("Failed to close database connection.", zap.Error(err))
			}
		}()
	}

	if err := shared_db.InitRedis(); err != nil {
		logging.Logger.Error("Failed to initialize Redis connection.", zap.Error(err))
	}

	if shared_db.Redis != nil {
		defer func() {
			if err := shared_db.Redis.Close(); err != nil {
				logging.Logger.Fatal("Failed to close Redis connection.", zap.Error(err))
			}
		}()
	}

	if err := oauth.InitOauth(); err != nil {
		logging.Logger.Error("OAuth initialization failed.", zap.Error(err))
	}

	port := shared_env.GetPORT()
	addr := ":" + port

	listener, err := net.Listen("tcp", addr)
	if err != nil {
		logging.Logger.Error("TCP Listener failed to listen on provided address.", zap.String("addr", addr), zap.Error(err))
	}

	grpcServer := grpc.NewServer(
		grpc.UnaryInterceptor(logging.GrpcLoggingInterceptor),
	)
	authService := auth_rpcs.NewAuthService()
	authpb.RegisterAuthServiceServer(grpcServer, authService)

	logging.Logger.Info("AuthService listening on "+addr, zap.String("port", port))
	if err := grpcServer.Serve(listener); err != nil {
		logging.Logger.Error("AuthService launch failed.", zap.Error(err))
	}
}
