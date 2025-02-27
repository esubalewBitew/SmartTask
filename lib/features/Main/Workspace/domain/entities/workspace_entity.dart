import 'package:equatable/equatable.dart';

class WorkspaceEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final List<String> memberIds;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? activeUsers; // {userId: {taskId: timestamp}}
  final bool isArchived;

  const WorkspaceEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.memberIds,
    required this.createdAt,
    this.updatedAt,
    this.activeUsers,
    this.isArchived = false,
  });

  WorkspaceEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    List<String>? memberIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? activeUsers,
    bool? isArchived,
  }) {
    return WorkspaceEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      memberIds: memberIds ?? this.memberIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      activeUsers: activeUsers ?? this.activeUsers,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'memberIds': memberIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'activeUsers': activeUsers,
      'isArchived': isArchived,
    };
  }

  factory WorkspaceEntity.fromJson(Map<String, dynamic> json) {
    return WorkspaceEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      ownerId: json['ownerId'] as String,
      memberIds: List<String>.from(json['memberIds'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      activeUsers: json['activeUsers'] as Map<String, dynamic>?,
      isArchived: json['isArchived'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        ownerId,
        memberIds,
        createdAt,
        updatedAt,
        activeUsers,
        isArchived,
      ];

  bool get isOwner => ownerId == id;
  bool get isMember => memberIds.contains(id);
  int get memberCount => memberIds.length;
}
