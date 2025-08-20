import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/localization/app_localizations_extension.dart';
import '../../../../widgets/custom_button.dart';
import '../../domain/entities/dish.dart';
import '../../domain/entities/selected_dish.dart';
import '../../domain/entities/custom_dish_request.dart';

class DishSelectionScreen extends ConsumerStatefulWidget {
  final String chefId;
  final String chefName;
  final List<Dish> availableDishes;
  final Function(List<SelectedDish>, CustomDishRequest?) onSelectionComplete;

  const DishSelectionScreen({
    super.key,
    required this.chefId,
    required this.chefName,
    required this.availableDishes,
    required this.onSelectionComplete,
  });

  @override
  ConsumerState<DishSelectionScreen> createState() => _DishSelectionScreenState();
}

class _DishSelectionScreenState extends ConsumerState<DishSelectionScreen> {
  List<SelectedDish> selectedDishes = [];
  CustomDishRequest? customDishRequest;
  bool showCustomDishForm = false;
  
  // Custom dish form controllers
  final _customDishNameController = TextEditingController();
  final _customDishDescriptionController = TextEditingController();
  final _customDishNotesController = TextEditingController();
  int _customDishTimeMinutes = 60;
  List<String> _customDishAllergens = [];
  List<String> _customDishDietaryRequirements = [];

