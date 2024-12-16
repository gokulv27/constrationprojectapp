import 'package:flutter/material.dart';
import '../models/document.dart';
import '../api/document_api.dart';
import '../widget/project_custom_bottom_navbar.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:permission_handler/permission_handler.dart';

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
      final documents =
      await _documentService.getProjectDocuments(widget.projectId);
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
      }
    }
  }

  Future<void> _downloadPDF(String url, String fileName) async {
    try {
      final response = await http.get(Uri.parse(url));
      final bytes = response.bodyBytes;
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');

      await file.writeAsBytes(bytes, flush: true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloaded $fileName')),
      );
    } catch (e) {
      print("$e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading file: $e')),
      );
    }
  }

  Future<void> _viewPDF(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      final bytes = response.bodyBytes;
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/temp.pdf');

      await file.writeAsBytes(bytes, flush: true);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerPage(filePath: file.path),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening file: $e')),
      );
    }
  }

  Future<void> _requestPermissions() async {
    if (await Permission.storage.request().isGranted) {
      // Permission is granted
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Storage permission is required')),
      );
    }
  }

  Future<void> _uploadDocumentManually() async {
    await _requestPermissions();

    // Use FilePicker to pick a document (if FilePicker is included)
    // FilePickerResult? result = await FilePicker.platform.pickFiles(
    //   type: FileType.custom,
    //   allowedExtensions: ['pdf'],
    // );
    // if (result != null && result.files.single.path != null) {
    //   String filePath = result.files.single.path!;
    //   bool success = await _uploadFileToServer(filePath);
    //   if (success) _loadDocuments();
    // }
  }

  Future<bool> _uploadFileToServer(String filePath) async {
    try {
      final fileName = filePath.split('/').last;
      await _documentService.uploadDocument(
        projectId: widget.projectId,
        file: File(filePath),
        fileName: fileName,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File uploaded successfully')),
      );
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading file: $e')),
      );
      return false;
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
            ? const Center(
          child: CircularProgressIndicator(color: Colors.green),
        )
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
                  document.documentName,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'Uploaded on: ${DateFormat('yyyy-MM-dd HH:mm').format(document.uploadedAt)}',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility,
                          color: Colors.blue),
                      onPressed: () => _viewPDF(document.fileUrl),
                    ),
                    IconButton(
                      icon: const Icon(Icons.download,
                          color: Colors.green),
                      onPressed: () =>
                          _downloadPDF(document.fileUrl, document.documentName),
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
        onPressed: _uploadDocumentManually,
        child: const Icon(Icons.upload_file),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class PDFViewerPage extends StatelessWidget {
  final String filePath;

  const PDFViewerPage({Key? key, required this.filePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PDFView(
        filePath: filePath,
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: false,
        pageFling: false,
        onRender: (_pages) {},
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading PDF: $error')),
          );
        },
        onPageError: (page, error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error on page $page: $error')),
          );
        },
      ),
    );
  }
}
