import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase initialization info: $e");
  }
  runApp(const LoqmaApp());
}

class LoqmaApp extends StatelessWidget {
  const LoqmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'لقمة - درعا',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        primaryColor: const Color(0xFFFF6B00),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: RestaurantsListScreen(),
      ),
    );
  }
}

// ============================================================================
// 1. شاشة قائمة المطاعم الرئيسية في درعا
// ============================================================================
class RestaurantsListScreen extends StatefulWidget {
  const RestaurantsListScreen({super.key});

  @override
  State<RestaurantsListScreen> createState() => _RestaurantsListScreenState();
}

class _RestaurantsListScreenState extends State<RestaurantsListScreen> {
  String _selectedCategory = 'الكل';
  String _searchQuery = '';

  final List<String> _categories = ['الكل', 'شاورما', 'وجبات سريعة', 'مشاوي', 'بيتزا', 'حلويات'];

  final List<Map<String, dynamic>> _restaurants = [
    {
      'id': 'rest_1',
      'name': 'مطعم البرنس',
      'category': 'شاورما',
      'rating': 4.8,
      'deliveryTime': '20-30 دقيقة',
      'deliveryFee': 5000,
      'imageIcon': Icons.lunch_dining,
      'menu': [
        {'id': 'm1', 'name': 'وجبة شاورما عربي دبل', 'price': 35000, 'desc': 'بطاطا، ثومية، مخلل، كولا'},
        {'id': 'm2', 'name': 'سندويش شاورما سوبر', 'price': 18000, 'desc': 'خبز صاج، ثوم، مخلل'},
        {'id': 'm3', 'name': 'صحن شاورما فرت 500غ', 'price': 45000, 'desc': 'لحم دجاج خالص مع المقبلات'},
      ]
    },
    {
      'id': 'rest_2',
      'name': 'مطعم المذاق الشامي',
      'category': 'مشاوي',
      'rating': 4.7,
      'deliveryTime': '35-50 دقيقة',
      'deliveryFee': 7000,
      'imageIcon': Icons.restaurant,
      'menu': [
        {'id': 'm4', 'name': 'كيلو مشاوي مشكل', 'price': 130000, 'desc': 'كباب، شقف، طاووق، خضار مشوية'},
        {'id': 'm5', 'name': 'وجبة كباب حلبجي', 'price': 42000, 'desc': '4 سيخ كباب مع ربيعة وسلطات'},
        {'id': 'm6', 'name': 'وجبة شيش طاووق', 'price': 38000, 'desc': '3 أسياخ طاووق مع ثومية ومحمرة'},
      ]
    },
    {
      'id': 'rest_3',
      'name': 'بيتزا وكرسبي درعا',
      'category': 'وجبات سريعة',
      'rating': 4.6,
      'deliveryTime': '25-40 دقيقة',
      'deliveryFee': 6000,
      'imageIcon': Icons.local_pizza,
      'menu': [
        {'id': 'm7', 'name': 'بيتزا ببروني عائلي', 'price': 55000, 'desc': 'جبنة موزاريللا وصوص بيتزا إيطالي'},
        {'id': 'm8', 'name': 'وجبة كرسبي 5 قطع', 'price': 36000, 'desc': 'بطاطا، كولسلو، صوص خاص'},
        {'id': 'm9', 'name': 'برغر دبل تشيز', 'price': 30000, 'desc': 'شريحتين لحم بقر مع شيدر وبطاطا'},
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredRestaurants = _restaurants.where((r) {
      final matchesCategory = _selectedCategory == 'الكل' || r['category'] == _selectedCategory;
      final matchesSearch = r['name'].toString().contains(_searchQuery);
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B00),
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.delivery_dining, color: Colors.white, size: 30),
            SizedBox(width: 10),
            Text('لُقمة - توصيل درعا', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        children: [
          // شريط البحث
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFFFF6B00),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'ابحث عن مطعم أو وجبة...',
                prefixIcon: const Icon(Icons.search, color: Colors.orange),
                fillColor: Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
              ),
            ),
          ),

          // تصنيفات المطاعم
          Container(
            height: 55,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFF6B00) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // قائمة المطاعم
          Expanded(
            child: filteredRestaurants.isEmpty
                ? const Center(child: Text('لا توجد مطاعم مطابقة للبحث'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredRestaurants.length,
                    itemBuilder: (context, index) {
                      final rest = filteredRestaurants[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 3,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: RestaurantMenuScreen(restaurant: rest),
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(rest['imageIcon'] as IconData, size: 45, color: const Color(0xFFFF6B00)),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(rest['name'], style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(Icons.star, color: Colors.amber, size: 18),
                                          Text(' ${rest['rating']}  •  ', style: const TextStyle(fontWeight: FontWeight.bold)),
                                          Icon(Icons.access_time, color: Colors.grey[600], size: 16),
                                          Text(' ${rest['deliveryTime']}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text('توصيل: ${rest['deliveryFee']} ل.س', style: const TextStyle(color: Color(0xFFFF6B00), fontSize: 13, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 2. شاشة منيو المطعم واختيار الوجبات
// ============================================================================
class RestaurantMenuScreen extends StatefulWidget {
  final Map<String, dynamic> restaurant;
  const RestaurantMenuScreen({super.key, required this.restaurant});

  @override
  State<RestaurantMenuScreen> createState() => _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends State<RestaurantMenuScreen> {
  final Map<String, int> _cartQuantities = {};

  void _updateQuantity(String itemId, int delta) {
    setState(() {
      final current = _cartQuantities[itemId] ?? 0;
      final newQty = current + delta;
      if (newQty <= 0) {
        _cartQuantities.remove(itemId);
      } else {
        _cartQuantities[itemId] = newQty;
      }
    });
  }

  int get _totalCartItems {
    return _cartQuantities.values.fold(0, (sum, q) => sum + q);
  }

  int get _subtotal {
    int total = 0;
    final menu = widget.restaurant['menu'] as List<dynamic>;
    _cartQuantities.forEach((itemId, qty) {
      final item = menu.firstWhere((m) => m['id'] == itemId);
      total += (item['price'] as int) * qty;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final menu = widget.restaurant['menu'] as List<dynamic>;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B00),
        title: Text(widget.restaurant['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: menu.length,
        itemBuilder: (context, index) {
          final item = menu[index];
          final qty = _cartQuantities[item['id']] ?? 0;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(item['desc'], style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        const SizedBox(height: 8),
                        Text('${item['price']} ل.س', style: const TextStyle(color: Color(0xFFFF6B00), fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                  ),
                  qty == 0
                      ? ElevatedButton(
                          onPressed: () => _updateQuantity(item['id'], 1),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B00),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('إضافة'),
                        )
                      : Row(
                          children: [
                            IconButton(
                              onPressed: () => _updateQuantity(item['id'], -1),
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            ),
                            Text('$qty', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            IconButton(
                              onPressed: () => _updateQuantity(item['id'], 1),
                              icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _totalCartItems > 0
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B00),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$_totalCartItems وجبات مختارة', style: const TextStyle(color: Colors.white, fontSize: 13)),
                      Text('$_subtotal ل.س', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Directionality(
                            textDirection: TextDirection.rtl,
                            child: CartCheckoutScreen(
                              restaurant: widget.restaurant,
                              cartQuantities: _cartQuantities,
                            ),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart_checkout),
                    label: const Text('إتمام الطلب', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFFFF6B00)),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

// ============================================================================
// 3. شاشة السلة ونموذج العنوان وإرسال الطلب
// ============================================================================
class CartCheckoutScreen extends StatefulWidget {
  final Map<String, dynamic> restaurant;
  final Map<String, int> cartQuantities;

  const CartCheckoutScreen({super.key, required this.restaurant, required this.cartQuantities});

  @override
  State<CartCheckoutScreen> createState() => _CartCheckoutScreenState();
}

class _CartCheckoutScreenState extends State<CartCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isSubmitting = false;

  int get _subtotal {
    int total = 0;
    final menu = widget.restaurant['menu'] as List<dynamic>;
    widget.cartQuantities.forEach((itemId, qty) {
      final item = menu.firstWhere((m) => m['id'] == itemId);
      total += (item['price'] as int) * qty;
    });
    return total;
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final menu = widget.restaurant['menu'] as List<dynamic>;
      final List<Map<String, dynamic>> orderItems = [];

      widget.cartQuantities.forEach((itemId, qty) {
        final item = menu.firstWhere((m) => m['id'] == itemId);
        orderItems.add({
          'itemId': itemId,
          'name': item['name'],
          'price': item['price'],
          'quantity': qty,
        });
      });

      final deliveryFee = widget.restaurant['deliveryFee'] as int;
      final grandTotal = _subtotal + deliveryFee;

      // حفظ الطلب في Firebase Firestore
      await FirebaseFirestore.instance.collection('orders').add({
        'restaurantId': widget.restaurant['id'],
        'restaurantName': widget.restaurant['name'],
        'customerName': _nameController.text.trim(),
        'customerPhone': _phoneController.text.trim(),
        'customerAddress': _addressController.text.trim(),
        'notes': _notesController.text.trim(),
        'items': orderItems,
        'subtotal': _subtotal,
        'deliveryFee': deliveryFee,
        'grandTotal': grandTotal,
        'status': 'قيد الانتظار',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // إظهار نتيجه النجاح
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 30),
              SizedBox(width: 8),
              Text('تم إرسال الطلب!'),
            ],
          ),
          content: Text('شكراً ${_nameController.text}! تم تسجيل طلبك بنجاح من ${widget.restaurant['name']}.\nسيتم التواصل معك هاتفياً للتأكيد.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('العودة للرئيسية', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ في إرسال الطلب: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final menu = widget.restaurant['menu'] as List<dynamic>;
    final deliveryFee = widget.restaurant['deliveryFee'] as int;
    final grandTotal = _subtotal
