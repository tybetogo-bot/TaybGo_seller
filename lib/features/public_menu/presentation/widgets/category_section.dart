import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/theme.dart';
import '../../../menu/data/models/menu_item_model.dart';
import '../../../menu/presentation/widgets/public_menu_item_card.dart';

/// Category section widget with expandable items list
class CategorySection extends StatelessWidget {
  final CategoryModel category;
  final List<MenuItemModel> items;
  final Function(MenuItemModel) onItemTap;

  const CategorySection({
    super.key,
    required this.category,
    required this.items,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context);
    final categoryName = category.getLocalizedName(locale.languageCode);

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : LightColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? DarkColors.border : LightColors.border,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 8.h,
          ),
          childrenPadding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            bottom: 16.h,
          ),
          title: Row(
            children: [
              if (category.imageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(6.r),
                  child: Image.network(
                    category.imageUrl!,
                    width: 32.w,
                    height: 32.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.category,
                      size: 24.sp,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
              ],
              Expanded(
                child: Text(
                  categoryName,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? DarkColors.textPrimary
                        : LightColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${items.length}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          children: [
            ...items.map((item) => PublicMenuItemCard(
                  item: item,
                  onTap: () => onItemTap(item),
                )),
          ],
        ),
      ),
    );
  }
}
