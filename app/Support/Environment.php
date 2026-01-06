<?php

namespace App\Support;

class Environment
{
    public const PUBLIC_KEYS = ['APP_NAME', 'API_URL', 'ENVIRONMENT', 'VERSION'];

    public static function value(string $key): string
    {
        $value = trim((string) env($key, ''));

        return $value === '' ? 'Not set' : $value;
    }

    public static function publicEnvs(): array
    {
        return array_map(
            fn (string $key) => [
                'key' => $key,
                'value' => self::value($key),
            ],
            self::PUBLIC_KEYS,
        );
    }
}
