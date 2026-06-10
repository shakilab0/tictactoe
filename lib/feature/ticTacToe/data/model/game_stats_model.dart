import 'package:hive_ce/hive.dart';
import 'package:tictactoe/feature/ticTacToe/domain/entity/game_enums.dart';


class GameStatsModel extends HiveObject {
  int gamesPlayed;
  int wins;
  int losses;
  int ties;
  int abandoned;
  int totalPlaySeconds;

  GameStatsModel({
    this.gamesPlayed = 0,
    this.wins = 0,
    this.losses = 0,
    this.ties = 0,
    this.abandoned = 0,
    this.totalPlaySeconds = 0,
  });

  static const String boxName = 'game_stats';
  static const String legacyRecordKey = 'main';
  static const String onePlayerKey = 'one_player';
  static const String twoPlayerKey = 'two_player';

  static String keyForMode(GameMode mode) =>
      mode == GameMode.onePlayer ? onePlayerKey : twoPlayerKey;
}

class GameStatsAdapter extends TypeAdapter<GameStatsModel> {
  @override
  final int typeId = 0;

  @override
  GameStatsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameStatsModel(
      gamesPlayed: (fields[0] as num?)?.toInt() ?? 0,
      wins: (fields[1] as num?)?.toInt() ?? 0,
      losses: (fields[2] as num?)?.toInt() ?? 0,
      ties: (fields[3] as num?)?.toInt() ?? 0,
      abandoned: (fields[4] as num?)?.toInt() ?? 0,
      totalPlaySeconds: (fields[5] as num?)?.toInt() ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, GameStatsModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.gamesPlayed)
      ..writeByte(1)
      ..write(obj.wins)
      ..writeByte(2)
      ..write(obj.losses)
      ..writeByte(3)
      ..write(obj.ties)
      ..writeByte(4)
      ..write(obj.abandoned)
      ..writeByte(5)
      ..write(obj.totalPlaySeconds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is GameStatsAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}