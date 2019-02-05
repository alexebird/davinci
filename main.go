package main

import (
	"fmt"
	"os"

	"github.com/alexebird/davinci/davinci"
	"github.com/davecgh/go-spew/spew"
	"github.com/urfave/cli"
)

func main() {
	app := cli.NewApp()
	app.Name = "davinci"
	app.Usage = "manage env var sourcing"
	app.Version = "0.0.1"

	app.Commands = []cli.Command{
		{
			Name: "search",
			Action: func(c *cli.Context) error {
				fmt.Println("search")
				d, err := davinci.CreateSession("/Users/alexbird/.davinci.yml")
				if err != nil {
					return err
				}

				foundTerms, err := d.Search(c.Args())
				if err != nil {
					return err
				}

				spew.Dump(foundTerms)

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

	err := app.Run(os.Args)
	if err != nil {
		panic(err)
	}
}
