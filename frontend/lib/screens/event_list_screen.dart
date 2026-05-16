import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../data/event_repository.dart';
import '../data/api_service.dart';
import '../models/event.dart';
import 'event_details_screen.dart';
import 'event_form_screen.dart';
import 'login_screen.dart';

class EventListScreen extends StatefulWidget {
  final bool isAdmin;

  const EventListScreen({super.key, required this.isAdmin});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  late Future<List<Event>> _eventsFuture;
  Timer? _refreshTimer;

  static const Color brandOrange = Color(0xFFFF6B35);

  @override
  void initState() {
    super.initState();
    _eventsFuture = EventRepository.getEvents();
    _refreshTimer = Timer.periodic(const Duration(seconds: 20), (_) => _refreshEvents());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshEvents() async {
    if (!mounted) return;
    setState(() => _eventsFuture = EventRepository.getEvents());
  }

  void _openDetails(Event event) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EventDetailsScreen(event: event)),
    );
  }

  void _openForm([Event? event]) async {
    final changed = await Navigator.of(context).push<bool?>(
      MaterialPageRoute(builder: (_) => EventFormScreen(event: event)),
    );
    if (changed == true) {
      _refreshEvents();
    }
  }

  void _confirmDelete(Event event) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Delete event?', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Remove "${event.title}" permanently?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Keep it', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (shouldDelete == true) {
      try {
        await EventRepository.remove(event.id);
        _refreshEvents();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event deleted successfully')),
          );
        }
      } catch (e) { /* Error handling removed */ }
    }
  }

  void _logout() {
    ApiService.clearAuth();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Gradient & Blobs (Consistent with Login)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFE8E0), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: brandOrange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom Modern AppBar
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [brandOrange, Color(0xFFFF9C71)],
                            ).createShader(bounds),
                            child: const Text(
                              'EventFlow',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -1.0,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: brandOrange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              widget.isAdmin ? 'Admin Mode' : 'Explore Mode',
                              style: const TextStyle(
                                color: brandOrange,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout_rounded, color: Colors.black54),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Events to explore',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.black87),
                      ),
                      Text(
                        'Browse and stay engaged with activities.',
                        style: TextStyle(color: Colors.black45, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: FutureBuilder<List<Event>>(
                    future: _eventsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: brandOrange));
                      }
                      if (snapshot.hasError) {
                        return _buildErrorState(snapshot.error.toString());
                      }

                      return ValueListenableBuilder<List<Event>>(
                        valueListenable: EventRepository.eventsNotifier,
                        builder: (context, events, child) {
                          if (events.isEmpty) {
                            return _buildEmptyState();
                          }
                          return ListView.separated(
                            padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                            itemCount: events.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 20),
                            itemBuilder: (context, index) {
                              final event = events[index];
                              return _EventTile(
                                event: event,
                                isAdmin: widget.isAdmin,
                                onDelete: () => _confirmDelete(event),
                                onEdit: () => _openForm(event),
                                onView: () => _openDetails(event),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _openForm(),
              backgroundColor: brandOrange,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              label: const Text('Add Event', style: TextStyle(fontWeight: FontWeight.bold)),
              icon: const Icon(Icons.add_rounded),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('No events yet.', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text('Oops! $error', textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
            TextButton(onPressed: _refreshEvents, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final Event event;
  final bool isAdmin;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EventTile({
    required this.event,
    required this.isAdmin,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onView,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black87),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: Colors.black26),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _DetailChip(icon: Icons.calendar_month_rounded, text: '${event.date.month}/${event.date.day}/${event.date.year}'),
                        const SizedBox(width: 8),
                        _DetailChip(icon: Icons.location_on_rounded, text: event.location),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    event.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.black54, height: 1.4, fontSize: 14),
                  ),
                  if (isAdmin) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1),
                    ),
                    Row(
                      children: [
                        _ActionButton(label: 'Edit', icon: Icons.edit_rounded, color: Colors.blueAccent, onTap: onEdit),
                        const SizedBox(width: 16),
                        _ActionButton(label: 'Delete', icon: Icons.delete_outline_rounded, color: Colors.redAccent, onTap: onDelete),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.black45),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}