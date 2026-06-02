import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/models/document.dart';
import 'package:lecle_downloads_path_provider/lecle_downloads_path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

class DocumentScreen extends StatefulWidget {
  final Document document;

  const DocumentScreen({super.key, required this.document});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Future<void> _exportPdf() async {
  //   if (!mounted) return;
  //   setState(() => _isLoading = true);

  //   final baseUrl = 'http://192.168.1.8:5000/pdf';
  //   final uri = Uri.parse(baseUrl);

  //   try {
  //     var request = http.MultipartRequest('POST', uri);

  //     final pages = widget.document.pages;

  //     // 1. Fallback security check if pages list is empty but thumbnail exists
  //     if (pages.isEmpty && widget.document.thumbnailPath != null) {
  //       if (!widget.document.thumbnailPath!.startsWith('http')) {
  //         request.files.add(
  //           await http.MultipartFile.fromPath(
  //             'images',
  //             widget.document.thumbnailPath!,
  //           ),
  //         );
  //       }
  //     } else {
  //       // 2. Loop through all document pages and attach them sequentially
  //       for (var page in pages) {
  //         if (!page.imagePath.startsWith('http')) {
  //           request.files.add(
  //             await http.MultipartFile.fromPath('images', page.imagePath),
  //           );
  //         }
  //       }
  //     }

  //     // Guard close: If no valid local image files are loaded, stop network cycle
  //     if (request.files.isEmpty) {
  //       throw Exception("No local image pages found to export.");
  //     }

  //     var streamedResponse = await request.send();
  //     var response = await http.Response.fromStream(streamedResponse);

  //     if (response.statusCode == 200) {
  //       String? downloadDirPath;

  //       if (Platform.isAndroid) {
  //         // 1. Request storage permission on Android
  //         var status = await Permission.storage.request();
  //         if (!status.isGranted) {
  //           // Fallback request if Android 13+ handles it via media permissions
  //           status = await Permission.manageExternalStorage.request();
  //         }

  //         if (status.isGranted) {
  //           // 2. Fetch the public downloads directory path
  //           final directory = await DownloadsPath.downloadsDirectory();
  //           downloadDirPath = directory?.path;
  //         } else {
  //           throw Exception(
  //             "Storage permission denied. Cannot save to Downloads.",
  //           );
  //         }
  //       } else if (Platform.isIOS) {
  //         // 3. On iOS, fallback to standard docs folder (made public via Info.plist)
  //         final directory = await getApplicationDocumentsDirectory();
  //         downloadDirPath = directory.path;
  //       }

  //       if (downloadDirPath != null) {
  //         final timestamp = DateTime.now().millisecondsSinceEpoch;
  //         final pdfFile = File('$downloadDirPath/bukacv_$timestamp.pdf');

  //         // 4. Write data to the shared public space
  //         await pdfFile.writeAsBytes(response.bodyBytes);

  //         if (mounted) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: Text(
  //                 Platform.isAndroid
  //                     ? 'PDF saved to your Downloads folder!'
  //                     : 'PDF saved! View it in the Files App.',
  //               ),
  //               backgroundColor: Colors.green,
  //             ),
  //           );
  //         }
  //       }
  //     } else {
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('Failed to export PDF: ${response.statusCode}'),
  //           ),
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint('Error exporting PDF: $e');
  //     if (mounted) {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text('Export error: $e')));
  //     }
  //   } finally {
  //     if (mounted) {
  //       setState(() => _isLoading = false);
  //     }
  //   }
  // }

  Future<void> _exportPdf() async {
    if (!mounted) return;
    String? chosenDirPath;

    try {
      String? selectedDirectory = await FilePicker.getDirectoryPath();
      
      if (selectedDirectory == null) {
        // User canceled the picker
        return; 
      }
      
      chosenDirPath = selectedDirectory;
    } catch (e) {
      debugPrint("Error picking directory: $e");
      return;
    }

    // final _pickedDirecotry = (await FlutterFileDialog.pickDirectory());
    // return;

    setState(() => _isLoading = true);

    final baseUrl = '${dotenv.env['BACKEND_URI'] ?? 'http://10.0.2.2:5000/process'}/pdf';
    // final baseUrl = 'http://192.168.1.8:5000/pdf';
    final uri = Uri.parse(baseUrl);

    try {
      // 1. Upload images via MultipartRequest
      var request = http.MultipartRequest('POST', uri);
      final pages = widget.document.pages;

      if (pages.isEmpty && widget.document.thumbnailPath != null) {
        if (!widget.document.thumbnailPath!.startsWith('http')) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'images',
              widget.document.thumbnailPath!,
            ),
          );
        }
      } else {
        for (var page in pages) {
          if (!page.imagePath.startsWith('http')) {
            request.files.add(
              await http.MultipartFile.fromPath('images', page.imagePath),
            );
          }
        }
      }

