// Gateway is the entrypoint of all services relating to handling application metadata.
//
// The music streaming part of the application is handled by the player server, hosted separately from the gateway.
package main

import (
	"log"
	"time"

	"github.com/Dev-Siri/wavelength/server/services/gateway/middleware"
	"github.com/Dev-Siri/wavelength/server/services/gateway/routes"
	"github.com/Dev-Siri/wavelength/server/shared/apicontrollers"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	shared_type_constants "github.com/Dev-Siri/wavelength/server/shared/constants/types"
	shared_env "github.com/Dev-Siri/wavelength/server/shared/env"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/healthcheck"
	"github.com/gofiber/fiber/v2/middleware/limiter"
	"github.com/gofiber/fiber/v2/middleware/requestid"
	"go.uber.org/zap"
)

const (
	rateLimitMaxRequests = 1000
	rateLimitExpiration  = time.Second * 30
	gatewayName          = "wavelength/musicmeta-api"
)

func main() {
	if err := logging.InitLogger(); err != nil {
		log.Fatal("Failed to initialize logger.")
	}

	if err := shared_env.InitEnv(); err != nil {
		logging.Logger.Error("Failed to initialize dotenv for environment variables.", zap.Error(err))
	}

	if err := clients.InitPlaylistClient(); err != nil {
		logging.Logger.Error("Playlist-service client failed to connect.", zap.Error(err))
	}

	if err := clients.InitMusicClient(); err != nil {
		logging.Logger.Error("Music-service client failed to connect.", zap.Error(err))
	}

	if err := clients.InitArtistClient(); err != nil {
		logging.Logger.Error("Artist-service client failed to connect.", zap.Error(err))
	}

	if err := clients.InitAlbumClient(); err != nil {
		logging.Logger.Error("Album-service client failed to connect.", zap.Error(err))
	}

	if err := clients.InitImageClient(); err != nil {
		logging.Logger.Error("Image-service client failed to connect.", zap.Error(err))
	}

	if err := clients.InitAuthClient(); err != nil {
		logging.Logger.Error("Auth-service client failed to connect.", zap.Error(err))
	}

	app := fiber.New(fiber.Config{
		ErrorHandler:            apicontrollers.GenericErrorHandler,
		EnableTrustedProxyCheck: true,
		TrustedProxies:          []string{"0.0.0.0/0"},
		AppName:                 gatewayName,
	})

	addr := ":" + shared_env.GetPORT()
	staticDir := shared_env.GetStaticDir()

	app.Use(requestid.New())
	app.Use(limiter.New(limiter.Config{
		Max:        rateLimitMaxRequests,
		Expiration: rateLimitExpiration,
		Next: func(ctx *fiber.Ctx) bool {
			goEnv := shared_type_constants.GetGoEnv()
			return goEnv == shared_type_constants.GoEnvDevelopment || ctx.Path() == "/healthz" || ctx.Path() == "/search/search-recommendations"
		},
		LimitReached:      apicontrollers.RateLimitExceededHandler,
		LimiterMiddleware: limiter.SlidingWindow{},
	}))
	app.Use(cors.New(cors.Config{
		AllowOrigins: shared_env.GetCorsOrigin(),
	}))

	app.Static("/", staticDir)
	app.Use(middleware.LogMiddleware)
	app.Use(healthcheck.New())

	routes.RegisterRoutes(app)

	if err := app.Listen(addr); err != nil {
		logging.Logger.Fatal("Failed to start server.", zap.String("address", addr))
	}
}
