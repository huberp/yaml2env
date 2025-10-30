package cmd

import (
	"fmt"
	"os"

	"github.com/huberp/yaml2env/internal/converter"
	"github.com/spf13/cobra"
)

var (
	version string
	commit  string
	date    string
)

var rootCmd = &cobra.Command{
	Use:   "yaml2env [yaml-file]",
	Short: "Project YAML file content into shell environment",
	Long: `yaml2env reads a YAML file and outputs shell commands
to set environment variables from the YAML content.`,
	Args: cobra.ExactArgs(1),
	RunE: runConvert,
}

var (
	shellType string
	prefix    string
)

func init() {
	rootCmd.Flags().StringVarP(&shellType, "shell", "s", "bash", "Shell type: bash, sh, powershell, cmd")
	rootCmd.Flags().StringVarP(&prefix, "prefix", "p", "", "Prefix for environment variable names")
}

// SetVersionInfo sets version information for the CLI
func SetVersionInfo(v, c, d string) {
	version = v
	commit = c
	date = d
	rootCmd.Version = fmt.Sprintf("%s (commit: %s, built: %s)", version, commit, date)
}

// Execute runs the root command
func Execute() error {
	return rootCmd.Execute()
}

func runConvert(cmd *cobra.Command, args []string) error {
	yamlFile := args[0]
	
	data, err := os.ReadFile(yamlFile)
	if err != nil {
		return fmt.Errorf("failed to read file: %w", err)
	}

	envVars, err := converter.YAMLToEnvVars(data, prefix)
	if err != nil {
		return fmt.Errorf("failed to convert YAML: %w", err)
	}

	output, err := converter.FormatForShell(envVars, shellType)
	if err != nil {
		return fmt.Errorf("failed to format for shell: %w", err)
	}

	fmt.Print(output)
	return nil
}
