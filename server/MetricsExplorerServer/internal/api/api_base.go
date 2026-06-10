package api

import (
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"

	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/config"
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

func Auth(sessionID string, isAdminOnly bool) (user *OnlineUser, code int32, msg string) {
	info, ok := OnlineUsers.Load(sessionID)
	if !ok || info == nil {
		code = 1
		msg = "invalid session"
		return
	}
	u, ok1 := info.(*OnlineUser)
	if !ok1 {
		code = 11
		msg = "invalid data type, internal error"
		return
	}
	if time.Now().Unix()-u.LastLogin > config.Get().SessionTimeoutSeconds {
		code = 13
		msg = "session expires, login again"
		OnlineUsers.Delete(sessionID)
		return
	}
	if isAdminOnly && u.UserName != config.Get().Admin.Name {
		code = 12
		msg = "only admin user allowd"
		return
	}
	user = u
	return
}
