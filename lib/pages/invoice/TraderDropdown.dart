import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/dataBase.dart';
import '../../generated/l10n.dart';
import '../../model/clien.dart';
import '../../provider/trader_provider.dart';

class TraderDropdown extends StatefulWidget {
  @override
  State<TraderDropdown> createState() => _TraderDropdownState();
}

class _TraderDropdownState extends State<TraderDropdown> {
  final DatabaseHelper databaseHelper = DatabaseHelper();

  List<ClienData> clients = [];
  bool isLoading = true;
  String? _selectedCode;
  @override
  void initState() {
    super.initState();
    fetchClientsFromFirebase();
    // استرجاع الكود المحدد من البروفايدر
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final traderProvider =
          Provider.of<TraderProvider>(context, listen: false);
      setState(() {
        _selectedCode = traderProvider.selectedCode;
      });
    });
  }

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

  @override
  Widget build(BuildContext context) {
    Locale locale = Localizations.localeOf(context);
    bool isRtl = locale.languageCode == 'ar';

    return Consumer<TraderProvider>(
      builder: (context, provider, child) {
        if (isLoading) {
          return CircularProgressIndicator.adaptive();
        }

        return Container(
          width: 200,
          child: DropdownButton<String>(
              hint: Center(child: Text(S().select_client)),
              isExpanded: true,
              value: _selectedCode,
              items: clients.map((client) {
                String displayName =
                    isRtl ? client.fullNameArabic : client.fullNameEnglish;

                return DropdownMenuItem<String>(
                  value: client.codeIdClien,
                  child: Text(displayName, textAlign: TextAlign.center),
                );
              }).toList(),
              onChanged: (String? selectedCode) async {
                if (selectedCode != null) {
                  setState(() {
                    _selectedCode = selectedCode; // Update the selected code
                  });
                  provider.setSelectedCode(selectedCode);

                  final selectedClient = clients.firstWhere(
                    (client) => client.codeIdClien == selectedCode,
                    orElse: () => ClienData(
                      fullNameArabic: '',
                      fullNameEnglish: '',
                      country: '',
                      state: '',
                      city: '',
                      addressArabic: '',
                      addressEnglish: '',
                      email: '',
                      phoneNumber: '',
                      createdAt: DateTime.now(),
                      codeIdClien: '',
                    ),
                  );
                  // حفظ بيانات العميل في Provider
                  provider.setTrader(selectedClient);

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Center(child: Text(S().client_saved_successfully))));
                }
              }),
        );
      },
    );
  }
}
