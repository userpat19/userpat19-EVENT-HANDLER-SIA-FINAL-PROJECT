<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Event extends Model
{
    // If a column isn't in this list, $event->update() will ignore it!
    protected $fillable = [
        'eventTitle',
        'eventDescription',
        'eventDate',
        'eventLocation'
    ];

    // Your migrations use custom names, so you must define these:
    const CREATED_AT = 'createdAt';
    const UPDATED_AT = 'updatedAt';
}