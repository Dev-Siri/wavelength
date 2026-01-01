package main

import (
	"log"
	"wavelength/services/gateway/api"
	error_controllers "wavelength/services/gateway/controllers/errors"
	"wavelength/services/gateway/db"
	"wavelength/services/gateway/env"
	"wavelength/services/gateway/middleware"
	"wavelength/services/gateway/routes"
	shared_db "wavelength/shared/db"
	shared_env "wavelength/shared/env"
	"wavelength/shared/logging"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/healthcheck"
	"go.uber.org/zap"
)

func main() {
	if err := logging.InitLogger(); err != nil {
		log.Fatal("Failed to initialize logger.")
	}

	if err := shared_env.InitEnv(); err != nil {
		logging.Logger.Fatal("Failed to initialize dotenv for environment variables.", zap.Error(err))
	}

	if err := shared_db.Connect(); err != nil {
		logging.Logger.Fatal("Failed to connect to the database.", zap.Error(err))
	}

	if shared_db.Database != nil {
		defer func() {
			if err := shared_db.Database.Close(); err != nil {
				logging.Logger.Fatal("Failed to close database connection.", zap.Error(err))
			}
		}()
	}

	if err := api.InitializeYouTubeClients(env.GetGoogleApiKey()); err != nil {
		logging.Logger.Fatal("Failed to initialize YouTube clients.", zap.Error(err))
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
