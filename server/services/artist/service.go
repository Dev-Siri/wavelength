package main

import (
	"log"
	"net"
	"wavelength/proto/artistpb"
	artist_rpcs "wavelength/services/artist/rpcs"
	shared_clients "wavelength/shared/clients"
	shared_db "wavelength/shared/db"
	shared_env "wavelength/shared/env"
	"wavelength/shared/logging"

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

	if err := shared_clients.InitYtScraperClient(); err != nil {
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
	artistService := artist_rpcs.NewArtistService()
	artistpb.RegisterArtistServiceServer(grpcServer, artistService)

	logging.Logger.Info("ArtistService listening on "+addr, zap.String("port", port))
	if err := grpcServer.Serve(listener); err != nil {
		logging.Logger.Error("ArtistService launch failed.", zap.Error(err))
	}
}
