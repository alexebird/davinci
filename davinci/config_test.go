package davinci_test

import (
	"github.com/alexebird/davinci/davinci"
	//"github.com/davecgh/go-spew/spew"
	"testing"
)

func TestLoad_path_exists(t *testing.T) {
	var data = `
---
options:
  paths:
    - './testdata'
`

	config, err := davinci.Load(data)
	if err != nil {
		t.Fail()
	}

	if config.Options.Paths[0] != "./testdata" {
		t.Fail()
	}
}

func TestLoad_path_non_exists(t *testing.T) {
	var data = `
---
options:
  paths:
    - './foobar'
`

	_, err := davinci.Load(data)
	if err == nil {
		t.Fail()
	}
}
