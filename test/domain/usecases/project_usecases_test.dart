import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tasktime/domain/entities/project_entity.dart';
import 'package:tasktime/domain/repositories/project_repository.dart';
import 'package:tasktime/domain/usecases/project_usecases.dart';

class MockProjectRepository extends Mock implements ProjectRepository {}

void main() {
  late MockProjectRepository mockRepository;
  late GetAllProjectsUseCase getAllProjectsUseCase;
  late GetProjectByIdUseCase getByIdUseCase;
  late SaveProjectUseCase saveProjectUseCase;
  late DeleteLocalProjectUseCase deleteLocalUseCase;

  setUp(() {
    mockRepository = MockProjectRepository();
    getAllProjectsUseCase = GetAllProjectsUseCase(mockRepository);
    getByIdUseCase = GetProjectByIdUseCase(mockRepository);
    saveProjectUseCase = SaveProjectUseCase(mockRepository);
    deleteLocalUseCase = DeleteLocalProjectUseCase(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(const ProjectEntity(id: '', name: ''));
  });

  const testProject = ProjectEntity(
    id: 'project-1',
    name: 'Test Project',
    color: 'blue',
    isFavorite: true,
  );

  group('GetAllProjectsUseCase', () {
    test('should return list of projects', () async {
      when(() => mockRepository.getAllProjects())
          .thenAnswer((_) async => [testProject]);

      final result = await getAllProjectsUseCase();

      expect(result, [testProject]);
      verify(() => mockRepository.getAllProjects()).called(1);
    });

    test('should return empty list when no projects', () async {
      when(() => mockRepository.getAllProjects()).thenAnswer((_) async => []);

      final result = await getAllProjectsUseCase();

      expect(result, isEmpty);
    });
  });

  group('GetProjectByIdUseCase', () {
    test('should return project when found', () async {
      when(() => mockRepository.getProjectById('project-1'))
          .thenAnswer((_) async => testProject);

      final result = await getByIdUseCase('project-1');

      expect(result, testProject);
    });

    test('should return null when not found', () async {
      when(() => mockRepository.getProjectById('unknown'))
          .thenAnswer((_) async => null);

      final result = await getByIdUseCase('unknown');

      expect(result, isNull);
    });
  });

  group('SaveProjectUseCase', () {
    test('should save project to repository', () async {
      when(() => mockRepository.saveProject(any()))
          .thenAnswer((_) async => testProject);

      final result = await saveProjectUseCase(testProject);

      expect(result, testProject);
      verify(() => mockRepository.saveProject(any())).called(1);
    });
  });

  group('DeleteLocalProjectUseCase', () {
    test('should delete project from repository', () async {
      when(() => mockRepository.deleteProject('project-1'))
          .thenAnswer((_) async {});

      await deleteLocalUseCase('project-1');

      verify(() => mockRepository.deleteProject('project-1')).called(1);
    });
  });
}
