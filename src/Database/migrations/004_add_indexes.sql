-- Дополнительные индексы для оптимизации

-- Составной индекс для быстрого поиска приемов пищи за день
-- Используем функцию date_trunc с AT TIME ZONE, которая является IMMUTABLE
CREATE OR REPLACE FUNCTION immutable_date_trunc(timestamptz) RETURNS date AS $$
  SELECT date_trunc('day', $1 AT TIME ZONE 'UTC')::date;
$$ LANGUAGE SQL IMMUTABLE;

CREATE INDEX idx_meals_user_date ON meals(user_id, immutable_date_trunc(eaten_at));

-- Индекс для поиска по калориям (для статистики)
CREATE INDEX idx_meals_calories ON meals(calories) WHERE is_confirmed = true;

-- Индекс для JSON поиска в raw_ai_data (если нужно)
CREATE INDEX idx_meals_ai_data_gin ON meals USING gin(raw_ai_data);

-- Частичный индекс только для подтвержденных приемов пищи
CREATE INDEX idx_meals_confirmed ON meals(user_id, eaten_at) WHERE is_confirmed = true;
