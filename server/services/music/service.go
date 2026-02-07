package main

import (
	"log"
	"net"
	"wavelength/proto/musicpb"
	"wavelength/services/music/api"
	music_rpcs "wavelength/services/music/rpcs"
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

	if err := shared_clients.InitArtistClient(); err != nil {
		logging.Logger.Fatal("Artist-service client failed to connect.", zap.Error(err))
	}

	if err := shared_clients.InitAlbumClient(); err != nil {
		logging.Logger.Fatal("Album-service client failed to connect.", zap.Error(err))
	}

	if err := api.InitializeYouTubeV3Client(); err != nil {
		logging.Logger.Fatal("Failed to initialize YouTube V3 client.", zap.Error(err))
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
	musicService := music_rpcs.NewMusicService()
	musicpb.RegisterMusicServiceServer(grpcServer, musicService)

	logging.Logger.Info("MusicService listening on "+addr, zap.String("port", port))
	if err := grpcServer.Serve(listener); err != nil {
		logging.Logger.Error("MusicService launch failed.", zap.Error(err))
	}
}
