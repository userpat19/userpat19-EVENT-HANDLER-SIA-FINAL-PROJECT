import 'package:flutter/material.dart';
import '../data/event_repository.dart';
import '../models/event.dart';

class EventFormScreen extends StatefulWidget {
  final Event? event;

  const EventFormScreen({super.key, this.event});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _capacityController;
  late DateTime _eventDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    _titleController = TextEditingController(text: event?.title ?? '');
    _locationController = TextEditingController(text: event?.location ?? '');
    _descriptionController = TextEditingController(text: event?.description ?? '');
    _capacityController = TextEditingController(text: event?.capacity.toString() ?? '50');
    _eventDate = event?.date ?? DateTime.now().add(const Duration(days: 3, hours: 18));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (!mounted || selectedDate == null) {
      return;
    }
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_eventDate),
    );
    if (!mounted || selectedTime == null) {
      return;
    }
    setState(() {
      _eventDate = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
    });
  }

  Future<void> _saveEvent() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      final event = widget.event;
      final newEvent = Event(
        id: event?.id ?? 'event-${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        date: _eventDate,
        capacity: int.tryParse(_capacityController.text.trim()) ?? 0,
      );

      if (event != null) {
        await EventRepository.update(newEvent);
      } else {
        await EventRepository.add(newEvent);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.event != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Event' : 'Create Event'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(labelText: 'Event title'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an event title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(labelText: 'Location'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _capacityController,
                  enabled: !_isLoading,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Capacity'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter capacity';
                    }
                    if (int.tryParse(value.trim()) == null || int.parse(value.trim()) < 0) {
                      return 'Capacity must be a non-negative number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  enabled: !_isLoading,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please add a brief description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Event date & time',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withAlpha((0.8 * 255).round()),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _isLoading ? null : _pickDate,
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: Text(
                    '${_eventDate.month}/${_eventDate.day}/${_eventDate.year} • ${_eventDate.hour.toString().padLeft(2, '0')}:${_eventDate.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveEvent,
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(54)),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                        )
                      : Text(isEditing ? 'Save changes' : 'Create event', style: const TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
