<?php

use App\Support\Environment;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('env', [
        'title' => 'Server Compass Demo Environment Variables',
        'envs' => Environment::publicEnvs(),
        'apiEndpoint' => url('/api/env'),
    ]);
});
