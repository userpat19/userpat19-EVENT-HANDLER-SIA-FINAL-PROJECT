import 'package:flutter/foundation.dart';

import '../models/event.dart';
import 'api_service.dart';

class EventRepository {
  EventRepository._();

  static List<Event> _cachedEvents = [];
  static final ValueNotifier<List<Event>> eventsNotifier = ValueNotifier(_cachedEvents);

  static Future<List<Event>> getEvents() async {
    try {
      _cachedEvents = await ApiService.fetchEvents();
      eventsNotifier.value = List.unmodifiable(_cachedEvents);
      return _cachedEvents;
    } catch (e) {
      print('Error fetching events: $e');
      return _cachedEvents;
    }
  }

  static Future<void> add(Event event) async {
    try {
      final createdEvent = await ApiService.createEvent(event);
      _cachedEvents.insert(0, createdEvent);
      eventsNotifier.value = List.unmodifiable(_cachedEvents);
    } catch (e) {
      print('Error adding event: $e');
      rethrow;
    }
  }

  static Future<void> update(Event updatedEvent) async {
    try {
      final event = await ApiService.updateEvent(updatedEvent.id, updatedEvent);
      final index = _cachedEvents.indexWhere((event) => event.id == updatedEvent.id);
      if (index != -1) {
        _cachedEvents[index] = event;
        eventsNotifier.value = List.unmodifiable(_cachedEvents);
      }
    } catch (e) {
      print('Error updating event: $e');
      rethrow;
    }
  }

  static Future<void> remove(String id) async {
    try {
      await ApiService.deleteEvent(id);
      _cachedEvents.removeWhere((event) => event.id == id);
      eventsNotifier.value = List.unmodifiable(_cachedEvents);
    } catch (e) {
      print('Error removing event: $e');
      rethrow;
    }
  }

  static Event? findById(String id) {
    try {
      return _cachedEvents.firstWhere((event) => event.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<Event> get events => _cachedEvents;
}
