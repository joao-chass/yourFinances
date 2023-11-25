import 'package:dio/dio.dart';

import '../model/cotacaoModel.dart';

class CotacaoRepository {
  var _dio = Dio();

  CotacaoRepository() {
    _dio = Dio();
    _dio.options.baseUrl = "https://economia.awesomeapi.com.br";
  }

  Future<CotacaoModel> obterCotacaoAtual() async {
    var result = await _dio.get("/last/EUR-BRL");
    return CotacaoModel.fromJson(result.data);
  }

  Future<CotacaoPorData> obterCotacaoPorData(String periodo) async {
    DateTime data = convertStringToDateTime(periodo);

    // Formatando a data de volta para uma string no formato YYYYMMDD
    String dataFormatada = formatDate(data);

    print(dataFormatada);

    var result = await _dio.get(
        "/EUR-BRL/1?start_date=${dataFormatada}&end_date=${dataFormatada}");
    return CotacaoPorData.fromJson(result.data[0]);
  }

  DateTime convertStringToDateTime(String dateString) {
    // Convertendo a string para a data
    List<String> components = dateString.split('-');
    int dia = int.parse(components[0]);
    int mes = int.parse(components[1]);
    int ano = int.parse(components[2]) + 2000;

    return DateTime(ano, mes, dia);
  }

  String formatDate(DateTime date) {
    // Formatando a data para o formato YYYYMMDD
    String ano = date.year.toString();
    String mes = date.month.toString().padLeft(2, '0');
    String dia = date.day.toString().padLeft(2, '0');

    return '$ano$mes$dia';
  }
}
