package global

import (
	"testing"
)

func TestGetPodPrefix(t *testing.T) {
	tests := []struct {
		name  string
		input string
		want  string
	}{
		//
		{
			name:  "1",
			input: "vm-single-20260607",
			want:  "vm-single-20260607",
		},
		{
			name:  "statefulset ordinal single dash returns whole string",
			input: "mydb--",
			want:  "mydb",
		},
		{
			name:  "statefulset ordinal single dash returns whole string",
			input: "mydb-0",
			want:  "mydb",
		},
		{
			name:  "single dash no further dashes returns whole string",
			input: "myapp-v2",
			want:  "myapp-v2",
		},
		{
			name:  "single dash tail looks like pod hash but no second dash returns whole string",
			input: "myapp-abc12",
			want:  "myapp",
		},
		{
			name:  "empty string",
			input: "",
			want:  "",
		},
		{
			name:  "no dash returns whole string",
			input: "simple",
			want:  "simple",
		},
		{
			name:  "typical k8s pod name strips replicaset hash and pod hash",
			input: "myapp-7d4f8c9b7-k8pnx",
			want:  "myapp",
		},
		{
			name:  "replicaset hash with trailing digit is stripped before isPodTail check",
			input: "webapp-a1b2c3d4-xyzpq",
			want:  "webapp",
		},
		{
			name:  "replicaset segment is all letters+numbers qualifies as pod tail",
			input: "svc-d9f2a1b3c-xwvut",
			want:  "svc",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := getPodPrefix(tt.input)
			if got != tt.want {
				t.Errorf("getPodPrefix(%q) = %q, want %q", tt.input, got, tt.want)
			}
		})
	}
}

func TestIsPodTail(t *testing.T) {
	tests := []struct {
		name  string
		input string
		want  bool
	}{
		{
			name:  "letters and numbers returns true",
			input: "abc12",
			want:  true,
		},
		{
			name:  "only letters returns false",
			input: "abc",
			want:  false,
		},
		{
			name:  "only numbers returns false",
			input: "123",
			want:  false,
		},
		{
			name:  "contains uppercase returns false",
			input: "abcA1",
			want:  false,
		},
		{
			name:  "contains hyphen returns false",
			input: "ab1-c2",
			want:  false,
		},
		{
			name:  "empty string returns false",
			input: "",
			want:  false,
		},
		{
			name:  "k8s replicaset hash pattern returns true",
			input: "7d4f8c9b",
			want:  true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := isPodTail(tt.input)
			if got != tt.want {
				t.Errorf("isPodTail(%q) = %v, want %v", tt.input, got, tt.want)
			}
		})
	}
}
