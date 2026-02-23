<?php

use App\Support\Environment;
use Illuminate\Support\Facades\Route;

Route::get('/env', function () {
    return response()->json([
        'envs' => Environment::publicEnvs(),
    ]);
});

Route::get('/health', function () {
    return response()->json([
        'status' => 'ok',
        'service' => 'servercompass-php-laravel-demo',
    ]);
});
