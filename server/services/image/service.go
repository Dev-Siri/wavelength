package main

import (
	"log"
	"net"

	"github.com/Dev-Siri/wavelength/server/proto/imagepb"
	image_rpcs "github.com/Dev-Siri/wavelength/server/services/image/rpcs"
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

	port := shared_env.GetPORT()
	addr := ":" + port

	listener, err := net.Listen("tcp", addr)
	if err != nil {
		logging.Logger.Error("TCP Listener failed to listen on provided address.", zap.String("addr", addr), zap.Error(err))
	}

	grpcServer := grpc.NewServer(
		grpc.UnaryInterceptor(logging.GrpcLoggingInterceptor),
	)
	imageService := image_rpcs.NewImageService()
	imagepb.RegisterImageServiceServer(grpcServer, imageService)

	logging.Logger.Info("ImageService listening on "+addr, zap.String("port", port))
	if err := grpcServer.Serve(listener); err != nil {
		logging.Logger.Error("ImageService launch failed.", zap.Error(err))
	}
}
