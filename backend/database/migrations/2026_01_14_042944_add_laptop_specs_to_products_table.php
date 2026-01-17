<?php
// Create new migration: php artisan make:migration add_laptop_specs_to_products_table

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up()
    {
        Schema::table('products', function (Blueprint $table) {
            $table->string('cpu')->nullable()->after('description');
            $table->string('ram')->nullable()->after('cpu');
            $table->string('storage')->nullable()->after('ram');
            $table->string('gpu')->nullable()->after('storage');
            $table->string('display')->nullable()->after('gpu');
            $table->string('battery')->nullable()->after('display');
            $table->string('warranty')->nullable()->after('battery');
        });
    }

    public function down()
    {
        Schema::table('products', function (Blueprint $table) {
            $table->dropColumn(['cpu', 'ram', 'storage', 'gpu', 'display', 'battery', 'warranty']);
        });
    }
};