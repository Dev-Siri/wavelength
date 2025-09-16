package image_controllers

import "github.com/gofiber/fiber/v2"

func ManualImageUpload(ctx *fiber.Ctx) error {
	return ctx.SendStatus(fiber.StatusNotImplemented)
}
