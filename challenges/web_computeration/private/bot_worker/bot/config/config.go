package config

import (
	"github.com/kelseyhightower/envconfig"
	"log"
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
	Listen           string `default:"0.0.0.0:8080" split_words:"true"`
	ChromeDriverPath string `default:"/usr/local/bin/chromedriver" split_words:"true"`
	BotWorkers       int    `default:"12" split_words:"true"`
	BotPoolPerWorker int    `default:"15" split_words:"true"`
}
