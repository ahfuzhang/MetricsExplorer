package middleware

import (
	"compress/gzip"
	"io"
	"net/http"
	"strings"

	"github.com/klauspost/compress/zstd"
)

type compressWriter struct {
	http.ResponseWriter
	cw io.WriteCloser
}

func (c *compressWriter) Write(b []byte) (int, error) {
	return c.cw.Write(b)
}

// Compress checks Accept-Encoding and compresses the response with zstd or gzip.
func Compress(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		ae := r.Header.Get("Accept-Encoding")

		if strings.Contains(ae, "zstd") {
			enc, err := zstd.NewWriter(w)
			if err == nil {
				w.Header().Set("Content-Encoding", "zstd")
				defer enc.Close()
				next.ServeHTTP(&compressWriter{ResponseWriter: w, cw: enc}, r)
				return
			}
		}

		if strings.Contains(ae, "gzip") {
			gz := gzip.NewWriter(w)
			w.Header().Set("Content-Encoding", "gzip")
			defer gz.Close()
			next.ServeHTTP(&compressWriter{ResponseWriter: w, cw: gz}, r)
			return
		}

		next.ServeHTTP(w, r)
	})
}
