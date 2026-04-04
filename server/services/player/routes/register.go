package routes

import "github.com/gofiber/fiber/v2"

func RegisterRoutes(app *fiber.App) {
	registerStreamRoutes(app)
	registerCollectorRoutes(app)
	registerPlayerRoutes(app)
}
