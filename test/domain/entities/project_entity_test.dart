import 'package:flutter_test/flutter_test.dart';
import 'package:tasktime/domain/entities/project_entity.dart';

void main() {
  group('ProjectEntity', () {
    const project = ProjectEntity(
      id: 'project-1',
      name: 'Test Project',
      color: 'blue',
      isFavorite: true,
      isInboxProject: false,
    );

    test('should create ProjectEntity with all properties', () {
      expect(project.id, 'project-1');
      expect(project.name, 'Test Project');
      expect(project.color, 'blue');
      expect(project.isFavorite, true);
      expect(project.isInboxProject, false);
    });

    test('copyWith should create new instance with updated values', () {
      final updated = project.copyWith(
        name: 'Updated Project',
        isFavorite: false,
      );

      expect(updated.id, 'project-1');
      expect(updated.name, 'Updated Project');
      expect(updated.isFavorite, false);
      expect(updated.color, 'blue');
    });

    test('equality check works correctly', () {
      const project2 = ProjectEntity(
        id: 'project-1',
        name: 'Test Project',
        color: 'blue',
        isFavorite: true,
        isInboxProject: false,
      );

      expect(project, equals(project2));
    });

    test('different projects are not equal', () {
      const project2 = ProjectEntity(id: 'project-2', name: 'Other');
      expect(project, isNot(equals(project2)));
    });

    test('props returns correct values', () {
      expect(project.props.contains('project-1'), true);
      expect(project.props.contains('Test Project'), true);
    });

    test('default values are applied', () {
      const minimalProject = ProjectEntity(id: 'p1', name: 'Min');

      expect(minimalProject.isFavorite, false);
      expect(minimalProject.isInboxProject, false);
    });
  });
}

