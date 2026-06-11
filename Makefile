
.PHONY: build build_web build_android build_windows build_linux run run_web build_server run_server dev \
	release_macos release_macos_arm64 release_macos_amd64 \
	release_android release_android_arm64 release_android_amd64 \
	release_server release_server_darwin_arm64 release_server_darwin_amd64 \
	release_server_windows_amd64 release_server_windows_arm64 \
	release_server_linux_amd64 release_server_linux_arm64

# ── macOS 客户端 ─────────────────────────────────────────────────────────────
build:
	flutter build macos


run:
	flutter run -d macos

# ── Web 前端 ─────────────────────────────────────────────────────────────────
build_web:
	flutter build web --wasm
	sed -i '' 's|<base href="/">|<base href="./">|' build/web/index.html

run_web:
	flutter run -d chrome

# ── Android ──────────────────────────────────────────────────────────────────
build_android:
	flutter build apk --release

# ── Windows ──────────────────────────────────────────────────────────────────
build_windows:
	flutter build windows --release

# ── Linux ────────────────────────────────────────────────────────────────────
build_linux:
	flutter build linux --release

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


release_server: \
	build_web \
	release_server_darwin_arm64 \
	release_server_darwin_amd64 \
	release_server_windows_amd64 \
	release_server_windows_arm64 \
	release_server_linux_amd64 \
	release_server_linux_arm64
	cp ./server/MetricsExplorerServer/MetricsExplorerServer.yaml dist/server/

release_server_darwin_arm64:
	cd ./server/MetricsExplorerServer/ && \
	GOOS=darwin GOARCH=arm64 go build -o ../../dist/server/MetricsExplorerServer_darwin_arm64 main.go

release_server_darwin_amd64:
	cd ./server/MetricsExplorerServer/ && \
	GOOS=darwin GOARCH=amd64 go build -o ../../dist/server/MetricsExplorerServer_darwin_amd64 main.go

release_server_windows_amd64:
	cd ./server/MetricsExplorerServer/ && \
	GOOS=windows GOARCH=amd64 go build -o ../../dist/server/MetricsExplorerServer_windows_amd64.exe main.go

release_server_windows_arm64:
	cd ./server/MetricsExplorerServer/ && \
	GOOS=windows GOARCH=arm64 go build -o ../../dist/server/MetricsExplorerServer_windows_arm64.exe main.go

release_server_linux_amd64:
	cd ./server/MetricsExplorerServer/ && \
	GOOS=linux GOARCH=amd64 go build -o ../../dist/server/MetricsExplorerServer_linux_amd64 main.go

release_server_linux_arm64:
	cd ./server/MetricsExplorerServer/ && \
	GOOS=linux GOARCH=arm64 go build -o ../../dist/server/MetricsExplorerServer_linux_arm64 main.go

release_macos: release_macos_arm64 release_macos_amd64

release_macos_arm64:
	flutter build macos --release
	#mkdir -p ./dist/macos/arm64
	#rm -rf ./dist/macos/arm64/metrics_explorer_arm64.app
	#cp -R build/macos/Build/Products/Release/metrics_explorer.app ./dist/macos/arm64/metrics_explorer_arm64.app
	hdiutil create -volname MetricsExplorer \
		-srcfolder build/macos/Build/Products/Release/metrics_explorer.app \
		-ov -format UDZO \
		./dist/macos/metrics_explorer_arm64.dmg

release_macos_amd64:
	flutter build macos --config-only --release
	cd macos && xcodebuild \
		-workspace Runner.xcworkspace \
		-scheme Runner \
		-configuration Release \
		ARCHS="x86_64" \
		ONLY_ACTIVE_ARCH=NO \
		SYMROOT="../build/macos_amd64" \
		build
	#mkdir -p ./dist/macos/amd64
	#rm -rf ./dist/macos/amd64/metrics_explorer_amd64.app
	#cp -R build/macos_amd64/Release/metrics_explorer.app ./dist/macos/amd64/metrics_explorer_amd64.app
	hdiutil create -volname MetricsExplorer \
		-srcfolder build/macos_amd64/Release/metrics_explorer.app \
		-ov -format UDZO \
		./dist/macos/metrics_explorer_amd64.dmg

release_android: release_android_arm64 release_android_amd64

release_android_arm64:
	flutter build apk --release --target-platform android-arm64 --split-per-abi
	mkdir -p ./dist/android
	cp build/app/outputs/flutter-apk/app-arm64-v8a-release.apk \
		./dist/android/metrics_explorer_arm64.apk

release_android_amd64:
	flutter build apk --release --target-platform android-x64 --split-per-abi
	mkdir -p ./dist/android
	cp build/app/outputs/flutter-apk/app-x86_64-release.apk \
		./dist/android/metrics_explorer_amd64.apk

VERSION=v0.1.0

gh_upload:
	gh release create $(VERSION) \
		dist/macos/* \
		dist/android/* \
		dist/server/* \
		--title "$(VERSION)" \
		--notes "First release"
