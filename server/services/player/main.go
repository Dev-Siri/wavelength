// Player is a separate API from the main gateway.
//
// Player itself acts as a gateway to other services related to the player.
// The purpose of this separation is that the player, compared to the API gateway, handles
// more long-lived connections with web-sockets, and communicates with services that perform
// the actual streaming of music content to the client.
// Additionally, if the player service suffers a failure, then the API gateway server stays up.
package main

import (
	"log"
	"time"

	"github.com/Dev-Siri/wavelength/server/services/player/routes"
	"github.com/Dev-Siri/wavelength/server/shared/apicontrollers"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	shared_db "github.com/Dev-Siri/wavelength/server/shared/db"
	shared_env "github.com/Dev-Siri/wavelength/server/shared/env"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	"github.com/Dev-Siri/wavelength/server/shared/middleware"
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/healthcheck"
	"github.com/gofiber/fiber/v2/middleware/limiter"
	"github.com/gofiber/fiber/v2/middleware/requestid"
	"go.uber.org/zap"
)

// Player is an expensive service, whose spam may burn a lot of bills.
// It's much stricter with handling security.
const (
	rateLimitMaxRequests = 600
	rateLimitExpiration  = time.Second * 15
	apiReadTimeout       = time.Second * 15
	apiWriteTimeout      = time.Second * 15
	idleTimeout          = time.Minute * 2
	gatewayName          = "wavelength/player"
)

func main() {
	if err := logging.InitLogger(); err != nil {
		log.Fatal("Failed to initialize logger.")
	}

	if err := shared_env.InitEnv(); err != nil {
		logging.Logger.Error("Failed to initialize dotenv for environment variables.", zap.Error(err))
	}

	if err := shared_db.ConnectStreamDatabase(); err != nil {
		logging.Logger.Error("Failed to initialize Postgres connection.", zap.Error(err))
	}

	if shared_db.StreamDatabase != nil {
		defer func() {
			if err := shared_db.StreamDatabase.Close(); err != nil {
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

	if err := clients.InitCollectorClient(); err != nil {
		logging.Logger.Error("Collector-service failed to initialize.", zap.Error(err))
	}

	if err := shared_db.InitObjectStorage(); err != nil {
		logging.Logger.Error("Failed to initialize GCS Object Store.", zap.Error(err))
	}

	if err := clients.InitYtScraperClient(); err != nil {
		logging.Logger.Error("YtScraper-service initialization failed.", zap.Error(err))
	}

	app := fiber.New(fiber.Config{
		ErrorHandler:            apicontrollers.GenericErrorHandler,
		EnableTrustedProxyCheck: true,
		TrustedProxies:          []string{"0.0.0.0/0"},
		ReadTimeout:             apiReadTimeout,
		WriteTimeout:            apiWriteTimeout,
		IdleTimeout:             idleTimeout,
		AppName:                 gatewayName,
	})

	addr := ":" + shared_env.GetPORT()
	staticDir := shared_env.GetStaticDir()

	app.Use(requestid.New())
	app.Use(healthcheck.New())
	app.Use(limiter.New(limiter.Config{
		Max:               rateLimitMaxRequests,
		Expiration:        rateLimitExpiration,
		LimitReached:      apicontrollers.RateLimitExceededHandler,
		LimiterMiddleware: limiter.SlidingWindow{},
	}))
	app.Use(cors.New(cors.Config{
		AllowOrigins: shared_env.GetCorsOrigin(),
	}))

	app.Static("/", staticDir)
	app.Use(middleware.LogMiddleware)

	routes.RegisterRoutes(app)

	if err := app.Listen(addr); err != nil {
		logging.Logger.Fatal("Failed to start server.", zap.String("address", addr))
	}
}
