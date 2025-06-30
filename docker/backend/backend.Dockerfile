FROM php:8.4-cli-alpine

# Устанавливаем нужные пакеты
RUN apk add --no-cache unzip git curl zlib-dev autoconf linux-headers postgresql-client postgresql-dev bash $PHPIZE_DEPS \
 && pecl install redis \
 && docker-php-ext-enable redis \
 && pecl install pcov \
 && docker-php-ext-enable pcov \
 && docker-php-ext-install sockets \
 && docker-php-ext-install pdo pdo_pgsql pgsql \
 && apk del linux-headers postgresql-dev \
 && apk del $PHPIZE_DEPS

# apk --no-cache - установка пакетов без сохранения кеша, что уменьшает размер образа
# unzip - для распаковки zip-архивов
# git - для работы с Git-репозиториями
# curl - для HTTP-запросов
# zlib-dev - библиотека для сжатия данных, нужна для многих PHP-расширений
# $PHPIZE_DEPS - переменная окружения, содержащая список пакетов, необходимых для компиляции PHP-расширений
# pecl install redis - установка PHP-расширения для работы с Redis через PECL
# docker-php-ext-enable redis - активация установленного расширения Redis
# pecl install pcov - установка PCOV (PHP Code Coverage) - современная и быстрая альтернатива Xdebug для измерения покрытия кода
# docker-php-ext-enable pcov - активация расширения PCOV для анализа покрытия кода тестами
# docker-php-ext-install sockets - установка расширения sockets (необходимо для RoadRunner)
# apk del PHPIZE_DEPS - удаление компиляторов и инструментов для сборки после установки, чтобы уменьшить размер образа

# Копируем настройки PHP
COPY ./php/php.ini /usr/local/etc/php/conf.d/local.ini
COPY ./php/conf.d/ /usr/local/etc/php/conf.d/

# php.ini - основной файл настройки PHP
# conf.d/ - директория с дополнительными конфигурационными файлами PHP

# Копируем бинарник Composer из официального образа
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Копируем бинарник RoadRunner
COPY --from=spiralscout/roadrunner:latest /usr/bin/rr /usr/local/bin/rr

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем composer файлы отдельно (для кеша)
COPY composer.json composer.lock ./

# Передаём аргумент для управления dev/prod-зависимостями
ARG INSTALL_DEV=false

# Устанавливаем зависимости с условием
RUN if [ "$INSTALL_DEV" = "true" ]; then \
      composer update --no-interaction --prefer-dist --no-scripts; \
    else \
      composer install --no-interaction --prefer-dist --no-scripts --no-dev; \
    fi

# Если INSTALL_DEV=true, устанавливаются все зависимости (включая dev)
# Если INSTALL_DEV=false (по умолчанию), устанавливаются только prod-зависимости
# --no-interaction - выполнение без интерактивных вопросов
# --prefer-dist - предпочтение загрузки пакетов из дистрибутивов, а не из исходников
# --no-scripts - пропуск выполнения скриптов, определенных в composer.json
# --no-dev - пропуск установки dev-зависимостей (только для prod-варианта)

# Копируем оставшиеся файлы проекта
COPY ./src /app/src
COPY ./public /app/public
COPY ./config /app/config
COPY ./.rr.yml /app/.rr.yaml

# Копируем и настраиваем entrypoint
COPY ./docker/backend/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Открываем порт для RoadRunner HTTP сервера
EXPOSE 8080

# Устанавливаем entrypoint для миграций
ENTRYPOINT ["/entrypoint.sh"]

# Запускаем RoadRunner
CMD ["rr", "serve"]
