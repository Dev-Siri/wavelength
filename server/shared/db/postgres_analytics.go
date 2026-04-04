package shared_db

import (
	"database/sql"

	shared_env "github.com/Dev-Siri/wavelength/server/shared/env"
	_ "github.com/lib/pq"
)

var AnalyticsDatabase *sql.DB

func ConnectAnalyticsDatabase() error {
	url, err := shared_env.GetAnalyticsDSN()
	if err != nil {
		return err
	}

	db, err := sql.Open("postgres", url)
	if err != nil {
		return err
	}

	AnalyticsDatabase = db
	return nil
}
