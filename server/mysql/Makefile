
MYSQL_CONTAINER_NAME := metrics-explorer-mysql
MYSQL_VERSION        := 8.0
MYSQL_PORT           := 3306
MYSQL_ROOT_PASSWORD  := root123
MYSQL_DATABASE       := metrics_explorer
MYSQL_DATA_DIR       := $(HOME)/Downloads/temp/metrics-explorer-mysql

.PHONY: start stop restart status logs shell clean

start:
	@mkdir -p $(MYSQL_DATA_DIR)
	docker run -d \
		--name $(MYSQL_CONTAINER_NAME) \
		-e MYSQL_ROOT_PASSWORD=$(MYSQL_ROOT_PASSWORD) \
		-e MYSQL_DATABASE=$(MYSQL_DATABASE) \
		-p $(MYSQL_PORT):3306 \
		-v $(MYSQL_DATA_DIR):/var/lib/mysql \
		--restart unless-stopped \
		mysql:$(MYSQL_VERSION)
	@echo "MySQL started. Data dir: $(MYSQL_DATA_DIR)"

stop:
	docker stop $(MYSQL_CONTAINER_NAME)

restart:
	docker restart $(MYSQL_CONTAINER_NAME)

status:
	docker ps -f name=$(MYSQL_CONTAINER_NAME)

logs:
	docker logs -f $(MYSQL_CONTAINER_NAME)

shell:
	docker exec -it $(MYSQL_CONTAINER_NAME) mysql -uroot -p$(MYSQL_ROOT_PASSWORD) $(MYSQL_DATABASE)

clean:
	docker rm -f $(MYSQL_CONTAINER_NAME)

install:
	mysql -h 127.0.0.1 -P 3306 -uroot -proot123 < admin.sql
	