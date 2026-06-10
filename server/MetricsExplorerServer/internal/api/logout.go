package api

import (
	"net/http"

	pb "github.com/ahfuzhang/MetricsExplorer/server/generated/metrics_explorer"
)

func Logout() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		reqBytes, err := Validate(w, r)
		if err != nil {
			return
		}

		req := &pb.ReadonlyLogoutRequest{}
		if err = req.FromProtobuf(reqBytes); err != nil {
			w.WriteHeader(http.StatusBadRequest)
			return
		}

		respond := func(code int32, msg string) {
			rsp := &pb.LogoutResponse{Code: code, Message: msg}
			w.Header().Set("Content-Type", "application/protobuf")
			w.WriteHeader(http.StatusOK)
			_, _ = w.Write(rsp.ToProtobuf(nil))
		}

		if req.Session == "" {
			respond(1, "missing session")
			return
		}
		OnlineUsers.Delete(req.Session)
		respond(0, "logout success")
	}
}
