import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restro_hub/core/data/database/database_provider.dart';
import 'package:restro_hub/features/auth/data/models/user_address_model.dart';

final userAddressesProvider = FutureProvider<List<UserAddressModel>>((
  ref,
) async {
  final db = await ref.watch(appDatabaseProvider.future);
  final rows = await db.select(db.cachedUserAddresses).get();

  return rows
      .map(
        (row) => UserAddressModel(
          id: row.id,
          userId: '', // Local DB doesn't store userId in this table currently
          label: row.label,
          addressLine1: row.addressLine1,
          addressLine2: row.addressLine2,
          city: row.city,
          state: row.state,
          postalCode: row.postalCode,
          latitude: row.latitude,
          longitude: row.longitude,
          isDefault: row.isDefault,
        ),
      )
      .toList();
});

final defaultAddressProvider = Provider<UserAddressModel>((ref) {
  final addressesAsync = ref.watch(userAddressesProvider);

  return addressesAsync.when(
    data: (addresses) {
      final defaultAddr =
          addresses.where((a) => a.isDefault).firstOrNull ??
          addresses.firstOrNull;
      if (defaultAddr != null) return defaultAddr;
      return _fallbackAddress;
    },
    loading: () => _fallbackAddress,
    error: (_, __) => _fallbackAddress,
  );
});

const _fallbackAddress = UserAddressModel(
  userId: '',
  label: 'Home',
  addressLine1: 'Budhanilkantha-Kathmandu',
  city: 'Nepal',
);
