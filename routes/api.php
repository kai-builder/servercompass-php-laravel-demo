<?php

use App\Support\Environment;
use Illuminate\Support\Facades\Route;

Route::get('/env', function () {
    return response()->json([
        'envs' => Environment::publicEnvs(),
    ]);
});
