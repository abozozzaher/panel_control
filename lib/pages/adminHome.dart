import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../generated/l10n.dart';
import '../service/app_drawer.dart';
import 'clien/addClien.dart';
import 'inventory/Inventory.dart';
import 'invoice/newInvoice.dart';
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
        title: Text('صفحة ادارة التطبيق'),
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
                      print('تم الضغط على إضافة عميل');
                    },
                    child: Text('إضافة عميل'),
                  ),
                ),

                SizedBox(width: 16), // مساحة بين الأزرار
                // زر إدخال الخيط
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // هنا تضيف الكود الذي سيتم تنفيذه عند الضغط على الزر
                      print('تم الضغط على إدخال الخيط');
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AddYarn(
                              toggleTheme: widget.toggleTheme,
                              toggleLocale: widget.toggleTheme),
                        ),
                      );
                    },
                    child: Text('إدخال الخيط'),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16), // مساحة بين الصفوف

            // زر إضافة فاتورة
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // هنا تضيف الكود الذي سيتم تنفيذه عند الضغط على الزر
                      print('تم الضغط على إضافة فاتورة');
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => InvoiceNewAdd(
                              toggleTheme: widget.toggleTheme,
                              toggleLocale: widget.toggleTheme),
                        ),
                      );
                    },
                    child: Text('إضافة فاتورة'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16), // مساحة بين الصفوف

            // زر حساب مجموع المخزن
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // هنا تضيف الكود الذي سيتم تنفيذه عند الضغط على الزر
                      print('تم الضغط على زر حساب مجموع المخزن');
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => Inventory(
                              toggleTheme: widget.toggleTheme,
                              toggleLocale: widget.toggleTheme),
                        ),
                      );
                    },
                    child: Text('اظهار محتوى المستودع كامل'),
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
