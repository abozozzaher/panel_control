import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../data/dataBase.dart';
import '../../model/clien.dart';
import '../../service/trader_service.dart';
import '../clien/clienPage.dart';

class TradersAccount extends StatefulWidget {
  const TradersAccount(
      {super.key,
      required VoidCallback toggleTheme,
      required VoidCallback toggleLocale});

  @override
  State<TradersAccount> createState() => _TradersAccountState();
}

class _TradersAccountState extends State<TradersAccount> {
  final TraderService traderService = TraderService();
  final DatabaseHelper databaseHelper = DatabaseHelper();

  List<ClienData> clients = [];
  bool isLoading = true;
  Map<String, double> clientDues = {};
  Map<String, dynamic> clientAllData = {};
  @override
  void initState() {
    super.initState();
    // traderService.
    fetchClientsFromFirebase();
  }

  Future<void> fetchClientsFromFirebase() async {
    if (kIsWeb) {
      try {
        QuerySnapshot snapshot =
            await FirebaseFirestore.instance.collection('cliens').get();
        List<ClienData> fetchedClients = snapshot.docs.map((doc) {
          return ClienData.fromMap(doc.data() as Map<String, dynamic>);
        }).toList();

        for (var client in fetchedClients) {
          double lastDues =
              await traderService.fetchLastDues(client.codeIdClien);
          clientDues[client.codeIdClien] = lastDues; // حفظ المستحقات الأخيرة

          List<Map<String, dynamic>> allDues =
              await traderService.fetchAllDues(client.codeIdClien);
          clientAllData[client.codeIdClien] = allDues; // حفظ جميع المستحقات
        }

        setState(() {
          clients = fetchedClients;
          isLoading = false;
        });
      } catch (e) {
        print('Error fetching clients: $e');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      try {
        List<Map<String, dynamic>> existingClients =
            await databaseHelper.checkClientsInDatabaseTraders();
        if (existingClients.isNotEmpty) {
          List<ClienData> clientsFromDb = existingClients.map((client) {
            return ClienData.fromMap(client);
          }).toList();

          for (var client in clientsFromDb) {
            double lastDues =
                await traderService.fetchLastDues(client.codeIdClien);
            clientDues[client.codeIdClien] = lastDues; // حفظ المستحقات الأخيرة

            List<Map<String, dynamic>> allDues =
                await traderService.fetchAllDues(client.codeIdClien);
            clientAllData[client.codeIdClien] = allDues; // حفظ جميع المستحقات
          }

          setState(() {
            clients = clientsFromDb;
            isLoading = false;
          });
        } else {
          QuerySnapshot snapshot =
              await FirebaseFirestore.instance.collection('cliens').get();
          List<ClienData> clientsFromFirebase = snapshot.docs.map((doc) {
            return ClienData.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();

          for (var client in clientsFromFirebase) {
            double lastDues =
                await traderService.fetchLastDues(client.codeIdClien);
            clientDues[client.codeIdClien] = lastDues; // حفظ المستحقات الأخيرة

            List<Map<String, dynamic>> allDues =
                await traderService.fetchAllDues(client.codeIdClien);
            clientAllData[client.codeIdClien] = allDues; // حفظ جميع المستحقات
          }

          for (var client in clientsFromFirebase) {
            await databaseHelper.saveClientToDatabaseTraders(client);
          }

          setState(() {
            clients = clientsFromFirebase;
            isLoading = false;
          });
        }
      } catch (e) {
        print('Error fetching clients: $e');
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /// 454545
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('قائمة العملاء')),
      body: isLoading
          ? Center(child: CircularProgressIndicator.adaptive())
          : clients.isEmpty
              ? Center(child: Text('لا يوجد عملاء'))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        color: Colors.amber,
                        //    height: 100,
                        // 454545
                        child: Text('هذا لتحويله الى بحث',
                            textAlign: TextAlign.center)),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: clients.length,
                        itemBuilder: (context, index) {
                          final client = clients[index];
                          final dues = clientDues[client.codeIdClien] ?? 0.0;
                          final allData =
                              clientAllData[client.codeIdClien] ?? [];

                          return ListTile(
                            title: Text(client.fullNameArabic,
                                textAlign: TextAlign.center),
                            subtitle: Text(
                                '${client.country},${client.state},${client.city}',
                                textAlign: TextAlign.center),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ClienPage(
                                    client: client,
                                    allData: allData,
                                    dues: dues,
                                  ),
                                ),
                              );
                            },
                            trailing: Text(
                              'Dues: ${dues.toStringAsFixed(2)}',
                              style: TextStyle(color: Colors.amber),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
