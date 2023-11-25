import 'package:flutter/material.dart';
import 'package:your_finances/model/cotacaoModel.dart';
import 'package:your_finances/repository/cotacao_repository.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class Deposit {
  final String date;
  final double amount;
  final double valorPago;

  Deposit({
    required this.date,
    required this.amount,
    required this.valorPago,
  });
}

class _HomePageState extends State<HomePage> {
  double amount = 0.0;
  double deposito = 0.0;
  double lucro = 0.0;
  double valorWise = 3716.76;
  double total = 0.0;
  double euro = 0.0;
  double mediaPaga = 0.0;
  double valorPagoEmTaa = 0.0;
  double taxaWiise = 0.0;
  double menorPago = 0.0;
  double maiorPago = 0.0;
  var _dadoCotacao = CotacaoModel();
  var _dadoCotacaoPorData = CotacaoPorData();
  bool carregando = false;
  CotacaoRepository cotacaoRepository = CotacaoRepository();

  @override
  void initState() {
    super.initState();
    bucarCotacao();
    somarDeposito();
    iniciarTime();
  }

  final List<Map<String, dynamic>> jsonData = [
    {"DATAS": "17-05-23", "DEPOSITOS": 2733.31, "EUROPAGO": 1.0},
    {"DATAS": "02-06-23", "DEPOSITOS": 2706.80, "EUROPAGO": 1.0},
    {"DATAS": "06-06-23", "DEPOSITOS": 2678.96, "EUROPAGO": 1.0},
    {"DATAS": "14-06-23", "DEPOSITOS": 3186.59, "EUROPAGO": 1.0},
    {"DATAS": "14-06-23", "DEPOSITOS": 26.82, "EUROPAGO": 1.0},
    {"DATAS": "26-07-23", "DEPOSITOS": 3204.41, "EUROPAGO": 1.0},
    {"DATAS": "18-09-23", "DEPOSITOS": 5286.98, "EUROPAGO": 1.0}
  ];

  void somarDeposito() {
    double soma = 0.0;
    for (var deposit in jsonData) {
      soma += deposit["DEPOSITOS"];
    }
    deposito = soma;
    total = deposito - lucro;

    setState(() {
      carregando = false;
    });
  }

  void recuperarTotalEuro() {
    setState(() {
      carregando = false;
    });

    double valorConvertido = 0.0;
    double valorPagoCotacao = 0.0;
    double obterTaxaIOF;
    double taxxaIOF = 0.0;

    for (var deposit in jsonData) {
      taxxaIOF = (deposit["DEPOSITOS"] * 1.1) / 100;
      var conversao = (deposit["DEPOSITOS"] - taxxaIOF) / deposit["EUROPAGO"];
      valorConvertido += conversao;
      taxxaIOF += taxxaIOF;
      valorPagoCotacao += deposit["EUROPAGO"];
    }

    lucro = valorWise * euro;

    taxaWiise = (amount - valorWise) * euro;

    valorPagoEmTaa = taxxaIOF;
    amount = valorConvertido;
    mediaPaga = valorPagoCotacao / jsonData.length;

    total = lucro - deposito;

    setState(() {
      carregando = false;
    });
  }

  void iniciarTime() {
    Timer.periodic(Duration(minutes: 5), (timer) {
      bucarCotacao();
    });
  }

  void bucarCotacao() async {
    setState(() {
      carregando = true;
    });

    _dadoCotacao = await cotacaoRepository.obterCotacaoAtual();
    var resultCotacao = _dadoCotacao.eURBRL?.ask;
    euro = double.parse(resultCotacao!);
    print(euro);

    setState(() {
      carregando = false;
    });
  }

  void buscarPorData() async {
    setState(() {
      carregando = true;
    });
    print('hi');
    for (var deposit in jsonData) {
      _dadoCotacaoPorData =
          await cotacaoRepository.obterCotacaoPorData(deposit["DATAS"]);
      var resultCotacao = _dadoCotacaoPorData.ask;
      var valorEuroData = double.parse(resultCotacao!);
      deposit["EUROPAGO"] = valorEuroData;
    }

    recuperarTotalEuro();
    recuperarMaiorEMenor();

    setState(() {
      carregando = false;
    });
    print(jsonData);
  }

  void recuperarMaiorEMenor() {
    double menorEuropago = jsonData
        .map<double>((e) => e["EUROPAGO"] as double)
        .reduce((value, element) => value < element ? value : element);

    double maiiorEuropago = jsonData
        .map<double>((e) => e["EUROPAGO"] as double)
        .reduce((value, element) => value > element ? value : element);

    menorPago = menorEuropago;
    maiorPago = maiiorEuropago;
  }

