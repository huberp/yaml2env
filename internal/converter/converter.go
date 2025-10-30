package converter

import (
	"fmt"
	"os"
	"strings"

	"gopkg.in/yaml.v3"
)

// EnvVar represents an environment variable
type EnvVar struct {
	Key   string
	Value string
}

// YAMLToEnvVars converts YAML data to environment variables
func YAMLToEnvVars(data []byte, prefix string) ([]EnvVar, error) {
	var content map[string]interface{}
	if err := yaml.Unmarshal(data, &content); err != nil {
		return nil, fmt.Errorf("invalid YAML: %w", err)
	}

	var envVars []EnvVar
	flatten("", content, prefix, &envVars)
	return envVars, nil
}

// flatten recursively flattens nested YAML structures
func flatten(parentKey string, data interface{}, prefix string, envVars *[]EnvVar) {
	switch v := data.(type) {
	case map[string]interface{}:
		for key, value := range v {
			newKey := buildKey(parentKey, key, prefix)
			flatten(newKey, value, prefix, envVars)
		}
	case []interface{}:
		for i, value := range v {
			newKey := fmt.Sprintf("%s_%d", parentKey, i)
			flatten(newKey, value, prefix, envVars)
		}
	default:
		*envVars = append(*envVars, EnvVar{
			Key:   parentKey,
			Value: fmt.Sprintf("%v", v),
		})
	}
}

// buildKey constructs the environment variable key
func buildKey(parent, key, prefix string) string {
	key = strings.ToUpper(strings.ReplaceAll(key, "-", "_"))

	if parent == "" {
		if prefix != "" {
			return prefix + "_" + key
		}
		return key
	}
	return parent + "_" + key
}

// FormatForShell formats environment variables for different shell types
func FormatForShell(envVars []EnvVar, shellType string) (string, error) {
	var sb strings.Builder

	switch strings.ToLower(shellType) {
	case "bash", "sh":
		for _, ev := range envVars {
			sb.WriteString(fmt.Sprintf("export %s='%s'\n", ev.Key, escapeSingleQuote(ev.Value)))
		}
	case "powershell", "ps1":
		for _, ev := range envVars {
			sb.WriteString(fmt.Sprintf("$env:%s = '%s'\n", ev.Key, escapeSingleQuote(ev.Value)))
		}
	case "cmd":
		for _, ev := range envVars {
			sb.WriteString(fmt.Sprintf("set %s=%s\n", ev.Key, ev.Value))
		}
	default:
		return "", fmt.Errorf("unsupported shell type: %s", shellType)
	}

	return sb.String(), nil
}

// escapeSingleQuote escapes single quotes in values
func escapeSingleQuote(s string) string {
	return strings.ReplaceAll(s, "'", "'\\''")
}

// SetEnvVars sets environment variables directly in the current process
// and writes to GITHUB_ENV if running in GitHub Actions
func SetEnvVars(envVars []EnvVar) (err error) {
	// Set in current process
	for _, ev := range envVars {
		if err := os.Setenv(ev.Key, ev.Value); err != nil {
			return fmt.Errorf("failed to set %s: %w", ev.Key, err)
		}
	}

	// If running in GitHub Actions, also write to GITHUB_ENV
	githubEnv := os.Getenv("GITHUB_ENV")
	if githubEnv != "" {
		// #nosec G304: GITHUB_ENV is a trusted GitHub Actions environment variable
		f, err := os.OpenFile(githubEnv, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0600)
		if err != nil {
			return fmt.Errorf("failed to open GITHUB_ENV file: %w", err)
		}
		defer func() {
			if closeErr := f.Close(); closeErr != nil && err == nil {
				err = fmt.Errorf("failed to close GITHUB_ENV file: %w", closeErr)
			}
		}()

		for _, ev := range envVars {
			if _, err := fmt.Fprintf(f, "%s=%s\n", ev.Key, ev.Value); err != nil {
				return fmt.Errorf("failed to write to GITHUB_ENV: %w", err)
			}
		}
	}

	return nil
}
