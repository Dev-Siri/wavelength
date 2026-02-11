package logging

import (
	shared_type_constants "github.com/Dev-Siri/wavelength/server/shared/constants/types"

	"go.uber.org/zap"
)

var Logger *zap.Logger

func InitLogger() error {
	var logger *zap.Logger
	var err error

	goEnv := shared_type_constants.GetGoEnv()
	if goEnv == shared_type_constants.GoEnvProduction {
		logger, err = zap.NewProduction()
	} else {
		logger, err = zap.NewDevelopment()
	}

	if err != nil {
		return err
	}

	Logger = logger
	return nil
}

func DestroyLogger() {
	if Logger != nil {
		Logger.Sync()
	}
}
