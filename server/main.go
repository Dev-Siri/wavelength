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
	"go.uber.org/zap"
)

func main() {
	if err := logging.InitLogger(); err != nil {
		log.Fatal("Failed to initialize logger.")
		return
	}

	if err := env.InitEnv(); err != nil {
		logging.Logger.Fatal("Failed to initialize dotenv for environment variables.")
	}

	if err := db.Connect(env.GetDBUrl()); err != nil {
		logging.Logger.Fatal("Failed to connect to the database.")
		return
	}

	if db.Database != nil {
		defer db.Database.Close()
	}

	api.InitializeYouTubeClient()

	app := fiber.New(fiber.Config{
		ErrorHandler: error_controllers.ErrorHandler,
	})

	addr := ":" + env.GetPORT()

	app.Use(middleware.LogMiddleware)
	app.Use(cors.New(cors.Config{
		AllowOrigins: env.GetCorsOrigin(),
	}))

	routes.RegisterRoutes(app)

	if err := app.Listen(addr); err != nil {
		logging.Logger.Fatal("Failed to start server.", zap.String("address", addr))
	}
}
