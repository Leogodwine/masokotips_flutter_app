import 'package:flutter/material.dart';
import 'buying_requests_tab.dart';
import '../chat/inbox_screen.dart';
import '../profile/profile_screen.dart';
import '../../l10n/app_localizations.dart';

class BuyerDashboardScreen extends StatefulWidget {
  const BuyerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<BuyerDashboardScreen> createState() => _BuyerDashboardScreenState();
}

class _BuyerDashboardScreenState extends State<BuyerDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const BuyingRequestsTab(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey[600],
          backgroundColor: Colors.white,
          elevation: 8,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InboxScreen()),
              ).then((_) {
                setState(() {
                  _selectedIndex = 0;
                });
              });
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              ).then((_) {
                setState(() {
                  _selectedIndex = 0;
                });
              });
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.campaign),
              label: AppLocalizations.of(context)!.myRequests,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.chat),
              label: AppLocalizations.of(context)!.messages,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: AppLocalizations.of(context)!.profile,
            ),
          ],
        ),
      ),
    );
  }
}
