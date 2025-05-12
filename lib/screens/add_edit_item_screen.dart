import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:lost_item_tracker/main.dart';
import '../models/item.dart';
import '../utils/storage_service.dart';

class AddEditItemScreen extends StatefulWidget {
  final StorageService storageService;
  final Item? item;

  const AddEditItemScreen({
    super.key,
    required this.storageService,
    this.item,
  });

  @override
  State<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class CustomText extends Text {
  const CustomText(super.data, {super.key });
  @override
  TextStyle? get style => GoogleFonts.tajawal();
}

class _AddEditItemScreenState extends State<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _areaController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  String? _imagePath;
  bool _isLost = true;
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
      _imagePath = widget.item!.imagePath;
      _isLost = widget.item!.isLost;
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
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  void _addTag() {
    final tag = _tagsController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagsController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _saveItem() async {
    if (_nameController.text.isEmpty ||
        _typeController.text.isEmpty ||
        _areaController.text.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(context.t.missingInformation),
          content: Text(context.t.fillRequiredFields),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: Text(context.t.ok),
            ),
          ],
        ),
      );
      return;
    }

    final item = Item(
      id: widget.item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      type: _typeController.text,
      area: _areaController.text,
      description: _descriptionController.text,
      imagePath: _imagePath,
      isLost: _isLost,
      date: _date,
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: CustomText(widget.item == null ? context.t.addItem : context.t.editItem ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _saveItem,
          child: CustomText(context.t.save),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _imagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(_imagePath!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(CupertinoIcons.photo),
                                );
                              },
                            ),
                          )
                        : const Center(
                            child: Icon(
                              CupertinoIcons.photo,
                              size: 48,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CupertinoSegmentedControl<bool>(
                children:  {
                  true: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: CustomText(context.t.lost),
                  ),
                  false: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: CustomText(context.t.found),
                  ),
                },
                groupValue: _isLost,
                onValueChanged: (value) {
                  setState(() {
                    _isLost = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              Text(
                context.t.itemDetails,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.activeBlue,
                ),
              ),
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: _nameController,
                placeholder: context.t.name,
                style: const TextStyle(
                    color: CupertinoColors.black
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: _typeController,
                placeholder: context.t.type,
                style: const TextStyle(
                    color: CupertinoColors.black
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: _areaController,
                placeholder: context.t.area,
                style: const TextStyle(
                    color: CupertinoColors.black
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: _descriptionController,
                placeholder: context.t.description,
                style: const TextStyle(
                    color: CupertinoColors.black
                ),
                padding: const EdgeInsets.all(12),
                maxLines: 3,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                context.t.date,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.activeBlue,
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final date = await showCupertinoModalPopup<DateTime>(
                    context: context,
                    builder: (context) => Container(
                      height: 216,
                      padding: const EdgeInsets.only(top: 6.0),
                      margin: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      color:
                          CupertinoColors.systemBackground.resolveFrom(context),
                      child: SafeArea(
                        top: false,
                        child: CupertinoDatePicker(
                          initialDateTime: _date,
                          mode: CupertinoDatePickerMode.date,
                          use24hFormat: true,
                          onDateTimeChanged: (DateTime newDate) {
                            setState(() => _date = newDate);
                          },

                        ),
                      ),
                    ),
                  );
                  if (date != null) {
                    setState(() => _date = date);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _date.toString().split(' ')[0],
                        style: const TextStyle(
                          fontSize: 17,
                          color: Colors.black
                        ),
                      ),
                      const Icon(
                        CupertinoIcons.calendar,
                        color: CupertinoColors.systemGrey,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
               Text(
                context.t.tags,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.activeBlue,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CupertinoTextField(
                      controller: _tagsController,
                      placeholder: context.t.addTag,
                      padding: const EdgeInsets.all(12),
                      style: const TextStyle(
                        color: CupertinoColors.black
                      ),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CupertinoButton(
                    padding: const EdgeInsets.all(12),
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(8),
                    onPressed: _addTag,
                    child: const Icon(CupertinoIcons.add),
                  ),
                ],
              ),
              if (_tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 15,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => _removeTag(tag),
                            child: const Icon(
                              CupertinoIcons.xmark_circle_fill,
                              size: 16,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
