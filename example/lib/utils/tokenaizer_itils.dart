import 'dart:io';
import 'package:path/path.dart' as path;

typedef Role = String;
typedef Message = Map<String, dynamic>;
typedef Dialog = List<Message>;

class Tokenizer {
  late Map<String, int> specialTokens;
  late int nWords;
  late int bosId;
  late int eosId;
  late int padId;
  late Set<int> stopTokens;
  final String pattern =
      r"(?i:'s|'t|'re|'ve|'m|'ll|'d)|[^\r\n\p{L}\p{N}]?\p{L}+|\p{N}{1,3}| ?[^\s\p{L}\p{N}]+[\r\n]*|\s*[\r\n]+|\s+(?!\S)|\s+";

  Tokenizer(String modelPath) {
    if (!File(modelPath).existsSync()) {
      throw Exception('Model file not found: $modelPath');
    }

    // Имитация загрузки рангов BPE
    final mergeableRanks = _loadTiktokenBPE(modelPath);
    final numBaseTokens = mergeableRanks.length;

    // Определение специальных токенов
    final specialTokenList = [
      "<|begin_of_text|>",
      "<|end_of_text|>",
      "<|reserved_special_token_0|>",
      "<|reserved_special_token_1|>",
      "<|reserved_special_token_2|>",
      "<|reserved_special_token_3|>",
      "<|start_header_id|>",
      "<|end_header_id|>",
      "<|reserved_special_token_4|>",
      "<|eot_id|>"
    ];

    specialTokens = {
      for (var i = 0; i < specialTokenList.length; i++)
        specialTokenList[i]: numBaseTokens + i
    };

    nWords = mergeableRanks.length;
    bosId = specialTokens["<|begin_of_text|>"]!;
    eosId = specialTokens["<|end_of_text|>"]!;
    padId = -1;
    stopTokens = {
      specialTokens["<|end_of_text|>"]!,
      specialTokens["<|eot_id|>"]!
    };
  }

  List<int> encode(String s, {bool bos = false, bool eos = false}) {
    final tokens = _tokenize(s);

    if (bos) {
      tokens.insert(0, bosId);
    }
    if (eos) {
      tokens.add(eosId);
    }

    return tokens;
  }

  String decode(List<int> tokens) {
    return tokens.map((e) => _decodeToken(e)).join();
  }

  List<int> _loadTiktokenBPE(String modelPath) {
    // Имитация загрузки модели BPE из файла
    return List.generate(50000, (index) => index);
  }

  List<int> _tokenize(String text) {
    // Имитация токенизации текста
    return text.codeUnits;
  }

  String _decodeToken(int token) {
    // Имитация декодирования токена
    return String.fromCharCode(token);
  }
}

class ChatFormat {
  final Tokenizer tokenizer;

  ChatFormat(this.tokenizer);

  List<int> encodeHeader(Message message) {
    final tokens = [tokenizer.specialTokens["<|start_header_id|>"]!];
    tokens.addAll(tokenizer.encode(message['role'] as String));
    tokens.add(tokenizer.specialTokens["<|end_header_id|>"]!);
    tokens.addAll(tokenizer.encode("\n\n"));
    return tokens;
  }

  List<int> encodeMessage(Message message) {
    final tokens = encodeHeader(message);
    tokens.addAll(tokenizer.encode(message['content'] as String));
    tokens.add(tokenizer.specialTokens["<|eot_id|>"]!);
    return tokens;
  }

  List<int> encodeDialogPrompt(Dialog dialog) {
    final tokens = [tokenizer.specialTokens["<|begin_of_text|>"]!];
    for (final message in dialog) {
      tokens.addAll(encodeMessage(message));
    }
    tokens.addAll(encodeHeader({"role": "assistant", "content": ""}));
    return tokens;
  }
}
