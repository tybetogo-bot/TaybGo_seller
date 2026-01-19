import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/currency/currency.dart';
import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';

/// Currency selection screen
class CurrencyScreen extends ConsumerWidget {
  const CurrencyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyState = ref.watch(currencyProvider);
    final currentCurrency = currencyState.currency;

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      appBar: AppBar(
        title: Text('settings.currency'.tr),
        backgroundColor: isDark ? DarkColors.background : LightColors.background,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: Currencies.all.length,
        itemBuilder: (context, index) {
          final currency = Currencies.all[index];
          final isSelected = currentCurrency.code == currency.code;

          return ListTile(
            title: Text(currency.name),
            subtitle: Text('${currency.code} (${currency.symbol})'),
            trailing: isSelected
                ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                : null,
            onTap: () {
              ref.read(currencyProvider.notifier).setCurrency(currency);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
