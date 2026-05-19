// ignore_for_file: public_member_api_docs

class IncompletePlanInfo {
  const IncompletePlanInfo({
    required this.id,
    required this.routeId,
    required this.stageCount,
    required this.createdAt,
    this.name,
    this.updatedAt,
    this.isImported = false,
    this.uuid,
    this.planUuid,
  });

  final int id;
  final int routeId;
  final String? name;
  final int stageCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isImported;
  final String? uuid;
  final String? planUuid;
}
