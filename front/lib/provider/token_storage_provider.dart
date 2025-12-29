import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/data_source/local/wazzup_token_storage.dart';

final tokenStorageProvider = Provider((ref)=>WazzupTokenStorage());
