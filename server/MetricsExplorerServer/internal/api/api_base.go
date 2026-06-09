package api

import (
	"fmt"
	"io"
	"net/http"
	"strings"
)

func Validate(w http.ResponseWriter, r *http.Request) (reqBytes []byte, err error) {
	if r.Method != http.MethodPost {
		w.WriteHeader(http.StatusMethodNotAllowed)
		io.Copy(io.Discard, r.Body)
		r.Body.Close()
		err = fmt.Errorf("Method Not Allowed")
		return
	}
	if !strings.HasPrefix(r.Header.Get("Content-Type"), "application/protobuf") {
		w.WriteHeader(http.StatusBadRequest)
		io.Copy(io.Discard, r.Body)
		r.Body.Close()
		err = fmt.Errorf("Bad Request")
		return
	}
	reqBytes, err = io.ReadAll(r.Body)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		r.Body.Close()
		return
	}
	_ = r.Body.Close()
	return
}
