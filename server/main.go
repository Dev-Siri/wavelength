package main

import (
	"log"
	"wavelength/api"
	error_controllers "wavelength/controllers/errors"
	"wavelength/db"
	"wavelength/env"
	"wavelength/logging"
	"wavelength/middleware"
	"wavelength/routes"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/healthcheck"
	"go.uber.org/zap"
)

func main() {
	if err := logging.InitLogger(); err != nil {
		log.Fatal("Failed to initialize logger.")
	}

	if err := env.InitEnv(); err != nil {
		logging.Logger.Fatal("Failed to initialize dotenv for environment variables.", zap.Error(err))
	}

	if err := db.Connect(env.GetDBUrl()); err != nil {
		logging.Logger.Fatal("Failed to connect to the database.", zap.Error(err))
	}

	if db.Database != nil {
		defer db.Database.Close()
	}

	if err := api.InitializeYouTubeClients(env.GetGoogleApiKey()); err != nil {
		logging.Logger.Fatal("Failed to initialize YouTube clients.", zap.Error(err))
	}

	app := fiber.New(fiber.Config{
		ErrorHandler: error_controllers.ErrorHandler,
	})

	addr := ":" + env.GetPORT()
	staticDir := env.GetStaticDir()

	app.Static("/", staticDir)
	app.Use(middleware.LogMiddleware)
	app.Use(healthcheck.New())
	app.Use(cors.New(cors.Config{
		AllowOrigins: env.GetCorsOrigin(),
	}))

	routes.RegisterRoutes(app)

	if err := app.Listen(addr); err != nil {
		logging.Logger.Fatal("Failed to start server.", zap.String("address", addr))
	}
}
