import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../models/item.dart';
import '../utils/storage_service.dart';

class AddEditItemScreen extends StatefulWidget {
  final StorageService storageService;
  final Item? item; // If provided, we're editing an existing item

  const AddEditItemScreen({
    super.key,
    required this.storageService,
    this.item,
  });

  @override
  State<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends State<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _areaController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLost = true;
  String? _imagePath;
  DateTime _date = DateTime.now();
  final List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nameController.text = widget.item!.name;
      _typeController.text = widget.item!.type;
      _areaController.text = widget.item!.area;
      _descriptionController.text = widget.item!.description;
      _isLost = widget.item!.isLost;
      _imagePath = widget.item!.imagePath;
      _date = widget.item!.date;
      _tags.addAll(widget.item!.tags);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _areaController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      final item = Item(
        id: widget.item?.id ?? const Uuid().v4(),
        name: _nameController.text,
        type: _typeController.text,
        area: _areaController.text,
        date: _date,
        isLost: _isLost,
        description: _descriptionController.text,
        imagePath: _imagePath,
        tags: _tags,
      );

      if (widget.item != null) {
        await widget.storageService.updateItem(item);
      } else {
        await widget.storageService.addItem(item);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'Add Item' : 'Edit Item'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Item Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an item name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _typeController,
              decoration: const InputDecoration(
                labelText: 'Item Type',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an item type';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _areaController,
              decoration: const InputDecoration(
                labelText: 'Area',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an area';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_date.toString().split(' ')[0]),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment<bool>(
                        value: true,
                        label: Text('Lost'),
                        icon: Icon(Icons.hourglass_empty),
                      ),
                      ButtonSegment<bool>(
                        value: false,
                        label: Text('Found'),
                        icon: Icon(Icons.find_in_page),
                      ),
                    ],
                    selected: {_isLost},
                    onSelectionChanged: (Set<bool> newSelection) {
                      setState(() {
                        _isLost = newSelection.first;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: Text(_imagePath == null ? 'Add Image' : 'Change Image'),
            ),
            if (_imagePath != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(_imagePath!),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Text('Failed to load image'),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saveItem,
              child: Text(widget.item == null ? 'Add Item' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
} 