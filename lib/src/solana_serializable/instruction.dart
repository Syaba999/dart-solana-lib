import 'package:solana/solana.dart';
import 'package:solana/src/solana_serializable/compact_array.dart';
import 'package:solana/src/solana_serializable/int.dart';
import 'package:solana/src/solana_serializable/solana_serializable.dart';
import 'package:solana/src/types/account_meta.dart';

class Instruction extends Serializable {
  Instruction._(
    this._programIdIndex,
    this._accountIndices,
    this._data,
  );

  factory Instruction.system({
    required List<AccountMeta> accounts,
    required CompactArray<int> data,
  }) =>
      Instruction._(
        accounts.indexWhere((meta) => meta.pubKey == solanaSystemProgramID),
        CompactArray.fromList(
          List<int>.generate(accounts.length, (index) => index),
        ),
        data,
      );

  final int _programIdIndex;
  final CompactArray<int> _accountIndices;
  final CompactArray<int> _data;

  @override
  List<int> serialize() {
    final Int programIdIndex = Int.from(_programIdIndex);
    return [
      ...programIdIndex.serialize(),
      ..._accountIndices.serialize(),
      ..._data.serialize(),
    ];
  }
}
