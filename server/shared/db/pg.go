package shared_db

import (
	"database/sql"

	shared_env "github.com/Dev-Siri/wavelength/server/shared/env"

	_ "github.com/lib/pq"
)

var Database *sql.DB

func Connect() error {
	url, err := shared_env.GetDBUrl()
	if err != nil {
		return err
	}

	db, err := sql.Open("postgres", url)
	if err != nil {
		return err
	}

	Database = db
	return nil
}
