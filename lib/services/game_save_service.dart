import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/game_state.dart';

class GameSaveService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DocumentReference<Map<String, dynamic>> get _playerDocument {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Player belum login.');
    }

    return _firestore.collection('users').doc(user.uid);
  }

  // Simpan progres game ke Firestore.
  Future<void> save(GameState game) async {
    await _playerDocument.set(
      game.toMap(),
      SetOptions(merge: true),
    );
  }

  // Muat progres game dari Firestore.
  Future<bool> load(GameState game) async {
    final snapshot = await _playerDocument.get();

    if (!snapshot.exists || snapshot.data() == null) {
      return false;
    }

    game.loadFromMap(snapshot.data()!);

    return true;
  }
}
