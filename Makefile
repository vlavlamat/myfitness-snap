# Указываем, что эти цели (targets) не являются файлами,
# а просто именованными действиями, которые всегда должны выполняться.
.PHONY: up down build dev-up dev-down dev-build \
        prod-up prod-down prod-build-multiarch \
        logs dev-logs prod-logs ps \
        test test-unit test-integration test-coverage test-setup

# ────────────────────────────────
# Переменные
# ────────────────────────────────

# Docker Hub username
REGISTRY_USER = vlavlamat

# ────────────────────────────────
# Основные псевдонимы
# ────────────────────────────────

up: dev-up
down: dev-down
build: dev-build
logs: dev-logs

# ──────────────────────────────────────
# Dev окружение (локальная разработка arm64)
# ──────────────────────────────────────

dev-up:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d

dev-down:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml down

dev-build:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml build \
	  --build-arg INSTALL_DEV=true
	docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d

dev-rebuild:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml build --no-cache
	docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d

dev-logs:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml logs -f --tail=100

# ────────────────────────────────
# Production окружение (сервер)
# ────────────────────────────────

prod-up:
	docker compose --env-file env/.env.prod -f docker-compose.yml -f docker-compose.prod.yml up -d

prod-down:
	docker compose --env-file env/.env.prod -f docker-compose.yml -f docker-compose.prod.yml down

prod-logs:
	docker compose --env-file env/.env.prod -f docker-compose.yml -f docker-compose.prod.yml logs -f --tail=100

# ────────────────────────────────
# Multi-architecture билд и пуш (единственный продакшн путь)
# ────────────────────────────────

prod-build:
	docker buildx create --use || true
	set -a && source env/.env.prod && set +a && \
	docker buildx build --platform linux/amd64,linux/arm64 --push -f docker/backend/backend.Dockerfile -t $(REGISTRY_USER)/roadrunner-backend-myfitness:prod . && \
	docker buildx build --platform linux/amd64,linux/arm64 --push -f docker/proxy/proxy.Dockerfile -t $(REGISTRY_USER)/nginx-proxy-myfitness:prod . && \
	docker buildx build --platform linux/amd64,linux/arm64 --push -f docker/frontend/vue.prod.Dockerfile -t $(REGISTRY_USER)/vue-frontend-myfitness:prod .

# ────────────────────────────────
# Утилиты
# ────────────────────────────────

# Список запущенных контейнеров и их статуса
ps:
	docker compose ps

# ────────────────────────────────
# Тестирование
# ────────────────────────────────

# Установка зависимостей для тестирования
test-setup:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml build --build-arg INSTALL_DEV=true php-fpm1
	docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d php-fpm1

# Запуск всех тестов в контейнере
test: test-setup
	docker compose -f docker-compose.yml -f docker-compose.dev.yml exec php-fpm1 vendor/bin/phpunit -c phpunit.xml

# Запуск только unit тестов
test-unit: test-setup
	docker compose -f docker-compose.yml -f docker-compose.dev.yml exec php-fpm1 vendor/bin/phpunit -c phpunit.xml --testsuite Unit

# Запуск только интеграционных тестов
test-integration: test-setup
	docker compose -f docker-compose.yml -f docker-compose.dev.yml exec php-fpm1 vendor/bin/phpunit -c phpunit.xml --testsuite Integration

# Запуск тестов с покрытием кода
test-coverage: test-setup
	docker compose -f docker-compose.yml -f docker-compose.dev.yml exec php-fpm1 vendor/bin/phpunit -c phpunit.xml --coverage-html ./coverage

# ────────────────────────────────
# Миграции
# ────────────────────────────────

# Миграции в dev окружении
migrate-dev:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml exec roadrunner-backend1 php src/scripts/migrate.php migrate

migrate-status-dev:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml exec roadrunner-backend1 php src/scripts/migrate.php status

# Миграции в prod окружении
migrate-prod:
	docker compose --env-file env/.env.prod -f docker-compose.yml -f docker-compose.prod.yml exec roadrunner-backend1 php src/scripts/migrate.php migrate

migrate-status-prod:
	docker compose --env-file env/.env.prod -f docker-compose.yml -f docker-compose.prod.yml exec roadrunner-backend1 php src/scripts/migrate.php status

# Создание новой миграции (локально)
create-migration:
	@read -p "Введите название миграции: " name; \
	last_number=$$(ls src/Database/migrations/*.sql 2>/dev/null | sed 's/.*\/\([0-9]*\)_.*/\1/' | sort -n | tail -1); \
	if [ -z "$$last_number" ]; then next_number="001"; else next_number=$$(printf "%03d" $$(($$last_number + 1))); fi; \
	filename="src/Database/migrations/$${next_number}_$${name}.sql"; \
	echo "-- Миграция: $${name}" > $$filename; \
	echo "-- Создана: $$(date)" >> $$filename; \
	echo "" >> $$filename; \
	echo "-- TODO: Добавьте SQL код ниже" >> $$filename; \
	echo "" >> $$filename; \
	echo "Создана миграция: $$filename"

# Команда для полного сброса dev БД, очистки таблицы migrations и применения новых миграций
dev-reset:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml down
	docker volume rm postgres-myfitness-data || true
	docker compose -f docker-compose.yml -f docker-compose.dev.yml build --build-arg INSTALL_DEV=true
	docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d
	@echo "Dev БД полностью сброшена и пересоздана!"
