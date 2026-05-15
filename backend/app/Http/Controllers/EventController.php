<?php

namespace App\Http\Controllers;

use App\Models\Event;
use Illuminate\Http\Request;

class EventController extends Controller
{
    public function index() {
        return response()->json(Event::all(), 200);
    }

    public function store(Request $request)
    {
        // Stick to your database column names: eventTitle, eventDescription, etc.
        $validated = $request->validate([
            'eventTitle'       => 'required|string|max:100',
            'eventDescription' => 'nullable|string',
            'eventDate'        => 'required|date',
            'eventLocation'    => 'required|string|max:100',
            'capacity'         => 'required|integer|min:0',
        ]);

        $event = Event::create($validated);

        return response()->json([
            'message' => 'Event created successfully',
            'event'   => $event
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $event = Event::find($id);

        if (!$event) {
            return response()->json(['message' => 'Event not found'], 404);
        }

        // 'sometimes' allows you to update only one field without sending the others
        $validated = $request->validate([
            'eventTitle'       => 'sometimes|string|max:100',
            'eventDescription' => 'nullable|string',
            'eventDate'        => 'sometimes|date',
            'eventLocation'    => 'sometimes|string|max:100',
            'capacity'         => 'sometimes|integer|min:0',
        ]);

        $event->update($validated);

        return response()->json([
            'message' => 'Event updated successfully',
            'event'   => $event
        ], 200);
    }

    public function destroy($id)
    {
        $event = Event::find($id);
        
        if (!$event) {
            return response()->json(['message' => 'Event not found'], 404);
        }

        $event->delete();
        return response()->json(['message' => 'Event deleted successfully'], 200);
    }
}