package db

import "github.com/oschwald/geoip2-golang/v2"

var GeoIpDb *geoip2.Reader

func InitGeoIP(path string) error {
	db, err := geoip2.Open(path)

	if err != nil {
		return err
	}

	GeoIpDb = db
	return nil
}
