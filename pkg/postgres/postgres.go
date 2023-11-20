package postgres

import (
	"context"
	"database/sql"
	"fmt"
	"net/url"

	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
	"go.uber.org/zap"
)

type PgDb struct {
	logger *zap.Logger
	db     *sqlx.DB
	Url    url.URL
}

// Get New Postgres Database
func NewPgDb(logger *zap.Logger, cfg PgConfig) (*PgDb, func() error, error) {
	sslMode := "require"
	if cfg.DisableTLS {
		sslMode = "disable"
	}

	query := make(url.Values)
	query.Set("sslmode", sslMode)
	query.Set("timezone", "utc")

	u := url.URL{
		Scheme:   "postgres",
		User:     url.UserPassword(cfg.User, cfg.Password),
		Host:     fmt.Sprintf("%s:%d", cfg.Host, cfg.Port),
		Path:     cfg.Name,
		RawQuery: query.Encode(),
	}

	db, err := sqlx.Open("postgres", u.String())
	if err != nil {
		return nil, nil, fmt.Errorf("error connecting to db: %s", err)
	}

	e := &PgDb{
		logger: logger,
		db:     db,
		Url:    u,
	}

	return e, db.Close, nil
}

// Get Conection, with a cancel func
func (db *PgDb) GetConn(ctx context.Context) (*sqlx.Conn, func() error, error) {
	conn, err := db.db.Connx(ctx)
	if err != nil {
		db.logger.Error("failed to create db connection", zap.Error(err))
		return nil, nil, err
	}

	return conn, conn.Close, nil
}

func (db *PgDb) RunInTx(ctx context.Context, fn func(*sqlx.Tx) error) error {
	conn, Close, err := db.GetConn(ctx)
	if err != nil {
		return err
	}
	defer Close()

	tx, err := conn.BeginTxx(ctx, &sql.TxOptions{Isolation: sql.LevelSerializable})
	if err != nil {
		db.logger.Warn("error beginning sqlx transaction", zap.Error(err))
		return err
	}

	return db.txRun(tx, fn)
}

func (db *PgDb) txRun(tx *sqlx.Tx, fn func(*sqlx.Tx) error) error {
	defer func() {
		if err := recover(); err != nil {
			if rbErr := tx.Rollback(); rbErr != nil {
				db.logger.Warn("tx.Rollback panicked", zap.Error(rbErr))
			}
			panic(err)
		}
	}()

	if err := fn(tx); err != nil {
		if rbError := tx.Rollback(); rbError != nil {
			db.logger.Warn("tx Rollback failed", zap.Error(rbError))
		}
		return err
	}
	return tx.Commit()
}
