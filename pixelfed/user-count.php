<?php
// Prints the number of user accounts, so the start script creates the first admin only once.
require '/var/www/html/vendor/autoload.php';
$app = require '/var/www/html/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
echo App\Models\User::count();
