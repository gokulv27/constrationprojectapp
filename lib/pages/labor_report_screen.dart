import 'package:flutter/material.dart';
import '../widget/report_labor_bottom_nav_bar.dart';
import '../models/labor_to_project.dart';
import '../api/labor_to_project_api.dart';

class LaborReportScreen extends StatefulWidget {
  final int projectId;

  const LaborReportScreen({Key? key, required this.projectId}) : super(key: key);

  @override
  State<LaborReportScreen> createState() => _LaborReportScreenState();
}

class _LaborReportScreenState extends State<LaborReportScreen> {
  int _currentIndex = 0;
  List<LaborToProject> _laborList = [];
  bool _isLoading = false;
  Map<int, bool> _selectedLabors = {};
  String _selectedWorkType = 'FULL';

  @override
  void initState() {
    super.initState();
    _fetchLaborList();
  }

  Future<void> _fetchLaborList() async {
    setState(() => _isLoading = true);
    try {
      final laborList = await LaborToProjectApi.getLaborForProject(widget.projectId);
      setState(() {
        _laborList = laborList;
        _selectedLabors = {for (var labor in laborList) labor.id: false};
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching labor list: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Method to handle the radio button selection
  void _onRadioOptionSelected(String value) {
    setState(() {
      _selectedWorkType = value; // Update the work type
    });
  }

  Widget _buildSelectedWidget() {
    // Display different widgets based on the selected work type
    if (_selectedWorkType == 'QuickReplace') {
      return const Center(child: Text('QuickReplace Widget'));
    } else if (_selectedWorkType == 'WorkSwap') {
      return const Center(child: Text('WorkSwap Widget'));
    } else if (_selectedWorkType == 'FillShift') {
      return const Center(child: Text('FillShift Widget'));
    }
    return const Center(child: Text('Please select a work type'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Labor Report',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              _onRadioOptionSelected(value);
            },
            icon: const Icon(Icons.list, color: Colors.white),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'QuickReplace',
                child: ListTile(
                  leading: Radio(value: 'QuickReplace', groupValue: null, onChanged: null),
                  title: Text('QuickReplace'),
                ),
              ),
              const PopupMenuItem(
                value: 'WorkSwap',
                child: ListTile(
                  leading: Radio(value: 'WorkSwap', groupValue: null, onChanged: null),
                  title: Text('WorkSwap'),
                ),
              ),
              const PopupMenuItem(
                value: 'FillShift',
                child: ListTile(
                  leading: Radio(value: 'FillShift', groupValue: null, onChanged: null),
                  title: Text('FillShift'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: _laborList.length,
              itemBuilder: (context, index) {
                return _buildLaborItem(_laborList[index]);
              },
            ),
          ),
          // Display the selected widget
          _buildSelectedWidget(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextButton(
              onPressed: _onSubmit,
              style: TextButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 98, vertical: 12),
              ),
              child: const Text(
                'Submit',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: PaymentBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }

  void _onSubmit() {
    print('Submit button pressed');
  }

  // The labor item widget
  Widget _buildLaborItem(LaborToProject labor) {
    return Card(
      color: Colors.grey[800],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Checkbox(
                  value: _selectedLabors[labor.id] ?? false,
                  onChanged: (bool? value) {
                    setState(() {
                      _selectedLabors[labor.id] = value ?? false;
                    });
                  },
                  activeColor: Colors.green,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        labor.laborName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        labor.skill,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(72, 15),
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
                      ),
                      child: const Text(
                        'Full Day',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        minimumSize: const Size(72, 15),
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
                      ),
                      child: const Text(
                        'Half Day',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(72, 15),
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
                      ),
                      child: const Text(
                        'Overtime',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
