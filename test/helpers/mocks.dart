import 'package:audioplayers/audioplayers.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:unicorn_crossing/loading/loading.dart';

class MockPreloadCubit extends MockCubit<PreloadState>
    implements PreloadCubit {}

class MockAudioCache extends Mock implements AudioCache {}
