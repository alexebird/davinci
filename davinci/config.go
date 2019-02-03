package davinci

import (
	"gopkg.in/yaml.v2"
)

type Options struct {
	Paths []string `yaml:"paths"`
}

type Config struct {
	Options `yaml:"options"`
}

func Load(data string) (*Config, error) {
	var config *Config = &Config{}
	err := yaml.Unmarshal([]byte(data), config)

	if err != nil {
		return nil, err
	}

	return config, nil
}
