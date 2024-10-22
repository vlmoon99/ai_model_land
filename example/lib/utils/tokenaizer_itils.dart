import 'dart:convert';
import 'dart:io';
import 'package:ai_model_land_example/modules/providers/onnx/model_interaction_onnx_modules/llm/tokenaizer_mergeable_ranks/special_tokens.dart';
import 'package:path/path.dart' as path;
import 'package:tiktoken/tiktoken.dart';
import 'package:tiktoken/src/common/byte_array.dart';

typedef Role = String;
typedef Message = Map<String, dynamic>;
typedef Dialog = List<Message>;

class Tokenizer {
  late Map<String, int> specialTokens;
  late int nWords;
  late int bosId;
  late List<int> eosId;
  late int padId;
  late Set<int> stopTokens;
  final String pattern =
      r"(?i:'s|'t|'re|'ve|'m|'ll|'d)|[^\\r\\n\\p{L}\\p{N}]?\\p{L}+|\\p{N}{1,3}| ?[^\\s\\p{L}\\p{N}]+[\\r\\n]*|\\s*[\\r\\n]+|\\s+(?!\\S)|\\s+";

  Tokenizer() {
    final inputFile = File(
        '../modules/providers/onnx/model_interaction_onnx_modules/llm/tokenaizer_mergeable_ranks/merges.json');
    final inputContent = inputFile.readAsStringSync();

    Map<String, dynamic> jsonData = jsonDecode(inputContent);

    Map<String, int> resultMap =
        jsonData.map((key, value) => MapEntry(key, value as int));

    final encoding = Tiktoken(
      name: "llm",
      patStr: pattern,
      mergeableRanks: resultMap
          .map((k, v) => MapEntry(ByteArray.fromList(base64Decode(k)), v)),
      specialTokens: TockenazierHelp.specialTokens,
    );

    // Имитация загрузки рангов BPE
    final numBaseTokens = resultMap.length;

    // Определение специальных токенов

    specialTokens = {
      for (var i = 0; i < TockenazierHelp.specialTokens.length; i++)
        TockenazierHelp.specialTokens.keys.elementAt(i): numBaseTokens + i
    };

    nWords = numBaseTokens;
    bosId = 128000;
    eosId = [128001, 128008, 128009];
    padId = -1;
    stopTokens = {
      specialTokens["<|end_of_text|>"]!,
      specialTokens["<|eot_id|>"]!
    };
  }

  List<int> encode(String s, {bool bos = false, bool eos = false}) {
    final tokens = _tokenize(s);

    if (bos) {
      tokens.insert(0, this.bosId);
    }
    if (eos) {
      tokens.addAll(this.eosId);
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
