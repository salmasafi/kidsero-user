import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kidsero_driver/core/theme/app_colors.dart';
import 'package:kidsero_driver/core/theme/app_sizes.dart';
import 'package:kidsero_driver/features/payments/utils/image_utils.dart';
import 'package:kidsero_driver/l10n/app_localizations.dart';

/// Widget for selecting and previewing receipt images
/// 
/// Provides functionality to:
/// - Select images from gallery or camera
/// - Display image preview
/// - Remove selected image
/// - Validate image size
/// - Encode image to base64
class ReceiptImagePicker extends StatefulWidget {
  /// Callback when an image is selected and validated
  final Function(String base64Image) onImageSelected;
  
  /// Callback when the image is removed
  final VoidCallback? onImageRemoved;
  
  /// Initial image file (optional)
  final File? initialImage;
  
  /// Maximum image size in bytes (default: 5 MB)
  final int maxSizeInBytes;

  const ReceiptImagePicker({
    super.key,
    required this.onImageSelected,
    this.onImageRemoved,
    this.initialImage,
    this.maxSizeInBytes = ImageUtils.defaultMaxSizeInBytes,
  });

  @override
  State<ReceiptImagePicker> createState() => _ReceiptImagePickerState();
}

class _ReceiptImagePickerState extends State<ReceiptImagePicker> {
  File? _selectedImage;
  String? _errorMessage;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.initialImage;
  }

  /// Show bottom sheet to select image source
  Future<void> _showImageSourceSelection() async {
    final localizations = AppLocalizations.of(context)!;
    
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primary),
                title: Text(localizations.selectFromGallery),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: Text(localizations.takePhoto),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Pick image from the specified source
  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final File? image = await ImageUtils.pickImage(source);
      
      if (image == null) {
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      // Validate image size
      if (!ImageUtils.isImageSizeValid(image, maxSizeInBytes: widget.maxSizeInBytes)) {
        final maxSizeInMB = widget.maxSizeInBytes / (1024 * 1024);
        final actualSize = ImageUtils.formatFileSize(ImageUtils.getImageSize(image));
        
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.imageSizeError(
            maxSizeInMB.toStringAsFixed(0),
            actualSize,
          );
          _isProcessing = false;
        });
        return;
      }

      // Encode to base64
      final String base64Image = await ImageUtils.imageToBase64(image);
      
      setState(() {
        _selectedImage = image;
        _errorMessage = null;
        _isProcessing = false;
      });

      // Notify parent widget
      widget.onImageSelected(base64Image);
    } catch (e) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.imagePickerError;
        _isProcessing = false;
      });
    }
  }

  /// Remove the selected image
  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _errorMessage = null;
    });
    
    widget.onImageRemoved?.call();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          localizations.receiptImage,
          style: TextStyle(
            fontSize: AppSizes.bodySize(context),
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppSizes.spacingSmall(context)),
        
        // Image picker/preview area
        if (_selectedImage == null)
          _buildImagePickerButton(localizations)
        else
          _buildImagePreview(),
        
        // Error message
        if (_errorMessage != null) ...[
          SizedBox(height: AppSizes.spacingSmall(context)),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Build the image picker button
  Widget _buildImagePickerButton(AppLocalizations localizations) {
    return InkWell(
      onTap: _isProcessing ? null : _showImageSourceSelection,
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(
            color: _errorMessage != null 
                ? AppColors.error 
                : AppColors.border,
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Center(
          child: _isProcessing
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      localizations.tapToChooseReceipt,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AppSizes.bodySize(context),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  /// Build the image preview with remove button
  Widget _buildImagePreview() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          // Image preview
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Image.file(
                _selectedImage!,
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Remove button
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: _removeImage,
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          
          // Change image button
          Positioned(
            bottom: 8,
            right: 8,
            child: Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: _showImageSourceSelection,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppLocalizations.of(context)!.changeImage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
