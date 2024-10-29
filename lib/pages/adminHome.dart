import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../generated/l10n.dart';
import '../service/app_drawer.dart';
import 'account/accountPage.dart';
import 'account/tradersAccount.dart';
import 'clien/addClien.dart';
import 'inventory/Inventory.dart';
import 'invoice/newInvoice.dart';
import 'proformaInvoice/newProformaInvoice.dart';
import 'yarn/addNewYarn.dart';

class AdminHomePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final VoidCallback toggleLocale;

  const AdminHomePage(
      {super.key, required this.toggleTheme, required this.toggleLocale});
  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(S().application_management_page),
        centerTitle: true,
        leading: isMobile
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  context.go('/');
                },
              ),
      ),
      drawer: AppDrawer(
          toggleTheme: widget.toggleTheme, toggleLocale: widget.toggleLocale),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // زر إضافة عميل
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // الانتقال إلى صفحة ClientEntryPage
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ClienEntryPage(
                              toggleTheme: widget.toggleTheme,
                              toggleLocale: widget.toggleTheme),
                        ),
                      );
                      // هنا تضيف الكود الذي سيتم تنفيذه عند الضغط على الزر
                    },
                    child: Text(S().add_clien, textAlign: TextAlign.center),
                  ),
                ),

                const SizedBox(width: 6), // مساحة بين الأزرار
                // زر إدخال حساب
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // هنا تضيف الكود الذي سيتم تنفيذه عند الضغط على الزر
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AccountPages(
                              toggleTheme: widget.toggleTheme,
                              toggleLocale: widget.toggleTheme),
                        ),
                      );
                    },
                    child: Text(S().add_account, textAlign: TextAlign.center),
                  ),
                ),
                const SizedBox(width: 6), // مساحة بين الأزرار
                // زر إدخال الخيط
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // هنا تضيف الكود الذي سيتم تنفيذه عند الضغط على الزر
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AddYarn(
                              toggleTheme: widget.toggleTheme,
                              toggleLocale: widget.toggleTheme),
                        ),
                      );
                    },
                    child: Text(S().add_yarn, textAlign: TextAlign.center),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16), // مساحة بين الصفوف

            // زر إضافة فاتورة
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // هنا تضيف الكود الذي سيتم تنفيذه عند الضغط على الزر
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => InvoiceNewAdd(
                              toggleTheme: widget.toggleTheme,
                              toggleLocale: widget.toggleTheme),
                        ),
                      );
                    },
                    child: Text('${S().add} ${S().invoice}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16), // مساحة بين الصفوف

            // زر حساب مجموع المخزن
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // هنا تضيف الكود الذي سيتم تنفيذه عند الضغط على الزر
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => Inventory(
                              toggleTheme: widget.toggleTheme,
                              toggleLocale: widget.toggleTheme),
                        ),
                      );
                    },
                    child: Text(S().show_full_repository_content),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16), // مساحة بين الصفوف

            // زر اظهار حساب كل تاجر
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TradersAccount(
                              toggleTheme: widget.toggleTheme,
                              toggleLocale: widget.toggleTheme),
                        ),
                      );
                    },
                    child: Text(S().traders_accounts),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16), // مساحة بين الصفوف

            // زر عمل فاتورة اولية
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => NewProformaInvoiceAdd(
                              toggleTheme: widget.toggleTheme,
                              toggleLocale: widget.toggleTheme),
                        ),
                      );
                    },
                    child: Text(S().pro_invoice),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
