import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../domain/entities/project_entity.dart';
import '../../../core/theme/app_colors.dart';

/// Card displaying a single project
class ProjectCard extends StatelessWidget {
  final ProjectEntity project;

  const ProjectCard({super.key, required this.project});

  Color get _projectColor {
    final colors = {
      'berry_red': Colors.red,
      'red': Colors.red,
      'orange': Colors.orange,
      'yellow': Colors.yellow,
      'olive_green': Colors.green,
      'lime_green': Colors.lightGreen,
      'green': Colors.green,
      'mint_green': Colors.teal,
      'teal': Colors.teal,
      'sky_blue': Colors.lightBlue,
      'light_blue': Colors.lightBlue,
      'blue': Colors.blue,
      'grape': Colors.purple,
      'violet': Colors.purple,
      'lavender': Colors.purpleAccent,
      'magenta': Colors.pink,
      'salmon': Colors.pinkAccent,
      'charcoal': Colors.grey,
      'grey': Colors.grey,
      'taupe': Colors.brown,
    };
    return colors[project.color] ?? AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openBoard(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 48,
                decoration: BoxDecoration(
                  color: _projectColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (project.isInboxProject)
                          const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(Icons.inbox, size: 18),
                          ),
                        Expanded(
                          child: Text(
                            project.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (project.isFavorite)
                          const Icon(
                            Icons.star,
                            size: 18,
                            color: Colors.amber,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  void _openBoard(BuildContext context) {
    context.push(
      AppRoutes.boardPath(project.id),
      extra: {RouteExtra.project: project},
    );
  }
}
