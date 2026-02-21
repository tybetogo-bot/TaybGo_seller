import 'package:teybatseller/features/orders/data/models/order_model.dart';
import 'package:teybatseller/features/menu/data/models/menu_item_model.dart';
import 'package:teybatseller/features/restaurant/data/models/restaurant_model.dart';

class MockDataGenerator {
  static const List<String> _customerNames = [
    'John Smith',
    'Sarah Johnson',
    'Michael Brown',
    'Emma Wilson',
    'David Lee',
    'Maria Garcia',
    'James Martinez',
    'Lisa Anderson',
    'Robert Taylor',
    'Jennifer Thomas',
    'William Moore',
    'Patricia Jackson',
  ];

  static const List<String> _menuItemNames = [
    'Margherita Pizza',
    'Pepperoni Pizza',
    'Chicken Burger',
    'Beef Burger',
    'Caesar Salad',
    'Greek Salad',
    'Pasta Carbonara',
    'Pasta Bolognese',
    'Fish and Chips',
    'Grilled Salmon',
    'Chicken Wings',
    'French Fries',
    'Onion Rings',
    'Garlic Bread',
    'Coca Cola',
    'Orange Juice',
    'Water',
    'Coffee',
    'Tea',
    'Chocolate Cake',
  ];

  /// Generate mock orders for tour demonstration
  static List<OrderModel> generateMockOrders(int count) {
    return List.generate(count, (index) {
      final statusIndex = index % 6;
      final status = _getMockStatus(statusIndex);
      final minutesAgo = index * 10;
      final customerName = _customerNames[index % _customerNames.length];

      return OrderModel(
        id: 'DEMO-${(index + 1).toString().padLeft(3, '0')}',
        customerName: customerName,
        phoneNumber: '${(6601234560 + index)}',
        countryCode: '+43',
        status: status,
        total: _getRandomAmount(index),
        subtotal: _getRandomAmount(index) * 0.9,
        deliveryFee: 2.50,
        createdAt: DateTime.now().subtract(Duration(minutes: minutesAgo)),
        address: _generateMockAddress(index),
        items: _generateMockOrderItems(index),
        restaurant: _generateMockOrderRestaurant(),
        notes: index % 3 == 0 ? 'Please ring the doorbell' : null,
        isManual: false, // Mark as non-manual for tour
      );
    });
  }

  static OrderStatusEnum _getMockStatus(int index) {
    switch (index) {
      case 0:
        return OrderStatusEnum.pending;
      case 1:
        return OrderStatusEnum.accepted;
      case 2:
        return OrderStatusEnum.onTheWay;
      case 3:
      case 4:
        return OrderStatusEnum.delivered;
      case 5:
        return OrderStatusEnum.searchingForDriver;
      default:
        return OrderStatusEnum.pending;
    }
  }

  static double _getRandomAmount(int seed) {
    final amounts = [15.50, 22.00, 18.75, 31.20, 12.50, 45.00, 28.90, 19.99, 35.50, 41.00];
    return amounts[seed % amounts.length];
  }

  static List<OrderItemModel> _generateMockOrderItems(int seed) {
    final itemCount = (seed % 3) + 1;
    return List.generate(itemCount, (index) {
      return OrderItemModel(
        id: 'item_${seed}_$index',
        menuItemId: 'menu_$index',
        name: _menuItemNames[((seed + index) * 3) % _menuItemNames.length],
        quantity: index % 2 == 0 ? 1 : 2,
        unitPrice: 8.50 + (index * 2.5),
        notes: index == 0 ? 'Extra cheese' : null,
      );
    });
  }

  static OrderRestaurantModel _generateMockOrderRestaurant() {
    return const OrderRestaurantModel(
      id: 1,
      name: 'Demo Restaurant',
      phone: '+436601234567',
    );
  }

  static AddressModel _generateMockAddress(int seed) {
    final streets = ['Main Street', 'Oak Avenue', 'Park Road', 'Lake Drive', 'Hill Street'];
    final buildings = ['Building 10', 'Building 15', 'Building 20', 'House 5', 'Apt 3'];

    return AddressModel(
      building: buildings[seed % buildings.length],
      street: streets[seed % streets.length],
      city: 'Vienna',
      postalCode: '1010',
      country: 'Austria',
      latitude: 48.2082 + (seed * 0.001),
      longitude: 16.3738 + (seed * 0.001),
    );
  }

