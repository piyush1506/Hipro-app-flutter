import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/session/user_session.dart';
import '../data/platform_api_service.dart';
import '../models/ecommerce_product_model.dart';

class EcommerceModuleScreen extends StatefulWidget {
  final String categorySlug;
  final String categoryTitle;
  final Color themeColor;

  const EcommerceModuleScreen({
    super.key,
    required this.categorySlug,
    required this.categoryTitle,
    this.themeColor = const Color(0xFF16A34A),
  });

  @override
  State<EcommerceModuleScreen> createState() => _EcommerceModuleScreenState();
}

class _EcommerceModuleScreenState extends State<EcommerceModuleScreen> {
  final PlatformApiService _apiService = PlatformApiService();
  late Future<PlatformFeedResponse?> _feedFuture;

  String _selectedTag = 'All';
  String _searchQuery = '';
  final Map<String, int> _cartQuantities = {};

  @override
  void initState() {
    super.initState();
    _feedFuture = _apiService.fetchCategoryFeed(widget.categorySlug);
  }

  int get _totalCartCount =>
      _cartQuantities.values.fold(0, (sum, count) => sum + count);

  void _showCartCheckoutSheet(List<EcommerceProduct> allProducts) {
    final cartProducts = allProducts
        .where((p) => (_cartQuantities[p.id] ?? 0) > 0)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final total = cartProducts.fold(
            0.0,
            (sum, p) => sum + (p.price * (_cartQuantities[p.id] ?? 1)),
          );

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.categoryTitle} Basket',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(),
                if (cartProducts.isEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text('Your basket is empty.'),
                    ),
                  )
                ] else ...[
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 280),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: cartProducts.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, idx) {
                        final item = cartProducts[idx];
                        final qty = _cartQuantities[item.id] ?? 1;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: item.imageUrl,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      '₹${item.price.toInt()} / ${item.unit}',
                                      style: const TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 11.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        if (qty > 1) {
                                          _cartQuantities[item.id] = qty - 1;
                                        } else {
                                          _cartQuantities.remove(item.id);
                                        }
                                      });
                                      setSheetState(() {});
                                    },
                                  ),
                                  Text(
                                    '$qty',
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        _cartQuantities[item.id] = qty + 1;
                                      });
                                      setSheetState(() {});
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  // Express Delivery & Address Info
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.bolt_rounded, size: 16, color: Color(0xFFEAB308)),
                            SizedBox(width: 4),
                            Text(
                              'Express 25-30 Min Delivery',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 13, color: Color(0xFF1864E8)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Delivering to: ${UserSession().selectedCity.isNotEmpty ? UserSession().selectedCity : "Bhilwara, Rajasthan"}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF475569),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Payable',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '₹${total.toInt()}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: widget.themeColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final itemsPayload = cartProducts.map((p) => {
                          'productId': p.id,
                          'name': p.name,
                          'price': p.price,
                          'unit': p.unit,
                          'quantity': _cartQuantities[p.id] ?? 1,
                          'imageUrl': p.imageUrl,
                        }).toList();

                        Navigator.pop(ctx);

                        // Call Backend API to register express order
                        final order = await _apiService.placeOrder(
                          categorySlug: widget.categorySlug,
                          categoryTitle: widget.categoryTitle,
                          customerName: UserSession().name ?? 'Valued Customer',
                          customerPhone: UserSession().phone ?? '',
                          deliveryAddress: 'Home • ${UserSession().selectedCity}',
                          city: UserSession().selectedCity.isNotEmpty ? UserSession().selectedCity : 'Bhilwara',
                          items: itemsPayload,
                          totalAmount: total,
                          paymentMethod: 'COD',
                        );

                        if (mounted) {
                          _showOrderSuccessDialog(order, total);
                          setState(() {
                            _cartQuantities.clear();
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.themeColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Confirm & Place Order (Cash on Delivery) →',
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _showOrderSuccessDialog(Map<String, dynamic>? order, double total) {
    final orderNumber = order?['orderNumber'] ?? 'FIB-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final est = order?['estimatedDelivery'] ?? '25 - 30 minutes';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: widget.themeColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: widget.themeColor,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Order Confirmed!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Order ID: #$orderNumber',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Estimated Delivery',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                        Text(
                          est,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Amount to Pay (COD)',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                        Text(
                          '₹${total.toInt()}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.themeColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.categoryTitle,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            Row(
              children: [
                const Icon(Icons.location_on_rounded, size: 11, color: Color(0xFF1864E8)),
                const SizedBox(width: 2),
                Text(
                  UserSession().selectedCity.isNotEmpty ? UserSession().selectedCity : 'Bhilwara',
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF0F172A)),
                onPressed: () async {
                  final feed = await _feedFuture;
                  if (feed != null && mounted) {
                    _showCartCheckoutSheet(feed.products);
                  }
                },
              ),
              if (_totalCartCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: widget.themeColor,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$_totalCartCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<PlatformFeedResponse?>(
        future: _feedFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2.5));
          }

          final feed = snapshot.data;
          final products = feed?.products ?? [];

          // Filter by tag & search
          final filtered = products.where((p) {
            if (_selectedTag != 'All' && p.category != _selectedTag) return false;
            if (_searchQuery.isNotEmpty &&
                !p.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
              return false;
            }
            return true;
          }).toList();

          return Column(
            children: [
              // Search Input
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Search in ${widget.categoryTitle}...',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF64748B)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),

              // Horizontal Category Filter Pills
              if (feed != null && feed.tags.isNotEmpty)
                Container(
                  color: Colors.white,
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: feed.tags.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final tag = feed.tags[idx];
                      final isSelected = tag == _selectedTag;
                      return ChoiceChip(
                        label: Text(tag),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) setState(() => _selectedTag = tag);
                        },
                        selectedColor: widget.themeColor.withValues(alpha: 0.14),
                        backgroundColor: const Color(0xFFF8FAFC),
                        labelStyle: TextStyle(
                          color: isSelected ? widget.themeColor : const Color(0xFF475569),
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          fontSize: 12,
                        ),
                        side: BorderSide(
                          color: isSelected ? widget.themeColor : const Color(0xFFE2E8F0),
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 8),

              // Product Grid
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text(
                              'No products found',
                              style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, idx) {
                          final product = filtered[idx];
                          final qty = _cartQuantities[product.id] ?? 0;

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Thumbnail with Badge
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                      child: CachedNetworkImage(
                                        imageUrl: product.imageUrl,
                                        height: 124,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        placeholder: (_, _) => Shimmer.fromColors(
                                          baseColor: const Color(0xFFE2E8F0),
                                          highlightColor: const Color(0xFFF8FAFC),
                                          child: Container(height: 124, color: Colors.white),
                                        ),
                                        errorWidget: (_, _, _) => Container(
                                          height: 124,
                                          color: const Color(0xFFF1F5F9),
                                          child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                    if (product.discountPercent > 0)
                                      Positioned(
                                        top: 8,
                                        left: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEF4444),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '${product.discountPercent.toInt()}% OFF',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),

                                // Details
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0F172A),
                                          height: 1.25,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        product.unit,
                                        style: const TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Text(
                                            '₹${product.price.toInt()}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w900,
                                              color: widget.themeColor,
                                            ),
                                          ),
                                          if (product.mrp > product.price) ...[
                                            const SizedBox(width: 4),
                                            Text(
                                              '₹${product.mrp.toInt()}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF94A3B8),
                                                decoration: TextDecoration.lineThrough,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // Add to Cart Button or Stepper
                                      qty == 0
                                          ? SizedBox(
                                              width: double.infinity,
                                              height: 32,
                                              child: OutlinedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _cartQuantities[product.id] = 1;
                                                  });
                                                },
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: widget.themeColor,
                                                  side: BorderSide(color: widget.themeColor),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  padding: EdgeInsets.zero,
                                                ),
                                                child: const Text(
                                                  'ADD',
                                                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                                                ),
                                              ),
                                            )
                                          : Container(
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: widget.themeColor,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  IconButton(
                                                    padding: EdgeInsets.zero,
                                                    icon: const Icon(Icons.remove, size: 16, color: Colors.white),
                                                    onPressed: () {
                                                      setState(() {
                                                        if (qty > 1) {
                                                          _cartQuantities[product.id] = qty - 1;
                                                        } else {
                                                          _cartQuantities.remove(product.id);
                                                        }
                                                      });
                                                    },
                                                  ),
                                                  Text(
                                                    '$qty',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    padding: EdgeInsets.zero,
                                                    icon: const Icon(Icons.add, size: 16, color: Colors.white),
                                                    onPressed: () {
                                                      setState(() {
                                                        _cartQuantities[product.id] = qty + 1;
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),

      // Floating Cart Summary Bar
      bottomSheet: _totalCartCount > 0
          ? Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: SafeArea(
                top: false,
                child: ElevatedButton(
                  onPressed: () async {
                    final feed = await _feedFuture;
                    if (feed != null && mounted) {
                      _showCartCheckoutSheet(feed.products);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.themeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.shopping_bag_outlined, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            '$_totalCartCount item${_totalCartCount > 1 ? 's' : ''} added',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const Row(
                        children: [
                          Text(
                            'View Basket',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, size: 16),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

