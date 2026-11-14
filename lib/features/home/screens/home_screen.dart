import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/network/api_client.dart';
import '../../../core/session/user_session.dart';
import '../../../core/widgets/chat_sheet.dart';
import '../../../main.dart';
import '../../inspections/models/request_model.dart';
import '../../inspections/screens/customer_requests_screen.dart';
import '../../navigation/main_nav_screen.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../offers/models/offer_model.dart';
import '../../offers/screens/offers_screen.dart';
import '../../quotations/models/quotation_model.dart';
import '../../quotations/screens/quotation_details_screen.dart';
import '../../quotations/screens/quotation_screen.dart';
import '../../services/models/service_model.dart';
import '../../services/screens/my_direct_bookings_screen.dart';
import '../../services/widgets/service_subservices_sheet.dart';
import '../../platform/screens/ecommerce_module_screen.dart';
import '../data/service_api_service.dart';
import '../models/slide_model.dart';
import '../../../core/widgets/city_selection_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onOpenDrawer, this.onSwitchTab});

  final VoidCallback? onOpenDrawer;
  final ValueChanged<int>? onSwitchTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  late final TextEditingController _searchController;
  late Future<List<ServiceItem>> _servicesFuture;
  late Future<List<SlideItem>> _slidesFuture;
  late Future<List<OfferItem>> _offersFuture;
  final ServiceApiService _apiService = ServiceApiService(ApiClient());
  bool _isServicesExpanded = true;
  String? _dismissedQuotationId;
  List<ServiceItem> _loadedServices = [];

  Future<List<ServiceItem>> _fetchServicesWithPrecache() {
    final currentCity = UserSession().selectedCity;
    return _apiService.fetchServices(city: currentCity).then((services) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        for (final s in services) {
          if (s.imageUrl.isNotEmpty && s.imageUrl.startsWith('http')) {
            precacheImage(
              CachedNetworkImageProvider(s.imageUrl),
              context,
              onError: (e, s) {},
            );
          }
          for (final sub in s.subServices) {
            if (sub.image != null && sub.image!.isNotEmpty && sub.image!.startsWith('http')) {
              precacheImage(
                CachedNetworkImageProvider(sub.image!),
                context,
                onError: (e, s) {},
              );
            }
          }
        }
      });
      return services;
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _servicesFuture = _fetchServicesWithPrecache();
    _slidesFuture = _apiService.fetchSlides(section: 'services');
    _offersFuture = _apiService.fetchOffers(section: 'services');
    UserSession().selectedCityNotifier.addListener(_onCityChanged);
    appState.fetchRequests();
    appState.fetchQuotations();
    appState.fetchNotifications();
    appState.fetchDirectBookings();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!UserSession().hasSelectedCity && mounted) {
        CitySelectionSheet.show(context);
      }
    });
  }

  void _onCityChanged() {
    if (mounted) {
      _reloadServices();
    }
  }

  @override
  void dispose() {
    UserSession().selectedCityNotifier.removeListener(_onCityChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _reloadServices() {
    setState(() {
      _servicesFuture = _fetchServicesWithPrecache();
      _slidesFuture = _apiService.fetchSlides(section: 'services');
      _offersFuture = _apiService.fetchOffers(section: 'services');
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = UserSession();
    final photo = user.photoUrl;
    final String displayName = (user.name != null && user.name!.isNotEmpty)
        ? user.name!
        : 'User';
    final initials = displayName
        .trim()
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFCFF),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFAFCFF),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEBF2FD), // Soft airy ambient blue at the top
              Color(0xFFF3F7FD), // Gentle transitional tint
              Color(0xFFFAFCFF), // Crisp ultra-light base
              Color(0xFFFAFCFF), // Clean base bottom
            ],
            stops: [0.0, 0.16, 0.45, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Top ambient glowing luminous orbs
            Positioned(
              top: -60,
              left: -40,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF0753ED).withValues(alpha: 0.08),
                      const Color(0xFF0753ED).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: -50,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF38BDF8).withValues(alpha: 0.09),
                      const Color(0xFF38BDF8).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom ambient glowing luminous orbs
            Positioned(
              bottom: -60,
              right: -40,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF0753ED).withValues(alpha: 0.07),
                      const Color(0xFF0753ED).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              left: -50,
              child: Container(
                width: 210,
                height: 210,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF38BDF8).withValues(alpha: 0.08),
                      const Color(0xFF38BDF8).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Main Content
            SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  _reloadServices();
                  await Future.wait([
                    _servicesFuture,
                    _slidesFuture,
                    _offersFuture,
                    appState.fetchRequests(),
                    appState.fetchQuotations(),
                    appState.fetchNotifications(),
                  ]);
                },
                color: const Color(0xFF0753ED),
                backgroundColor: Colors.white,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Top Header: Hindustan Logo + Notifications + User Avatar
                      _buildHindustanHeader(photo, initials),

                      const SizedBox(height: 12),

                      // 2. Location Pill: Bhilwara, Rajasthan
                      _buildLocationPill(context),

                      const SizedBox(height: 12),

                      // 3. Search Bar: Search services, products or experiences...
                      _buildEnhancedSearchBar(),

                      const SizedBox(height: 16),

                      // Quotation Received Alert Card on Home Page (if any)
                      ListenableBuilder(
                        listenable: appState,
                        builder: (context, _) {
                          final latestQuote = appState.latestPendingQuotation;
                          if (latestQuote == null ||
                              latestQuote.id == _dismissedQuotationId) {
                            return const SizedBox.shrink();
                          }
                          final hasMatchingRequest = appState.requests.any(
                            (r) =>
                                r.id == latestQuote.requestId ||
                                r.requestNumber == latestQuote.requestId ||
                                r.requestNumber == latestQuote.quoteNumber,
                          );
                          if (!hasMatchingRequest) {
                            return const SizedBox.shrink();
                          }
                          return _buildQuotationReceivedAlertCard(latestQuote);
                        },
                      ),

                      if (_searchQuery.isEmpty) ...[
                        // 4. Hero Banner ("Build Your Dream with Hipro")
                        _buildHeroBanner(context),

                        const SizedBox(height: 20),

                        // 5. Explore Categories (Hipro, FreshInBasket, Fashion Basket, Adventure)
                        _buildExploreCategoriesSection(context),

                        const SizedBox(height: 20),

                        // 6. Quick Access (My Requests, My Orders, Offers & Deals, Reviews, Support)
                        _buildQuickAccessSection(context),

                        const SizedBox(height: 20),

                        // 7. Side-by-Side Dual Feature Cards ("Popular Services – Hipro" & "Fresh Picks – FreshInBasket")
                        _buildDualFeatureCards(context),

                        const SizedBox(height: 16),

                        // 8. Special Offers for You! Banner
                        _buildSpecialOffersBanner(context),

                        const SizedBox(height: 20),
                      ],

                      // 9. Services Search Results or Directory
                      FutureBuilder<List<ServiceItem>>(
                        future: _servicesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return _buildServicesShimmer();
                          }

                          if (snapshot.hasError) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text(
                                      'Could not load services from backend',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF334155),
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _reloadServices,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            );
                          }

                          final rawAll = snapshot.data ?? [];
                          _loadedServices = rawAll;
                          final allServices = rawAll.where((s) {
                            final lower = s.name.toLowerCase();
                            return !lower.contains('adventure') &&
                                !lower.contains('entertainment') &&
                                !lower.contains('district');
                          }).toList();
                          final filtered = _searchQuery.isEmpty
                              ? allServices
                              : allServices
                                    .where(
                                      (s) =>
                                          s.name.toLowerCase().contains(
                                            _searchQuery.toLowerCase(),
                                          ) ||
                                          s.shortDescription
                                              .toLowerCase()
                                              .contains(
                                                _searchQuery.toLowerCase(),
                                              ),
                                    )
                                    .toList();

                          if (_searchQuery.isNotEmpty) {
                            if (filtered.isEmpty) {
                              return _buildSearchEmptyState();
                            } else {
                              return _buildSearchResultsGrid(filtered);
                            }
                          }

                          return _buildCategoryDirectory(allServices);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePreviewDialog(
    BuildContext context,
    String imageUrl,
    String title,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: Colors.white,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.65,
                ),
                child: InteractiveViewer(
                  maxScale: 4.0,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    fadeInDuration: const Duration(milliseconds: 100),
                    placeholder: (_, _) => SizedBox(
                      height: 220,
                      child: Shimmer.fromColors(
                        baseColor: const Color(0xFFE2E8F0),
                        highlightColor: const Color(0xFFF8FAFC),
                        child: Container(
                          width: double.infinity,
                          height: 220,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    errorWidget: (_, _, _) => const SizedBox(
                      height: 220,
                      child: Center(
                        child: Icon(
                          Icons.broken_image_rounded,
                          size: 48,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Quotation Received Alert Card on Home Page
  Widget _buildQuotationReceivedAlertCard(QuotationModel quote) {
    String? matchedImageUrl;
    ServiceRequestModel? matchedReq;

    // 1. Check matching inspection request photos
    try {
      matchedReq = appState.requests.firstWhere(
        (r) =>
            r.id == quote.requestId ||
            r.requestNumber == quote.requestNumber ||
            r.requestNumber == quote.requestId,
      );
      if (matchedReq.photos.isNotEmpty) {
        matchedImageUrl = matchedReq.photos.first;
      }
    } catch (_) {}

    // 2. Check notification imageUrl
    if (matchedImageUrl == null || matchedImageUrl.isEmpty) {
      try {
        final notif = appState.notifications.firstWhere(
          (n) =>
              n.referenceId == quote.id || n.quoteNumber == quote.quoteNumber,
        );
        if (notif.imageUrl != null && notif.imageUrl!.isNotEmpty) {
          matchedImageUrl = notif.imageUrl;
        }
      } catch (_) {}
    }

    final projectName = quote.title.isNotEmpty
        ? quote.title
        : (matchedReq != null ? matchedReq.subServiceName : '');
    final locationName = quote.location.isNotEmpty
        ? quote.location
        : (matchedReq != null ? matchedReq.address : '');
    final formattedAmount = quote.grandTotal.toStringAsFixed(0);

    final bool hasValidImage = matchedImageUrl != null &&
        matchedImageUrl.isNotEmpty &&
        (matchedImageUrl.startsWith('http://') ||
            matchedImageUrl.startsWith('https://'));

    // Check if the image is a service illustration/PNG vs a camera photo
    final bool isServiceIllustration = hasValidImage &&
        (matchedImageUrl.contains('icon') ||
            matchedImageUrl.contains('service') ||
            matchedImageUrl.endsWith('.png') ||
            _loadedServices.any((s) => s.imageUrl == matchedImageUrl));

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF1864E8).withValues(alpha: 0.2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1864E8).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Alert Header Strip
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(19),
              ),
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF1864E8).withValues(alpha: 0.15),
                  width: 0.8,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1864E8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt_rounded, color: Colors.white, size: 13),
                      SizedBox(width: 3),
                      Text(
                        'NEW QUOTATION',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'You have received a quotation',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _dismissedQuotationId = quote.id;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Card Body
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Prominent Service / Site Image (Enlarged to 94x94 with tap-to-enlarge)
                GestureDetector(
                  onTap: hasValidImage
                      ? () => _showImagePreviewDialog(
                          context,
                          matchedImageUrl!,
                          projectName,
                        )
                      : null,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 94,
                          height: 94,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          padding: isServiceIllustration
                              ? const EdgeInsets.all(8)
                              : EdgeInsets.zero,
                          child: hasValidImage
                              ? CachedNetworkImage(
                                  imageUrl: matchedImageUrl,
                                  width: 94,
                                  height: 94,
                                  fit: isServiceIllustration
                                      ? BoxFit.contain
                                      : BoxFit.cover,
                                  filterQuality: FilterQuality.high,
                                  fadeInDuration: const Duration(milliseconds: 100),
                                  fadeOutDuration: const Duration(milliseconds: 100),
                                  placeholder: (context, url) => Shimmer.fromColors(
                                    baseColor: const Color(0xFFE2E8F0),
                                    highlightColor: const Color(0xFFF8FAFC),
                                    child: Container(
                                      width: 94,
                                      height: 94,
                                      color: Colors.white,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    color: const Color(0xFFEEF2FF),
                                    child: const Icon(
                                      Icons.receipt_long_rounded,
                                      color: Color(0xFF1864E8),
                                      size: 36,
                                    ),
                                  ),
                                )
                              : Container(
                                  color: const Color(0xFFEEF2FF),
                                  child: const Center(
                                    child: Icon(
                                      Icons.receipt_long_rounded,
                                      color: Color(0xFF1864E8),
                                      size: 38,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      if (hasValidImage)
                        Positioned(
                          right: 4,
                          bottom: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A)
                                  .withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.zoom_in_rounded,
                              size: 13,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        projectName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Estimate #${quote.quoteNumber}',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            '₹ $formattedAmount',
                            style: const TextStyle(
                              color: Color(0xFF1864E8),
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'GST Included',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                              ),
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

          // Action Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => QuotationDetailsScreen(
                            quotation: quote,
                            projectName: projectName,
                            location: locationName,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label: const Text(
                      'View Quotation & Scope',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1864E8),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            const QuotationScreen(initialSection: 2),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F172A),
                    side: const BorderSide(
                      color: Color(0xFFCBD5E1),
                      width: 0.8,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 11,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'All Quotes',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 1. Top Header: Hindustan Brand Logo + Notification Bell + User Avatar
  Widget _buildHindustanHeader(String? photo, String initials) {
    return Row(
      children: [
        // Brand Logo
        const _HindustanBrandLogo(size: 38),
        const SizedBox(width: 10),
        // Title & Subtitle
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hindustan',
                style: TextStyle(
                  color: Color(0xFF07358D),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Everything You Need, In One App',
                style: TextStyle(
                  color: Color(0xFF062A79),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Notification Bell Icon with Badge
        ListenableBuilder(
          listenable: appState,
          builder: (context, _) {
            final unreadCount = appState.unreadNotificationsCount;
            final displayCount = unreadCount > 0 ? unreadCount : 2;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const NotificationsScreen(),
                      ),
                    );
                  },
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: Color(0xFF10183F),
                    size: 26,
                  ),
                ),
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$displayCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(width: 6),
        // User Avatar with small chevron down
        InkWell(
          onTap: widget.onOpenDrawer ?? () => widget.onSwitchTab?.call(4),
          borderRadius: BorderRadius.circular(20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0753ED), width: 1.5),
                ),
                child: CircleAvatar(
                  radius: 17,
                  backgroundColor: const Color(0xFFEFF6FF),
                  foregroundImage: (photo != null && photo.isNotEmpty)
                      ? NetworkImage(photo)
                      : null,
                  child: Text(
                    initials.isEmpty ? 'H' : initials,
                    style: const TextStyle(
                      color: Color(0xFF0753ED),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: Color(0xFF10183F),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 2. Location Pill: Bhilwara, Rajasthan
  Widget _buildLocationPill(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: () => CitySelectionSheet.show(context),
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFF),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFDDE5FF), width: 0.8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10183F).withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: Color(0xFF0753ED),
                size: 16,
              ),
              const SizedBox(width: 6),
              ValueListenableBuilder<String>(
                valueListenable: UserSession().selectedCityNotifier,
                builder: (context, city, _) {
                  final displayCity = city.isNotEmpty
                      ? (city.contains(',') ? city : '$city, Rajasthan')
                      : 'Bhilwara, Rajasthan';
                  return Text(
                    displayCity,
                    style: const TextStyle(
                      color: Color(0xFF10183F),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                },
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF10183F),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 3. Hero Banner ("Build Your Dream with Hipro")
  Widget _buildHeroBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 165,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF20458B),
            Color(0xFF214C97),
            Color(0xFF285AAC),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF214C97).withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Construction & Modern Villa Image on the Right
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: MediaQuery.of(context).size.width * 0.54,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: 'https://images.unsplash.com/photo-1541888946425-d0fbb18615f7?auto=format&fit=crop&w=1000&q=80',
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(color: const Color(0xFF20458B)),
                    errorWidget: (_, _, _) => Container(color: const Color(0xFF20458B)),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF20458B),
                          const Color(0xFF20458B).withValues(alpha: 0.35),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.40, 1.0],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Pagination dots at Top Right
            Positioned(
              top: 14,
              right: 16,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 14,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
            // Left Content: Headline + Subtitle + Button
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.4,
                        height: 1.15,
                      ),
                      children: [
                        TextSpan(text: 'Build Your Dream\nwith '),
                        TextSpan(
                          text: 'Hipro',
                          style: TextStyle(color: Color(0xFFFFC51A)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Construction • Renovation • Maintenance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => widget.onSwitchTab?.call(1),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Explore Services',
                            style: TextStyle(
                              color: Color(0xFF10337A),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 13,
                            color: Color(0xFF10337A),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4. Explore Categories (Hipro, FreshInBasket, Fashion Basket, Adventure)
  Widget _buildExploreCategoriesSection(BuildContext context) {
    final categories = [
      {
        'title': 'Hipro',
        'subtitle': 'Construction &\nHome Services',
        'bgColor': const Color(0xFFE2ECFF),
        'borderColor': const Color(0xFFCEDDFF),
        'btnColor': const Color(0xFF0753ED),
        'icon': Icons.apartment_rounded,
        'action': () => widget.onSwitchTab?.call(1),
      },
      {
        'title': 'FreshInBasket',
        'subtitle': 'Fruits & Vegetables',
        'bgColor': const Color(0xFFE4F6E9),
        'borderColor': const Color(0xFFCEEBDA),
        'btnColor': const Color(0xFF0E6289),
        'icon': Icons.shopping_basket_rounded,
        'action': () => _showFreshInBasketSheet(context),
      },
      {
        'title': 'Fashion Basket',
        'subtitle': 'Fashion & Lifestyle',
        'bgColor': const Color(0xFFFBE6F2),
        'borderColor': const Color(0xFFF4D5E7),
        'btnColor': const Color(0xFFD72A60),
        'icon': Icons.checkroom_rounded,
        'action': () => _showFashionBasketSheet(context),
      },
      {
        'title': 'Adventure',
        'subtitle': 'Travel & Experiences',
        'bgColor': const Color(0xFFFFF0DF),
        'borderColor': const Color(0xFFF6DFCA),
        'btnColor': const Color(0xFFC34B13),
        'icon': Icons.terrain_rounded,
        'action': () => MainNavScreen.switchToAdventure(context),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Explore Categories',
              style: TextStyle(
                color: Color(0xFF10183F),
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            InkWell(
              onTap: () => widget.onSwitchTab?.call(1),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View All',
                    style: TextStyle(
                      color: Color(0xFF0753ED),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 3),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFF0753ED),
                    size: 14,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(categories.length, (index) {
            final cat = categories[index];
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index < categories.length - 1 ? 8 : 0,
                ),
                child: InkWell(
                  onTap: cat['action'] as VoidCallback,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
                    decoration: BoxDecoration(
                      color: cat['bgColor'] as Color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: cat['borderColor'] as Color,
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Icon(
                            cat['icon'] as IconData,
                            size: 34,
                            color: cat['btnColor'] as Color,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          cat['title'] as String,
                          style: const TextStyle(
                            color: Color(0xFF10183F),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        SizedBox(
                          height: 26,
                          child: Text(
                            cat['subtitle'] as String,
                            style: const TextStyle(
                              color: Color(0xFF485A86),
                              fontSize: 9.5,
                              height: 1.2,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 13,
                              color: cat['btnColor'] as Color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // 5. Quick Access (My Requests, My Orders, Offers & Deals, Reviews, Support)
  Widget _buildQuickAccessSection(BuildContext context) {
    final items = [
      {
        'title': 'My Requests',
        'icon': Icons.assignment_outlined,
        'color': const Color(0xFF0753ED),
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CustomerRequestsScreen(),
            ),
          );
        },
      },
      {
        'title': 'My Orders',
        'icon': Icons.shopping_bag_outlined,
        'color': const Color(0xFF0753ED),
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const MyDirectBookingsScreen(),
            ),
          );
        },
      },
      {
        'title': 'Offers & Deals',
        'icon': Icons.percent_rounded,
        'color': const Color(0xFF0753ED),
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const OffersScreen(),
            ),
          );
        },
      },
      {
        'title': 'Reviews',
        'icon': Icons.star_rounded,
        'color': const Color(0xFFFFAB00),
        'onTap': () => _showReviewsSheet(context),
      },
      {
        'title': 'Support',
        'icon': Icons.headset_mic_outlined,
        'color': const Color(0xFF0753ED),
        'onTap': () {
          ChatSheet.show(
            context,
            title: 'Hindustan Support 24/7',
            subtitle: 'Real-time assistant & project consultation',
          );
        },
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Access',
          style: TextStyle(
            color: Color(0xFF10183F),
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index < items.length - 1 ? 6 : 0,
                ),
                child: InkWell(
                  onTap: item['onTap'] as VoidCallback,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFDDE5FF)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10183F).withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          size: 24,
                          color: item['color'] as Color,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['title'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF10183F),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // 6. Side-by-Side Dual Feature Cards
  Widget _buildDualFeatureCards(BuildContext context) {
    return Row(
      children: [
        // Card 1: Popular Services - Hipro
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F6FF),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFBBD0FF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Popular Services – Hipro',
                        style: TextStyle(
                          color: Color(0xFF10275D),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: () => widget.onSwitchTab?.call(1),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View All',
                            style: TextStyle(
                              color: Color(0xFF0753ED),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 10,
                            color: Color(0xFF0753ED),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: 'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?auto=format&fit=crop&w=400&q=80',
                        width: 62,
                        height: 62,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(color: Colors.white),
                        errorWidget: (_, _, _) => Container(
                          width: 62,
                          height: 62,
                          color: Colors.white,
                          child: const Icon(Icons.home_work_outlined, color: Color(0xFF0753ED)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Interior Design &\nHome Renovation',
                            style: TextStyle(
                              color: Color(0xFF10183F),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          const Row(
                            children: [
                              Icon(Icons.star_rounded, color: Color(0xFFFFAB00), size: 13),
                              SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  '4.8 (1.2k reviews)',
                                  style: TextStyle(
                                    color: Color(0xFF1C346B),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ElevatedButton(
                            onPressed: () => widget.onSwitchTab?.call(1),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0753ED),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              minimumSize: Size.zero,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text(
                              'Book Now',
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Card 2: Fresh Picks - FreshInBasket
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF2FBF5),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFBBE4D0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Fresh Picks – FreshInBasket',
                        style: TextStyle(
                          color: Color(0xFF0B4126),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: () => _showFreshInBasketSheet(context),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View All',
                            style: TextStyle(
                              color: Color(0xFF008954),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 10,
                            color: Color(0xFF008954),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?auto=format&fit=crop&w=400&q=80',
                        width: 62,
                        height: 62,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(color: Colors.white),
                        errorWidget: (_, _, _) => Container(
                          width: 62,
                          height: 62,
                          color: Colors.white,
                          child: const Icon(Icons.shopping_basket_outlined, color: Color(0xFF008954)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fresh Fruits &\nVegetables',
                            style: TextStyle(
                              color: Color(0xFF10183F),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          const Row(
                            children: [
                              Icon(Icons.star_rounded, color: Color(0xFFFFAB00), size: 13),
                              SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  '4.7 (856 reviews)',
                                  style: TextStyle(
                                    color: Color(0xFF1C346B),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ElevatedButton(
                            onPressed: () => _showFreshInBasketSheet(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF008954),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              minimumSize: Size.zero,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text(
                              'Shop Now',
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 7. Special Offers for You! Banner
  Widget _buildSpecialOffersBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFFFFD6DB),
        border: Border.all(color: const Color(0xFFFCC5CD)),
      ),
      child: Row(
        children: [
          // 3D Gift Box
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF08A),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.card_giftcard_rounded,
                color: Color(0xFFDC2626),
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Special Offers for You!',
                  style: TextStyle(
                    color: Color(0xFF10183F),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Save more across all categories',
                  style: TextStyle(
                    color: Color(0xFF485A86),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const OffersScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8242B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Explore Offers',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                ),
                SizedBox(width: 3),
                Icon(Icons.arrow_forward_rounded, size: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Dynamic Gateways for FreshInBasket & Fashion Basket
  void _showFreshInBasketSheet(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EcommerceModuleScreen(
          categorySlug: 'freshinbasket',
          categoryTitle: 'FreshInBasket',
          themeColor: Color(0xFF16A34A),
        ),
      ),
    );
  }

  void _showFashionBasketSheet(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EcommerceModuleScreen(
          categorySlug: 'fashion_basket',
          categoryTitle: 'Fashion Basket',
          themeColor: Color(0xFFDB2777),
        ),
      ),
    );
  }

  void _showReviewsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 30),
                SizedBox(width: 8),
                Text(
                  '4.8',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                ),
                SizedBox(width: 8),
                Text(
                  '• 1,240+ Verified Customer Reviews',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildReviewItem('Rajesh Sharma', 'Electrical & Switchboard Repair', 'Engineer arrived within 45 mins. Very polite and thoroughly fixed all loose connections.', 5),
            const Divider(height: 20),
            _buildReviewItem('Priya Verma', 'Plumbing & Water Leakage', 'Clean workmanship. Transparent pricing with complete digital quote receipt.', 5),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(String author, String service, String text, int stars) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(author, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
            Row(
              children: List.generate(
                stars,
                (_) => const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(service, style: const TextStyle(color: Color(0xFF1864E8), fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(color: Color(0xFF475569), fontSize: 12.5)),
      ],
    );
  }

  // Pill-styled search bar matching the provided design
  Widget _buildEnhancedSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFDDE5FF)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10183F).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val.trim()),
        style: const TextStyle(
          color: Color(0xFF10183F),
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF485A86),
            size: 21,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  splashRadius: 18,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF485A86),
                    size: 18,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          hintText: 'Search services, products or experiences...',
          hintStyle: const TextStyle(
            color: Color(0xFF485A86),
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  // Helpful Empty State when no results match query
  Widget _buildSearchEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: Color(0xFF94A3B8),
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No services found for "$_searchQuery"',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Try searching with general keywords like "Waterproofing", "Leakage", or "Civil"',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                child: const Text('View All Services'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  _searchController.text = 'Waterproofing';
                  setState(() => _searchQuery = 'Waterproofing');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1864E8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Try Waterproofing',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. Informative, High-Clarity Search Results Card List
  Widget _buildSearchResultsGrid(List<ServiceItem> services) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDDE5FF)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10183F).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with count & clear button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.manage_search_rounded,
                    color: Color(0xFF0753ED),
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Search Results (${services.length})',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF10183F),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'Clear Search',
                    style: TextStyle(
                      color: Color(0xFF0753ED),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Informative Vertical Service Cards
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: services.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final service = services[index];
              return Material(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: () {
                    ServiceSubservicesSheet.show(context, service: service);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFDDE5FF)),
                    ),
                    child: Row(
                      children: [
                        // Service Image Thumbnail
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 80,
                            height: 80,
                            color: const Color(0xFFEFF6FF),
                            padding: (service.imageUrl.isNotEmpty && !service.imageUrl.contains('cdn-icons-png'))
                                ? EdgeInsets.zero
                                : const EdgeInsets.all(8),
                            child: service.imageUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: service.imageUrl,
                                    fit: service.imageUrl.contains('cdn-icons-png')
                                        ? BoxFit.contain
                                        : BoxFit.cover,
                                    filterQuality: FilterQuality.high,
                                    fadeInDuration: const Duration(milliseconds: 100),
                                    fadeOutDuration: const Duration(milliseconds: 100),
                                    placeholder: (_, _) => Shimmer.fromColors(
                                      baseColor: const Color(0xFFE2E8F0),
                                      highlightColor: const Color(0xFFF8FAFC),
                                      child: Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.white,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(
                                          Icons.construction_rounded,
                                          color: Color(0xFF0753ED),
                                          size: 30,
                                        ),
                                  )
                                : const Icon(
                                    Icons.construction_rounded,
                                    color: Color(0xFF0753ED),
                                    size: 30,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Service Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.name,
                                style: const TextStyle(
                                  color: Color(0xFF10183F),
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (service.shortDescription.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(
                                  service.shortDescription,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF485A86),
                                    fontSize: 11.5,
                                    height: 1.25,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Book Action Button
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0753ED),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0753ED)
                                    .withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Book',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 3),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 13,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 4. All Categories Directory (MakeMyTrip style browser)
  Widget _buildCategoryDirectory(List<ServiceItem> services) {
    if (services.isEmpty) return const SizedBox.shrink();

    final topServices = services.take(3).toList();
    final gridServices = services.length > 3
        ? services.skip(3).toList()
        : services;
    final displayedGrid = _isServicesExpanded
        ? gridServices
        : gridServices.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top 3 High-Priority Services
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFDDE5FF)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10183F).withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: topServices.map((service) {
              return Expanded(child: _buildTopServiceCard(service));
            }).toList(),
          ),
        ),

        const SizedBox(height: 14),

        // Full Services Expandable Card
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 18, 14, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFDDE5FF)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10183F).withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayedGrid.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.67,
                  ),
                  itemBuilder: (context, index) {
                    final s = displayedGrid[index];
                    return _buildGridServiceItem(s);
                  },
                ),

                if (gridServices.length > 6) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isServicesExpanded = !_isServicesExpanded;
                      });
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _isServicesExpanded
                                ? 'Show Less'
                                : 'View All (${gridServices.length} Services)',
                            style: const TextStyle(
                              color: Color(0xFF0753ED),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            _isServicesExpanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: const Color(0xFF0753ED),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Skeleton Shimmer for Dynamic Services Loading State
  Widget _buildServicesShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 140,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            Container(
              width: 60,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Shimmer.fromColors(
          baseColor: const Color(0xFFE2E8F0),
          highlightColor: const Color(0xFFF8FAFC),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.5,
            ),
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 22),
      ],
    );
  }

  // 1. Top Prominent Service Card (Clean, borderless with tactile ripple)
  Widget _buildTopServiceCard(ServiceItem service) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          ServiceSubservicesSheet.show(context, service: service);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFDDE5FF)),
                  ),
                  padding: (service.imageUrl.isNotEmpty && !service.imageUrl.contains('cdn-icons-png'))
                      ? EdgeInsets.zero
                      : const EdgeInsets.all(8),
                  child: service.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: service.imageUrl,
                          fit: service.imageUrl.contains('cdn-icons-png')
                              ? BoxFit.contain
                              : BoxFit.cover,
                          filterQuality: FilterQuality.high,
                          fadeInDuration: const Duration(milliseconds: 100),
                          fadeOutDuration: const Duration(milliseconds: 100),
                          placeholder: (_, _) => Shimmer.fromColors(
                            baseColor: const Color(0xFFE2E8F0),
                            highlightColor: const Color(0xFFF8FAFC),
                            child: Container(
                              width: 88,
                              height: 88,
                              color: Colors.white,
                            ),
                          ),
                          errorWidget: (_, _, _) => const Icon(
                            Icons.construction_rounded,
                            color: Color(0xFF0753ED),
                            size: 38,
                          ),
                        )
                      : const Icon(
                          Icons.construction_rounded,
                          color: Color(0xFF0753ED),
                          size: 38,
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                service.name,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF10183F),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 2. MakeMyTrip Style 3-Column Grid Service Item (With touch ripple)
  Widget _buildGridServiceItem(ServiceItem service) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          ServiceSubservicesSheet.show(context, service: service);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFDDE5FF)),
                  ),
                  padding: (service.imageUrl.isNotEmpty && !service.imageUrl.contains('cdn-icons-png'))
                      ? EdgeInsets.zero
                      : const EdgeInsets.all(8),
                  child: service.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: service.imageUrl,
                          fit: service.imageUrl.contains('cdn-icons-png')
                              ? BoxFit.contain
                              : BoxFit.cover,
                          filterQuality: FilterQuality.high,
                          fadeInDuration: const Duration(milliseconds: 100),
                          fadeOutDuration: const Duration(milliseconds: 100),
                          placeholder: (_, _) => Shimmer.fromColors(
                            baseColor: const Color(0xFFE2E8F0),
                            highlightColor: const Color(0xFFF8FAFC),
                            child: Container(
                              width: 88,
                              height: 88,
                              color: Colors.white,
                            ),
                          ),
                          errorWidget: (_, _, _) => const Icon(
                            Icons.build_circle_outlined,
                            color: Color(0xFF0753ED),
                            size: 38,
                          ),
                        )
                      : const Icon(
                          Icons.build_circle_outlined,
                          color: Color(0xFF0753ED),
                          size: 38,
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                service.name,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF10183F),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HindustanBrandLogo extends StatelessWidget {
  final double size;
  const _HindustanBrandLogo({this.size = 38});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HindustanBrandLogoPainter(),
      ),
    );
  }
}

class _HindustanBrandLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Left vertical bar (Gradient cyan to royal blue)
    final leftPath = Path()
      ..moveTo(0, h * 0.12)
      ..lineTo(w * 0.36, 0)
      ..lineTo(w * 0.36, h * 0.88)
      ..lineTo(0, h)
      ..close();

    final leftPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF38BDF8), Color(0xFF1D4ED8)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w * 0.36, h));
    canvas.drawPath(leftPath, leftPaint);

    // Right vertical bar (Gradient royal blue to deep navy)
    final rightPath = Path()
      ..moveTo(w * 0.64, 0)
      ..lineTo(w, h * 0.12)
      ..lineTo(w, h)
      ..lineTo(w * 0.64, h * 0.88)
      ..close();

    final rightPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1D4ED8), Color(0xFF1E3A8A)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(w * 0.64, 0, w * 0.36, h));
    canvas.drawPath(rightPath, rightPaint);

    // Connecting horizontal chevron crossbar
    final centerPath = Path()
      ..moveTo(w * 0.36, h * 0.38)
      ..lineTo(w * 0.64, h * 0.38)
      ..lineTo(w * 0.64, h * 0.62)
      ..lineTo(w * 0.36, h * 0.62)
      ..close();

    final centerPaint = Paint()..color = const Color(0xFF2563EB);
    canvas.drawPath(centerPath, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
