<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Event extends Model
{
    protected $table = 'events';

    public const CREATED_AT = 'createdAt';
    public const UPDATED_AT = 'updatedAt';

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

    protected $appends = [
        'title',
        'description',
        'date',
        'location',
    ];

    protected $hidden = [
        'eventTitle',
        'eventDescription',
        'eventDate',
        'eventLocation',
    ];

    public function getTitleAttribute()
    {
        return $this->attributes['eventTitle'] ?? null;
    }

    public function setTitleAttribute($value)
    {
        $this->attributes['eventTitle'] = $value;
    }

    public function getDescriptionAttribute()
    {
        return $this->attributes['eventDescription'] ?? null;
    }

    public function setDescriptionAttribute($value)
    {
        $this->attributes['eventDescription'] = $value;
    }

    public function getDateAttribute()
    {
        return $this->eventDate;
    }

    public function setDateAttribute($value)
    {
        $this->attributes['eventDate'] = $value;
    }

    public function getLocationAttribute()
    {
        return $this->attributes['eventLocation'] ?? null;
    }

    public function setLocationAttribute($value)
    {
        $this->attributes['eventLocation'] = $value;
    }
}