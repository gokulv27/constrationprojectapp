import 'package:flutter/material.dart';

class PaymentBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const PaymentBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 50,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.data_saver_off_sharp),
            activeIcon: Icon(Icons.data_saver_on_sharp),
            label: 'Report',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on_outlined),
            activeIcon: Icon(Icons.monetization_on_sharp),
            label: 'Payment',
          ),
        ],
      ),
    );
  }
}

