import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/dataBase.dart';
import '../../generated/l10n.dart';
import '../../model/clien.dart';
import '../../provider/trader_provider.dart';
import '../../service/toasts.dart';

class TraderDropdownForInvoice extends StatefulWidget {
  const TraderDropdownForInvoice({super.key});

  @override
  State<TraderDropdownForInvoice> createState() =>
      _TraderDropdownForInvoiceState();
}

class _TraderDropdownForInvoiceState extends State<TraderDropdownForInvoice> {
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
    try {
      if (kIsWeb) {
        // إذا كان المستخدم على الويب

        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('cliens')
            .where('work', isEqualTo: true)
            .get();
        setState(() {
          clients = snapshot.docs.map((doc) {
            return ClienData.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();

          isLoading = false;
        });
      } else {
        // إذا كان المستخدم على الموبايل
        //    try {
        List<Map<String, dynamic>> existingClients =
            await databaseHelper.checkClientsInDatabaseTraders();

        if (existingClients.isNotEmpty) {
          // إذا كانت البيانات موجودة في قاعدة البيانات المحلية
          setState(() {
            clients = existingClients
                .map((client) => ClienData.fromMap(client))
                .toList();
            isLoading = false;
          });
          List<ClienData> clientsFromDb = existingClients.map((client) {
            return ClienData.fromMap(client);
          }).toList();
          setState(() {
            clients = clientsFromDb;
            isLoading = false;
          });
        } else {
          // إذا لم تكن البيانات موجودة في قاعدة البيانات المحلية، احضرها من Firebase
          QuerySnapshot snapshot = await FirebaseFirestore.instance
              .collection('cliens')
              .where('work', isEqualTo: true)
              .get();
          List<ClienData> clientsFromFirebase = snapshot.docs.map((doc) {
            return ClienData.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();
          // احفظ البيانات في قاعدة البيانات المحلية
          for (var client in clientsFromFirebase) {
            databaseHelper.saveClientToDatabaseTraders(client);
          }

          setState(() {
            clients = clientsFromFirebase;
            isLoading = false;
          });
        }
      }
      showToast(S().data_requested_from_firebase_successfully);
    } catch (e) {
      showToast('${S().error_fetching_clients}: $e');
      print('${S().error_fetching_clients}: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Locale locale = Localizations.localeOf(context);
    bool isRtl = locale.languageCode == 'ar';

    return Consumer<TraderProvider>(
      builder: (context, provider, child) {
        if (isLoading) {
          return const CircularProgressIndicator.adaptive();
        }

        return SizedBox(
          width: 300,
          child: DropdownButton<String>(
              hint: Center(child: Text(S().select_client)),
              isExpanded: true,
              value: _selectedCode,
              items: clients.map((client) {
                String displayName =
                    isRtl ? client.fullNameArabic : client.fullNameEnglish;
                return DropdownMenuItem<String>(
                  value: client.codeIdClien,
                  child: Center(child: Text(displayName)),
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
                  showToast(S().client_saved_successfully);
                }
              }),
        );
      },
    );
  }
}
