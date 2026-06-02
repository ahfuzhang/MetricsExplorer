
.PHONY: build build_web run run_web build_server run_server dev

# ── macOS 客户端 ─────────────────────────────────────────────────────────────
build:
	flutter build macos

run:
	flutter run -d macos

# ── Web 前端 ─────────────────────────────────────────────────────────────────
build_web:
	flutter build web
	sed -i '' 's|<base href="/">|<base href="./">|' build/web/index.html

run_web:
	flutter run -d chrome

# ── Go 后端 ──────────────────────────────────────────────────────────────────
build_server:
	cd server && go build -o ../bin/server .

# 生产模式：先编译 Flutter web，再启动 Go 服务器（同端口 8080）
run_server: build_web
	cd server && go run . -addr :8080

# 开发模式：Go 服务器在 8080 提供数据 API + CORS，Flutter dev server 在 3000 热重载
# 两个进程并发运行，Ctrl-C 会终止 Flutter（Go 服务器在后台，用 kill 结束）
dev:
	@echo "Starting Go server on :8080 (background)..."
	@cd server && go run . -addr :8080 &
	@echo "Starting Flutter dev server on :3000..."
	flutter run -d chrome --web-port=3000
