import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../core/constants/app_constants.dart';
import '../core/services/mock_api_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<NotificationModel> get notifications => _notifications;

  Future<void> loadNotifications() async {
    if (_notifications.isNotEmpty) return;

    _isLoading = true;
    notifyListeners();

    await MockApiService.simulateNetworkCall();

    _notifications = AppConstants.mockNotifications
        .map((n) => NotificationModel.fromJson(n))
        .toList();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendNotification({
    required String title,
    required String body,
    required String type,
    required String targetGroup,
  }) async {
    _isLoading = true;
    notifyListeners();

    await MockApiService.simulateNetworkCall();

    final newNotification = NotificationModel(
      id: 'n${_notifications.length + 1}',
      title: title,
      body: body,
      type: type,
      targetGroup: targetGroup,
      sentDate: DateTime.now().toIso8601String(),
      status: type.contains('Template') ? 'Template Active' : 'Sent',
    );

    _notifications.insert(0, newNotification); // Show newest first
    _isLoading = false;
    notifyListeners();
  }
}
