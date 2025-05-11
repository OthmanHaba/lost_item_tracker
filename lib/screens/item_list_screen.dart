import 'package:flutter/cupertino.dart';
import 'dart:io';
import '../models/item.dart';
import '../utils/storage_service.dart';
import 'add_edit_item_screen.dart';
import 'item_details_screen.dart';
import 'profile_screen.dart';

class ItemListScreen extends StatefulWidget {
  final StorageService storageService;

  const ItemListScreen({super.key, required this.storageService});

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  List<Item> _items = [];
  List<Item> _filteredItems = [];
  bool _isLoading = true;
  String _searchQuery = '';
  bool _showOnlyLost = false;
  bool _showOnlyFound = false;
  bool _showRecovered = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    final items = await widget.storageService.getItems();
    setState(() {
      _items = items;
      _applyFilters();
      _isLoading = false;
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredItems = _items.where((item) {
        final matchesSearch = _searchQuery.isEmpty ||
            item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item.type.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item.area.toLowerCase().contains(_searchQuery.toLowerCase());
        
        final matchesStatus = (!_showOnlyLost && !_showOnlyFound && !_showRecovered) ||
            (_showOnlyLost && item.isLost && !item.recovered) ||
            (_showOnlyFound && !item.isLost && !item.recovered) ||
            (_showRecovered && item.recovered);

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Lost Item Tracker'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.person_circle),
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.add),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => AddEditItemScreen(
                      storageService: widget.storageService,
                    ),
                  ),
                );
                if (result == true) {
                  _loadItems();
                }
              },
            ),
          ],
        ),
      ),
      child: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CupertinoSearchTextField(
                    placeholder: 'Search items...',
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _applyFilters();
                      });
                    },
                  ),
                ),
                if (_isLoading)
                  const Expanded(
                    child: Center(child: CupertinoActivityIndicator()),
                  )
                else if (_filteredItems.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.search,
                            size: 64,
                            color: CupertinoColors.systemGrey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No items yet.\nTap + to add an item.'
                                : 'No items found matching your search.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 17,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        return ItemCard(
                          item: item,
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => ItemDetailsScreen(
                                  item: item,
                                  storageService: widget.storageService,
                                ),
                              ),
                            );
                            if (result == true) {
                              _loadItems();
                            }
                          },
                          onDelete: () async {
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
                              await widget.storageService.deleteItem(item.id);
                              _loadItems();
                            }
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
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
                            size: 48,
                            color: item.recovered
                                ? CupertinoColors.systemGreen
                                : item.isLost
                                    ? CupertinoColors.systemRed
                                    : CupertinoColors.systemGreen,
                          ),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Icon(
                          CupertinoIcons.delete,
                          size: 20,
                          color: CupertinoColors.destructiveRed,
                        ),
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: item.recovered
                              ? CupertinoColors.systemGreen.withOpacity(0.1)
                              : item.isLost
                                  ? CupertinoColors.systemRed.withOpacity(0.1)
                                  : CupertinoColors.systemGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.recovered
                              ? 'Recovered'
                              : item.isLost
                                  ? 'Lost'
                                  : 'Found',
                          style: TextStyle(
                            fontSize: 12,
                            color: item.recovered
                                ? CupertinoColors.systemGreen
                                : item.isLost
                                    ? CupertinoColors.systemRed
                                    : CupertinoColors.systemGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.type,
                          style: const TextStyle(
                            fontSize: 15,
                            color: CupertinoColors.systemGrey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.location,
                        size: 16,
                        color: CupertinoColors.systemGrey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.area,
                          style: const TextStyle(
                            fontSize: 13,
                            color: CupertinoColors.systemGrey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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