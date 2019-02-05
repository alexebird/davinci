package davinci_test

import (
	"github.com/alexebird/davinci/davinci"
	"github.com/davecgh/go-spew/spew"
	"testing"
)

func createSesh() *davinci.Session {
	return &davinci.Session{
		
		Paths: []string{
			"./testdata/envs0",
			"./testdata/envs1",
		},
	}
}

func TestSearch(t *testing.T) {
	//var e *davinci.Env = createEnv()
	paths := []string{
		"./testdata/envs0",
		"./testdata/envs1",
	},

	searchFor := []string{"dev", "prod", "foo", "bar"}

	units := davinci.Search(paths, searchFor)
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
