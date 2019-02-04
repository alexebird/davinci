package davinci

import (
	"fmt"
	"os"

	"gopkg.in/yaml.v2"
)

type Options struct {
	Paths []string `yaml:"paths"`
}

type Config struct {
	Options `yaml:"options"`
}

func Load(data string) (*Config, error) {
	var config *Config = new(Config)
	err := yaml.Unmarshal([]byte(data), config)

	if err != nil {
		return nil, err
	}

	for _, path := range config.Options.Paths {
		info, err := os.Stat(path)
		if err != nil {
			return nil, err
		}
		if !info.IsDir() {
			return nil, fmt.Errorf("%s is not a directory", path)
		}
	}

	return config, nil
}
