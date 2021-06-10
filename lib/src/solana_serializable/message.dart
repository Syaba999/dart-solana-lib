import 'package:solana/solana.dart';
import 'package:solana/src/base58/base58.dart' as base58;
import 'package:solana/src/solana_serializable/address.dart';
import 'package:solana/src/solana_serializable/compact_array.dart';
import 'package:solana/src/solana_serializable/instruction.dart';
import 'package:solana/src/solana_serializable/int.dart';
import 'package:solana/src/solana_serializable/message_header.dart';
import 'package:solana/src/solana_serializable/solana_serializable.dart';
import 'package:solana/src/types/account_meta.dart';
import 'package:solana/src/types/blockhash.dart';

/// This is an implementation of the Solana message format.
class Message extends Serializable {
  Message._({
    required this.header,
    required this.accounts,
    required this.recentBlockhash,
    required this.instructions,
  });

  /// Creates a solana transfer message to send [lamports] SOL tokens from [source]
  /// to [destination]. The recent block hash must be queried and provided as
  /// [recentBlockhash] to this function.
  factory Message.transfer({
    required String source,
    required String destination,
    required int lamports,
    required Blockhash recentBlockhash,
  }) {
    final accounts = [
      AccountMeta.writeable(pubKey: source, isSigner: true),
      AccountMeta.writeable(pubKey: destination, isSigner: false),
      AccountMeta.readonly(pubKey: solanaSystemProgramID, isSigner: false)
    ];
    final data = CompactArray.fromList([
      ...Int.from(2, bitSize: 32),
      ...Int.from(lamports, bitSize: 64),
    ]);
    final instruction = Instruction.system(
      accounts: accounts,
      data: data,
    );

    return Message._(
      header: MessageHeader.fromAccounts(accounts),
      accounts: CompactArray.fromList([
        for (AccountMeta account in accounts) Address.from(account.pubKey),
      ]),
      recentBlockhash: recentBlockhash.blockhash,
      instructions: CompactArray.fromList([instruction]),
    );
  }

  final MessageHeader header;
  final CompactArray<Address> accounts;
  final String recentBlockhash;
  final CompactArray<Instruction> instructions;

  @override
  List<int> serialize() => [
        ...header.serialize(),
        ...accounts.serialize(),
        ...base58.decode(recentBlockhash),
        ...instructions.serialize(),
      ];
}
