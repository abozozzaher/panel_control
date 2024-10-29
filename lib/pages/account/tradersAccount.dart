import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../data/dataBase.dart';
import '../../generated/l10n.dart';
import '../../model/clien.dart';
import '../../service/toasts.dart';
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

  ///9998
  Future<void> fetchClientsFromFirebase() async {
    if (kIsWeb) {
      try {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('cliens')
            .where('work', isEqualTo: true)
            .get();
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
        showToast(S().data_requested_from_firebase_successfully);
      } catch (e) {
        showToast('${S().error_fetching_clients} $e');
        print('${S().error_fetching_clients} $e');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      try {
        List<Map<String, dynamic>> existingClients =
            await databaseHelper.checkClientsInDatabaseTraders();
        print('sss asas $existingClients');

        if (existingClients.isNotEmpty) {
          showToast(S().get_data_from_phone_base);

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
          QuerySnapshot snapshot = await FirebaseFirestore.instance
              .collection('cliens')
              .where('work', isEqualTo: true)
              .get();
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
            databaseHelper.saveClientToDatabaseTraders(client);
          }

          setState(() {
            clients = clientsFromFirebase;
            isLoading = false;
          });
        }
        showToast(S().data_requested_from_firebase_successfully);
      } catch (e) {
        showToast('${S().error_fetching_clients} $e');
        print('${S().error_fetching_clients} $e');

        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S().customer_list)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : clients.isEmpty
              ? Center(child: Text(S().no_clients))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(color: Colors.amber, width: 300),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: clients.length,
                        itemBuilder: (context, index) {
                          clients.sort((a, b) =>
                              (clientDues[a.codeIdClien] ?? 0.0)
                                  .compareTo(clientDues[b.codeIdClien] ?? 0.0));

                          final client = clients[index];
                          final dues = clientDues[client.codeIdClien] ?? 0.0;
                          final allData =
                              clientAllData[client.codeIdClien] ?? [];

                          return ListTile(
                            title: Text(client.fullNameArabic,
                                textAlign: TextAlign.start),
                            subtitle: Text(
                                '${client.country},${client.state},${client.city}',
                                textAlign: TextAlign.start),
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
                              '${dues.toStringAsFixed(2)}\$',
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  color: dues > 0 ? Colors.green : Colors.red,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
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
