import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/theme.dart';
import '../../application/menu_notifier.dart';
import '../../data/models/menu_item_model.dart';

/// Categories management screen
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final menuState = ref.watch(menuProvider);
    final categories = menuState.categories;

    // Show error snackbar if there's an error
    ref.listen(menuProvider, (previous, next) {
      if (next.error != null && previous?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(menuProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      appBar: AppBar(
        title: Text('menu.categories'.tr),
        backgroundColor: isDark ? DarkColors.background : LightColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCategoryDialog(isDark),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: Breakpoints.maxContentWidth,
          ),
          child: menuState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : categories.isEmpty
                  ? _buildEmptyState(isDark)
                  : RefreshIndicator(
                      onRefresh: () => ref.read(menuProvider.notifier).refresh(),
                      child: ReorderableListView.builder(
                        padding: EdgeInsets.all(16.w),
                        itemCount: categories.length,
                        onReorder: (oldIndex, newIndex) {
                          ref.read(menuProvider.notifier).reorderCategories(oldIndex, newIndex);
                        },
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final itemCount = menuState.getItemCountForCategory(category.id);
                          return _CategoryTile(
                            key: ValueKey(category.id),
                            category: category,
                            itemCount: itemCount,
                            isDark: isDark,
                            index: index,
                            onEdit: () => _showEditCategoryDialog(isDark, category),
                            onDelete: () => _deleteCategory(category),
                          );
                        },
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 64.sp,
            color: isDark ? DarkColors.textTertiary : LightColors.textTertiary,
          ),
          SizedBox(height: 16.h),
          Text(
            'menu.noCategories'.tr,
            style: TextStyle(
              fontSize: 16.sp,
              color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () => _showAddCategoryDialog(isDark),
            icon: const Icon(Icons.add),
            label: Text('menu.addCategory'.tr),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(bool isDark) {
    final controller = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('menu.addCategory'.tr),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'menu.categoryName'.tr,
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
            enabled: !isLoading,
            onSubmitted: (_) async {
              if (controller.text.isNotEmpty && !isLoading) {
                setDialogState(() => isLoading = true);
                final success = await ref.read(menuProvider.notifier).addCategory(controller.text);
                if (success && dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                } else {
                  setDialogState(() => isLoading = false);
                }
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
              child: Text('common.cancel'.tr),
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (controller.text.isNotEmpty) {
                        setDialogState(() => isLoading = true);
                        final success = await ref.read(menuProvider.notifier).addCategory(controller.text);
                        if (success && dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                        } else {
                          setDialogState(() => isLoading = false);
                        }
                      }
                    },
              child: isLoading
                  ? SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('common.add'.tr),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCategoryDialog(bool isDark, CategoryModel category) {
    final controller = TextEditingController(text: category.name);
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('menu.editCategory'.tr),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'menu.categoryName'.tr,
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
            enabled: !isLoading,
            onSubmitted: (_) async {
              if (controller.text.isNotEmpty && !isLoading) {
                setDialogState(() => isLoading = true);
                final success = await ref.read(menuProvider.notifier).updateCategory(category.id, controller.text);
                if (success && dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                } else {
                  setDialogState(() => isLoading = false);
                }
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
              child: Text('common.cancel'.tr),
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (controller.text.isNotEmpty) {
                        setDialogState(() => isLoading = true);
                        final success = await ref.read(menuProvider.notifier).updateCategory(category.id, controller.text);
                        if (success && dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                        } else {
                          setDialogState(() => isLoading = false);
                        }
                      }
                    },
              child: isLoading
                  ? SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('common.save'.tr),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteCategory(CategoryModel category) {
    final itemCount = ref.read(menuProvider).getItemCountForCategory(category.id);
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('menu.deleteCategory'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('common.actionCannotBeUndone'.tr),
            if (itemCount > 0) ...[
              SizedBox(height: 8.h),
              Text(
                'menu.categoryHasItems'.tr.replaceAll('{count}', itemCount.toString()),
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('common.cancel'.tr),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(menuProvider.notifier).deleteCategory(category.id);
            },
            child: Text('common.delete'.tr, style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    super.key,
    required this.category,
    required this.itemCount,
    required this.isDark,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  final CategoryModel category;
  final int itemCount;
  final bool isDark;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : LightColors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        leading: ReorderableDragStartListener(
          index: index,
          child: Icon(Icons.drag_handle, color: isDark ? DarkColors.textTertiary : LightColors.textTertiary),
        ),
        title: Text(
          category.name,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
          ),
        ),
        subtitle: Text(
          '$itemCount ${'orders.items'.tr}',
          style: TextStyle(
            fontSize: 12.sp,
            color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'edit', child: Text('common.edit'.tr)),
            PopupMenuItem(value: 'delete', child: Text('common.delete'.tr)),
          ],
        ),
      ),
    );
  }
}

