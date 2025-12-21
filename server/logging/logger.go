package logging

import (
	type_constants "wavelength/constants/types"

	"go.uber.org/zap"
)

var Logger *zap.Logger

func InitLogger() error {
	var logger *zap.Logger
	var err error

	goEnv := type_constants.GetGoEnv()
	if goEnv == type_constants.GoEnvProduction {
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
