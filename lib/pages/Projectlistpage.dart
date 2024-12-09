import 'package:flutter/material.dart';
import '../models/project.dart';
import '../api/project_api.dart';
import '../widget/drawer_widget.dart';

class ProjectListPage extends StatefulWidget {
  const ProjectListPage({Key? key}) : super(key: key);

  @override
  _ProjectListPageState createState() => _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage> {
  List<Project> _projects = [];
  List<Project> _filteredProjects = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  Set<String> _selectedProjects = {};

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
    await _fetchProjects();
    setState(() => _isLoading = false);
  }

  Future<void> _fetchProjects() async {
    try {
      final projectList = await ProjectApi.getProjectList();
      setState(() {
        _projects = projectList;
        _filteredProjects = projectList;
      });
    } catch (e) {
      print('Error fetching projects: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load projects')),
      );
    }
  }

  void _filterProjects(String query) {
    setState(() {
      _filteredProjects = _projects.where((project) {
        return project.name.toLowerCase().contains(query.toLowerCase()) ||
            project.id.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _toggleProjectSelection(String projectId) {
    setState(() {
      if (_selectedProjects.contains(projectId)) {
        _selectedProjects.remove(projectId);
      } else {
        _selectedProjects.add(projectId);
      }
    });
  }

  void _addProject() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddProjectPage()),
    );
    if (result == true) _fetchProjects();
  }

  void _navigateToProjectDetails(Project project) {
    // TODO: Implement navigation to Project Details Page
    print('Navigating to details of project: ${project.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project List', style: TextStyle(color: Colors.white)),
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
                onChanged: _filterProjects,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search projects',
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
                  : _filteredProjects.isEmpty
                  ? const Center(
                child: Text(
                  'No projects found',
                  style: TextStyle(color: Colors.white),
                ),
              )
                  : ListView.builder(
                itemCount: _filteredProjects.length,
                itemBuilder: (context, index) {
                  final project = _filteredProjects[index];
                  return Card(
                    color: Colors.grey[800],
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: Checkbox(
                        value: _selectedProjects.contains(project.id),
                        onChanged: (_) => _toggleProjectSelection(project.id),
                        activeColor: Colors.green,
                      ),
                      title: Text(
                        project.name,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ID: ${project.id}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            'Location: ${project.location}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            'Start Date: ${project.startDate}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            'Status: ${project.status}',
                            style: TextStyle(
                              color: project.status == 'Ongoing' ? Colors.green : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      onTap: () => _navigateToProjectDetails(project),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProject,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}