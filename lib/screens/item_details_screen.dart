import 'package:flutter/cupertino.dart';
import 'dart:io';
import '../models/item.dart';
import '../utils/storage_service.dart';
import 'add_edit_item_screen.dart';

class ItemDetailsScreen extends StatelessWidget {
  final Item item;
  final StorageService storageService;

  const ItemDetailsScreen({
    super.key,
    required this.item,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Item Details'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.ellipsis),
          onPressed: () {
            showCupertinoModalPopup(
              context: context,
              builder: (context) => CupertinoActionSheet(
                actions: [
                  CupertinoActionSheetAction(
                    onPressed: () async {
                      Navigator.pop(context);
                      final result = await Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => AddEditItemScreen(
                            storageService: storageService,
                            item: item,
                          ),
                        ),
                      );
                      if (result == true) {
                        Navigator.pop(context, true);
                      }
                    },
                    child: const Text('Edit Item'),
                  ),
                  CupertinoActionSheetAction(
                    isDestructiveAction: true,
                    onPressed: () async {
                      Navigator.pop(context);
                      final confirmed = await showCupertinoDialog<bool>(
                        context: context,
                        builder: (context) => CupertinoAlertDialog(
                          title: const Text('Delete Item'),
                          content: const Text(
                              'Are you sure you want to delete this item?'),
                          actions: [
                            CupertinoDialogAction(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            CupertinoDialogAction(
                              isDestructiveAction: true,
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        await storageService.deleteItem(item.id);
                        if (context.mounted) {
                          Navigator.pop(context, true);
                        }
                      }
                    },
                    child: const Text('Delete Item'),
                  ),
                ],
                cancelButton: CupertinoActionSheetAction(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
            );
          },
        ),
      ),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: item.imagePath != null
                      ? Hero(
                        tag:ValueKey("my-image-${item.imagePath}"),
                        child: Image.file(
                            File(item.imagePath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: CupertinoColors.systemGrey6,
                                child: const Center(
                                  child: Icon(CupertinoIcons.photo),
                                ),
                              );
                            },
                          ),
                      )
                      : Container(
                          color: item.recovered
                              ? CupertinoColors.systemGreen.withOpacity(0.1)
                              : item.isLost
                                  ? CupertinoColors.systemRed.withOpacity(0.1)
                                  : CupertinoColors.systemGreen.withOpacity(0.1),
                          child: Center(
                            child: Icon(
                              item.recovered
                                  ? CupertinoIcons.checkmark_circle
                                  : item.isLost
                                      ? CupertinoIcons.time
                                      : CupertinoIcons.checkmark_circle,
                              size: 64,
                              color: item.recovered
                                  ? CupertinoColors.systemGreen
                                  : item.isLost
                                      ? CupertinoColors.systemRed
                                      : CupertinoColors.systemGreen,
                            ),
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: item.recovered
                                  ? CupertinoColors.systemGreen.withOpacity(0.1)
                                  : item.isLost
                                      ? CupertinoColors.systemRed.withOpacity(0.1)
                                      : CupertinoColors.systemGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item.recovered
                                  ? 'Recovered'
                                  : item.isLost
                                      ? 'Lost'
                                      : 'Found',
                              style: TextStyle(
                                color: item.recovered
                                    ? CupertinoColors.systemGreen
                                    : item.isLost
                                        ? CupertinoColors.systemRed
                                        : CupertinoColors.systemGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (!item.recovered && !item.isLost)
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.checkmark_circle,
                                  color: CupertinoColors.systemGreen,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Mark as Recovered',
                                  style: TextStyle(
                                    color: CupertinoColors.systemGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onPressed: () async {
                            final confirmed = await showCupertinoDialog<bool>(
                              context: context,
                              builder: (context) => CupertinoAlertDialog(
                                title: const Text('Mark as Recovered'),
                                content: const Text(
                                    'Are you sure you want to mark this item as recovered?'),
                                actions: [
                                  CupertinoDialogAction(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  CupertinoDialogAction(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Mark as Recovered'),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true) {
                              final updatedItem = item.copyWith(recovered: true);
                              await storageService.updateItem(updatedItem);
                              if (context.mounted) {
                                Navigator.pop(context, true);
                              }
                            }
                          },
                        ),
                      const SizedBox(height: 24),
                      _buildInfoSection(
                        'Details',
                        [
                          _buildInfoRow('Type', item.type),
                          _buildInfoRow('Area', item.area),
                          _buildInfoRow(
                            'Date',
                            item.date.toString().split(' ')[0],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildInfoSection(
                        'Description',
                        [
                          Text(
                            item.description,
                            style: const TextStyle(
                              fontSize: 17,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        ],
                      ),
                      if (item.tags.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _buildInfoSection(
                          'Tags',
                          [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: item.tags.map((tag) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.systemGrey6,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    tag,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: CupertinoColors.systemGrey,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.activeBlue,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 17,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 