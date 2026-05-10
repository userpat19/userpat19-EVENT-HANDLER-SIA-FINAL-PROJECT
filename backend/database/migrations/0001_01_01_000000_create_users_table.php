<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 1. Creates the exact users table from your phpMyAdmin
        Schema::create('users', function (Blueprint $table) {
            $table->id(); 
            $table->string('firstName', 100);
            $table->string('lastName', 100);
            $table->string('email', 100)->unique();
            $table->string('password', 100);
            $table->boolean('isAdmin')->default(false);
            $table->timestamp('createdAt')->useCurrent();
            $table->timestamp('updatedAt')->useCurrent()->useCurrentOnUpdate();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};