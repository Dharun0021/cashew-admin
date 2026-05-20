class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type; // Push Notification, WhatsApp Placeholder UI, Broadcast Notification
  final String targetGroup;
  final String sentDate;
  final String status;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.targetGroup,
    required this.sentDate,
    required this.status,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      type: json['type'],
      targetGroup: json['targetGroup'],
      sentDate: json['sentDate'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'targetGroup': targetGroup,
      'sentDate': sentDate,
      'status': status,
    };
  }
}
