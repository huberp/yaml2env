package converter

import (
	"testing"
)

func TestYAMLToEnvVars(t *testing.T) {
	tests := []struct {
		name     string
		yaml     string
		prefix   string
		expected []EnvVar
		wantErr  bool
	}{
		{
			name: "simple key-value",
			yaml: "key: value\nfoo: bar",
			prefix: "",
			expected: []EnvVar{
				{Key: "KEY", Value: "value"},
				{Key: "FOO", Value: "bar"},
			},
			wantErr: false,
		},
		{
			name: "nested structure",
			yaml: "database:\n  host: localhost\n  port: 5432",
			prefix: "",
			expected: []EnvVar{
				{Key: "DATABASE_HOST", Value: "localhost"},
				{Key: "DATABASE_PORT", Value: "5432"},
			},
			wantErr: false,
		},
		{
			name: "with prefix",
			yaml: "host: localhost",
			prefix: "APP",
			expected: []EnvVar{
				{Key: "APP_HOST", Value: "localhost"},
			},
			wantErr: false,
		},
		{
			name: "array values",
			yaml: "items:\n  - first\n  - second",
			prefix: "",
			expected: []EnvVar{
				{Key: "ITEMS_0", Value: "first"},
				{Key: "ITEMS_1", Value: "second"},
			},
			wantErr: false,
		},
		{
			name:    "invalid YAML",
			yaml:    "invalid: yaml: content: bad",
			prefix:  "",
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result, err := YAMLToEnvVars([]byte(tt.yaml), tt.prefix)
			
			if tt.wantErr {
				if err == nil {
					t.Errorf("expected error but got none")
				}
				return
			}
			
			if err != nil {
				t.Errorf("unexpected error: %v", err)
				return
			}
			
			if len(result) != len(tt.expected) {
				t.Errorf("expected %d env vars, got %d", len(tt.expected), len(result))
				return
			}
			
			// Convert to map for easier comparison
			resultMap := make(map[string]string)
			for _, ev := range result {
				resultMap[ev.Key] = ev.Value
			}
			
			for _, expected := range tt.expected {
				if resultMap[expected.Key] != expected.Value {
					t.Errorf("for key %s: expected %s, got %s", expected.Key, expected.Value, resultMap[expected.Key])
				}
			}
		})
	}
}

func TestFormatForShell(t *testing.T) {
	envVars := []EnvVar{
		{Key: "KEY1", Value: "value1"},
		{Key: "KEY2", Value: "value2"},
	}

	tests := []struct {
		name      string
		shellType string
		want      string
		wantErr   bool
	}{
		{
			name:      "bash format",
			shellType: "bash",
			want:      "export KEY1='value1'\nexport KEY2='value2'\n",
			wantErr:   false,
		},
		{
			name:      "sh format",
			shellType: "sh",
			want:      "export KEY1='value1'\nexport KEY2='value2'\n",
			wantErr:   false,
		},
		{
			name:      "powershell format",
			shellType: "powershell",
			want:      "$env:KEY1 = 'value1'\n$env:KEY2 = 'value2'\n",
			wantErr:   false,
		},
		{
			name:      "cmd format",
			shellType: "cmd",
			want:      "set KEY1=value1\nset KEY2=value2\n",
			wantErr:   false,
		},
		{
			name:      "unsupported shell",
			shellType: "fish",
			wantErr:   true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := FormatForShell(envVars, tt.shellType)
			
			if tt.wantErr {
				if err == nil {
					t.Errorf("expected error but got none")
				}
				return
			}
			
			if err != nil {
				t.Errorf("unexpected error: %v", err)
				return
			}
			
			if got != tt.want {
				t.Errorf("FormatForShell() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestEscapeSingleQuote(t *testing.T) {
	tests := []struct {
		input    string
		expected string
	}{
		{"no quotes", "no quotes"},
		{"it's working", "it'\\''s working"},
		{"multiple'quotes'here", "multiple'\\''quotes'\\''here"},
	}

	for _, tt := range tests {
		t.Run(tt.input, func(t *testing.T) {
			result := escapeSingleQuote(tt.input)
			if result != tt.expected {
				t.Errorf("escapeSingleQuote(%q) = %q, want %q", tt.input, result, tt.expected)
			}
		})
	}
}