  /// Generate mock menu items for tour demonstration
  static List<MenuItemModel> generateMockMenuItems(int count) {
    return List.generate(count, (index) {
      final isAvailable = index % 4 != 3; // 75% available
      final price = 5.0 + (index * 2.5);
      final categoryId = (index % 6) + 1;

      return MenuItemModel(
        id: 'demo-menu-${index + 1}',
        categoryId: categoryId.toString(),
        name: _menuItemNames[index % _menuItemNames.length],
        nameAr: _getArabicName(index),
        nameDe: _getGermanName(index),
        nameFr: _getFrenchName(index),
        description: 'Delicious ${_menuItemNames[index % _menuItemNames.length]}',
        descriptionAr: 'لذيذ',
        descriptionDe: 'Köstlich',
        descriptionFr: 'Délicieux',
        price: price,
        imageUrl: 'https://via.placeholder.com/300x200?text=${Uri.encodeComponent(_menuItemNames[index % _menuItemNames.length])}',
        isAvailable: isAvailable,
        preparationTime: 15 + (index % 3) * 5,
        createdAt: DateTime.now().subtract(Duration(days: 30 - index)),
      );
    });
  }

  static String _getArabicName(int index) {
    const arabicNames = [
      'بيتزا مارغريتا',
      'بيتزا ببروني',
      'برجر دجاج',
      'برجر لحم',
      'سلطة سيزر',
    ];
    return arabicNames[index % arabicNames.length];
  }

  static String _getGermanName(int index) {
    const germanNames = [
      'Margherita Pizza',
      'Pepperoni Pizza',
      'Hähnchen Burger',
      'Rindfleisch Burger',
      'Caesar Salat',
    ];
    return germanNames[index % germanNames.length];
  }

  static String _getFrenchName(int index) {
    const frenchNames = [
      'Pizza Margherita',
      'Pizza Pepperoni',
      'Burger au Poulet',
      'Burger au Bœuf',
      'Salade César',
    ];
    return frenchNames[index % frenchNames.length];
  }

  /// Generate mock restaurant with today's stats
  static RestaurantModel generateMockRestaurant() {
    return RestaurantModel(
      id: 'demo-restaurant-001',
      name: 'Demo Restaurant',
      description: 'A demonstration restaurant for tour purposes',
      phone: '+436601234567',
      email: 'demo@restaurant.com',
      address: 'Stephansplatz 1, 1010 Vienna, Austria',
      city: 'Vienna',
      country: 'Austria',
      imageUrl: 'https://via.placeholder.com/400x300?text=Demo+Restaurant',
      logoUrl: 'https://via.placeholder.com/150x150?text=Logo',
      status: RestaurantStatus.active,
      isOpen: true,
      deliveryFee: 2.50,
      minimumOrder: 10.00,
      estimatedDeliveryTime: 30,
      todayStats: const RestaurantStats(
        pendingOrders: 3,
        totalOrders: 28,
        totalRevenue: 542.50,
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    );
  }

  /// Generate list of mock categories
  static List<CategoryModel> generateMockCategories() {
    return [
      const CategoryModel(
        id: '1',
        name: 'Pizza',
        nameAr: 'بيتزا',
        nameDe: 'Pizza',
        nameFr: 'Pizza',
        sortOrder: 1,
      ),
      const CategoryModel(
        id: '2',
        name: 'Burgers',
        nameAr: 'برجر',
        nameDe: 'Burger',
        nameFr: 'Burgers',
        sortOrder: 2,
      ),
      const CategoryModel(
        id: '3',
        name: 'Salads',
        nameAr: 'سلطات',
        nameDe: 'Salate',
        nameFr: 'Salades',
        sortOrder: 3,
      ),
      const CategoryModel(
        id: '4',
        name: 'Pasta',
        nameAr: 'معكرونة',
        nameDe: 'Pasta',
        nameFr: 'Pâtes',
        sortOrder: 4,
      ),
      const CategoryModel(
        id: '5',
        name: 'Drinks',
        nameAr: 'مشروبات',
        nameDe: 'Getränke',
        nameFr: 'Boissons',
        sortOrder: 5,
      ),
      const CategoryModel(
        id: '6',
        name: 'Desserts',
        nameAr: 'حلويات',
        nameDe: 'Desserts',
        nameFr: 'Desserts',
        sortOrder: 6,
      ),
    ];
  }
}
