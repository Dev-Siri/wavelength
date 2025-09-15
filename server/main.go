package main

import (
	"log"
	"wavelength/api"
	error_controllers "wavelength/controllers/errors"
	"wavelength/db"
	"wavelength/env"
	"wavelength/logging"
	"wavelength/middleware"
	"wavelength/models/responses"
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

	app := fiber.New(fiber.Config{
		ErrorHandler: func(ctx *fiber.Ctx, err error) error {
			if e, ok := err.(*fiber.Error); ok && e.Code == fiber.StatusMethodNotAllowed {
				return error_controllers.MethodNotAllowed(ctx)
			} else if e.Code == fiber.StatusNotFound {
				return error_controllers.NotFound(ctx)
			}

			return ctx.Status(fiber.StatusInternalServerError).JSON(responses.Error{
				Success: false,
				Message: err.Error(),
			})
		},
	})

	api.InitializeYouTubeClient()

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
