package metricsexplorer

import (
	"embed"
	"io/fs"
)

//go:embed build/web
var webFiles embed.FS

// WebFS returns an fs.FS rooted at the embedded build/web directory.
func WebFS() fs.FS {
	sub, err := fs.Sub(webFiles, "build/web")
	if err != nil {
		panic(err)
	}
	return sub
}
