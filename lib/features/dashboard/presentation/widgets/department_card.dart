import 'package:flutter/material.dart';

class DepartmentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? description;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;
  final bool featured;
  final String available; // 'online', 'offline', or 'both'

  const DepartmentCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.description,
    required this.icon,
    required this.gradient,
    required this.onTap,
    this.featured = false,
    this.available = 'both',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: featured
            ? const BorderSide(color: Colors.blue, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon Container
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 26,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Title
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Subtitle
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Available Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: available == 'online'
                          ? Colors.green.shade100
                          : available == 'offline'
                              ? Colors.grey.shade200
                              : Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      available == 'online'
                          ? '비대면'
                          : available == 'offline'
                              ? '대면'
                              : '대면/비대면',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        color: available == 'online'
                            ? Colors.green.shade800
                            : available == 'offline'
                                ? Colors.grey.shade800
                                : Colors.blue.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Featured Badge
            if (featured)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF10B981)],
                    ),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '추천',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
