import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../data/dataBase.dart';
import '../../model/clien.dart';
import '../../service/trader_service.dart';

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
  Map<String, double> clientDues = {}; // متغير لحفظ المستحقات
  @override
  void initState() {
    super.initState();
    // traderService.
    fetchClientsFromFirebase();
  }

/*
  Future<void> fetchClientsFromFirebase() async {
    if (kIsWeb) {
      // إذا كان المستخدم على الويب
      try {
        QuerySnapshot snapshot =
            await FirebaseFirestore.instance.collection('cliens').get();
        setState(() {
          clients = snapshot.docs.map((doc) {
            return ClienData.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();

          isLoading = false;
        });
      } catch (e) {
        print('Error fetching clients: $e');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      // إذا كان المستخدم على الموبايل
      try {
        List<Map<String, dynamic>> existingClients =
            await databaseHelper.checkClientsInDatabaseTraders();
        if (existingClients.isNotEmpty) {
          // إذا كانت البيانات موجودة في قاعدة البيانات المحلية
          //   setState(() {            clients = existingClients                .map((client) => ClienData.fromMap(client))                .toList();          isLoading = false; });
          List<ClienData> clientsFromDb = existingClients.map((client) {
            return ClienData.fromMap(client);
          }).toList();
          setState(() {
            clients = clientsFromDb;
            isLoading = false;
          });
        } else {
          // إذا لم تكن البيانات موجودة في قاعدة البيانات المحلية، احضرها من Firebase
          QuerySnapshot snapshot =
              await FirebaseFirestore.instance.collection('cliens').get();
          List<ClienData> clientsFromFirebase = snapshot.docs.map((doc) {
            return ClienData.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();

          // احفظ البيانات في قاعدة البيانات المحلية
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
*/

  Future<void> fetchClientsFromFirebase() async {
    if (kIsWeb) {
      try {
        QuerySnapshot snapshot =
            await FirebaseFirestore.instance.collection('cliens').get();
        List<ClienData> fetchedClients = snapshot.docs.map((doc) {
          return ClienData.fromMap(doc.data() as Map<String, dynamic>);
        }).toList();

        for (var client in fetchedClients) {
          double dues = await traderService.fetchLastDues(client.codeIdClien);
          clientDues[client.codeIdClien] = dues; // حفظ المستحقات
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
            double dues = await traderService.fetchLastDues(client.codeIdClien);
            clientDues[client.codeIdClien] = dues; // حفظ المستحقات
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
            double dues = await traderService.fetchLastDues(client.codeIdClien);
            clientDues[client.codeIdClien] = dues; // حفظ المستحقات
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('قائمة العملاء')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : clients.isEmpty
              ? Center(child: Text('لا يوجد عملاء'))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        color: Colors.amber,
                        //    height: 100,
                        child: Text('هذا لتحويله الى بحث',
                            textAlign: TextAlign.center)),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: clients.length,
                        itemBuilder: (context, index) {
                          final client = clients[index];
                          final dues = clientDues[client.codeIdClien] ?? 0.0;

                          return ListTile(
                            title: Text(client.fullNameArabic,
                                textAlign: TextAlign.center),
                            subtitle: Text(
                                '${client.country},${client.state},${client.city}',
                                textAlign: TextAlign.center),
                            onTap: () {},
                            trailing: Text(
                              'Dues: $dues',
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
