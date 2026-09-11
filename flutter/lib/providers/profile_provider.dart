import 'dart:convert';

import 'package:alpha_app/models/profile_completion_model.dart';
import 'package:alpha_app/models/profile_model.dart';
import 'package:alpha_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider();

  ProfileModel? _profile;
  ProfileModel? get profile => _profile;

  ProfileCompletionModel? _profileCompletion;
  ProfileCompletionModel? get profileCompletion => _profileCompletion;

  String _financialLevel = 'Intermediate';
  String get financialLevel => _financialLevel;

  String _financialTier = 'low';
  String get financialTier => _financialTier;

  int _activeGoalsCount = 0;
  int get activeGoalsCount => _activeGoalsCount;

  int _confirmedCycleExpensesCount = 0;
  int get confirmedCycleExpensesCount => _confirmedCycleExpensesCount;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _errorCode;
  String? get errorCode => _errorCode;

  bool get hasProfile => _profile != null;

  String get displayName {
    final value = _profile?.name.trim() ?? '';
    return value.isEmpty ? 'Not available' : value;
  }

  String get firstName {
    final name = displayName.trim();
    if (name.isEmpty || name == 'Not available') {
      return '';
    }
    return name.split(RegExp(r'\s+')).first;
  }

  DateTime? get birthDate => _profile?.birthDate;

  bool get isBirthdayToday {
    final date = birthDate;
    if (date == null) {
      return false;
    }

    final now = DateTime.now();
    return date.month == now.month && date.day == now.day;
  }

  String get email {
    return (_profile?.email ?? '').isEmpty ? 'Not available' : _profile!.email;
  }

  String? get photoUrl => _profile?.photoUrl;

  Future<void> loadProfileSummary() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _errorCode = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/users/profile/summary');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body);
        final data = body['data'];
        final user = data['user'] ?? {};
        final financial = data['financialProfile'] ?? {};
        final stats = data['statistics'] ?? {};

        _profile = ProfileModel(
          id: user['id']?.toString(),
          name: user['fullName']?.toString() ?? '',
          email: user['email']?.toString() ?? '',
          birthDate: user['birthDate'] != null
              ? DateTime.tryParse(user['birthDate'].toString())
              : null,
          joinedAt: user['memberSince'] != null
              ? DateTime.tryParse(user['memberSince'].toString())
              : null,
          photoUrl: user['avatarUrl'],
        );

        _financialLevel = financial['level']?.toString() ?? 'Intermediate';
        _financialTier = financial['tier']?.toString() ?? 'low';
        _activeGoalsCount = stats['activeGoals'] ?? 0;
        _confirmedCycleExpensesCount = stats['confirmedCycleExpenses'] ?? 0;

        if (data['profileCompletion'] != null) {
          _profileCompletion =
              ProfileCompletionModel.fromJson(data['profileCompletion']);
        }

        _errorMessage = null;
        _errorCode = null;
      } else if (response.statusCode == 403) {
        try {
          final body = jsonDecode(response.body);
          _errorCode = body['code'];
          _errorMessage = body['message'] ??
              'Account not verified. Please verify your email.';
        } catch (_) {
          _errorCode = 'ACCOUNT_NOT_VERIFIED';
          _errorMessage =
              'Account not verified. Please verify your email.';
        }
      } else if (response.statusCode == 401) {
        _errorCode = 'UNAUTHORIZED';
        _errorMessage = 'Your session has expired. Please log in again.';
      } else {
        _errorCode = 'LOAD_FAILED';
        _errorMessage =
            'Failed to load profile summary (${response.statusCode})';
      }
    } catch (e) {
      _errorCode = 'NETWORK_ERROR';
      _errorMessage = 'Error loading profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshProfileSummary() async {
    await loadProfileSummary();
  }

  Future<bool> loadFullProfile() async {
    if (_isLoading) {
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _errorCode = null;
    notifyListeners();

    bool success = false;

    try {
      final response = await ApiService.get('/users/profile');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body);
        final data = body['data'];

        _profile = ProfileModel(
          id: data['id']?.toString(),
          name: data['fullName']?.toString() ?? '',
          email: data['email']?.toString() ?? '',
          phone: data['phoneNumber']?.toString(),
          birthDate: data['birthDate'] != null
              ? DateTime.tryParse(data['birthDate'].toString())
              : null,
          gender: data['gender']?.toString(),
        );

        _errorMessage = null;
        _errorCode = null;
        success = true;
      } else {
        try {
          final body = jsonDecode(response.body);
          _errorMessage =
              body['message']?.toString() ?? 'Failed to load full profile';
        } catch (_) {
          _errorMessage =
              'Failed to load full profile (${response.statusCode})';
        }
      }
    } catch (e) {
      _errorMessage = 'Error loading full profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return success;
  }

  Future<bool> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    String? gender,
    DateTime? birthDate,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Map<String, dynamic> updateData = {};

      if (name != null) updateData['fullName'] = name;
      if (email != null) updateData['email'] = email;
      if (phone != null) updateData['phone'] = phone;
      if (gender != null) updateData['gender'] = gender;
      if (birthDate != null) {
        updateData['birthDate'] =
            birthDate.toIso8601String().split('T').first;
      }

      final response =
          await ApiService.patch('/users/profile', body: updateData);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await loadFullProfile();
        loadProfileSummary();
        _isSaving = false;
        notifyListeners();
        return true;
      } else {
        final body = jsonDecode(response.body);
        _errorMessage = body['message'] ?? 'Failed to update profile';
      }
    } catch (e) {
      _errorMessage = 'Error updating profile: $e';
    }

    _isSaving = false;
    notifyListeners();
    return false;
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.post('/auth/change-password', body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      });

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _isSaving = false;
        notifyListeners();
        return true;
      } else {
        final body = jsonDecode(response.body);
        _errorMessage = body['message'] ?? 'Failed to change password';
      }
    } catch (_) {
      _errorMessage = 'Network error during password change';
    }

    _isSaving = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    try {
      await ApiService.post('/auth/logout', body: {});
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');

    _profile = null;
    _activeGoalsCount = 0;
    _confirmedCycleExpensesCount = 0;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
