import 'package:flutter/material.dart';
import '../models/labor_skill.dart';
import '../models/labor_to_project.dart';
import '../api/labor_to_project_api.dart';
import '../widget/project_custom_bottom_navbar.dart';
import 'document_page.dart';
import 'package:http/http.dart' as http;

class LaborToProjectPage extends StatefulWidget {
  final int projectId;

  const LaborToProjectPage({Key? key, required this.projectId}) : super(key: key);

  @override
  _LaborToProjectPageState createState() => _LaborToProjectPageState();
}

class _LaborToProjectPageState extends State<LaborToProjectPage> {
  List<LaborToProject> _laborList = [];
  List<LaborSkill> _skills = [];
  bool _isLoading = false;
  //String? _selectedSkill;
  Set<String> _selectedSkills = {};
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  int _currentIndex = 2;

  // Set to track selected labor IDs
  final Set<int> _selectedLabors = {};

  @override
  void initState() {
    super.initState();
    _fetchLaborForProject();
    _fetchSkills();
  }

  Future<void> _fetchLaborForProject() async {
    setState(() => _isLoading = true);
    try {
      final laborList = await LaborToProjectApi.getLaborForProject(widget.projectId);
      setState(() {
        _laborList = laborList;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load labor: $e')),
      );
    } finally {
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
      print('$e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load skills: $e')),
      );
    }
  }

  List<LaborToProject> get filteredLaborList {
    final filteredBySkills = _selectedSkills.isEmpty
        ? _laborList
        : _laborList.where((labor) => _selectedSkills.contains(labor.skill)).toList();

    if (_searchQuery.isEmpty) return filteredBySkills;

    return filteredBySkills
        .where((labor) =>
    labor.laborName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        labor.skill.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Future<void> _removeLabor(int laborId) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:8000/project/api/projects/1/labor/remove/$laborId/'),
      );

      if (response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Labor removed successfully!')),
        );
        await _fetchLaborForProject();
      } else {
        throw Exception('Failed to remove labor: ${response.statusCode}');
      }
    } catch (e) {
      print('$e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing labor: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _bulkDeleteLabors() async {
    setState(() => _isLoading = true);
    try {
      for (var laborId in _selectedLabors) {
        await http.delete(
          Uri.parse('http://10.0.2.2:8000/project/api/projects/1/labor/remove/$laborId/'),
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected labors removed successfully!')),
      );
      _selectedLabors.clear();
      await _fetchLaborForProject();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing selected labors: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildLaborCard(LaborToProject labor) {
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
                // Checkbox with green color
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
                  activeColor: Colors.green, // Green checkbox color
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    labor.laborName.toUpperCase(),
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
                    labor.skill.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 15.0),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Delete button
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await _removeLabor(labor.id);
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(9.0),
                  ),
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    'Pending: ₹${labor.pendingAmount.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(9.0),
                  ),
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    'Start: ${labor.startDate}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(9.0),
                  ),
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    'Wages: ₹${labor.wagesPerDay.toStringAsFixed(2)}',
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

  void _onNavTap(int index) {
    if (index != _currentIndex) {
      setState(() => _currentIndex = index);

      if (index == 0) {
        Navigator.pop(context);
      } else if (index == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DocumentPage(projectId: widget.projectId),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Labor in this Project',
          style: TextStyle(color: Colors.white),
        ),
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
                    children: _selectedSkills.map((skill) {
                      return Chip(
                        label: Text(skill, style: TextStyle(color: Colors.grey[300])),
                        backgroundColor: Colors.grey[700],
                        deleteIconColor: Colors.grey[400],
                        onDeleted: () {
                          setState(() {
                            _selectedSkills.remove(skill);
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
        actions: [
          _isLoading
              ? Padding(
            padding: const EdgeInsets.all(10.0),
            child: CircularProgressIndicator(color: Colors.white),
          )
              : PopupMenuButton<String>(
            icon: const Icon(Icons.list, color: Colors.white),
            onSelected: (String newValue) {
              setState(() {
                if (newValue == 'All Skills') {
                  _selectedSkills.clear();
                } else {
                  if (_selectedSkills.contains(newValue)) {
                    _selectedSkills.remove(newValue);
                  } else {
                    _selectedSkills.add(newValue);
                  }
                }
              });
            },
            color: Colors.grey[800],
            itemBuilder: (BuildContext context) {
              List<PopupMenuEntry<String>> menuItems = [
                PopupMenuItem<String>(
                  value: 'All Skills',
                  child: Row(
                    children: [
                      Checkbox(
                        value: _selectedSkills.isEmpty,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value!) {
                              _selectedSkills.clear();
                            }
                          });
                        },
                        fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                          if (states.contains(MaterialState.selected)) {
                            return Colors.grey[600]!;
                          }
                          return Colors.grey[400]!;
                        }),
                      ),
                      const SizedBox(width: 8),
                      Text('All Skills', style: TextStyle(color: Colors.grey[300])),
                    ],
                  ),
                ),
              ];

              for (LaborSkill skill in _skills) {
                menuItems.add(
                  PopupMenuItem<String>(
                    value: skill.name,
                    child: Row(
                      children: [
                        Checkbox(
                          value: _selectedSkills.contains(skill.name),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value!) {
                                _selectedSkills.add(skill.name);
                              } else {
                                _selectedSkills.remove(skill.name);
                              }
                            });
                          },
                          fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return Colors.grey[600]!;
                            }
                            return Colors.grey[400]!;
                          }),
                        ),
                        const SizedBox(width: 8),
                        Text(skill.name, style: TextStyle(color: Colors.grey[300])),
                      ],
                    ),
                  ),
                );
              }

              return menuItems;
            },
          ),
          if (_selectedLabors.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _bulkDeleteLabors,
            ),
        ],
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
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredLaborList.isEmpty
                  ? const Center(
                child: Text(
                  'No labor assigned to this project.',
                  style: TextStyle(color: Colors.white),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DocumentPage(projectId: widget.projectId),
            ),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

