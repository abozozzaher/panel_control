import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/clien.dart';
import '../../provider/trader_provider.dart';

class TraderDropdown extends StatefulWidget {
  // final void Function(dynamic trader) onTraderSelected;

//  TraderDropdown({required this.onTraderSelected});

  @override
  State<TraderDropdown> createState() => _TraderDropdownState();
}

class _TraderDropdownState extends State<TraderDropdown> {
  List<ClienData> clients = [];
  bool isLoading = true;
  String? _selectedCode;
  @override
  void initState() {
    super.initState();
    fetchClientsFromFirebase();
  }

  Future<void> fetchClientsFromFirebase() async {
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
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TraderProvider>(
      builder: (context, provider, child) {
        if (isLoading) {
          return CircularProgressIndicator();
        }

        return DropdownButton<String>(
            hint: Text('Select Client'),
            isExpanded: true,
            value: _selectedCode,
            items: clients.map((client) {
              return DropdownMenuItem<String>(
                value: client.codeIdClien,
                child: Text(client.fullNameEnglish),
              );
            }).toList(),
            onChanged: (String? selectedCode) async {
              if (selectedCode != null) {
                setState(() {
                  _selectedCode = selectedCode; // Update the selected code
                });

                print('Selected Code: $selectedCode'); // للتحقق من الكود المحدد
                //    widget.onTraderSelected(selectedCode);

                final selectedClient = clients.firstWhere(
                  (client) => client.codeIdClien == selectedCode,
                  orElse: () => ClienData(
                    fullNameArabic: '',
                    fullNameEnglish: '',
                    address: '',
                    phoneNumber: '',
                    createdAt: DateTime.now(),
                    codeIdClien: '',
                  ),
                );

                if (selectedClient != null) {
                  print(
                      'Client found: ${selectedClient.fullNameEnglish}'); // التحقق من العثور على العميل

                  // حفظ بيانات العميل في Provider
                  provider.setTrader(selectedClient);
                  print(
                      'Provider data: ${provider.trader!.address} = ${provider.trader!.codeIdClien}= ${provider.trader!.fullNameArabic}= ${provider.trader!.fullNameEnglish}');
/*
يوجد خطا فيحفظ البيانات في قاعدة البيانات نعود اليها فيما بعد
4444444444
                  // حفظ بيانات العميل في SQLite
                  final dbHelper = DatabaseHelper();
                  await dbHelper.insertTraderCodeDetails(
                      selectedClient.codeIdClien,
                      selectedClient.fullNameEnglish);
                  final savedData = await dbHelper
                      .getTraderCodeDetails(selectedClient.codeIdClien);

                  if (savedData != null) {
                    print('SQLite data: ${savedData.toString()}');
                  } else {
                    print('No data found in SQLite');
                  }
*/
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Client saved successfully')),
                  );
                } else {
                  print('Client not found'); // في حالة عدم العثور على العميل
                }
              }
            });
      },
    );
  }
}
