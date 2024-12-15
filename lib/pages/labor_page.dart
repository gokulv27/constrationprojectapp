import 'package:flutter/material.dart';
import '../models/labor.dart';
import '../api/labor_api.dart';
import 'add_labor_page.dart';
import '../widget/drawer_widget.dart';

class LaborPage extends StatefulWidget {
  const LaborPage({Key? key}) : super(key: key);

  @override
  _LaborPageState createState() => _LaborPageState();
}

class _LaborPageState extends State<LaborPage> {
  List<Labor> _labors = [];
  List<Labor> _filteredLabors = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializePage() async {
    setState(() => _isLoading = true);
    await _fetchLabors();
    setState(() => _isLoading = false);
  }

  Future<void> _fetchLabors() async {
    try {
      final laborList = await LaborApi.getLaborList();
      setState(() {
        _labors = laborList;
        _filteredLabors = laborList;
      });
    } catch (e) {
      print('Error fetching labors: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load labors')),
      );
    }
  }

  void _filterLabors(String query) {
    setState(() {
      _filteredLabors = _labors.where((labor) {
        return labor.name.toLowerCase().contains(query.toLowerCase()) ||
            labor.phoneNo.contains(query);
      }).toList();
    });
  }

  Future<void> _deleteLabor(Labor labor) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete ${labor.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await LaborApi.deleteLabor(labor.id);
      setState(() {
        _labors.remove(labor);
        _filteredLabors.remove(labor);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Labor deleted successfully')),
      );
    } catch (e) {
      print('Error deleting labor: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete labor: $e')),
      );
    }
  }

  Future<void> _editLabor(Labor labor) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AddLaborPage(labor: labor)),
    );
    if (result == true) {
      _fetchLabors(); // Refresh the list after editing
    }
  }

  void _addLabor() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddLaborPage()),
    );
    if (result == true) _fetchLabors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Labor Management', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
      ),
      drawer: const DrawerWidget(),
      body: Container(
        color: Colors.grey[900],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: _filterLabors,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(color: Colors.green),
              )
                  : _filteredLabors.isEmpty
                  ? const Center(
                child: Text(
                  'No labors found',
                  style: TextStyle(color: Colors.white),
                ),
              )
                  : ListView.builder(
                itemCount: _filteredLabors.length,
                itemBuilder: (context, index) {
                  final labor = _filteredLabors[index];
                  return Card(
                    color: Colors.grey[800],
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              labor.name,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                          ),
                          Text(
                            labor.skillName, // Use skillName here
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Phone: ${labor.phoneNo}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            'Daily Wages: ₹${labor.dailyWages.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.white),
                            onPressed: () => _editLabor(labor),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red),
                            onPressed: () => _deleteLabor(labor),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addLabor,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
