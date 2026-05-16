import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../data/event_repository.dart';
import '../models/event.dart';

class EventFormScreen extends StatefulWidget {
  final Event? event;

  const EventFormScreen({super.key, this.event});

  static const Color brandOrange = Color(0xFFFF6B35);

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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: EventFormScreen.brandOrange),
          ),
          child: child!,
        );
      },
    );
    if (!mounted || selectedDate == null) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_eventDate),
    );
    if (!mounted || selectedTime == null) return;

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

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.event != null;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: Text(
          isEditing ? 'Update Details' : 'New Event',
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // Background accents
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: EventFormScreen.brandOrange.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configure your event',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1),
                    ),
                    const SizedBox(height: 8),
                    const Text('Fill in the details below to publish your event.', 
                        style: TextStyle(color: Colors.black45, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 32),

                    _buildField(
                      controller: _titleController,
                      label: 'Event Title',
                      hint: 'E.g. Tech Conference 2026',
                      icon: Icons.title_rounded,
                    ),
                    const SizedBox(height: 20),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            controller: _locationController,
                            label: 'Location',
                            hint: 'Room 404',
                            icon: Icons.place_rounded,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildField(
                            controller: _capacityController,
                            label: 'Capacity',
                            hint: '100',
                            icon: Icons.people_alt_rounded,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _buildField(
                      controller: _descriptionController,
                      label: 'Description',
                      hint: 'Tell everyone what it\'s about...',
                      icon: Icons.description_rounded,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),

                    // Date Picker Area
                    const Text('Schedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _isLoading ? null : _pickDate,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: EventFormScreen.brandOrange.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: EventFormScreen.brandOrange.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, color: EventFormScreen.brandOrange),
                            const SizedBox(width: 16),
                            Text(
                              '${_eventDate.month}/${_eventDate.day}/${_eventDate.year} at ${_eventDate.hour.toString().padLeft(2, '0')}:${_eventDate.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: EventFormScreen.brandOrange),
                            ),
                            const Spacer(),
                            const Icon(Icons.edit_calendar_rounded, color: EventFormScreen.brandOrange, size: 20),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                    
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: EventFormScreen.brandOrange,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(64),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(isEditing ? 'Save Changes' : 'Create Event', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          enabled: !_isLoading,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.black38, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: EventFormScreen.brandOrange, width: 2),
            ),
          ),
          validator: (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
        ),
      ],
    );
  }
}