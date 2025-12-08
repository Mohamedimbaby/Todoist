import 'package:equatable/equatable.dart';

/// Project entity representing a Todoist project
class ProjectEntity extends Equatable {
  final String id;
  final String name;
  final String color;
  final int order;
  final bool isInboxProject;
  final bool isFavorite;
  final String? parentId;
  final String? url;

  const ProjectEntity({
    required this.id,
    required this.name,
    this.color = 'grey',
    this.order = 0,
    this.isInboxProject = false,
    this.isFavorite = false,
    this.parentId,
    this.url,
  });

  ProjectEntity copyWith({
    String? id,
    String? name,
    String? color,
    int? order,
    bool? isInboxProject,
    bool? isFavorite,
    String? parentId,
    String? url,
  }) {
    return ProjectEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      order: order ?? this.order,
      isInboxProject: isInboxProject ?? this.isInboxProject,
      isFavorite: isFavorite ?? this.isFavorite,
      parentId: parentId ?? this.parentId,
      url: url ?? this.url,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        color,
        order,
        isInboxProject,
        isFavorite,
        parentId,
        url,
      ];
}

