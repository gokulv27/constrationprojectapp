import 'package:flutter/material.dart';
import '../models/labor_skill.dart';
import '../models/labor_to_project.dart';
import '../api/labor_to_project_api.dart';
import '../widget/project_custom_bottom_navbar.dart';
import 'document_page.dart';
import 'labor_report_screen.dart';
import 'labor_selection_to_project_page.dart';

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
  Set<String> _selectedSkills = {};
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  int _currentIndex = 2;
  final Set<int> _selectedLabors = {};

  @override
  void initState() {
    super.initState();
    _fetchLaborForProject();
    _fetchSkills();
  }

  /// Fetch labor assigned to the project
  Future<void> _fetchLaborForProject() async {
    setState(() => _isLoading = true);
    try {
      final laborList = await LaborToProjectApi().getLaborForProject(widget.projectId);
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

  /// Fetch available skills
  Future<void> _fetchSkills() async {
    try {
      final skills = await LaborToProjectApi().getSkills();
      setState(() {
        _skills = skills;
      });
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Failed to load skills: $e')
      //   ),
      // );
    }
  }

  /// Get filtered labor list based on selected skills and search query
  List<LaborToProject> get filteredLaborList {
    final filteredBySkills = _selectedSkills.isEmpty
        ? _laborList
        : _laborList.where((labor) => _selectedSkills.contains(labor.skill)).toList();

    if (_searchQuery.isEmpty) return filteredBySkills;

    return filteredBySkills.where((labor) {
      final query = _searchQuery.toLowerCase();
      return labor.laborName.toLowerCase().contains(query) ||
          labor.skill.toLowerCase().contains(query);
    }).toList();
  }

  /// Remove a single labor from the project
  Future<void> _removeLabor(int laborId) async {
    setState(() => _isLoading = true);
    try {
      // Pass both projectId and laborId
      await LaborToProjectApi().removeLaborFromProject(widget.projectId, laborId);
      setState(() {
        _laborList.removeWhere((labor) => labor.id == laborId);
        _selectedLabors.remove(laborId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Labor removed successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove labor: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Bulk delete selected labor assignments
  Future<void> _bulkDeleteLabors() async {
    for (final laborId in _selectedLabors) {
      await _removeLabor(laborId);
    }
  }

  /// Handle bottom navigation tap
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

  /// Build individual labor cards
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
                  child: Text(
                    labor.laborName.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8.0),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[600]!,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  child: Text(
                    labor.skill.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 15.0),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeLabor(labor.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Labor in this Project',
          style: TextStyle(
            color: Colors.white, // Set the text color to white
          ),
        ),
        backgroundColor: Colors.black, // Set the background color to black
        iconTheme: const IconThemeData(
          color: Colors.white, // Set the icon color to white
        ),
        actions: [
          if (_selectedLabors.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _bulkDeleteLabors,
            ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LaborReportScreen(projectId: widget.projectId),
                ),
              );
            },
            child: const Text(
              'Report',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[900],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
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
              builder: (context) => LaborSelectionPage(projectId: widget.projectId),
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
