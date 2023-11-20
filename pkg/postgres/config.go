package postgres

type PgConfig struct {
	User       string
	Password   string
	Host       string
	Port       int
	Name       string
	DisableTLS bool
}
