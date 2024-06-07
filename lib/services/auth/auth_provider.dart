import 'package:codecraft/services/auth/auth_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = Provider<Auth>((ref) => Auth(FirebaseAuth.instance));
