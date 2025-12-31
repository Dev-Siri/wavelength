package db

import (
	"archive/tar"
	"bytes"
	"compress/gzip"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
	"wavelength/services/gateway/constants"
	"wavelength/services/gateway/env"

	"github.com/oschwald/geoip2-golang/v2"
)

var GeoIpDb *geoip2.Reader

func InitGeoIP() error {
	path := env.GetGeoIPMMDBPath()

	if err := downloadGeoIPDB(path); err != nil {
		return err
	}

	db, err := geoip2.Open(path)
	if err != nil {
		return err
	}

	GeoIpDb = db
	return nil
}

func downloadGeoIPDB(out string) error {
	os.MkdirAll(constants.LocalAppLibPath, os.ModePerm)

	_, err := os.Stat(out)
	if err == nil {
		return nil
	}

	accountId, licenseKey := env.GetMaxMindCreds()

	request, err := http.NewRequest(http.MethodGet, constants.MaxMindDbDownloadUrl, nil)
	if err != nil {
		return err
	}

	request.SetBasicAuth(accountId, licenseKey)
	response, err := http.DefaultClient.Do(request)
	if err != nil {
		return err
	}

	defer response.Body.Close()

	if response.StatusCode != http.StatusOK {
		return fmt.Errorf("GeoIP DB Download failed: %s", response.Status)
	}

	geoIPArchive, err := io.ReadAll(response.Body)
	if err != nil {
		return err
	}

	return extractMMDBFromTarGz(geoIPArchive, out)
}

func extractMMDBFromTarGz(data []byte, out string) error {
	// gunzip
	gz, err := gzip.NewReader(bytes.NewReader(data))
	if err != nil {
		return fmt.Errorf("gzip reader: %w", err)
	}
	defer gz.Close()

	tr := tar.NewReader(gz)

	for {
		hdr, err := tr.Next()
		if err == io.EOF {
			break
		}
		if err != nil {
			return fmt.Errorf("tar read: %w", err)
		}

		if hdr.Typeflag == tar.TypeReg && strings.HasSuffix(hdr.Name, ".mmdb") {
			f, err := os.Create(out)
			if err != nil {
				return err
			}
			defer f.Close()

			_, err = io.Copy(f, tr)
			return err
		}
	}

	return fmt.Errorf("mmdb file not found in archive")
}
