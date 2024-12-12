import 'package:flutter/material.dart';
import '../models/project.dart';
import '../api/project_api.dart';
import '../widget/drawer_widget.dart';
import 'project_details_page.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({Key? key}) : super(key: key);

  @override
  _ProjectPageState createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  late List<Project> _projects;
  late List<Project> _filteredProjects;
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
        SnackBar(
          content: Text('Failed to load projects: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _filterProjects(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProjects = _projects;
      } else {
        _filteredProjects = _projects.where((project) {
          final projectName = project.projectName.toLowerCase();
          final clientName = project.clientName.toLowerCase();
          return projectName.contains(query.toLowerCase()) ||
              clientName.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Project Management',
          style: TextStyle(color: Colors.white),
        ),
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
                  hintText: 'Search projects or clients',
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProjectDetailsPage(project: project),
                          ),
                        );
                      },
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              project.projectName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: project.activeStatus
                                  ? Colors.green
                                  : Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              project.activeStatus
                                  ? 'Active'
                                  : 'Inactive',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Client: ${project.clientName}',
                            style:
                            const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            'Budget: ₹${project.budget.toStringAsFixed(2)}',
                            style:
                            const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            'Location: ${project.location}',
                            style:
                            const TextStyle(color: Colors.grey),
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
    );
  }
}
