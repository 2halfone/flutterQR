import 'package:flutter/material.dart';
import 'dart:math' as math;

class MenuItem {
  final String id;
  final String label;
  final String value;

  MenuItem({required this.id, required this.label, required this.value});
}

class MenuAnimation extends StatefulWidget {
  final List<MenuItem> items;
  final String label;
  final String value;
  final Function(String) onChange;
  final EdgeInsetsGeometry padding;

  const MenuAnimation({
    Key? key,
    required this.items,
    required this.label,
    required this.value,
    required this.onChange,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  @override
  State<MenuAnimation> createState() => _MenuAnimationState();
}

class _MenuAnimationState extends State<MenuAnimation> {
  bool _isOpen = false;
  late OverlayEntry _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _key = GlobalKey();

  MenuItem? get selectedItem {
    return widget.items.firstWhere(
      (item) => item.value == widget.value,
      orElse: () => MenuItem(id: '', label: 'Select an option', value: ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          CompositedTransformTarget(
            link: _layerLink,
            child: GestureDetector(
              key: _key,
              onTap: _toggleDropdown,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 18,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          selectedItem?.label ?? 'Select an option',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    AnimatedRotation(
                      turns: _isOpen ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _overlayEntry.remove();
      setState(() => _isOpen = false);
    } else {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry);
      setState(() => _isOpen = true);
    }
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox = _key.currentContext!.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    
    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 5),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: math.min(300, widget.items.length * 50),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  final bool isSelected = item.value == widget.value;
                  
                  return InkWell(
                    onTap: () {
                      widget.onChange(item.value);
                      _toggleDropdown();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
                        border: Border(
                          bottom: BorderSide(
                            color: index == widget.items.length - 1 
                                ? Colors.transparent 
                                : Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.label,
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check,
                              color: Colors.blue,
                              size: 18,
                            ),
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
  }

  @override
  void dispose() {
    if (_isOpen) {
      _overlayEntry.remove();
    }
    super.dispose();
  }
}