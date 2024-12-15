import 'package:flutter/material.dart';
import '../models/project.dart';
import '../widget/project_custom_bottom_navbar.dart';
import 'package:intl/intl.dart';
import 'document_page.dart';
import 'labor_to_project_page.dart';

class ProjectDetailsPage extends StatefulWidget {
  final Project project;

  const ProjectDetailsPage({Key? key, required this.project}) : super(key: key);

  @override
  _ProjectDetailsPageState createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  int _currentIndex = 0;

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 1) {
      // Navigate to Documents page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DocumentPage(projectId: widget.project.id),
        ),
      );
    } else if (index == 2) {
      // Navigate to Labor to Project page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LaborToProjectPage(projectId: widget.project.id),
        ),
      );
    }
    // Add other navigation handlers as needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.project.projectName,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.grey[900],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailCard('Project Details', [
                _buildDetailRow('Project Name', widget.project.projectName),
                _buildDetailRow('Client Name', widget.project.clientName),
                _buildDetailRow('Location', widget.project.location),
                _buildDetailRow('Budget', '₹${widget.project.budget.toStringAsFixed(2)}'),
                _buildDetailRow('Status', widget.project.activeStatus ? 'Active' : 'Inactive'),
              ]),
              const SizedBox(height: 16),
              _buildDetailCard('Land Details', [
                _buildDetailRow('Land Facing', widget.project.landFacing),
                _buildDetailRow('Land Width', '${widget.project.landWidth} m'),
                _buildDetailRow('Land Breadth', '${widget.project.landBreadth} m'),
                _buildDetailRow('Number of Floors', widget.project.numFloors.toString()),
                _buildDetailRow('Build Area', '${widget.project.buildArea} sq m'),
              ]),
              const SizedBox(height: 16),
              _buildDetailCard('Additional Information', [
                _buildDetailRow('Project ID', widget.project.id.toString()),
                _buildDetailRow('Client ID', widget.project.clientId.toString()),
                _buildDetailRow('Created At', _formatDateTime(widget.project.createdAt)),
                _buildDetailRow('Updated At', _formatDateTime(widget.project.updatedAt)),
              ]),
              const SizedBox(height: 80), // Add padding for bottom nav bar
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildDetailCard(String title, List<Widget> children) {
    return Card(
      color: Colors.grey[800],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }
}
