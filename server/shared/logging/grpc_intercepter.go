package logging

import (
	"context"
	"time"

	"go.uber.org/zap"
	"google.golang.org/grpc"
)

func GrpcLoggingInterceptor(
	ctx context.Context,
	req any,
	info *grpc.UnaryServerInfo,
	handler grpc.UnaryHandler,
) (response any, err error) {
	start := time.Now()

	Logger.Info("gRPC (Request)",
		zap.String("method", info.FullMethod),
		zap.Any("request", req),
	)

	response, err = handler(ctx, req)

	Logger.Info("gRPC (Response)",
		zap.String("method", info.FullMethod),
		zap.Duration("duration", time.Since(start)),
		zap.Error(err),
	)

	return response, err
}
