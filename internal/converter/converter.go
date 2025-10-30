package converter

import (
	"fmt"
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
