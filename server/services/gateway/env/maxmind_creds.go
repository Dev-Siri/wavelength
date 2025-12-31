package env

import "os"

func GetMaxMindCreds() (string, string) {
	maxMindAccountId := os.Getenv("MAXMIND_ACCOUNT_ID")
	maxmindLicenseKey := os.Getenv("MAXMIND_LICENSE_KEY")

	return maxMindAccountId, maxmindLicenseKey
}
