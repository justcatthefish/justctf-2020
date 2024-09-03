package config

import (
	"github.com/kelseyhightower/envconfig"
	"log"
	"time"
)

var Config *config

func init() {
	var s config
	err := envconfig.Process("", &s)
	if err != nil {
		log.Fatal(err.Error())
	}
	Config = &s
}

type config struct {
	Listen              string        `default:"0.0.0.0:80" split_words:"true"`

	CreateSandboxSh     string        `default:"/scripts/create.sh" split_words:"true"`
	DestroySandboxSh    string        `default:"/scripts/destory.sh" split_words:"true"`
	CleanAllSandboxSh   string        `default:"/scripts/clean_all.sh" split_words:"true"`

	SandboxDuration     time.Duration `default:"900s" split_words:"true"`
	SandboxNewCreation  time.Duration `default:"900s" split_words:"true"`

	OneTimeHashDuration time.Duration `default:"60s" split_words:"true"`

	HashcashDifficult   int `default:"28" split_words:"true"`
}
