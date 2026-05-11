<?php

namespace App\Http\Controllers;

use App\Models\Event;
use Illuminate\Http\Request;

class EventController extends Controller
{
    public function index() {
        return response()->json(Event::all(), 200);
    }

    // This handles the POST /events
    public function store(Request $request)
    {
        $validated = $request->validate([
            'eventTitle'       => 'required|string|max:100',
            'eventDescription' => 'nullable|string',
            'eventDate'        => 'required|date',
            'eventLocation'    => 'required|string|max:100',
        ]);

        $event = Event::create($validated);

        return response()->json([
            'message' => 'Event created successfully',
            'event'   => $event
        ], 201);
    }

    // This handles the PUT /events/{id}
    public function update(Request $request, $id)
    {
        $event = Event::find($id);

        if (!$event) {
            return response()->json(['message' => 'Event not found'], 404);
        }

        $validated = $request->validate([
            'eventTitle'       => 'sometimes|string|max:100',
            'eventDescription' => 'nullable|string',
            'eventDate'        => 'sometimes|date',
            'eventLocation'    => 'sometimes|string|max:100',
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