  String formatarData(dataString) {
    // Convertendo a string para DateTime

    DateTime data = DateFormat("dd-MM-yy").parse(dataString);

    // Formatando para o mês abreviado
    String mesAbreviado =
        "${DateFormat.d().format(data)}  ${DateFormat.MMM().format(data)}";

    return mesAbreviado;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.indigoAccent,
      //   child: const Icon(Icons.refresh),
      //   onPressed: () {
      //     buscarPorData();
      //   },
      // ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              height: 130.0,
              width: double.infinity,
              decoration: BoxDecoration(
                color: euro > mediaPaga ? Colors.indigoAccent : Colors.green,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(0),
                  bottomLeft: Radius.circular(
                      20), // Define como 0 se você não quiser arredondar
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: carregando
                  ? const Center(
                      child: CircularProgressIndicator(
                      color: Colors.white,
                    ))
                  : Wrap(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  euro > mediaPaga
                                      ? "Acima da media"
                                      : "Compra",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400),
                                ),
                                const Text(
                                  "Cotação Atual",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  '€${euro.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ]),
                        ),
                        // Row(),
                        SizedBox(
                          width: double.infinity,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Your balance',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '€${valorWise.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                ),
                              ]),
                        ),

                        // Center(
                        //   child: TextButton(
                        //     onPressed: () {
                        //       buscarPorData();
                        //     },
                        //     child: const Icon(
                        //       Icons.refresh,
                        //       size: 40,
                        //       color: Colors.white,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
            ),
            SizedBox(
              width: double.infinity,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Chip(
                      backgroundColor: Colors.green[50],
                      shadowColor: Colors.grey[50],
                      avatar: const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(
                          Icons.arrow_drop_down_rounded,
                          color: Colors.white,
                        ),
                      ),
                      label: Text(
                        '€${menorPago.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: Colors.green,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Chip(
                      backgroundColor: Colors.amber[50],
                      shadowColor: Colors.grey[50],
                      avatar: const CircleAvatar(
                        backgroundColor: Colors.amber,
                        child: Icon(
                          Icons.bolt,
                          color: Colors.white,
                        ),
                      ),
                      label: Text(
                        '€${mediaPaga.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Chip(
                      backgroundColor: Colors.red[50],
                      shadowColor: Colors.grey[50],
                      avatar: const CircleAvatar(
                        backgroundColor: Colors.red,
                        child: Icon(
                          Icons.arrow_drop_up_rounded,
                          color: Colors.white,
                        ),
                      ),
                      label: Text(
                        '€${maiorPago.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      color: Colors.grey[200],
                      elevation: 0,
                      child: SizedBox(
                        width: double.infinity,
                        height: 80,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.account_balance_wallet_outlined,
                                  size: 18,
                                  color: Colors.black,
                                ),
                                Text(
                                  "Carteira",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 19,
                                      fontWeight: FontWeight.w300),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Text(
                              'R\$ ${deposito.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      color: Colors.grey[200],
                      elevation: 0,
                      child: SizedBox(
                        width: double.infinity,
                        height: 80,
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.savings_outlined,
                                  size: 18,
                                  color: Colors.black,
                                ),
                                Text(
                                  "Lucro",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 19,
                                      fontWeight: FontWeight.w300),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Text(
                              'R\$${lucro.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      color: total > 0 ? Colors.green[50] : Colors.red[50],
                      elevation: 0,
                      child: SizedBox(
                        width: double.infinity,
                        height: 80,
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  total > 0
                                      ? Icons.arrow_drop_up_rounded
                                      : Icons.arrow_drop_down_rounded,
                                  size: 28,
                                  color: total > 0 ? Colors.green : Colors.red,
                                ),
                                Text(
                                  "Total",
                                  style: TextStyle(
                                      color:
                                          total > 0 ? Colors.green : Colors.red,
                                      fontSize: 19,
                                      fontWeight: FontWeight.w300),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              'R\$${total.toStringAsFixed(2)}',
                              style: TextStyle(
                                  color: total > 0 ? Colors.green : Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                "Investimero",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                '€${amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    color: Colors.black87, fontSize: 16),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                "Taxa IOF",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                "- R\$${valorPagoEmTaa.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                ),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                "Taxa WISE",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                "- R\$${taxaWiise.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                ),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                "Total Taxa",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "- R\$${(valorPagoEmTaa + taxaWiise).toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ))
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: jsonData.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // const Divider(
                        //   height: 0, // Altura da linha
                        //   color: Colors.grey, // Cor da linha
                        // ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      shape: CircleBorder(),
                                      elevation: 0.0,
                                      padding: const EdgeInsets.all(13.0),
                                      primary: Colors.grey[200], // Cor cinza
                                    ),
                                    child: const Icon(
                                      Icons.add_card_outlined,
                                      size: 15,
                                      color: Colors.black87,
                                    )),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Valor Adicionado",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        '+R\$${jsonData[index]["DEPOSITOS"].toStringAsFixed(2)}',
                                        style: const TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w300),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '€${jsonData[index]["EUROPAGO"].toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          color: Colors.indigoAccent,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      '${formatarData(jsonData[index]["DATAS"])}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w300),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
