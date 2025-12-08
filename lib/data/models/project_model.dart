import 'package:hive/hive.dart';
import '../../domain/entities/project_entity.dart';

part 'project_model.g.dart';

@HiveType(typeId: 4)
class ProjectModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String color;

  @HiveField(3)
  final int order;

  @HiveField(4)
  final bool isInboxProject;

  @HiveField(5)
  final bool isFavorite;

  @HiveField(6)
  final String? parentId;

  @HiveField(7)
  final String? url;

  ProjectModel({
    required this.id,
    required this.name,
    this.color = 'grey',
    this.order = 0,
    this.isInboxProject = false,
    this.isFavorite = false,
    this.parentId,
    this.url,
  });

  factory ProjectModel.fromEntity(ProjectEntity entity) {
    return ProjectModel(
      id: entity.id,
      name: entity.name,
      color: entity.color,
      order: entity.order,
      isInboxProject: entity.isInboxProject,
      isFavorite: entity.isFavorite,
      parentId: entity.parentId,
      url: entity.url,
    );
  }

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'].toString(),
      name: json['name'] as String,
      color: json['color'] as String? ?? 'grey',
      order: json['order'] as int? ?? 0,
      isInboxProject: json['is_inbox_project'] as bool? ?? false,
      isFavorite: json['is_favorite'] as bool? ?? false,
      parentId: json['parent_id']?.toString(),
      url: json['url'] as String?,
    );
  }

  ProjectEntity toEntity() {
    return ProjectEntity(
      id: id,
      name: name,
      color: color,
      order: order,
      isInboxProject: isInboxProject,
      isFavorite: isFavorite,
      parentId: parentId,
      url: url,
    );
  }
}

