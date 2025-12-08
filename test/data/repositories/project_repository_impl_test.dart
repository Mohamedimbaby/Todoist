import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tasktime/data/models/project_model.dart';
import 'package:tasktime/data/repositories/project_repository_impl.dart';
import 'package:tasktime/domain/entities/project_entity.dart';

class MockBox extends Mock implements Box<ProjectModel> {}

void main() {
  late MockBox mockBox;
  late ProjectRepositoryImpl repository;

  setUp(() {
    mockBox = MockBox();
    repository = ProjectRepositoryImpl(projectsBox: mockBox);
  });

  setUpAll(() {
    registerFallbackValue(ProjectModel(id: '', name: ''));
  });

  final testModel = ProjectModel(
    id: 'project-1',
    name: 'Test Project',
    color: 'blue',
    isFavorite: true,
  );

  group('ProjectRepositoryImpl', () {
    test('getAllProjects returns list of entities', () async {
      when(() => mockBox.values).thenReturn([testModel]);

      final result = await repository.getAllProjects();

      expect(result.length, 1);
      expect(result.first.name, 'Test Project');
    });

    test('getProjectById returns project when found', () async {
      when(() => mockBox.get('project-1')).thenReturn(testModel);

      final result = await repository.getProjectById('project-1');

      expect(result, isNotNull);
      expect(result!.id, 'project-1');
    });

    test('getProjectById returns null when not found', () async {
      when(() => mockBox.get('unknown')).thenReturn(null);

      final result = await repository.getProjectById('unknown');

      expect(result, isNull);
    });

    test('saveProject saves to box', () async {
      when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

      const entity = ProjectEntity(
        id: 'project-1',
        name: 'New Project',
      );

      await repository.saveProject(entity);

      verify(() => mockBox.put('project-1', any())).called(1);
    });

    test('deleteProject removes from box', () async {
      when(() => mockBox.delete('project-1')).thenAnswer((_) async {});

      await repository.deleteProject('project-1');

      verify(() => mockBox.delete('project-1')).called(1);
    });
  });
}
