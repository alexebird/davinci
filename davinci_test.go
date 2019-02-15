package main

import (
	"github.com/davecgh/go-spew/spew"
	"testing"
)

func createSesh() *Session {
	return &Session{
		Config: &Config{
			Options: Options{
				Paths: []string{
					"./testdata/envs0",
					"./testdata/envs1",
				},
			},
		},
	}
}

func TestSearch(t *testing.T) {
	var s *Session = createSesh()
	terms := []string{"dev", "prod", "foo", "bar"}
	units, _ := s.Search(terms)
	spew.Dump(units)

	if units[0] != "testdata/envs0/dev/foo.sh" {
		t.Fail()
	}
	if units[1] != "testdata/envs0/prod/foo.sh" {
		t.Fail()
	}
	if units[2] != "testdata/envs1/bar/foo.sh" {
		t.Fail()
	}
	if units[3] != "testdata/envs1/foo/foo.sh" {
		t.Fail()
	}
}

func TestLoadConfig_path_exists(t *testing.T) {
	var data = `
---
options:
  paths:
    - './testdata'
`

	config, err := LoadConfigData(data)
	if err != nil {
		t.Error(err)
	}

	if config.Options.Paths[0] != "./testdata" {
		t.Fail()
	}
}

func TestLoadConfig_path_non_exists(t *testing.T) {
	var data = `
---
options:
  paths:
    - './foobar'
`

	_, err := LoadConfigData(data)
	if err == nil {
		t.Fail()
	}
}
