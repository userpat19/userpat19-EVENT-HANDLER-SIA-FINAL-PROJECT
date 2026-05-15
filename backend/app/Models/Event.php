<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Event extends Model
{
    protected $table = 'events';

    // Make sure these match your migration column names exactly
    const CREATED_AT = 'createdAt';
    const UPDATED_AT = 'updatedAt';

    protected $fillable = [
        'eventTitle',
        'eventDescription',
        'eventDate',
        'eventLocation',
        'capacity',
    ];

    protected $casts = [
        'eventDate' => 'datetime',
        'capacity' => 'integer',
    ];

    // Accessors allow you to use $event->title in Flutter 
    // even if the DB column is eventTitle.
    public function getTitleAttribute() { return $this->eventTitle; }
    public function getDescriptionAttribute() { return $this->eventDescription; }
    public function getDateAttribute() { return $this->eventDate; }
    public function getLocationAttribute() { return $this->eventLocation; }
}