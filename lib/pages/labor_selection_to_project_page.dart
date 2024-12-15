import 'package:flutter/material.dart';
import '../models/labor_skill.dart';
import '../models/labor_to_project.dart';
import '../api/labor_to_project_api.dart';
import '../models/labor.dart';
import '../api/labor_api.dart';

class LaborSelectionPage extends StatefulWidget {
  final int projectId;

  const LaborSelectionPage({Key? key, required this.projectId}) : super(key: key);

  @override
  _LaborSelectionPageState createState() => _LaborSelectionPageState();
}

class _LaborSelectionPageState extends State<LaborSelectionPage> {
  List<Labor> _laborList = [];
  List<LaborSkill> _skills = [];
  Set<int> _selectedLabors = {};
  Set<int> _selectedSkills = <int>{}; // Update 1: Changed Set declaration
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
      final laborList = await LaborApi.getLaborList();
      setState(() {
        _laborList = laborList;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching labor list: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchSkills() async {
    try {
      final skills = await LaborToProjectApi.getSkills();
      setState(() {
        _skills = skills;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching skills: $e')),
      );
    }
  }

  Future<void> _submitSelectedLabors() async {
    setState(() => _isLoading = true);
    try {
      for (int laborId in _selectedLabors) {
        await LaborToProjectApi.addLaborToProject(
          widget.projectId,
          laborId,
          DateTime.now().toIso8601String(),
          null,
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Laborers added to project successfully!')),
      );
      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding laborers to project: $e')),
      );
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

  Widget _buildLaborCard(Labor labor) {
    return Card(
      color: Colors.grey[800],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Checkbox(
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
                Expanded(
                  flex: 3,
                  child: Text(
                    labor.name.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8.0),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[600],
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  child: Text(
                    labor.skillName.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 15.0),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(9.0),
                  ),
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    'Wages: ₹${labor.dailyWages.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Filter by Skills',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _skills.length,
                      itemBuilder: (context, index) {
                        final skill = _skills[index];
                        return CheckboxListTile(
                          title: Text(skill.name, style: TextStyle(color: Colors.white)),
                          value: _selectedSkills.contains(skill.id),
                          onChanged: (bool? value) { // Update 2: Changed onChanged callback
                            setModalState(() {
                              setState(() {
                                if (value == true) {
                                  _selectedSkills.add(skill.id);
                                } else {
                                  _selectedSkills.remove(skill.id);
                                }
                              });
                            });
                          },
                          activeColor: Colors.green[600],
                          checkColor: Colors.white,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            setState(() {
                              _selectedSkills.clear();
                            });
                          });
                        },
                        child: Text('Clear All', style: TextStyle(color: Colors.grey[300])),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Apply', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Laborers', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_selectedSkills.isNotEmpty ? 50.0 : 0.0),
          child: _selectedSkills.isNotEmpty
              ? Container(
            color: Colors.grey[800],
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: _selectedSkills.map((skillId) {
                      final skill = _skills.firstWhere((s) => s.id == skillId);
                      return Chip(
                        label: Text(skill.name, style: TextStyle(color: Colors.grey[300])),
                        backgroundColor: Colors.grey[700],
                        deleteIconColor: Colors.grey[400],
                        onDeleted: () {
                          setState(() {
                            _selectedSkills.remove(skillId);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[400]),
                  onPressed: () {
                    setState(() {
                      _selectedSkills.clear();
                    });
                  },
                ),
              ],
            ),
          )
              : const SizedBox.shrink(),
        ),
      ),
      body: Container(
        color: Colors.grey[900],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
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
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      _showFilterOptions(context);
                    },
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    tooltip: 'Filter Options', // Optional: provides a tooltip when long-pressed
                  ),


                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredLaborList.isEmpty
                  ? Center(
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
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: _selectedLabors.isNotEmpty ? _submitSelectedLabors : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedLabors.isNotEmpty ? Colors.green : Colors.grey,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
          ),
          child: Text(
            'Add Selected Laborers',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

