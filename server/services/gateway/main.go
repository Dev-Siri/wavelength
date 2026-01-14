package main

import (
	"log"
	"wavelength/services/gateway/clients"
	error_controllers "wavelength/services/gateway/controllers/errors"
	"wavelength/services/gateway/db"
	"wavelength/services/gateway/env"
	"wavelength/services/gateway/middleware"
	"wavelength/services/gateway/routes"
	shared_clients "wavelength/shared/clients"
	shared_env "wavelength/shared/env"
	"wavelength/shared/logging"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/healthcheck"
	"github.com/gofiber/fiber/v2/middleware/requestid"
	"go.uber.org/zap"
)

func main() {
	if err := logging.InitLogger(); err != nil {
		log.Fatal("Failed to initialize logger.")
	}

	if err := shared_env.InitEnv(); err != nil {
		logging.Logger.Fatal("Failed to initialize dotenv for environment variables.", zap.Error(err))
	}

	if err := clients.InitPlaylistClient(); err != nil {
		logging.Logger.Fatal("Playlist-service client failed to connect.", zap.Error(err))
	}

	if err := clients.InitMusicClient(); err != nil {
		logging.Logger.Fatal("Music-service client failed to connect.", zap.Error(err))
	}

	if err := shared_clients.InitArtistClient(); err != nil {
		logging.Logger.Fatal("Artist-service client failed to connect.", zap.Error(err))
	}

	if err := clients.InitAlbumClient(); err != nil {
		logging.Logger.Fatal("Album-service client failed to connect.", zap.Error(err))
	}

	if err := clients.InitImageClient(); err != nil {
		logging.Logger.Fatal("Image-service client failed to connect.", zap.Error(err))
	}

	if err := db.InitGeoIP(); err != nil {
		// Intentional to not use .Fatal to continue the application bootstrapping even after failure.
		logging.Logger.Error("Failed to initialize GeoIP Lookup Database.")
	}

	app := fiber.New(fiber.Config{
		ErrorHandler:            error_controllers.ErrorHandler,
		EnableTrustedProxyCheck: true,
		TrustedProxies:          []string{"0.0.0.0/0"},
		ProxyHeader:             "CF-Connecting-IP",
	})

	addr := ":" + shared_env.GetPORT()
	staticDir := env.GetStaticDir()

	app.Use(requestid.New())
	app.Use(cors.New(cors.Config{
		AllowOrigins: env.GetCorsOrigin(),
	}))

	app.Static("/", staticDir)
	app.Use(middleware.LogMiddleware)
	app.Use(healthcheck.New())

	routes.RegisterRoutes(app)

	if err := app.Listen(addr); err != nil {
		logging.Logger.Fatal("Failed to start server.", zap.String("address", addr))
	}
}
