import 'package:flutter/material.dart';
import 'dart:async';
import '../services/dawa_address_service.dart';

class AddressAutocompleteField extends StatefulWidget {
  final String? initialValue;
  final Function(DawaAddress) onAddressSelected;
  final String hintText;
  final String labelText;
  final bool enabled;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  const AddressAutocompleteField({
    super.key,
    this.initialValue,
    required this.onAddressSelected,
    this.hintText = 'Indtast adresse...',
    this.labelText = 'Adresse',
    this.enabled = true,
    this.controller,
    this.focusNode,
  });

  @override
  State<AddressAutocompleteField> createState() => _AddressAutocompleteFieldState();
}

class _AddressAutocompleteFieldState extends State<AddressAutocompleteField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<DawaAddress> _suggestions = [];
  Timer? _debounceTimer;
  bool _isLoading = false;
  DawaAddress? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _removeOverlay();
    if (widget.controller == null) _controller.dispose();
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    print('Address field text changed: ${_controller.text}');
    
    // If text was changed programmatically after selection, don't search
    if (_selectedAddress != null && _controller.text == _selectedAddress!.tekst) {
      return;
    }
    
    _selectedAddress = null;
    _debounceTimer?.cancel();
    
    if (_controller.text.length < 3) {
      print('Text too short for search (${_controller.text.length} chars)');
      _removeOverlay();
      return;
    }

    print('Scheduling address search in 500ms...');
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchAddresses(_controller.text);
    });
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      // Delay removing overlay to allow tap on suggestions
      Future.delayed(const Duration(milliseconds: 200), () {
        _removeOverlay();
      });
    }
  }

  Future<void> _searchAddresses(String query) async {
    print('Searching for address: $query');
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final addresses = await DawaAddressService.searchAddresses(query);
      
      if (!mounted) return;
      
      print('Got ${addresses.length} suggestions');
      
      setState(() {
        _suggestions = addresses;
        _isLoading = false;
      });

      if (_suggestions.isNotEmpty && _focusNode.hasFocus) {
        print('Showing overlay with suggestions');
        _showOverlay();
      } else {
        print('No suggestions or focus lost, removing overlay');
        _removeOverlay();
      }
    } catch (e) {
      print('Error searching addresses: $e');
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        _suggestions = [];
      });
      _removeOverlay();
    }
  }

  void _selectAddress(DawaAddress address) {
    setState(() {
      _selectedAddress = address;
      _controller.text = address.tekst;
      _suggestions = [];
    });
    
    widget.onAddressSelected(address);
    _removeOverlay();
    _focusNode.unfocus();
  }

  void _showOverlay() {
    _removeOverlay();
    
    // Get the render box to calculate width
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    final double width = renderBox?.size.width ?? 300;
    
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 50),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        final address = _suggestions[index];
                        final isLast = index == _suggestions.length - 1;
                        
                        return InkWell(
                          onTap: () => _selectAddress(address),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: !isLast
                                  ? Border(
                                      bottom: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline
                                            .withOpacity(0.1),
                                      ),
                                    )
                                  : null,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  address.tekst.isNotEmpty ? address.tekst : '${address.vejnavn} ${address.husnr}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (address.postnr.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    '${address.postnr} ${address.postnrnavn}${address.kommune.isNotEmpty ? ', ${address.kommune}' : ''}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          prefixIcon: const Icon(Icons.location_on_outlined),
          suffixIcon: _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : _selectedAddress != null
                  ? IconButton(
                      icon: const Icon(Icons.check_circle),
                      color: Colors.green,
                      onPressed: null,
                    )
                  : _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _controller.clear();
                            _selectedAddress = null;
                            _removeOverlay();
                          },
                        )
                      : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
          ),
          filled: true,
          fillColor: theme.colorScheme.surface,
        ),
      ),
    );
  }
}