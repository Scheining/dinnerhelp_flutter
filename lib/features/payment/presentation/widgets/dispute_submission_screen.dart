import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../domain/entities/dispute_case.dart';
import '../../../core/constants/spacing.dart';

class DisputeSubmissionScreen extends ConsumerStatefulWidget {
  final String bookingId;
  final String chefName;
  final DateTime bookingDate;
  final Function(DisputeCase) onSubmit;
  final VoidCallback? onCancel;

  const DisputeSubmissionScreen({
    Key? key,
    required this.bookingId,
    required this.chefName,
    required this.bookingDate,
    required this.onSubmit,
    this.onCancel,
  }) : super(key: key);

  @override
  ConsumerState<DisputeSubmissionScreen> createState() => _DisputeSubmissionScreenState();
}

class _DisputeSubmissionScreenState extends ConsumerState<DisputeSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _pageController = PageController();
  
  // Form state
  DisputeReason? _selectedReason;
  int _currentStep = 0;
  final List<File> _attachedImages = [];
  final List<String> _attachedDocuments = [];
  bool _isSubmitting = false;

  // Predefined reasons with descriptions
  final Map<DisputeReason, DisputeReasonInfo> _reasonInfo = {
    DisputeReason.serviceNotProvided: const DisputeReasonInfo(
      title: 'Service Not Provided',
      description: 'The chef did not provide the agreed service',
      icon: Icons.cancel,
      examples: ['Chef cancelled last minute', 'No communication', 'Service never started'],
    ),
    DisputeReason.chefNoShow: const DisputeReasonInfo(
      title: 'Chef No-Show',
      description: 'The chef did not arrive at the scheduled time',
      icon: Icons.person_off,
      examples: ['Chef never arrived', 'No response on booking day', 'Left waiting'],
    ),
    DisputeReason.serviceQualityPoor: const DisputeReasonInfo(
      title: 'Poor Service Quality',
      description: 'The service quality was significantly below expectations',
      icon: Icons.thumb_down,
      examples: ['Food was not prepared properly', 'Unprepared chef', 'Poor cooking skills'],
    ),
    DisputeReason.foodSafetyConcern: const DisputeReasonInfo(
      title: 'Food Safety Concern',
      description: 'There were food safety or hygiene issues',
      icon: Icons.warning,
      examples: ['Unsafe food handling', 'Poor hygiene', 'Allergic reaction'],
    ),
    DisputeReason.unprofessionalBehavior: const DisputeReasonInfo(
      title: 'Unprofessional Behavior',
      description: 'The chef behaved unprofessionally',
      icon: Icons.report,
      examples: ['Rude behavior', 'Inappropriate conduct', 'Disrespectful attitude'],
    ),
    DisputeReason.propertyDamage: const DisputeReasonInfo(
      title: 'Property Damage',
      description: 'The chef caused damage to your property',
      icon: Icons.broken_image,
      examples: ['Kitchen equipment damaged', 'Spills not cleaned', 'Broken items'],
    ),
    DisputeReason.wrongOrder: const DisputeReasonInfo(
      title: 'Wrong Order/Menu',
      description: 'The chef prepared different dishes than agreed',
      icon: Icons.restaurant_menu,
      examples: ['Wrong dishes prepared', 'Missing items', 'Dietary restrictions ignored'],
    ),
    DisputeReason.priceDispute: const DisputeReasonInfo(
      title: 'Price Dispute',
      description: 'Disagreement about the charges',
      icon: Icons.attach_money,
      examples: ['Unexpected charges', 'Price different than quoted', 'Hidden fees'],
    ),
  };

  @override
  void dispose() {
    _descriptionController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Dispute'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onCancel,
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(theme),
          
          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentStep = index),
              children: [
                _buildBookingInfoStep(theme),
                _buildReasonSelectionStep(theme),
                _buildDescriptionStep(theme),
                _buildEvidenceStep(theme),
                _buildReviewStep(theme),
              ],
            ),
          ),
          
          // Navigation buttons
          _buildNavigationButtons(theme),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(Spacing.medium),
      child: Row(
        children: List.generate(5, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(
                right: index < 4 ? Spacing.small : 0,
              ),
              decoration: BoxDecoration(
                color: isActive 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBookingInfoStep(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(Spacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Information',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: Spacing.medium),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    icon: Icons.person_outline,
                    label: 'Chef',
                    value: widget.chefName,
                  ),
                  const SizedBox(height: Spacing.small),
                  _buildInfoRow(
                    icon: Icons.calendar_today,
                    label: 'Booking Date',
                    value: _formatDate(widget.bookingDate),
                  ),
                  const SizedBox(height: Spacing.small),
                  _buildInfoRow(
                    icon: Icons.numbers,
                    label: 'Booking ID',
                    value: widget.bookingId,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: Spacing.large),
          
          Container(
            padding: const EdgeInsets.all(Spacing.medium),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: Spacing.small),
                    Text(
                      'Important Information',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.small),
                Text(
                  'Filing a dispute is a serious matter. Please provide accurate and detailed information to help us resolve the issue fairly.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          Text(
            'We will review your dispute and work to resolve it within 3-5 business days.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonSelectionStep(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(Spacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select the Issue',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: Spacing.small),
          
          Text(
            'Choose the option that best describes your issue:',
            style: theme.textTheme.bodyMedium,
          ),
          
          const SizedBox(height: Spacing.medium),
          
          Expanded(
            child: ListView.builder(
              itemCount: _reasonInfo.length,
              itemBuilder: (context, index) {
                final reason = _reasonInfo.keys.elementAt(index);
                final info = _reasonInfo[reason]!;
                final isSelected = _selectedReason == reason;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: Spacing.small),
                  child: InkWell(
                    onTap: () => setState(() => _selectedReason = reason),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(Spacing.medium),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? Border.all(color: theme.colorScheme.primary, width: 2)
                            : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              info.icon,
                              color: isSelected
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          
                          const SizedBox(width: Spacing.medium),
                          
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  info.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  info.description,
                                  style: theme.textTheme.bodySmall,
                                ),
                                if (info.examples.isNotEmpty) ...[
                                  const SizedBox(height: Spacing.small),
                                  Text(
                                    'Examples: ${info.examples.take(2).join(', ')}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontStyle: FontStyle.italic,
                                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: theme.colorScheme.primary,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionStep(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(Spacing.medium),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Describe the Issue',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: Spacing.small),
            
            Text(
              'Please provide a detailed description of what happened:',
              style: theme.textTheme.bodyMedium,
            ),
            
            const SizedBox(height: Spacing.medium),
            
            Expanded(
              child: TextFormField(
                controller: _descriptionController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please provide a description of the issue';
                  }
                  if (value.trim().length < 20) {
                    return 'Please provide more details (at least 20 characters)';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: 'Describe what happened in detail...\n\nInclude:\n• What you expected\n• What actually happened\n• When it occurred\n• Any relevant details',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
            ),
            
            const SizedBox(height: Spacing.medium),
            
            Container(
              padding: const EdgeInsets.all(Spacing.small),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: Spacing.small),
                  Expanded(
                    child: Text(
                      'Tip: The more details you provide, the faster we can resolve your dispute.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvidenceStep(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(Spacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Evidence (Optional)',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: Spacing.small),
          
          Text(
            'Upload photos, documents, or other evidence to support your dispute:',
            style: theme.textTheme.bodyMedium,
          ),
          
          const SizedBox(height: Spacing.medium),
          
          // Upload buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('Add Photo'),
                ),
              ),
              const SizedBox(width: Spacing.small),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickDocument,
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Add Document'),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: Spacing.medium),
          
          // Attached files
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Images
                  if (_attachedImages.isNotEmpty) ...[
                    _buildSectionHeader('Photos', _attachedImages.length),
                    const SizedBox(height: Spacing.small),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: Spacing.small,
                        mainAxisSpacing: Spacing.small,
                      ),
                      itemCount: _attachedImages.length,
                      itemBuilder: (context, index) {
                        final image = _attachedImages[index];
                        return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(image),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _attachedImages.removeAt(index);
                                  });
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: Spacing.medium),
                  ],
                  
                  // Documents
                  if (_attachedDocuments.isNotEmpty) ...[
                    _buildSectionHeader('Documents', _attachedDocuments.length),
                    const SizedBox(height: Spacing.small),
                    ...(_attachedDocuments.asMap().entries.map((entry) {
                      final index = entry.key;
                      final document = entry.value;
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.description),
                          title: Text(document.split('/').last),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _attachedDocuments.removeAt(index);
                              });
                            },
                          ),
                        ),
                      );
                    })),
                  ],
                  
                  // Empty state
                  if (_attachedImages.isEmpty && _attachedDocuments.isEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(Spacing.large),
                      child: Column(
                        children: [
                          Icon(
                            Icons.upload_file,
                            size: 64,
                            color: theme.colorScheme.onSurface.withOpacity(0.3),
                          ),
                          const SizedBox(height: Spacing.medium),
                          Text(
                            'No evidence added yet',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: Spacing.small),
                          Text(
                            'Evidence can help support your dispute, but it\'s optional.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(Spacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Your Dispute',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: Spacing.medium),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Booking info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.medium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Booking Information',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: Spacing.small),
                          Text('Booking ID: ${widget.bookingId}'),
                          Text('Chef: ${widget.chefName}'),
                          Text('Date: ${_formatDate(widget.bookingDate)}'),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: Spacing.small),
                  
                  // Issue type
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.medium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Issue Type',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: Spacing.small),
                          if (_selectedReason != null)
                            Text(_reasonInfo[_selectedReason!]!.title),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: Spacing.small),
                  
                  // Description
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.medium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: Spacing.small),
                          Text(
                            _descriptionController.text.isNotEmpty
                                ? _descriptionController.text
                                : 'No description provided',
                            style: _descriptionController.text.isEmpty
                                ? theme.textTheme.bodyMedium?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: Spacing.small),
                  
                  // Evidence
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.medium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Evidence',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: Spacing.small),
                          Text(
                            '${_attachedImages.length} photos, ${_attachedDocuments.length} documents',
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: Spacing.medium),
                  
                  // Warning
                  Container(
                    padding: const EdgeInsets.all(Spacing.medium),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.error.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_outlined,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(width: Spacing.small),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Important Notice',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.error,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Once submitted, this dispute will be reviewed by our team. Please ensure all information is accurate.',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(Spacing.medium),
      child: Row(
        children: [
          // Back button
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: const Text('Back'),
              ),
            ),
          
          if (_currentStep > 0) const SizedBox(width: Spacing.medium),
          
          // Next/Submit button
          Expanded(
            child: ElevatedButton(
              onPressed: _canProceed() && !_isSubmitting ? () {
                if (_currentStep < 4) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  _submitDispute();
                }
              } : null,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_currentStep < 4 ? 'Next' : 'Submit Dispute'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: Spacing.small),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: Spacing.small),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Helper methods

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return true;
      case 1:
        return _selectedReason != null;
      case 2:
        return _descriptionController.text.trim().isNotEmpty &&
               _descriptionController.text.trim().length >= 20;
      case 3:
        return true; // Evidence is optional
      case 4:
        return _selectedReason != null &&
               _descriptionController.text.trim().isNotEmpty;
      default:
        return false;
    }
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _attachedImages.add(File(image.path));
      });
    }
  }

  void _pickDocument() async {
    // This would integrate with a document picker
    // For now, just add a placeholder
    setState(() {
      _attachedDocuments.add('document_${DateTime.now().millisecondsSinceEpoch}.pdf');
    });
  }

  void _submitDispute() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    
    // Create evidence list
    final evidence = <DisputeEvidence>[];
    
    // Add image evidence
    for (int i = 0; i < _attachedImages.length; i++) {
      evidence.add(DisputeEvidence(
        id: 'img_$i',
        type: EvidenceType.photo,
        title: 'Photo ${i + 1}',
        fileUrl: _attachedImages[i].path,
        submittedAt: DateTime.now(),
        submittedBy: 'current_user_id', // Would be actual user ID
      ));
    }
    
    // Add document evidence
    for (int i = 0; i < _attachedDocuments.length; i++) {
      evidence.add(DisputeEvidence(
        id: 'doc_$i',
        type: EvidenceType.document,
        title: 'Document ${i + 1}',
        fileUrl: _attachedDocuments[i],
        submittedAt: DateTime.now(),
        submittedBy: 'current_user_id', // Would be actual user ID
      ));
    }
    
    // Create dispute case
    final dispute = DisputeCase(
      id: 'dispute_${DateTime.now().millisecondsSinceEpoch}',
      bookingId: widget.bookingId,
      userId: 'current_user_id', // Would be actual user ID
      chefId: 'chef_id', // Would be actual chef ID
      reason: _selectedReason!,
      description: _descriptionController.text.trim(),
      status: DisputeStatus.submitted,
      priority: _selectedReason!.defaultPriority,
      evidence: evidence,
      createdAt: DateTime.now(),
    );
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() => _isSubmitting = false);
    
    widget.onSubmit(dispute);
  }
}

class DisputeReasonInfo {
  final String title;
  final String description;
  final IconData icon;
  final List<String> examples;

  const DisputeReasonInfo({
    required this.title,
    required this.description,
    required this.icon,
    this.examples = const [],
  });
}