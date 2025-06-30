#!/usr/bin/env php
<?php

require_once __DIR__ . '/../../vendor/autoload.php';

use App\Database\Connection;
use App\Database\Migration;

// Загружаем переменные окружения
if (file_exists(__DIR__ . '/../.env')) {
    $lines = file(__DIR__ . '/../.env', FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos($line, '#') === 0) continue;
        [$key, $value] = explode('=', $line, 2);
        $_ENV[trim($key)] = trim($value);
    }
}

try {
    $pdo = Connection::getInstance();
    $migrationsPath = __DIR__ . '/../Database/migrations';
    $migration = new Migration($pdo, $migrationsPath);

    $command = $argv[1] ?? 'migrate';

    switch ($command) {
        case 'migrate':
            $migration->migrate();
            break;
        case 'status':
            $migration->status();
            break;
        case 'rollback':
            $migration->rollback();
            break;
        default:
            echo "Использование: php migrate.php [migrate|status|rollback]\n";
            exit(1);
    }

} catch (Exception $e) {
    echo "❌ Ошибка: " . $e->getMessage() . "\n";
    exit(1);
}
