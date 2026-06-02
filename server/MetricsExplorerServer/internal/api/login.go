package api

import (
	"crypto/sha256"
	"database/sql"
	"encoding/hex"
	"io"
	"net/http"
	"strings"
	"sync"
	"time"

	"github.com/google/uuid"

	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/config"
	"github.com/ahfuzhang/MetricsExplorer/server/MetricsExplorerServer/internal/global"
	pb "github.com/ahfuzhang/MetricsExplorer/server/generated/metrics_explorer"
)

var OnlineUsers = &sync.Map{}

type OnlineUser struct {
	UserName  string
	LastLogin int64
}

func Login() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			w.WriteHeader(http.StatusMethodNotAllowed)
			io.Copy(io.Discard, r.Body)
			r.Body.Close()
			return
		}
		if !strings.HasPrefix(r.Header.Get("Content-Type"), "application/protobuf") {
			w.WriteHeader(http.StatusBadRequest)
			io.Copy(io.Discard, r.Body)
			r.Body.Close()
			return
		}
		body, err := io.ReadAll(r.Body)
		if err != nil {
			w.WriteHeader(http.StatusBadRequest)
			r.Body.Close()
			return
		}
		defer r.Body.Close()

		req := &pb.ReadonlyLoginRequest{}
		if err = req.FromProtobuf(body); err != nil {
			w.WriteHeader(http.StatusBadRequest)
			return
		}
		//
		cfg := config.Get()
		if req.UserName == cfg.Admin.Name {
			in := cfg.Salt + cfg.Admin.Passwd
			hash := sha256.Sum256([]byte(in))
			if hex.EncodeToString(hash[:]) != req.Passwd {
				w.WriteHeader(http.StatusUnauthorized)
				return
			}
			// 登录成功
			sessionID := uuid.New().String()
			OnlineUsers.Store(sessionID, &OnlineUser{
				UserName:  req.UserName,
				LastLogin: time.Now().Unix(),
			})
			// todo: 对于 app 客户端，可以去掉
			http.SetCookie(w, &http.Cookie{
				Name:     "session_id",
				Value:    sessionID,
				Path:     "/",
				HttpOnly: true,
			})
			rsp := &pb.LoginResponse{
				Code:    0,
				Message: "login success",
				Session: sessionID,
			}
			w.Header().Set("Content-Type", "application/protobuf")
			w.WriteHeader(http.StatusOK)
			_, _ = w.Write(rsp.ToProtobuf(nil))
			return
		}
		// 从数据库查询普通用户
		db := global.GetMysql()
		var storedPasswd string
		// todo: 这里要做预防破解的功能
		err = db.QueryRow(
			"SELECT passwd FROM users WHERE user_name = ? AND passwd = ? LIMIT 1",
			req.UserName, req.Passwd,
		).Scan(&storedPasswd)
		if err != nil {
			code, msg := int32(1), "invalid username or password"
			if err != sql.ErrNoRows {
				code, msg = 2, "database error: "+err.Error()
			}
			rsp := &pb.LoginResponse{Code: code, Message: msg}
			w.Header().Set("Content-Type", "application/protobuf")
			w.WriteHeader(http.StatusOK)
			_, _ = w.Write(rsp.ToProtobuf(nil))
			return
		}
		// 登录成功，分配 session id
		sessionID := uuid.New().String()
		OnlineUsers.Store(sessionID, &OnlineUser{
			UserName:  req.UserName,
			LastLogin: time.Now().Unix(),
		})
		http.SetCookie(w, &http.Cookie{
			Name:     "session_id",
			Value:    sessionID,
			Path:     "/",
			HttpOnly: true,
		})
		rsp := &pb.LoginResponse{
			Code:    0,
			Message: "login success",
			Session: sessionID,
		}
		w.Header().Set("Content-Type", "application/protobuf")
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write(rsp.ToProtobuf(nil))
	}
}