  @override
  void dispose() {
    _customDishNameController.dispose();
    _customDishDescriptionController.dispose();
    _customDishNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text('Vælg retter'), // Select dishes
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.screenPaddingHorizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSpacing.verticalSpace16,
                  
                  // Header
                  Text(
                    '${widget.chefName}s Menu',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  AppSpacing.verticalSpace8,
                  Text(
                    'Vælg retter fra menuen eller anmod om tilpassede retter',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  AppSpacing.verticalSpace24,
                  
                  // Available dishes
                  if (widget.availableDishes.isNotEmpty) ...[
                    _buildDishList(theme),
                    AppSpacing.verticalSpace32,
                  ],
                  
                  // Custom dish section
                  _buildCustomDishSection(theme),
                  AppSpacing.verticalSpace24,
                  
                  // Selected dishes summary
                  if (selectedDishes.isNotEmpty || customDishRequest != null)
                    _buildSelectionSummary(theme),
                    
                  AppSpacing.verticalSpace32,
                ],
              ),
            ),
          ),
          
          // Bottom action buttons
          _buildBottomActions(theme),
        ],
      ),
    );
  }

  Widget _buildDishList(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tilgængelige retter', // Available dishes
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        AppSpacing.verticalSpace16,
        
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.availableDishes.length,
          separatorBuilder: (_, __) => AppSpacing.verticalSpace12,
          itemBuilder: (context, index) {
            final dish = widget.availableDishes[index];
            final selectedDish = selectedDishes.where((s) => s.dish.id == dish.id).firstOrNull;
            
            return _buildDishCard(dish, selectedDish, theme);
          },
        ),
      ],
    );
  }

  Widget _buildDishCard(Dish dish, SelectedDish? selectedDish, ThemeData theme) {
    final isSelected = selectedDish != null;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _toggleDishSelection(dish),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Row(
            children: [
              // Dish image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: dish.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(dish.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: dish.imageUrl == null
                      ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                      : null,
                ),
                child: dish.imageUrl == null
                    ? Icon(
                        Icons.restaurant,
                        color: theme.colorScheme.primary,
                        size: 32,
                      )
                    : null,
              ),
              AppSpacing.horizontalSpace16,
              
              // Dish details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            dish.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (dish.isPopular)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.tertiary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Populær', // Popular
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onTertiary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (dish.description != null) ...[
                      AppSpacing.verticalSpace4,
                      Text(
                        dish.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    AppSpacing.verticalSpace8,
                    
                    // Dietary info and time
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _buildInfoChip(
                          '${dish.preparationTimeMinutes} min',
                          Icons.access_time,
                          theme,
                        ),
                        if (dish.isVegan)
                          _buildInfoChip('Vegansk', Icons.eco, theme),
                        if (dish.isVegetarian && !dish.isVegan)
                          _buildInfoChip('Vegetar', Icons.eco_outlined, theme),
                        if (dish.isGlutenFree)
                          _buildInfoChip('Glutenfri', Icons.no_food, theme),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Selection controls
              if (isSelected) ...[
                AppSpacing.horizontalSpace16,
                Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _decrementDishQuantity(dish),
                          icon: const Icon(Icons.remove_circle_outline),
                          iconSize: 24,
                          color: theme.colorScheme.primary,
                        ),
                        Text(
                          '${selectedDish!.quantity}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _incrementDishQuantity(dish),
                          icon: const Icon(Icons.add_circle_outline),
                          iconSize: 24,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ] else ...[
                AppSpacing.horizontalSpace16,
                Icon(
                  Icons.add_circle_outline,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomDishSection(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.restaurant_menu,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                AppSpacing.horizontalSpace12,
                Expanded(
                  child: Text(
                    'Tilpasset ret', // Custom dish
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      showCustomDishForm = !showCustomDishForm;
                    });
                  },
                  child: Text(
                    showCustomDishForm ? 'Skjul' : 'Anmod', // Hide : Request
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                ),
              ],
            ),
            AppSpacing.verticalSpace8,
            Text(
              'Har du ønsker til en specifik ret? Beskriv det her, og kokken vil vurdere det.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            
            if (showCustomDishForm) ...[
              AppSpacing.verticalSpace16,
              _buildCustomDishForm(theme),
            ],
            
            if (customDishRequest != null) ...[
              AppSpacing.verticalSpace16,
              _buildCustomDishSummary(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCustomDishForm(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _customDishNameController,
          decoration: InputDecoration(
            labelText: 'Retnavn', // Dish name
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
        AppSpacing.verticalSpace12,
        
        TextField(
          controller: _customDishDescriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Beskrivelse', // Description
            hintText: 'Beskriv den ret du gerne vil have...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
        AppSpacing.verticalSpace16,
        
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _saveCustomDishRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Gem anmodning'), // Save request
              ),
            ),
            AppSpacing.horizontalSpace12,
            TextButton(
              onPressed: () {
                setState(() {
                  showCustomDishForm = false;
                  _clearCustomDishForm();
                });
              },
              child: const Text('Annuller'), // Cancel
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomDishSummary(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              AppSpacing.horizontalSpace8,
              Expanded(
                child: Text(
                  'Tilpasset ret anmodet', // Custom dish requested
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    customDishRequest = null;
                    _clearCustomDishForm();
                  });
                },
                child: const Text('Fjern'), // Remove
              ),
            ],
          ),
          AppSpacing.verticalSpace8,
          Text(
            customDishRequest!.name,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (customDishRequest!.description.isNotEmpty) ...[
            AppSpacing.verticalSpace4,
            Text(
              customDishRequest!.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectionSummary(ThemeData theme) {
    final totalPreparationTime = selectedDishes.fold(0, (sum, dish) => sum + dish.totalPreparationTimeMinutes) + 
        (customDishRequest?.estimatedPreparationTimeMinutes ?? 0);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Valgte retter', // Selected dishes
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            AppSpacing.verticalSpace12,
            
            // Selected dishes
            ...selectedDishes.map((selectedDish) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${selectedDish.dish.name} ${selectedDish.quantity > 1 ? '(${selectedDish.quantity}x)' : ''}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    '${selectedDish.totalPreparationTimeMinutes} min',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            )),
            
            // Custom dish
            if (customDishRequest != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        customDishRequest!.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    Text(
                      '${customDishRequest!.estimatedPreparationTimeMinutes} min',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Total tilberedningstid', // Total preparation time
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '$totalPreparationTime min',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions(ThemeData theme) {
    final hasSelection = selectedDishes.isNotEmpty || customDishRequest != null;
    
    return Container(
      padding: AppSpacing.screenPaddingHorizontal.copyWith(
        top: AppSpacing.space16,
        bottom: AppSpacing.space24,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'Fortsæt', // Continue
              onPressed: hasSelection ? () {
                widget.onSelectionComplete(selectedDishes, customDishRequest);
              } : null,
              variant: ButtonVariant.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleDishSelection(Dish dish) {
    final existingIndex = selectedDishes.indexWhere((s) => s.dish.id == dish.id);
    
    setState(() {
      if (existingIndex >= 0) {
        selectedDishes.removeAt(existingIndex);
      } else {
        selectedDishes.add(SelectedDish(dish: dish));
      }
    });
  }

  void _incrementDishQuantity(Dish dish) {
    final existingIndex = selectedDishes.indexWhere((s) => s.dish.id == dish.id);
    if (existingIndex >= 0) {
      setState(() {
        selectedDishes[existingIndex] = selectedDishes[existingIndex].copyWith(
          quantity: selectedDishes[existingIndex].quantity + 1,
        );
      });
    }
  }

  void _decrementDishQuantity(Dish dish) {
    final existingIndex = selectedDishes.indexWhere((s) => s.dish.id == dish.id);
    if (existingIndex >= 0) {
      final currentQuantity = selectedDishes[existingIndex].quantity;
      setState(() {
        if (currentQuantity > 1) {
          selectedDishes[existingIndex] = selectedDishes[existingIndex].copyWith(
            quantity: currentQuantity - 1,
          );
        } else {
          selectedDishes.removeAt(existingIndex);
        }
      });
    }
  }

  void _saveCustomDishRequest() {
    if (_customDishNameController.text.isNotEmpty && 
        _customDishDescriptionController.text.isNotEmpty) {
      setState(() {
        customDishRequest = CustomDishRequest(
          name: _customDishNameController.text,
          description: _customDishDescriptionController.text,
          estimatedPreparationTimeMinutes: _customDishTimeMinutes,
          allergens: _customDishAllergens,
          dietaryRequirements: _customDishDietaryRequirements,
          additionalNotes: _customDishNotesController.text.isNotEmpty 
              ? _customDishNotesController.text 
              : null,
        );
        showCustomDishForm = false;
      });
    }
  }

  void _clearCustomDishForm() {
    _customDishNameController.clear();
    _customDishDescriptionController.clear();
    _customDishNotesController.clear();
    _customDishTimeMinutes = 60;
    _customDishAllergens = [];
    _customDishDietaryRequirements = [];
  }
}