import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/run.dart';
import '../services/run_share_service.dart';
import 'run_share_template.dart';

/// Dialog that prompts user to save their run with an optional image
class SaveRunDialog extends StatefulWidget {
  final Run run;
  final String? activityType;
  final VoidCallback? onSaved;
  final VoidCallback? onSkipped;

  const SaveRunDialog({
    super.key,
    required this.run,
    this.activityType,
    this.onSaved,
    this.onSkipped,
  });

  /// Shows the save run dialog and returns true if saved, false if skipped
  static Future<bool> show({
    required BuildContext context,
    required Run run,
    String? activityType,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SaveRunDialog(run: run, activityType: activityType),
    );
    return result ?? false;
  }

  @override
  State<SaveRunDialog> createState() => _SaveRunDialogState();
}

class _SaveRunDialogState extends State<SaveRunDialog> {
  Uint8List? _selectedImageBytes;
  bool _isLoading = false;
  bool _showTemplate = false;
  String? _errorMessage;

  final GlobalKey _templateKey = GlobalKey();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: _showTemplate ? _buildTemplateView() : _buildInitialDialog(),
    );
  }

  Widget _buildInitialDialog() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF00A86B).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Color(0xFF00A86B),
              size: 40,
            ),
          ),

          const SizedBox(height: 20),

          // Title
          const Text(
            'Great Run! 🎉',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),

          const SizedBox(height: 8),

          // Stats summary
          Text(
            '${widget.run.distanceKm.toStringAsFixed(2)} km in ${_formatDuration(widget.run.duration)}',
            style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
          ),

          const SizedBox(height: 24),

          // Question
          const Text(
            'Would you like to save and share this run?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Color(0xFF374151)),
          ),

          const SizedBox(height: 24),

          // Buttons
          Row(
            children: [
              // Skip button
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _handleSkip,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Skip',
                    style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Save button
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A86B),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save Run',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateView() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                IconButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          setState(() {
                            _showTemplate = false;
                            _selectedImageBytes = null;
                          });
                        },
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const Expanded(
                  child: Text(
                    'Customize Your Card',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),

            const SizedBox(height: 16),

            // Template preview
            RunShareTemplate(
              repaintKey: _templateKey,
              imageBytes: _selectedImageBytes,
              distanceKm: widget.run.distanceKm,
              duration: widget.run.duration,
              pace: widget.run.paceMinutesPerKm,
              activityType: widget.activityType,
              date: widget.run.startedAt,
            ),

            const SizedBox(height: 20),

            // Image selection buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Camera button
                _buildImageButton(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  onPressed: _isLoading
                      ? null
                      : () => _pickImage(ImageSource.camera),
                ),

                const SizedBox(width: 16),

                // Gallery button
                _buildImageButton(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  onPressed: _isLoading
                      ? null
                      : () => _pickImage(ImageSource.gallery),
                ),

                if (_selectedImageBytes != null) ...[
                  const SizedBox(width: 16),
                  // Remove image button
                  _buildImageButton(
                    icon: Icons.delete_outline_rounded,
                    label: 'Remove',
                    onPressed: _isLoading
                        ? null
                        : () {
                            setState(() {
                              _selectedImageBytes = null;
                            });
                          },
                    isDestructive: true,
                  ),
                ],
              ],
            ),

            // Error message
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ],

            const SizedBox(height: 20),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveAndShare,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A86B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save & Share',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool isDestructive = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: isDestructive
              ? Colors.red.withOpacity(0.1)
              : const Color(0xFF00A86B).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : const Color(0xFF00A86B),
                size: 24,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDestructive ? Colors.red : const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Read the image as bytes to avoid dart:io File issues
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick image: $e';
      });
    }
  }

  void _handleSkip() {
    Navigator.of(context).pop(false);
    widget.onSkipped?.call();
  }

  void _handleSave() {
    setState(() {
      _showTemplate = true;
    });
  }

  Future<void> _saveAndShare() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Wait for the widget to render
      await Future.delayed(const Duration(milliseconds: 100));

      // Capture the template as an image
      final capturedImageBytes = await RunShareTemplateCapture.captureAsImage(
        _templateKey,
      );

      if (capturedImageBytes == null) {
        setState(() {
          _errorMessage = 'Failed to capture image';
          _isLoading = false;
        });
        return;
      }

      // Save image to gallery using the service
      final savedToGallery = await RunShareService.saveImageToGallery(
        capturedImageBytes,
      );

      if (savedToGallery) {
        // Prepare path data
        final pathData = widget.run.path
            .map((p) => {'lat': p.latitude, 'lng': p.longitude})
            .toList();

        // Also try to save to backend (optional)
        try {
          await RunShareService.saveRunWithImage(
            runId: widget.run.id,
            distanceMeters: widget.run.distanceMeters,
            duration: widget.run.duration,
            startedAt: widget.run.startedAt,
            endedAt: widget.run.endedAt,
            path: pathData,
            imageBytes: capturedImageBytes,
            activityType: widget.activityType,
          );
        } catch (_) {
          // Ignore backend errors since image is saved locally
        }

        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image saved to gallery! 📸'),
              backgroundColor: Color(0xFF00A86B),
              duration: Duration(seconds: 2),
            ),
          );

          Navigator.of(context).pop(true);
          widget.onSaved?.call();
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to save image to gallery';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    }
    return '${minutes}m ${seconds}s';
  }
}
