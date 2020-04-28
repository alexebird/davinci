package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path"
	"path/filepath"
	"regexp"
	"sort"
	"strings"

	_ "github.com/davecgh/go-spew/spew"
	"github.com/urfave/cli/v2"
	"gopkg.in/yaml.v2"
)

type Options struct {
	Paths []string `yaml:"paths"`
}

type PromptConfig struct {
	Patterns map[PatternName][]Pattern `yaml:"patterns"`
	Contexts map[ContextName][]Context `yaml:"contexts"`
}

type Pattern struct {
	Pattern string `yaml:"pattern"`
	Shorten string `yaml:"shorten"`
	Color   string `yaml:"color"`
}

type Context struct {
	Vars         []string      `yaml:"vars"`
	PatternNames []PatternName `yaml:"patterns"`
}

type Config struct {
	Options      `yaml:"options"`
	PromptConfig `yaml:"prompt"`
}

type Unit string
type PatternName string
type ContextName string

type Session struct {
	Config *Config
}

func main() {
	home, err := os.UserHomeDir()
	if err != nil {
		panic(err)
	}

	app := cli.NewApp()
	app.Name = "davinci"
	app.Usage = "manage env var sourcing"
	app.Version = "0.0.1"
	//spew.Dump("S.P.E.W.")

	app.Flags = []cli.Flag{
		&cli.StringFlag{
			Name:    "config",
			Aliases: []string{"c"},
			Usage:   "config file path. default: $HOME/.davinci.yml",
			Value:   path.Join(home, ".davinci.yml"),
		},
	}

	app.Commands = []*cli.Command{
		{
			Name: "search",
			Flags: []cli.Flag{
				&cli.BoolFlag{
					Name:    "eval",
					Aliases: []string{"e"},
					Usage:   "print file contents for eval",
					Value:   false,
				},
			},
			Action: func(c *cli.Context) error {
				d, err := CreateSession(c.String("config"))
				if err != nil {
					return err
				}

				evalPaths, err := d.Search(c.Args().Slice())
				if err != nil {
					return err
				}

				evalCode, err := readFilesForEval(evalPaths)
				if err != nil {
					log.Fatalf("error: %v", err)
				}
				fmt.Print(evalCode)

				return nil
			},
		},
		//{
		//Name: "clear",
		//Action: func(c *cli.Context) error {
		//return nil
		//},
		//},
	}

	err = app.Run(os.Args)
	if err != nil {
		panic(err)
	}
}

func CreateSession(configPath string) (*Session, error) {
	config, err := LoadConfigFile(configPath)
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
		unitsFromPath, err := getUnitsFromPath(path)
		if err != nil {
			return nil, err
		}
		for _, unit := range unitsFromPath {
			if unitMatches(unit, terms) {
				for _, file := range unit.listFiles() {
					files = append(files, file)
				}
			}
		}
	}

	return files, nil
}

func unitMatches(u Unit, terms []string) bool {
	ustr := u.unitName()

	for _, term := range terms {
		if strings.Compare(ustr, term) == 0 {
			return true
		}
	}

	return false
}

func (u Unit) unitName() string {
	return path.Base(string(u))
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

func isValidUnit(fileInfo os.FileInfo) bool {
	return fileInfo.IsDir() && strings.Compare(fileInfo.Name(), ".git") != 0
}

func getUnitsFromPath(pth string) ([]Unit, error) {
	files, err := ioutil.ReadDir(pth)
	if err != nil {
		return nil, err
	}

	var units []Unit
	for _, file := range files {
		if isValidUnit(file) {
			unit := Unit(path.Join(pth, file.Name()))
			units = append(units, unit)
		}
	}

	sort.SliceStable(units, func(i, j int) bool {
		return strings.Compare(string(units[i]), string(units[j])) < 0
	})

	return units, nil
}

func LoadConfigFile(configPath string) (*Config, error) {
	data, err := ioutil.ReadFile(configPath)
	if err != nil {
		return nil, err
	}

	return LoadConfigData(string(data))
}

func LoadConfigData(data string) (*Config, error) {
	var config *Config = &Config{}
	err := yaml.Unmarshal([]byte(data), config)
	if err != nil {
		return nil, err
	}

	var newPaths []string

	// validate that the paths are indeed directories.
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

func readFilesForEval(files []string) (string, error) {
	var err error
	var data []byte
	var file *os.File
	var evalBuf strings.Builder
	for i := 3; i >= 1; i-- {
	}

	for _, fname := range files {
		file, err = os.Open(fname)
		if err != nil {
			return "", err
		}
		defer file.Close()

		fmt.Fprintf(&evalBuf, "# %s\n", fname)
		data, err = ioutil.ReadAll(file)
		fmt.Fprintf(&evalBuf, "%s\n", data)
	}

	return evalBuf.String(), nil
}

// print the colorized shell prompt based on the config.
//func (s *Session) PrintShellPrompt() error {

//}
