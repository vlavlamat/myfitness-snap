<?php

declare(strict_types=1);

namespace App\Database;

use PDO;
use PDOException;

class Connection
{
    private static ?PDO $instance = null;

    public static function getInstance(): PDO
    {
        if (self::$instance === null) {
            $host = $_ENV['DB_HOST'] ?? 'postgres';
            $port = $_ENV['DB_PORT'] ?? 5432;
            $dbName = $_ENV['DB_NAME'] ?? 'myfitnesssnap';
            $username = $_ENV['DB_USER'] ?? 'postgres';
            $password = $_ENV['DB_PASSWORD'] ?? 'password';

            $dsn = "pgsql:host={$host};port={$port};dbname={$dbName}";

            try {
                self::$instance = new PDO($dsn, $username, $password, [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES => false,
                ]);
            } catch (PDOException $e) {
                throw new \RuntimeException("Connection failed: " . $e->getMessage());
            }
        }

        return self::$instance;
    }
}
