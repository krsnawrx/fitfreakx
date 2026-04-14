import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/models/user_model.dart';

final mockDatabaseProvider = Provider((ref) => MockDatabaseService());

class MockDatabaseService {
  UserModel? _currentUser;
  
  Future<void> saveUserBiometrics({required double height, required double weight, required double tdee, required String goal}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = UserModel(
      uid: 'mock_uid_123',
      name: 'Fit Freak',
      height: height,
      weight: weight,
      tdee: tdee,
      goal: goal,
    );
  }

  UserModel? get currentUser => _currentUser;
}
