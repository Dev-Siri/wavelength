package main

import (
	"log"
	"net"

	"github.com/Dev-Siri/wavelength/server/proto/albumpb"
	album_rpcs "github.com/Dev-Siri/wavelength/server/services/album/rpcs"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
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

	if err := clients.InitYtScraperClient(); err != nil {
		logging.Logger.Fatal("YtScraper-service client failed to connect.", zap.Error(err))
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

	port := shared_env.GetPORT()
	addr := ":" + port

	listener, err := net.Listen("tcp", addr)
	if err != nil {
		logging.Logger.Error("TCP Listener failed to listen on provided address.", zap.String("addr", addr), zap.Error(err))
	}

	grpcServer := grpc.NewServer(
		grpc.UnaryInterceptor(logging.GrpcLoggingInterceptor),
	)
	albumService := album_rpcs.NewAlbumService()
	albumpb.RegisterAlbumServiceServer(grpcServer, albumService)

	logging.Logger.Info("AlbumService listening on "+addr, zap.String("port", port))
	if err := grpcServer.Serve(listener); err != nil {
		logging.Logger.Error("AlbumService launch failed.", zap.Error(err))
	}
}
