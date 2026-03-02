<?php

namespace App\Support;

class Environment
{
    public const CONFIG_MAP = [
        'APP_NAME' => 'app.name',
        'API_URL' => 'servercompass.api_url',
        'ENVIRONMENT' => 'servercompass.environment',
        'VERSION' => 'servercompass.version',
    ];

    public static function value(string $configKey): string
    {
        $value = trim((string) config($configKey, ''));

        return $value === '' ? 'Not set' : $value;
    }

    public static function publicEnvs(): array
    {
        return array_map(
            fn (string $key, string $configKey) => [
                'key' => $key,
                'value' => self::value($configKey),
            ],
            array_keys(self::CONFIG_MAP),
            array_values(self::CONFIG_MAP),
        );
    }
}
