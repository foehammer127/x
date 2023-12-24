package postgres

import "github.com/jmoiron/sqlx"

type PgConfig struct {
	User       string
	Password   string
	Host       string
	Port       int
	Name       string
	DisableTLS bool
}

type TxFunction func(tx *sqlx.Tx) error
