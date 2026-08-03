import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:tahfez/modules/reader/domain/models/reader_model.dart';
import 'package:tahfez/modules/surah/domain/params/surah_play_params.dart';
import 'package:tahfez/modules/surah/domain/surah_repo.dart';

part 'play_screen_state.dart';

class PlayScreenCubit extends Cubit<PlayScreenState> {
  final SurahRepo _surahRepo;
  PlayScreenCubit(this._surahRepo) : super(PlayScreenInitialState());

  final SurahPlayParams playParams = SurahPlayParams(
    startSurahNumber: 1,
    endSurahNumber: 1,
    reader: ReaderModel.fake(),
    startAya: 1,
    endAya: 7,
  );

  Future<void> play() async {
    await _surahRepo.play(playParams);
  }
}
