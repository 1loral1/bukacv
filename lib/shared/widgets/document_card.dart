import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/document.dart';
import '../../core/constants/app_constants.dart';
import '../../features/document/document_screen.dart';

class DocumentCard extends StatelessWidget {
  final Document document;

  const DocumentCard({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DocumentScreen(document: document)),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Hero(
                tag: 'doc_${document.id}',
                // FlightShuttleBuilder prevents layout distortion during animation
                flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
                  return Material(
                    type: MaterialType.transparency,
                    child: toHeroContext.widget,
                  );
                },
                child: Container(
                  margin: const EdgeInsets.all(8),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.s),
                    image: DecorationImage(
                      image: (document.thumbnailPath?.startsWith('http') == true)
                          ? NetworkImage(document.thumbnailPath!)
                          : (document.thumbnailPath != null
                              ? FileImage(File(document.thumbnailPath!))
                              : const AssetImage('assets/placeholder.png')) as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s,
                0,
                AppSpacing.s,
                AppSpacing.xs,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    DateFormat('MMM dd, yyyy').format(document.createdAt),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}