package main

import (
	"log"
	"wavelength/env"
	"wavelength/logging"

	"github.com/gofiber/fiber/v2"
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

	app := fiber.New()
	addr := ":" + env.GetPORT()

	if err := app.Listen(addr); err != nil {
		logging.Logger.Fatal("Failed to start server.", zap.String("address", addr))
	}
}
