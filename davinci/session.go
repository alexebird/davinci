package davinci

import (
	"fmt"
	"io/ioutil"
	"os"
	"path"
	"path/filepath"
	"sort"
	"strings"
	//"github.com/davecgh/go-spew/spew"
)

type Unit string

type Session struct {
	Config *Config
}

func CreateSession(configPath string) (*Session, error) {
	config, err := LoadConfig(configPath)
	if err != nil {
		return nil, err
	}

	sesh := &Session{
		Config: config,
	}

	return sesh, nil
}

// Returns all files contained in the specified env units.
// TODO Edge Cases
// - multiple units of the same name -> apply them in order of found
// - nested dirs in a unit -> treat them as flat -- meaningless to the tool, but the user may use for organizing.
func (s *Session) Search(terms []string) ([]string, error) {
	var files []string
	for _, path := range s.Config.Options.Paths {
		fmt.Println(path)
		unitsFromPath, err := getUnitsFromPath(path)
		if err != nil {
			return nil, err
		}
		for _, unit := range unitsFromPath {
			for _, file := range unit.listFiles() {
				files = append(files, file)
			}
		}
	}

	return files, nil
}

func (u Unit) listFiles() []string {
	var filteredFiles []string

	err := filepath.Walk(string(u), func(path string, info os.FileInfo, err error) error {
		if err != nil {
			fmt.Printf("error walking file tree %q: %v\n", path, err)
			return err
		}

		if info.Mode().IsRegular() && isValidFile(path) {
			filteredFiles = append(filteredFiles, path)
		}

		return nil
	})

	if err != nil {
		fmt.Printf("error walking the path %q: %v\n", string(u), err)
		return nil
	}

	return filteredFiles
}

func isValidFile(name string) bool {
	if strings.HasSuffix(name, ".sh") || strings.HasSuffix(name, ".gpg") {
		return true
	}

	return false
}

func getUnitsFromPath(pth string) ([]Unit, error) {
	files, err := ioutil.ReadDir(pth)
	if err != nil {
		return nil, err
	}

	var units []Unit
	for _, file := range files {
		unit := Unit(path.Join(pth, file.Name()))
		units = append(units, unit)
	}

	sort.SliceStable(units, func(i, j int) bool {
		return strings.Compare(string(units[i]), string(units[j])) < 0
	})

	return units, nil
}
