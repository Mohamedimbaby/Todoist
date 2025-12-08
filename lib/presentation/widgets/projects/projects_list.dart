import 'package:flutter/material.dart';
import '../../../domain/entities/project_entity.dart';
import 'project_card.dart';

/// List of projects
class ProjectsList extends StatelessWidget {
  final List<ProjectEntity> projects;

  const ProjectsList({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No projects yet'),
            SizedBox(height: 8),
            Text(
              'Tap + to create your first project',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: projects.length,
      itemBuilder: (context, index) => ProjectCard(project: projects[index]),
    );
  }
}

