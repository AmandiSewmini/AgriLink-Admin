import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/price_service.dart';
import '../models/market_price_model.dart';
import '../utils/app_colors.dart';
import 'admin_login_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final _authService = AuthService();
  final _priceService = PriceService();

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  Future<void> _handleLogout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AdminLoginView()),
      );
    }
  }

  void _showAddPriceDialog([MarketPriceModel? existingPrice]) {
    final formKey = GlobalKey<FormState>();
    final cropController = TextEditingController(text: existingPrice?.cropName ?? '');
    final wholesaleController = TextEditingController(
      text: existingPrice?.wholesalePrice.toString() ?? '',
    );
    final retailController = TextEditingController(
      text: existingPrice?.retailPrice.toString() ?? '',
    );
    final marketController = TextEditingController(text: existingPrice?.market ?? 'Dambulla');
    String selectedUnit = existingPrice?.unit ?? 'kg';
    double fairPrice = 0;

    void calculateFairPrice() {
      final wholesale = double.tryParse(wholesaleController.text) ?? 0;
      final retail = double.tryParse(retailController.text) ?? 0;
      fairPrice = MarketPriceModel.calculateFairPrice(wholesale, retail);
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.agriLinkGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  existingPrice == null ? Icons.add_circle_outline : Icons.edit_outlined,
                  color: AppColors.agriLinkGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  existingPrice == null ? 'Add Market Price' : 'Update Market Price',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: cropController,
                    decoration: const InputDecoration(
                      labelText: 'Crop Name',
                      hintText: 'e.g., Beans, Tomato',
                    ),
                    enabled: existingPrice == null,
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: wholesaleController,
                    decoration: const InputDecoration(
                      labelText: 'Wholesale Price (LKR)',
                      prefixText: 'Rs ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    onChanged: (_) {
                      setDialogState(() => calculateFairPrice());
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: retailController,
                    decoration: const InputDecoration(
                      labelText: 'Retail Price (LKR)',
                      prefixText: 'Rs ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    onChanged: (_) {
                      setDialogState(() => calculateFairPrice());
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: marketController,
                    decoration: const InputDecoration(
                      labelText: 'Market',
                      hintText: 'e.g., Dambulla',
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedUnit,
                    decoration: const InputDecoration(labelText: 'Unit'),
                    items: ['kg', 'g', 'item']
                        .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() => selectedUnit = value ?? 'kg');
                    },
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.agriLinkGreen.withOpacity(0.1),
                          AppColors.agriLinkGreen.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.agriLinkGreen.withOpacity(0.3), width: 2),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calculate_outlined,
                              color: AppColors.agriLinkGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Calculated Fair Price',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.agriLinkGreen,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Rs ${fairPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.agriLinkGreen,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Formula: (0.4 × ${wholesaleController.text}) + (0.6 × ${retailController.text})',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final wholesale = double.parse(wholesaleController.text);
                  final retail = double.parse(retailController.text);
                  final fair = MarketPriceModel.calculateFairPrice(wholesale, retail);

                  final now = DateTime.now();
                  final price = MarketPriceModel(
                    cropName: cropController.text.trim(),
                    wholesalePrice: wholesale,
                    retailPrice: retail,
                    fairPrice: fair,
                    market: marketController.text.trim(),
                    unit: selectedUnit,
                    createdAt: now,
                    updatedAt: now,
                  );

                  try {
                    await _priceService.setMarketPrice(price);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            existingPrice == null
                                ? 'Price added successfully'
                                : 'Price updated successfully',
                          ),
                          backgroundColor: AppColors.agriLinkGreen,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    }
                  }
                }
              },
              icon: Icon(existingPrice == null ? Icons.add : Icons.check),
              label: Text(existingPrice == null ? 'Add Price' : 'Update Price'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.agriLinkGreen,
                foregroundColor: Colors.white,
                elevation: 2,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deletePrice(String cropName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.error,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Delete Price',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete the price for $cropName? This action cannot be undone.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _priceService.deletePrice(cropName);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Price deleted successfully'),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.storefront, size: 24),
                SizedBox(width: 8),
                Text(
                  'AgriLink Admin',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ],
            ),
            SizedBox(height: 2),
            Text(
              'Market Price Dashboard',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        backgroundColor: AppColors.agriLinkGreen,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: AppColors.agriLinkGreen.withOpacity(0.5),
        toolbarHeight: 70,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: StreamBuilder<List<MarketPriceModel>>(
        stream: _priceService.streamPrices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final prices = snapshot.data ?? [];

          if (prices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.agriLinkGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.storefront_outlined,
                      size: 64,
                      color: AppColors.agriLinkGreen,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No market prices yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start by adding your first crop price',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => _showAddPriceDialog(),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Add First Price'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.agriLinkGreen,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: AppColors.agriLinkGreen.withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: prices.length,
            itemBuilder: (context, index) {
              final price = prices[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 3,
                shadowColor: AppColors.agriLinkGreen.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.agriLinkGreen,
                    radius: 24,
                    child: Text(
                      price.cropName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    price.cropName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Wholesale: Rs ${price.wholesalePrice.toStringAsFixed(2)}'),
                      Text('Retail: Rs ${price.retailPrice.toStringAsFixed(2)}'),
                      Text(
                        'Fair Price: Rs ${price.fairPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.agriLinkGreen,
                        ),
                      ),
                      Text('Market: ${price.market} | Unit: ${price.unit}'),
                      const SizedBox(height: 4),
                      Text(
                        'Added: ${_formatDateTime(price.createdAt)}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                      Text(
                        'Updated: ${_formatDateTime(price.updatedAt)}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppColors.agriLinkGreen),
                        onPressed: () => _showAddPriceDialog(price),
                        tooltip: 'Edit',
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.agriLinkGreen.withOpacity(0.1),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        onPressed: () => _deletePrice(price.cropName),
                        tooltip: 'Delete',
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.error.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPriceDialog(),
        backgroundColor: AppColors.agriLinkGreen,
        foregroundColor: Colors.white,
        elevation: 6,
        icon: const Icon(Icons.add_circle_outline),
        label: const Text(
          'Add Price',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
