-- Создание таблицы приемов пищи
CREATE TABLE meals (
                       id SERIAL PRIMARY KEY,
                       user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                       photo_url TEXT,
                       photo_file_id TEXT,
                       title TEXT NOT NULL,
                       description TEXT,
                       calories INT NOT NULL CHECK (calories >= 0),
                       protein DECIMAL(6,2) DEFAULT 0 CHECK (protein >= 0),
                       fat DECIMAL(6,2) DEFAULT 0 CHECK (fat >= 0),
                       carbs DECIMAL(6,2) DEFAULT 0 CHECK (carbs >= 0),
                       meal_type TEXT DEFAULT 'other' CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack', 'other')),
                       eaten_at TIMESTAMPTZ DEFAULT NOW(),
                       raw_ai_data JSONB,
                       is_confirmed BOOLEAN DEFAULT false,
                       created_at TIMESTAMPTZ DEFAULT NOW(),
                       updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Индексы для оптимизации запросов
CREATE INDEX idx_meals_user_id ON meals(user_id);
CREATE INDEX idx_meals_eaten_at ON meals(eaten_at);
CREATE INDEX idx_meals_user_eaten ON meals(user_id, eaten_at);

-- Комментарии
COMMENT ON TABLE meals IS 'Приемы пищи пользователей';
COMMENT ON COLUMN meals.raw_ai_data IS 'Сырые данные от AI в JSON формате';
COMMENT ON COLUMN meals.is_confirmed IS 'Подтвержден ли прием пищи пользователем';