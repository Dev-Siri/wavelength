package env

import "os"

func GetYtDlpCookiesPath() string {
	ytDlpCookiesPath := os.Getenv("YT_DLP_COOKIES_PATH")
	return ytDlpCookiesPath
}
