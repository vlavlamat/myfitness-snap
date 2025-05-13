## 🛠️ Техническая документация проекта "MyFitnessSnap"

### 🧱 Общая архитектура

**Компоненты:**

* Telegram Bot (бот-помощник в Telegram)
* PHP Backend (REST API + Telegram webhook)
* PostgreSQL база данных
* AI-интеграция (OpenAI GPT-4 Vision API)
* Web-интерфейс (SSR на PHP)
* Docker Compose-инфраструктура

**Взаимодействие компонентов:**

1. Пользователь отправляет фото в Telegram-бот
2. Бот получает `file_id` и загружает фото через Telegram API
3. Фото передаётся на обработку в GPT-4 Vision API
4. AI возвращает список еды + калории + БЖУ
5. Ответ отправляется пользователю на подтверждение
6. После подтверждения — данные сохраняются в PostgreSQL
7. Пользователь может просматривать статистику через Telegram или Web-интерфейс

---

### ⚙️ Технологический стек

| Область       | Технология                     |
| ------------- | ------------------------------ |
| Язык          | PHP 8.x                        |
| БД            | PostgreSQL                     |
| Бот           | php-telegram-bot/core          |
| AI            | OpenAI GPT-4 Vision            |
| Веб-интерфейс | PHP SSR (Twig/Blade)           |
| Хостинг       | Docker, Nginx, Supervisor      |
| Cron задачи   | Для сброса статистики и планов |

---

### 🗂️ Структура проекта

```
myfitnesssnap/
├── bot/                    # Telegram webhook и логика
│   ├── BotHandler.php
│   └── TelegramRouter.php
├── public/                 # Веб-доступная директория
│   └── index.php
├── src/
│   ├── AI/                 # Работа с GPT API
│   │   └── FoodAnalyzer.php
│   ├── DB/                 # Работа с БД
│   │   └── MealRepository.php
│   ├── Web/                # SSR-интерфейс
│   │   ├── controllers/
│   │   ├── views/
│   │   └── routes.php
├── scripts/                # cron-скрипты и задания
├── docker/
│   ├── php.Dockerfile
│   ├── nginx.Dockerfile
│   └── postgres.Dockerfile
├── .env
├── docker-compose.yml
└── README.md
```

---

### 🧩 Основные модули и классы

#### ✅ `TelegramRouter.php`

* Парсит входящие апдейты
* Делегирует обработку сообщения (фото, текст, команды)

#### ✅ `FoodAnalyzer.php`

* Получает файл изображения
* Отправляет его в GPT-4 Vision с промптом
* Получает JSON: блюдо, калории, БЖУ

#### ✅ `MealRepository.php`

* Сохраняет приём пищи
* Получает статистику за день/неделю
* Управляет целями и пользователями
* Обрабатывает повторение и шаблоны

#### ✅ `controllers/`

* `DashboardController`: калории на сегодня, графики
* `GoalController`: цели
* `MealController`: ручной ввод, история, редактирование, повторение еды
* `StatsController`: вес, метрики тела, экспорт отчётов

#### ✅ `routes.php`

* Простая маршрутизация вида:

```php
GET /dashboard => DashboardController@index
POST /goal => GoalController@update
POST /weight => StatsController@storeWeight
```

---

### 🗄️ Структура базы данных (PostgreSQL)

```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  telegram_id BIGINT UNIQUE NOT NULL,
  name TEXT,
  daily_calories_goal INT DEFAULT 2000,
  protein_ratio INT DEFAULT 30,
  fat_ratio INT DEFAULT 30,
  carb_ratio INT DEFAULT 40,
  micronutrients JSONB,
  mode TEXT DEFAULT 'simple',
  meals_per_day INT DEFAULT 3,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE meals (
  id SERIAL PRIMARY KEY,
  user_id INT REFERENCES users(id),
  photo_url TEXT,
  title TEXT,
  calories INT,
  protein DECIMAL(5,2),
  fat DECIMAL(5,2),
  carbs DECIMAL(5,2),
  micronutrients JSONB,
  meal_type TEXT,
  eaten_at TIMESTAMPTZ DEFAULT NOW(),
  raw_ai_data JSONB
);

CREATE TABLE body_stats (
  id SERIAL PRIMARY KEY,
  user_id INT REFERENCES users(id),
  weight DECIMAL(5,2),
  fat_percent DECIMAL(5,2),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE daily_goals (
  id SERIAL PRIMARY KEY,
  user_id INT REFERENCES users(id),
  day_of_week INT,
  calories INT,
  protein_ratio INT,
  fat_ratio INT,
  carb_ratio INT
);
```

---

### 🧬 Профили: простой и сложный режим

* `simple`: только калории и БЖУ
* `advanced`: добавляется учёт микронутриентов (калий, магний, натрий, железо, витамины и т.п.)
* Переключается через команду `/mode simple` или `/mode advanced`

---

### 🍽️ Поддержка приёмов пищи

* Пользователь задаёт кол-во приёмов пищи `/meals set 5`
* Каждый приём может быть помечен: `breakfast`, `lunch`, `dinner`, `snack`, и т.д.
* Поддержка повторения приёмов пищи `/repeat last` или выбор из истории

---

### 📊 Графики и визуализация

* Генерация PNG-диаграмм на сервере (через GD, ImageMagick или matplotlib)
* Круговые диаграммы по БЖУ и микронутриентам
* Графики веса, калорий, прогресса целей
* Отправка изображений в Telegram

---

### 🔔 Напоминания и уведомления

* Пользователь может установить напоминания о приёмах пищи `/remind at 13:00`
* Уведомления через Telegram API по расписанию (cron)

---

### 📦 Экспорт данных

* Экспорт дневника питания, статистики и веса в PDF/CSV
* Отправка через Telegram `/export week` или через Web-интерфейс

---

### 🔐 Аутентификация

* Через Telegram OAuth (или ручная регистрация по коду)
* Авторизация сессий на вебе через токены

---

### 📊 Метрики и статистика

* Количество фото / приёмов пищи в день
* Средняя калорийность
* Цель достигнута / нет
* Вес и изменения по времени
* Отображение на графике по дням / неделям
* Часто повторяемые блюда

---

### 🔄 Расширения на будущее

* Распознавание голосовых сообщений (Whisper API)
* Расчёт микронутриентов
* Генерация отчётов (PDF)
* Интеграция с Apple Health / Google Fit
* Платные подписки
* Друзья и челленджи (социальная активность)
* API для интеграции с внешними сервисами

---

### 🧪 Тестирование

* Unit-тесты (PHPUnit): логика расчётов и анализа
* Интеграционные тесты: Telegram API + DB
* e2e тесты (опционально через Playwright/Pest)

---

### 🧭 Развёртывание

* Через Docker Compose
* Сервер Ubuntu: Nginx + PHP-FPM + PostgreSQL
* Webhook Telegram ставится через CLI

```bash
curl -F "url=https://example.com/bot/webhook.php" https://api.telegram.org/bot<token>/setWebhook
```

---

### 🧾 Логи и мониторинг

* Хранение логов в `/logs`
* Ошибки AI и Telegram записываются в `error.log`
* Метрики можно подключить через Prometheus (опционально)
