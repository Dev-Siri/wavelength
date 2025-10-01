package utils

import (
	"bufio"
	"net/http"
	"net/http/cookiejar"
	"net/url"
	"os"
	"strconv"
	"strings"
	"time"
)

func LoadCookies(jar *cookiejar.Jar, filename string) error {
	file, err := os.Open(filename)

	if err != nil {
		return err
	}

	defer file.Close()

	scanner := bufio.NewScanner(file)

	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())

		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}

		parts := strings.Split(line, "\t")

		if len(parts) < 7 {
			continue
		}

		domain := parts[0]
		path := parts[2]
		secure := parts[3] == "TRUE"
		expiry := parts[4]
		name := parts[5]
		value := parts[6]

		u := &url.URL{
			Scheme: "http",
			Host:   domain,
			Path:   path,
		}
		if secure {
			u.Scheme = "https"
		}

		var exp time.Time
		if ts, err := parseExpiry(expiry); err == nil {
			exp = ts
		}

		c := &http.Cookie{
			Name:    name,
			Value:   value,
			Path:    path,
			Domain:  domain,
			Secure:  secure,
			Expires: exp,
		}

		jar.SetCookies(u, []*http.Cookie{c})
	}

	return scanner.Err()
}

func parseExpiry(raw string) (time.Time, error) {
	sec, err := strconv.ParseInt(raw, 10, 64)

	if err != nil {
		return time.Time{}, err
	}

	return time.Unix(sec, 0), nil
}
