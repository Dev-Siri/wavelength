package db

import (
	"database/sql"

	_ "github.com/lib/pq"
)

var Database *sql.DB

func Connect(url string) error {
	db, err := sql.Open("postgres", url)

	if err != nil {
		return err
	}

	Database = db
	return nil
}
