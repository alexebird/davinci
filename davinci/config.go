package davinci

import (
	"fmt"
	"io/ioutil"
	"os"
	"regexp"
	"strings"

	"gopkg.in/yaml.v2"
)

type Options struct {
	Paths []string `yaml:"paths"`
}

type Config struct {
	Options `yaml:"options"`
}

func LoadConfig(configPath string) (*Config, error) {
	data, err := ioutil.ReadFile(configPath)
	if err != nil {
		return nil, err
	}

	var config *Config = &Config{}
	err = yaml.Unmarshal([]byte(data), config)
	if err != nil {
		return nil, err
	}

	var newPaths []string

	for _, pth := range config.Options.Paths {
		pth = expandPath(pth)
		info, err := os.Stat(pth)
		if err != nil {
			return nil, err
		}
		if !info.IsDir() {
			return nil, fmt.Errorf("%s is not a directory", pth)
		}

		newPaths = append(newPaths, pth)
	}

	config.Options.Paths = newPaths

	return config, nil
}

func expandPath(pth string) string {
	envVarRe := regexp.MustCompile(`\${([a-zA-Z0-9_]+)}`)
	var res string

	res = envVarRe.ReplaceAllStringFunc(pth, func(match string) string {
		match = strings.Trim(match, "${}")
		return os.Getenv(match)
	})

	return res
}
