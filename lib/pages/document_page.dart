import 'package:flutter/material.dart';
import '../models/document.dart';
import '../api/document_api.dart';
import '../widget/project_custom_bottom_navbar.dart';
import 'package:intl/intl.dart';
import 'labor_to_project_page.dart';

class DocumentPage extends StatefulWidget {
  final int projectId;

  const DocumentPage({Key? key, required this.projectId}) : super(key: key);

  @override
  _DocumentPageState createState() => _DocumentPageState();
}

class _DocumentPageState extends State<DocumentPage> {
  final DocumentService _documentService = DocumentService();
  List<Document> _documents = [];
  bool _isLoading = true;
  int _currentIndex = 1; // Default index for Documents tab

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() => _isLoading = true);
    try {
      final documents = await _documentService.getProjectDocuments(widget.projectId);
      setState(() {
        _documents = documents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load documents: $e')),
      );
    }
  }

  void _onNavTap(int index) {
    if (index != _currentIndex) {
      setState(() => _currentIndex = index);
      if (index == 0) {
        Navigator.pop(context);
      } else if (index == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LaborToProjectPage(projectId: widget.projectId),
          ),
        );
      }
    }
  }

  Future<void> _downloadAndOpenPDF(String url, String fileName) async {
    try {
      // Get the directory to save the file
      // final directory = await getApplicationDocumentsDirectory();
      // final filePath = '${directory.path}/$fileName';

      // Download the file
      // final file = await _documentService.downloadDocument(
      //   url: url,
      //   savePath: filePath,
      // );

      // Open the downloaded PDF using flutter_pdfview
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => PDFViewerPage(filePath: file.path),
      //   ),
      // );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Project Documents',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.grey[900],
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.green))
            : _documents.isEmpty
            ? const Center(
          child: Text(
            'No documents found.',
            style: TextStyle(color: Colors.grey),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: _documents.length,
          itemBuilder: (context, index) {
            final document = _documents[index];
            return Card(
              color: Colors.grey[800],
              child: ListTile(
                title: Text(
                  document.fileName,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'Uploaded on: ${DateFormat('yyyy-MM-dd HH:mm').format(document.uploadedAt)}',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (document.documentType != null)
                      Chip(
                        label: Text(
                          document.documentType!.name,
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.blue,
                      ),
                    IconButton(
                      icon: const Icon(Icons.download, color: Colors.green),
                      onPressed: () {
                        _downloadAndOpenPDF(document.fileUrl, document.fileName);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add manual upload action or call _uploadDocumentManually with a predefined file
        },
        child: const Icon(Icons.upload_file),
        backgroundColor: Colors.green,
      ),
    );
  }
}