      if (request.files.isEmpty) {
        throw Exception("No local image pages found to export.");
      }

      // 2. Send the upload request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // Parse the returned JSON to get the download URL
        final responseData = jsonDecode(response.body);
        final filename = responseData['filename'];

        // 3. Handle Storage Permissions for downloading
        String? downloadDirPath;
        if (Platform.isAndroid) {
          var status = await Permission.storage.request();
          if (!status.isGranted) {
            status = await Permission.manageExternalStorage.request();
          }
          if (status.isGranted) {
            final directory = await DownloadsPath.downloadsDirectory();
            downloadDirPath = directory?.path;
          } else {
            throw Exception("Storage permission denied.");
          }
        } else if (Platform.isIOS) {
          final directory = await getApplicationDocumentsDirectory();
          downloadDirPath = directory.path;
        }

        if (Platform.isAndroid) {
          var notificationStatus = await Permission.notification.status;
          if (!notificationStatus.isGranted) {
            await Permission.notification.request();
          }
        }

        if (downloadDirPath != null) {
          final timestamp = DateTime.now().millisecondsSinceEpoch;

          final downloadUrl = '${dotenv.env['BACKEND_URI'] ?? 'http://10.0.2.2:5000/process'}/download/$filename';
          // final downloadUrl = 'http://192.168.1.8:5000/download/$filename';
          await FlutterDownloader.enqueue(
            url: downloadUrl,
            headers: {'Accept': 'application/pdf'},
            savedDir: chosenDirPath ?? downloadDirPath,
            fileName: 'bukacv_$timestamp.pdf',
            showNotification: true, // This puts it in the notification tray!
            openFileFromNotification: true, // Allows tapping to open
            saveInPublicStorage: true,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Download Started... Check your notification'),
                backgroundColor: Colors.blue,
              ),
            );
          }
        }
      } else {
        final responseData = jsonDecode(response.body);
        throw Exception('Failed to generate PDF: ${responseData["error"]}');
      }
    } catch (e) {
      debugPrint('Error exporting PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildPageImage(String? path) {
    if (path == null) {
      return const Icon(
        Icons.insert_drive_file,
        size: 100,
        color: Colors.white,
      );
    }
    if (path.startsWith('http')) {
      return Image.network(path, fit: BoxFit.contain);
    }
    return Image.file(File(path), fit: BoxFit.contain);
  }

  @override
  Widget build(BuildContext context) {
    final pages = widget.document.pages;
    final totalPages = pages.isEmpty ? 1 : pages.length;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.document.title,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            if (totalPages > 1)
              Text(
                'Page ${_currentPage + 1} of $totalPages',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  pages.isEmpty
                      ? Center(
                          child: Hero(
                            tag: 'doc_${widget.document.id}',
                            child: InteractiveViewer(
                              minScale: 0.5,
                              maxScale: 4.0,
                              child: _buildPageImage(
                                widget.document.thumbnailPath,
                              ),
                            ),
                          ),
                        )
                      : PageView.builder(
                          controller: _pageController,
                          itemCount: totalPages,
                          onPageChanged: (index) {
                            // Safely delay state changes right outside structural frame callbacks
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(() {
                                  _currentPage = index;
                                });
                              }
                            });
                          },
                          itemBuilder: (context, index) {
                            final pageWidget = Center(
                              child: InteractiveViewer(
                                minScale: 0.5,
                                maxScale: 4.0,
                                child: _buildPageImage(pages[index].imagePath),
                              ),
                            );
                            if (index == 0) {
                              return Hero(
                                tag: 'doc_${widget.document.id}',
                                child: pageWidget,
                              );
                            }
                            return pageWidget;
                          },
                        ),

                  // Bottom Dot Indicators over image layout background
                  if (totalPages > 1)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          totalPages,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 10 : 6,
                            height: _currentPage == index ? 10 : 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPage == index
                                  ? Colors.white
                                  : Colors.white38,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.m,
        horizontal: AppSpacing.l,
      ),
      color: const Color(0xFF1E1E1E),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ActionButton(icon: Icons.share, label: 'Share', onTap: () {}),
          _ActionButton(
            icon: Icons.picture_as_pdf,
            label: 'Export PDF',
            onTap: _exportPdf,
          ),
          _ActionButton(icon: Icons.edit, label: 'Rename', onTap: () {}),
          _ActionButton(
            icon: Icons.delete,
            label: 'Delete',
            color: Colors.redAccent,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color ?? Colors.white, size: 24),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: TextStyle(color: color ?? Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
