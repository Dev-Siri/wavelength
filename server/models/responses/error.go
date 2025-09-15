package responses

import (
	"encoding/json"
	"wavelength/logging"

	"go.uber.org/zap"
)

type Error struct {
	Success bool   `json:"success"`
	Message string `json:"message"`
}

func CreateErrorResponse(errorResponse *Error) []byte {
	errorResponse.Success = false
	jsonBytes, err := json.Marshal(errorResponse)

	if err != nil {
		go logging.Logger.Error("Failed to serialize response", zap.Error(err))
		return nil
	}

	return jsonBytes
}
