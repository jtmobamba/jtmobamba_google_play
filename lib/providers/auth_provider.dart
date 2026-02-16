import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';
import '../services/resend_service.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _supabaseService.currentUser != null;

  AuthProvider() {
    _init();
  }

  void _init() {
    _supabaseService.authStateChanges.listen((state) async {
      if (state.session?.user != null) {
        await _loadUserProfile(state.session!.user.id);
      } else {
        _user = null;
        notifyListeners();
      }
    });

    // Check current session
    if (_supabaseService.currentUser != null) {
      _loadUserProfile(_supabaseService.currentUser!.id);
    }
  }

  Future<void> _loadUserProfile(String userId) async {
    try {
      _user = await _supabaseService.getUserProfile(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabaseService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );

      if (response.user != null) {
        await _loadUserProfile(response.user!.id);

        // Send welcome email via Resend
        if (email.isNotEmpty) {
          await ResendService().sendWelcomeEmail(
            email: email,
            name: fullName ?? 'Valued Customer',
          );
        }

        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = 'Sign up failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } on AuthException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabaseService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _loadUserProfile(response.user!.id);
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = 'Sign in failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } on AuthException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _supabaseService.signOut();
      _user = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabaseService.resetPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _supabaseService.updateUserProfile(updatedUser);
      _user = updatedUser;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
