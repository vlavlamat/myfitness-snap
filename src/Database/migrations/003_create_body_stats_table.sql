
-- Создание таблицы статистики тела
CREATE TABLE body_stats (
                            id SERIAL PRIMARY KEY,
                            user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                            weight DECIMAL(5,2) CHECK (weight > 0 AND weight < 1000),
                            fat_percent DECIMAL(4,1) CHECK (fat_percent >= 0 AND fat_percent <= 100),
                            muscle_mass DECIMAL(5,2),
                            notes TEXT,
                            measured_at TIMESTAMPTZ DEFAULT NOW(),
                            created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Индексы
CREATE INDEX idx_body_stats_user_id ON body_stats(user_id);
CREATE INDEX idx_body_stats_measured_at ON body_stats(measured_at);

COMMENT ON TABLE body_stats IS 'Статистика тела пользователей (вес, жир, мышцы)';