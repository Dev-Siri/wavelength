package models

import (
	"encoding/json"

	"github.com/gofiber/fiber/v2"
	"google.golang.org/protobuf/encoding/protojson"
	"google.golang.org/protobuf/proto"
)

func Success[T any](ctx *fiber.Ctx, data T) error {
	if msg, ok := any(data).(proto.Message); ok {
		bytes, err := protojson.Marshal(msg)
		if err != nil {
			return err
		}

		response := fiber.Map{
			"success":   true,
			"requestId": ctx.Locals("requestid"),
			"data":      json.RawMessage(bytes),
		}

		return ctx.JSON(response)
	}

	return ctx.JSON(fiber.Map{
		"success":   true,
		"requestId": ctx.Locals("requestid"),
		"data":      data,
	})
}

func Error(ctx *fiber.Ctx, message string) error {
	response := &fiber.Map{
		"success":   false,
		"requestId": ctx.Locals("requestid"),
		"message":   message,
	}

	return ctx.JSON(response)
}
