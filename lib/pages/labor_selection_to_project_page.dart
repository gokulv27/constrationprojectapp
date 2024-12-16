import 'package:flutter/material.dart';
import '../models/labor.dart';
import '../models/labor_skill.dart';
import '../api/labor_api.dart';
import '../api/labor_to_project_api.dart';
import 'package:intl/intl.dart';
import '../models/labor_to_project.dart';
import '../api/labor_to_project_api.dart';

class LaborSelectionPage extends StatefulWidget {
  final int projectId;

  const LaborSelectionPage({Key? key, required this.projectId}) : super(key: key);

  @override
  _LaborSelectionPageState createState() => _LaborSelectionPageState();
}

class _LaborSelectionPageState extends State<LaborSelectionPage> {
  final LaborToProjectApi _laborToProjectApi = LaborToProjectApi();

  List<Labor> _laborList = [];
  List<LaborSkill> _skills = [];
  Set<int> _selectedLabors = {};
  Set<int> _selectedSkills = {};
  bool _isLoading = false;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchLaborList();
    _fetchSkills();
  }

  Future<void> _fetchLaborList() async {
    setState(() => _isLoading = true);
    try {
      final laborList = await LaborApi.getLaborList(); // Accessed statically
      setState(() => _laborList = laborList);
    } catch (e) {
      _showError('Error fetching labor list: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchSkills() async {
    try {
      final skills = await _laborToProjectApi.getSkills();
      setState(() => _skills = skills);
    } catch (e) {
      // _showError('Error fetching skills: $e');
    }
  }

  Future<void> _submitSelectedLabors() async {
    if (_selectedLabors.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      // Fetch existing labor assignments for the project
      final List<LaborToProject> existingAssignments =
      await _laborToProjectApi.getLaborForProject(widget.projectId);

      // Extract the labor IDs from the existing assignments
      final existingLaborIds = existingAssignments.map((e) => e.labor).toSet();

      // Format the current date to "YYYY-MM-DD"
      final String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Iterate through selected labors and add them if they are not already assigned
      for (int laborId in _selectedLabors) {
        if (existingLaborIds.contains(laborId)) {
          // Skip adding if the labor is already assigned
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Labor ID $laborId is already in this project.')),
          );
          continue;
        }

        // Construct the payload
        final payload = {
          "labor": laborId,
          "project": widget.projectId,
          "start_date": currentDate,
          "end_date": null, // Adjust this if an end_date is available
        };

        // Send the payload via API
        await _laborToProjectApi.addLaborToProject(payload);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Laborers added to project successfully!')),
      );
      Navigator.pop(context, true); // Navigate back on success
    } catch (e) {
      // Display error message
      print(e);
      _showError('Error adding laborers to project: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }





  List<Labor> get filteredLaborList {
    return _laborList.where((labor) {
      final matchesSearch = labor.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          labor.skillName.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesSkill = _selectedSkills.isEmpty || _selectedSkills.contains(labor.skillId);
      return matchesSearch && matchesSkill;
    }).toList();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Laborers', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: Colors.white, // Set the icon color to white
        ),
      ),

      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredLaborList.isEmpty
                ? const Center(
              child: Text(
                'No laborers available.',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            )
                : ListView.builder(
              itemCount: filteredLaborList.length,
              itemBuilder: (context, index) {
                return _buildLaborCard(filteredLaborList[index]);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildSubmitButton(),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by Name or Skill',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLaborCard(Labor labor) {
    return Card(
      color: Colors.grey[800],
      child: ListTile(
        title: Text(
          labor.name.toUpperCase(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Skill: ${labor.skillName}\nWages: ₹${labor.dailyWages.toStringAsFixed(2)}',
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Checkbox(
          value: _selectedLabors.contains(labor.id),
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                _selectedLabors.add(labor.id);
              } else {
                _selectedLabors.remove(labor.id);
              }
            });
          },
          activeColor: Colors.green,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: _selectedLabors.isNotEmpty ? _submitSelectedLabors : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedLabors.isNotEmpty ? Colors.green : Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
        ),
        child: const Text(
          'Add Selected Laborers',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
