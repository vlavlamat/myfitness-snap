<?php

declare(strict_types=1);

// Добавим работу с сессиями
session_start(); // ← автоматически использует RedisCluster!

// Тестируем сессии
if (!isset($_SESSION['visits'])) {
    $_SESSION['visits'] = 0;
}
$_SESSION['visits']++;

?>
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MyFitness App</title>
</head>
<body>
    <h1>MyFitness Snap</h1>
    <p>Количество посещений: <?= $_SESSION['visits'] ?></p>
    <p>ID сессии: <?= session_id() ?></p>
    <p>Сессии хранятся в Redis Cluster! 🚀</p>
</body>
</html>
