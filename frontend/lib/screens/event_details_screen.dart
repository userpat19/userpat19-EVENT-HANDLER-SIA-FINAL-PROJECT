import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../models/event.dart';

class EventDetailsScreen extends StatelessWidget {
  final Event event;

  const EventDetailsScreen({super.key, required this.event});

  static const Color brandOrange = Color(0xFFFF6B35);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Using CustomScrollView for a nice parallax-ready feel
      body: Stack(
        children: [
          // 1. Decorative Background Elements
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: brandOrange.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Custom Navigation Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Event Details',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48), // Balancing spacer
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    children: [
                      // --- Event Hero Header ---
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [brandOrange, Color(0xFFFF9C71)],
                        ).createShader(bounds),
                        child: Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1.5,
                            height: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- Tactile Info Card ---
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _InfoRow(
                              icon: Icons.calendar_today_rounded,
                              label: 'When',
                              value: _formatDate(event.date),
                              color: brandOrange,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Divider(height: 1, color: Color(0xFFF0F0F0)),
                            ),
                            _InfoRow(
                              icon: Icons.place_rounded,
                              label: 'Where',
                              value: event.location,
                              color: const Color(0xFF4ACFAC),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Divider(height: 1, color: Color(0xFFF0F0F0)),
                            ),
                            _InfoRow(
                              icon: Icons.group_rounded,
                              label: 'Capacity',
                              value: '${event.capacity} spots available',
                              color: const Color(0xFF5D5FEF),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // --- Description Section ---
                      const Text(
                        'About this event',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        event.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Secondary "Back" Button for UX
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(60),
                          side: BorderSide(color: Colors.grey.shade200, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text(
                          'Back to Events',
                          style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    String time = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return '${months[date.month - 1]} ${date.day}, ${date.year} • $time';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black38,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}