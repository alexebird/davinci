package main

import (
	"bytes"
	"encoding/csv"
	"fmt"
	"io"
	"log"
	"os"
	//"strconv"
	"strings"

	_ "github.com/davecgh/go-spew/spew"
	"gopkg.in/urfave/cli.v1"
)

type cell interface {
	val() string
}

type header struct {
	text           string
	shift          int
	hideCol        bool
	hideHeaderText bool
	index          int
}

func (h header) val() string {
	return h.text
}

type data struct {
	text string
}

func (d data) val() string {
	return d.text
}

func readCsv(inputFile io.Reader) [][]string {
	var buf bytes.Buffer

	if _, err := io.Copy(&buf, inputFile); err != nil {
		log.Fatal(err)
	}

	r := csv.NewReader(strings.NewReader(buf.String()))
	buf.Reset()

	records, err := r.ReadAll()
	if err != nil {
		log.Fatal(err)
	}

	return records
}

func printTable(records [][]cell, headers []cell, colWidths []int) {
	var rightMargin string
	var nCells int
	var hdr header

	for _, row := range records {
		nCells = len(row)

		for j, cell := range row {
			hdr = headers[j].(header)

			if hdr.hideCol {
				if j == nCells-1 {
					fmt.Print("\n")
				}
			} else {
				if j == nCells-1 {
					rightMargin = "\n"
				} else {
					rightMargin = "  "
				}

				format := fmt.Sprintf("%%-%ds%s", colWidths[j], rightMargin)

				switch cell.(type) {
				case header:
					if hdr.hideHeaderText {
						fmt.Printf(format, strings.Repeat(" ", colWidths[j]))
					} else {
						fmt.Printf(format, cell.val())
					}
				default:
					fmt.Printf(format, cell.val())
				}
			}
		}
	}
}

func parseHeaders(headerArgs []string, colCount int) ([]cell, int) {
	var headers []cell = make([]cell, 0, colCount)
	var hideCol bool
	var hideHeaderText bool
	var shift int
	//var err error
	var headersMap map[string]header = make(map[string]header)

	for i, cell := range headerArgs {
		s := strings.Split(cell, ":")
		text := s[0]
		hideCol = false
		hideHeaderText = false
		shift = 0
		//err = nil

		if len(s) > 1 {
			opts := strings.Split(s[1], ",")

			for _, opt := range opts {
				//fmt.Printf("%s\n", opt)

				if opt == "." {
					hideCol = true
				} else if opt == "_" {
					hideHeaderText = true
					//} else if opt[0] == '{' || opt[0] == '}' {
					//num := opt[1:]

					//shift, err = strconv.Atoi(num)
					//if err != nil {
					//fmt.Printf("couldn't convert %s to number\n", num)
					//os.Exit(1)
					//}

					//if opt[0] == '{' {
					//shift = -shift
					//}
				} else {
					fmt.Printf("unknown option: %s\n", opt)
					os.Exit(1)
				}
			}
		}

		newHeader := header{
			hideCol:        hideCol,
			hideHeaderText: hideHeaderText,
			shift:          shift,
			text:           text,
			index:          i,
		}

		if existingHeader, ok := headersMap[newHeader.text]; !ok {
			headers = append(headers, newHeader)
			headersMap[newHeader.text] = newHeader
		} else {
			headers[existingHeader.index] = newHeader
		}
	}

	//spew.Dump(headersMap)

	// reconcile shifts
	//shift = 0
	//var hdr header
	//for i := 0; i < len(headers); i++ {
	//hdr = headers[i]
	//shift = hdr.shift

	//if shift < 0 {
	//// swap i with it's left neighbor "shift" times
	//for j := 0; j < -shift; j++ {

	//}
	//} else if shift < 0 {

	//}
	//}

	return headers, len(headersMap)
}

func main() {
	app := cli.NewApp()

	app.Action = func(c *cli.Context) error {
		var headerArgs []string = c.Args()
		records := readCsv(os.Stdin)

		if len(records) == 0 {
			//log.Fatal("")
			os.Exit(0)
		}

		colCount := len(records[0])
		colWidths := make([]int, len(records[0]))

		// validate row sizes
		for _, row := range records {
			l := len(row)
			if l != colCount {
				log.Fatal("all rows must be the same width")
				os.Exit(1)
			}
		}

		// convert headers to structs
		var headers []cell
		var uniqueCount int
		headers, uniqueCount = parseHeaders(headerArgs, colCount)

		if uniqueCount != len(records[0]) {
			log.Fatal("header count must be same as row width")
			os.Exit(1)
		}

		// get colWidths
		for j, cell := range headers {
			l := len(cell.val())
			hdr, _ := cell.(header)

			if l > colWidths[j] && !hdr.hideHeaderText {
				colWidths[j] = l
			}
		}

		for _, row := range records {
			for j, cell := range row {
				l := len(cell)

				if l > colWidths[j] {
					colWidths[j] = l
				}
			}
		}

		// convert records to structs
		var cells [][]cell = make([][]cell, 0, len(records))

		for _, row := range records {
			rowCells := make([]cell, 0, colCount)
			for _, cell := range row {
				rowCells = append(rowCells, data{text: cell})
			}
			cells = append(cells, rowCells)
		}

		//spew.Dump([][]cell{headers})
		printTable([][]cell{headers}, headers, colWidths)

		//spew.Dump(cells)
		printTable(cells, headers, colWidths)

		return nil
	}

	app.Run(os.Args)
}
