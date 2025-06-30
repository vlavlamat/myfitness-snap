-- Создание таблицы пользователей
CREATE TABLE users (
                       id SERIAL PRIMARY KEY,
                       telegram_id BIGINT UNIQUE NOT NULL,
                       name TEXT,
                       username TEXT,
                       daily_calories_goal INT DEFAULT 2000,
                       protein_ratio INT DEFAULT 30,
                       fat_ratio INT DEFAULT 30,
                       carb_ratio INT DEFAULT 40,
                       mode TEXT DEFAULT 'simple' CHECK (mode IN ('simple', 'advanced')),
                       timezone TEXT DEFAULT 'UTC',
                       is_active BOOLEAN DEFAULT true,
                       created_at TIMESTAMPTZ DEFAULT NOW(),
                       updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Индекс для быстрого поиска по telegram_id
CREATE INDEX idx_users_telegram_id ON users(telegram_id);

-- Комментарии
COMMENT ON TABLE users IS 'Пользователи Telegram бота';
COMMENT ON COLUMN users.telegram_id IS 'ID пользователя в Telegram';
COMMENT ON COLUMN users.mode IS 'Режим: simple или advanced';