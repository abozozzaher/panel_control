import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../service/toasts.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';
import '../../provider/trader_provider.dart';
import '../../service/account_service.dart';
import '../clien/traderDropdownForInvoice.dart';

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

  bool _showTextField = false; // مربع النص مخفي في البداية
  String _selectedOperation = ''; // العملية المختارة (إدخال أو إخراج)
  TextEditingController controllerPlus = TextEditingController();
  TextEditingController controllerMinus = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final trader = Provider.of<TraderProvider>(context).trader;

    return Scaffold(
      appBar: AppBar(title: Text(S().add_account), centerTitle: true, actions: [
        IconButton(
            onPressed: () {
              context.go('/');
            },
            icon: const Icon(Icons.home))
      ]),
      body: Center(
        child: Column(
          children: [
            // بيانات التاجر منسدلة اختيار التاجر
            const TraderDropdownForInvoice(),
            const SizedBox(height: 20),
            // اختيار نوع العملية
            trader == null
                ? Center(child: Text(S().no_trader_selected))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DropdownButton<String>(
                        value: _selectedOperation.isEmpty
                            ? null
                            : _selectedOperation,
                        hint: Center(child: Text(S().select_operation_type)),
                        items: [
                          DropdownMenuItem(
                            value: 'Plus',
                            child: Center(child: Text(S().input)),
                          ),
                          DropdownMenuItem(
                            value: 'Minus',
                            child: Center(child: Text(S().output)),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedOperation = value!;
                            _showTextField = true;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      if (_showTextField) ...[
                        SizedBox(
                          width: 200,
                          child: TextField(
                            controller: _selectedOperation == 'Plus'
                                ? controllerPlus
                                : controllerMinus,
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: _selectedOperation == 'Plus'
                                    ? S().enter_value_plus
                                    : S().enter_value_minus),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ],
                  ),
            trader == null
                ? Center(child: Text(S().no_trader_selected))
                : ElevatedButton(
                    onPressed: () {
                      double? value = _selectedOperation == 'Plus'
                          ? double.tryParse('+${controllerPlus.text}') ?? 0.00
                          : double.tryParse('-${controllerMinus.text}') ?? 0.00;

                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                  S().this_value_will_be_added_to_the_customers_account,
                                  textAlign: TextAlign.center),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                      '${S().trader_name} : ${trader.fullNameArabic}'),
                                  Container(
                                    color: _selectedOperation == 'Plus'
                                        ? Colors.greenAccent
                                        : Colors.redAccent,
                                    child: Text('${S().account} : \$ $value'),
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
                                            backgroundColor: Colors.redAccent),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          S().cancel,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 5, width: 5),
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
                                          String invoiceCode = 'No invoice';
                                          String downloadUrlPdf = 'No url';
                                          print('4wwww4');
                                          accountService
                                              .saveValueToFirebase(
                                                  trader.codeIdClien,
                                                  value,
                                                  invoiceCode,
                                                  downloadUrlPdf)
                                              .then((_) {
                                            controllerMinus.clear();
                                            controllerPlus.clear();
                                            context.go('/');
                                            showToast(
                                                S().value_added_successfully);
                                            Navigator.of(context).pop();
                                          }).catchError((error) {
                                            showToast(
                                                '${S().an_error_occurred_while_adding} : $error');
                                            print('ss11 $error');
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
                    child: Text(S().save_value, textAlign: TextAlign.center),
                  ),
          ],
        ),
      ),
    );
  }
}
