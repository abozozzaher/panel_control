import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';
import '../../provider/trader_provider.dart';
import '../../service/account_service.dart';
import '../invoice/TraderDropdown.dart';

class AccountPages extends StatefulWidget {
  final VoidCallback toggleTheme;
  final VoidCallback toggleLocale;
  const AccountPages(
      {super.key, required this.toggleTheme, required this.toggleLocale});

  @override
  State<AccountPages> createState() => _AccountPagesState();
}

class _AccountPagesState extends State<AccountPages> {
  final AccountService accountService = AccountService();

  bool _showTextField = true;
  String _buttonText = 'Plus';
  TextEditingController controllerPlus = TextEditingController();
  TextEditingController controllerMinus = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final trader = Provider.of<TraderProvider>(context).trader;

    return Scaffold(
      //// 454545
      appBar: AppBar(title: Text('Account Page'), centerTitle: true, actions: [
        IconButton(
            onPressed: () {
              context.go('/');
            },
            icon: Icon(Icons.home))
      ]),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // بيانات التاجر منسدلة اختيار التاجر
              TraderDropdown(),
              SizedBox(height: 20),
              // مندسلة الطلبات التي تم مسحها من قبل العامل
              trader == null
                  ? Center(child: Text(S().no_trader_selected))
                  : Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _showTextField = !_showTextField;
                                //// 454545
                                _buttonText == 'Plus' ? 'Minus' : 'Plus';
                              });
                            },
                            child: Text(_buttonText),
                          ),
                          SizedBox(height: 20),
                          _showTextField
                              ? SizedBox(
                                  width: 200,
                                  child: TextField(
                                    controller: controllerPlus,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      //// 454545
                                      labelText: 'Enter value Plus',
                                    ),
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                  ),
                                )
                              : SizedBox(
                                  width: 200,
                                  child: TextField(
                                    controller: controllerMinus,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      //// 454545
                                      labelText: 'Enter value Minus',
                                    ),
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                  ),
                                ),
                        ],
                      ),
                    ),
              SizedBox(height: 20),

              trader == null
                  ? Center(child: Text(S().no_trader_selected))
                  : ElevatedButton(
                      onPressed: () {
                        double value = _showTextField
                            ? double.tryParse('+${controllerPlus.text}') ?? 0.00
                            : double.tryParse('-${controllerMinus.text}') ??
                                0.00;

                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                //// 454545
                                title: Text(
                                    'هذه القيمة سيتم اضافة لحساب العميل',
                                    textAlign: TextAlign.center),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    //// 454545
                                    Text(
                                        '${'trader Name'} : ${trader.fullNameArabic}'),
                                    _showTextField
                                        ? Container(
                                            color: Colors.greenAccent,
                                            //// 454545
                                            child: Text(
                                                '${'account'} : \$ ${value}'),
                                          )
                                        : Container(
                                            color: Colors.redAccent,
                                            //// 454545
                                            child: Text(
                                                '${'account'} : \$ ${value}'),
                                          ),
                                  ],
                                ),
                                actions: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                              backgroundColor:
                                                  Colors.redAccent),
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Close dialog
                                          },
                                          child: Text(
                                            S().cancel,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 5, width: 5),
                                      Expanded(
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                              backgroundColor:
                                                  Colors.greenAccent),
                                          child: Text(S().confirm,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black)),
                                          onPressed: () {
                                            // إضافة البيانات إلى Firebase
                                            String invoiceCode =
                                                'No invoice'; //
                                            accountService
                                                .saveValueToFirebase(
                                                    trader.codeIdClien,
                                                    value,
                                                    invoiceCode)
                                                .then((_) {
                                              controllerMinus.clear();
                                              controllerPlus.clear();
                                              context.go('/');
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      content: Center(
                                                          //// 454545
                                                          child: Text(
                                                              'Value added successfully'))));
                                              Navigator.of(context).pop();
                                            }).catchError((error) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Center(
                                                        child: Text(
                                                            '${S().an_error_occurred_while_adding} : $error'))),
                                              );
                                              Navigator.of(context).pop();
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            });
                      },
                      //// 454545
                      child: Text('Save Value', textAlign: TextAlign.center),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
