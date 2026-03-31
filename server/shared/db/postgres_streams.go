package shared_db

import (
	"database/sql"

	shared_env "github.com/Dev-Siri/wavelength/server/shared/env"
	_ "github.com/lib/pq"
)

var StreamDatabase *sql.DB

func ConnectStreamDatabase() error {
	url, err := shared_env.GetStreamDSN()
	if err != nil {
		return err
	}

	db, err := sql.Open("postgres", url)
	if err != nil {
		return err
	}

	StreamDatabase = db
	return nil
}
