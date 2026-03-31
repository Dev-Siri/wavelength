package shared_type_constants

import "os"

type GoEnv string

const (
	GoEnvProduction  GoEnv = "prod"
	GoEnvDevelopment GoEnv = "dev"
)

func GetGoEnv() GoEnv {
	goEnv := os.Getenv("GO_ENV")

	if goEnv == "prod" {
		return GoEnvProduction
	}

	return GoEnvDevelopment
}
