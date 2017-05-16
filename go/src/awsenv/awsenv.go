package awsenv

import (
	"fmt"
	"os"
)

func GetRequiredEnvVar(name string) string {
	value := os.Getenv(name)
	if value == "" {
		fmt.Fprintf(os.Stderr, "error: must set env var %s\n", name)
		os.Exit(1)
	}
	return value
}

func AssertAwsEnv() {
	GetRequiredEnvVar("AWS_ENV")
	GetRequiredEnvVar("AWS_ACCESS_KEY_ID")
	GetRequiredEnvVar("AWS_SECRET_ACCESS_KEY")
	GetRequiredEnvVar("AWS_DEFAULT_REGION")
}
