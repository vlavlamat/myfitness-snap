<?php

declare(strict_types=1);

namespace App\Database;

use PDO;
use PDOException;

class Migration
{
    private PDO $pdo;
    private string $migrationsPath;

    public function __construct(PDO $pdo, string $migrationsPath)
    {
        $this->pdo = $pdo;
        $this->migrationsPath = $migrationsPath;
    }

    /**
     * Запуск всех миграций
     */
    public function migrate(): void
    {
        echo "🚀 Начинаем миграции...\n";

        $this->createMigrationsTable();
        $migrations = $this->getMigrationsToRun();

        if (empty($migrations)) {
            echo "✅ Все миграции уже применены!\n";
            return;
        }

        foreach ($migrations as $migration) {
            $this->runMigration($migration);
        }

        echo "🎉 Все миграции успешно применены!\n";
    }

    /**
     * Создает таблицу для отслеживания миграций
     */
    private function createMigrationsTable(): void
    {
        $sql = "
            CREATE TABLE IF NOT EXISTS migrations (
                id SERIAL PRIMARY KEY,
                migration_name VARCHAR(255) UNIQUE NOT NULL,
                applied_at TIMESTAMPTZ DEFAULT NOW()
            )
        ";

        $this->pdo->exec($sql);
        echo "📋 Таблица migrations готова\n";
    }

    /**
     * Получает список миграций для выполнения
     */
    private function getMigrationsToRun(): array
    {
        // Получаем все файлы миграций
        $allMigrations = glob($this->migrationsPath . '/*.sql');
        sort($allMigrations);

        // Получаем уже примененные миграции
        $stmt = $this->pdo->query("SELECT migration_name FROM migrations ORDER BY migration_name");
        $appliedMigrations = $stmt->fetchAll(PDO::FETCH_COLUMN);

        // Фильтруем только новые миграции
        $migrationsToRun = [];
        foreach ($allMigrations as $migrationFile) {
            $migrationName = basename($migrationFile);
            if (!in_array($migrationName, $appliedMigrations)) {
                $migrationsToRun[] = $migrationFile;
            }
        }

        return $migrationsToRun;
    }

    /**
     * Выполняет одну миграцию
     */
    private function runMigration(string $migrationFile): void
    {
        $migrationName = basename($migrationFile);
        echo "⚡ Применяем миграцию: {$migrationName}... ";

        try {
            $this->pdo->beginTransaction();

            // Читаем и выполняем SQL файл
            $sql = file_get_contents($migrationFile);
            $this->pdo->exec($sql);

            // Записываем в таблицу migrations
            $stmt = $this->pdo->prepare("INSERT INTO migrations (migration_name) VALUES (?)");
            $stmt->execute([$migrationName]);

            $this->pdo->commit();
            echo "✅\n";

        } catch (PDOException $e) {
            $this->pdo->rollBack();
            echo "❌\n";
            throw new \RuntimeException("Ошибка в миграции {$migrationName}: " . $e->getMessage());
        }
    }

    /**
     * Откат последней миграции (опционально)
     */
    public function rollback(): void
    {
        echo "⚠️  Откат миграций не реализован. Сделайте это вручную если нужно.\n";
        // Здесь можно добавить логику отката, если создать down-миграции
    }

    /**
     * Показать статус миграций
     */
    public function status(): void
    {
        $this->createMigrationsTable();

        $allMigrations = glob($this->migrationsPath . '/*.sql');
        sort($allMigrations);

        $stmt = $this->pdo->query("SELECT migration_name, applied_at FROM migrations ORDER BY migration_name");
        $appliedMigrations = [];
        while ($row = $stmt->fetch()) {
            $appliedMigrations[$row['migration_name']] = $row['applied_at'];
        }

        echo "📊 Статус миграций:\n";
        echo str_repeat('-', 80) . "\n";

        foreach ($allMigrations as $migrationFile) {
            $migrationName = basename($migrationFile);
            $status = isset($appliedMigrations[$migrationName]) ? '✅ Применена' : '⏳ Ожидает';
            $date = isset($appliedMigrations[$migrationName]) ? $appliedMigrations[$migrationName] : '';

            printf("%-40s %-15s %s\n", $migrationName, $status, $date);
        }
    }
}
