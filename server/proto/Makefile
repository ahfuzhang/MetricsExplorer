
generate:
	mkdir -p ../generated/metrics_explorer/ && \
	hulu generate \
	  -src=config.proto \
	  -go_out=../generated/metrics_explorer/

generate_api:
	mkdir -p ../generated/metrics_explorer/ && \
	hulu generate \
	  -src=api.proto \
	  -go_out=../generated/metrics_explorer/ && \
	mkdir -p ../generated/victoria_metrics_api/ && \
	hulu generate \
	  -src=victoria_metrics_api.proto \
	  -go_out=../generated/victoria_metrics_api/

generate_dart:
	buf generate . --path api.proto

all: generate generate_api generate_dart
	@echo "done"
