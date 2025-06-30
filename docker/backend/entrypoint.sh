#!/bin/bash
set -e

echo "Ожидаем готовности PostgreSQL..."
# Используем переменные окружения из docker-compose
until pg_isready -h ${DB_HOST:-postgres} -p ${DB_PORT:-5432} -U ${DB_USER:-postgres}; do
    echo "PostgreSQL еще не готова, ждем..."
    sleep 2
done

echo "PostgreSQL готова!"

# Запускаем миграции только если они есть
if [ -d "/app/src/scripts" ] && [ -f "/app/src/scripts/migrate.php" ]; then
    echo "Запускаем миграции..."
    php /app/src/scripts/migrate.php migrate
    echo "Миграции завершены!"
else
    echo "Миграции не найдены, пропускаем..."
fi

echo "RoadRunner готов к запуску!"

# Запускаем основную команду (RoadRunner)
exec "$@"
