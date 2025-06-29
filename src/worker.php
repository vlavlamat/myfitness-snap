<?php

declare(strict_types=1);

use Psr\Http\Message\ResponseInterface;
use Spiral\RoadRunner\Worker;
use Spiral\RoadRunner\Http\PSR7Worker;
use Nyholm\Psr7\Factory\Psr17Factory;

// Подключаем автозагрузчик
require __DIR__ . '/../vendor/autoload.php';

// Создаем PSR-7 совместимый worker для HTTP
$worker = Worker::create();
$factory = new Psr17Factory();

// Используем специальный PSR7Worker для HTTP запросов
$psr7Worker = new PSR7Worker($worker, $factory, $factory, $factory);

while (true) {
    try {
        // Получаем HTTP запрос через PSR7Worker
        $request = $psr7Worker->waitRequest();

        if ($request === null) {
            break;
        }

        // Обрабатываем запрос
        $response = handleRequest($request, $factory);

        // Отправляем ответ
        $psr7Worker->respond($response);

    } catch (Throwable $e) {
        // Создаем безопасный ответ об ошибке
        $errorResponse = createErrorResponse($factory, $e);
        
        try {
            $psr7Worker->respond($errorResponse);
        } catch (Throwable $respondError) {
            // Если не можем отправить ответ, используем базовую обработку
            $worker->error('Failed to send error response: ' . $respondError->getMessage());
            break;
        }
    }
}

/**
 * Создает безопасный HTTP ответ об ошибке без использования json_encode
 */
function createErrorResponse(Psr17Factory $factory, Throwable $e): ResponseInterface
{
    // Создаем простой JSON вручную, чтобы избежать JsonException
    $errorMessage = str_replace(['"', "\n", "\r", "\t"], ['\"', '\\n', '\\r', '\\t'], $e->getMessage());
    $errorFile = str_replace(['"', "\n", "\r", "\t"], ['\"', '\\n', '\\r', '\\t'], $e->getFile());
    
    $jsonBody = sprintf(
        '{"error":"Internal Server Error","message":"%s","file":"%s","line":%d}',
        $errorMessage,
        $errorFile,
        $e->getLine()
    );

    return $factory->createResponse(500)
        ->withHeader('Content-Type', 'application/json')
        ->withHeader('Access-Control-Allow-Origin', '*')
        ->withBody($factory->createStream($jsonBody));
}

/**
 * Безопасная сериализация в JSON с обработкой ошибок
 */
function safeJsonEncode(array $data, int $flags = 0): string
{
    try {
        return json_encode($data, $flags | JSON_THROW_ON_ERROR);
    } catch (JsonException $e) {
        // Если не можем сериализовать данные, создаем простой JSON вручную
        return '{"error":"JSON encoding failed","message":"' . 
               str_replace('"', '\"', $e->getMessage()) . '"}';
    }
}

function handleRequest($request, $factory)
{
    // Добавляем CORS заголовки для всех ответов
    $corsHeaders = [
        'Access-Control-Allow-Origin' => '*',
        'Access-Control-Allow-Methods' => 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers' => 'Content-Type, Authorization',
    ];

    $path = $request->getUri()->getPath();
    $method = $request->getMethod();

    // Обработка CORS preflight запросов
    if ($method === 'OPTIONS') {
        $response = $factory->createResponse(200);
        foreach ($corsHeaders as $header => $value) {
            $response = $response->withHeader($header, $value);
        }
        return $response;
    }

    // Health check - убираем /api префикс, так как nginx его удаляет
    if ($path === '/health' && $method === 'GET') {
        try {
            $data = [
                'status' => 'ok',
                'timestamp' => time(),
                'message' => 'RoadRunner v3 is running',
                'php_version' => PHP_VERSION,
                'memory_usage' => memory_get_usage(true),
                'peak_memory' => memory_get_peak_usage(true),
                'server_time' => date('Y-m-d H:i:s'),
            ];

            $jsonData = safeJsonEncode($data, JSON_PRETTY_PRINT);
            $response = $factory->createResponse(200)
                ->withHeader('Content-Type', 'application/json')
                ->withBody($factory->createStream($jsonData));

            foreach ($corsHeaders as $header => $value) {
                $response = $response->withHeader($header, $value);
            }

            return $response;
        } catch (Throwable $e) {
            return createErrorResponse($factory, $e);
        }
    }

    // Test endpoint
    if ($path === '/test' && $method === 'GET') {
        try {
            $data = [
                'message' => 'Test endpoint working',
                'method' => $method,
                'path' => $path,
                'full_uri' => (string) $request->getUri(),
                'time' => date('Y-m-d H:i:s'),
                'query_params' => $request->getQueryParams(),
                'headers' => $request->getHeaders(),
            ];

            $jsonData = safeJsonEncode($data, JSON_PRETTY_PRINT);
            $response = $factory->createResponse(200)
                ->withHeader('Content-Type', 'application/json')
                ->withBody($factory->createStream($jsonData));

            foreach ($corsHeaders as $header => $value) {
                $response = $response->withHeader($header, $value);
            }

            return $response;
        } catch (Throwable $e) {
            return createErrorResponse($factory, $e);
        }
    }

    // Echo endpoint for POST requests
    if ($path === '/echo' && $method === 'POST') {
        try {
            $body = $request->getBody()->getContents();
            $data = [
                'received' => $body,
                'method' => $method,
                'content_type' => $request->getHeaderLine('Content-Type'),
                'time' => date('Y-m-d H:i:s'),
            ];

            $jsonData = safeJsonEncode($data, JSON_PRETTY_PRINT);
            $response = $factory->createResponse(200)
                ->withHeader('Content-Type', 'application/json')
                ->withBody($factory->createStream($jsonData));

            foreach ($corsHeaders as $header => $value) {
                $response = $response->withHeader($header, $value);
            }

            return $response;
        } catch (Throwable $e) {
            return createErrorResponse($factory, $e);
        }
    }

    // Default 404
    try {
        $data = [
            'error' => 'Not found',
            'path' => $path,
            'method' => $method
        ];
        
        $jsonData = safeJsonEncode($data);
        $response = $factory->createResponse(404)
            ->withHeader('Content-Type', 'application/json')
            ->withBody($factory->createStream($jsonData));

        foreach ($corsHeaders as $header => $value) {
            $response = $response->withHeader($header, $value);
        }

        return $response;
    } catch (Throwable $e) {
        return createErrorResponse($factory, $e);
    }
}