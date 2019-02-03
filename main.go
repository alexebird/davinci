package main

import (
	"fmt"
	"log"
	"os"

	"github.com/urfave/cli"
)

func main() {
	app := cli.NewApp()
	app.Name = "davinci"
	app.Usage = "manage env var sourcing"
	app.Version = "0.0.1"

	app.Commands = []cli.Command{
		{
			Name: "set",
			Action: func(c *cli.Context) error {
				fmt.Println("set")
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
		log.Fatal(err)
	}
}
