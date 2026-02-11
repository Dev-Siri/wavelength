package security

import (
	"crypto/tls"
	"crypto/x509"

	shared_type_constants "github.com/Dev-Siri/wavelength/server/shared/constants/types"

	"google.golang.org/grpc/credentials"
	"google.golang.org/grpc/credentials/insecure"
)

func GetTransportCreds() (credentials.TransportCredentials, error) {
	goEnv := shared_type_constants.GetGoEnv()

	if goEnv == shared_type_constants.GoEnvDevelopment {
		return insecure.NewCredentials(), nil
	}

	systemRoots, err := x509.SystemCertPool()
	if err != nil {
		return nil, err
	}

	creds := credentials.NewTLS(&tls.Config{
		RootCAs:            systemRoots,
		InsecureSkipVerify: true,
	})
	return creds, nil
}
