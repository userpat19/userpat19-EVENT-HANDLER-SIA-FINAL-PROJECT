<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('events', function (Blueprint $table) {
            $table->id();
            $table->string('eventTitle', 100);
            $table->text('eventDescription')->nullable();
            $table->dateTime('eventDate');
            $table->string('eventLocation', 100);
            $table->integer('capacity')->default(0); // Added capacity here
            $table->timestamp('createdAt')->useCurrent();
            $table->timestamp('updatedAt')->useCurrent()->useCurrentOnUpdate();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('events');
    }
};