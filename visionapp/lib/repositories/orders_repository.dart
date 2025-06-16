import '../core/services/supabase_services.dart';
import '../models/orders.dart';

class OrdersRepository {
  final SupabaseService _supabaseService;
  static const String _tableName = 'orders';
  static const String _productsTable = 'order_products';

  OrdersRepository() : _supabaseService = SupabaseService.instance;

 Future<List<Order>> getAllOrders() async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .select('''
            *,
            products:$_productsTable(*)
          ''')
          .order('created_date', ascending: false);

      return (response as List).map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

    Future<Order> createOrder(Order order) async {
    try {
      // Insert the order first
      final orderResponse = await _supabaseService.client
          .from(_tableName)
          .insert({
            'client_id': order.clientId,
            'client_name': order.clientName,
            'due_date': order.dueDate.toIso8601String(),
            'status': order.status.toString().split('.').last.toLowerCase(),
            'priority': order.priority.toString().split('.').last.toLowerCase(),
            'special_instructions': order.specialInstructions,
            'created_date': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      // Insert order products
      final productsData = order.products.map((product) => {
        'order_id': orderResponse['id'],
        'product_id': product.productId,
        'quantity': product.quantity,
        'completed': product.completed,
      }).toList();

      await _supabaseService.client.from(_productsTable).insert(productsData);

      // Return the created order with its products
      return Order.fromJson({
        ...orderResponse,
        'products': productsData,
      });
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }


Future<void> deleteOrder(String orderId) async {
    try {
      await _supabaseService.client
          .from(_tableName)
          .delete()
          .eq('id', orderId);
    } catch (e) {
      throw Exception('Failed to delete order: $e');
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      final statusStr = status.toString().split('.').last.toLowerCase();
      await _supabaseService.client
          .from('orders')
          .update({
            'status': statusStr,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  Future<void> updateProductCompletion(
    String orderId,
    String productId,  // Changed from productName
    int completedCount,
  ) async {
    try {
      await _supabaseService.client
          .from('order_products')
          .update({'completed': completedCount})
          .eq('order_id', orderId)
          .eq('product_id', productId);  // Changed from name to product_id
    } catch (e) {
      throw Exception('Failed to update product completion: $e');
    }
  }

  Future<Order> duplicateOrder(Order order) async {
    try {
      // Create new order without ID
      final orderData = order.toJson()
        ..remove('id')
        ..['created_date'] = DateTime.now().toIso8601String()
        ..['status'] = OrderStatus.in_production.toString().split('.').last;

      final orderResponse = await _supabaseService.client
          .from(_tableName)
          .insert(orderData)
          .select()
          .single();

      // Duplicate products for new order
      await Future.wait(
        order.products.map((product) async {
          await _supabaseService.client
              .from(_productsTable)
              .insert({
                'order_id': orderResponse['id'],
                'product_id': product.productId,
                'quantity': product.quantity,
                'completed': 0, // Reset completed count
              });
        }),
      );

      // Return new order with products
      final response = await _supabaseService.client
          .from(_tableName)
          .select('''
            *,
            products:$_productsTable(*)
          ''')
          .eq('id', orderResponse['id'])
          .single();

      return Order.fromJson(response);
    } catch (e) {
      throw Exception('Failed to duplicate order: $e');
    }
  }

  Future<Order> updateOrder(Order order) async {
    try {
      // Update the order
      final orderResponse = await _supabaseService.client
          .from(_tableName)
          .update({
            'client_name': order.clientName,
            'due_date': order.dueDate.toIso8601String(),
            'status': order.status.toString().split('.').last,
            'priority': order.priority.toString().split('.').last,
            'special_instructions': order.specialInstructions,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', order.id)
          .select()
          .single();

      // Delete existing products
      await _supabaseService.client
          .from(_productsTable)
          .delete()
          .eq('order_id', order.id);

      // Create new products
      await Future.wait(
        order.products.map((product) async {
          await _supabaseService.client
              .from(_productsTable)
              .insert({
                'order_id': order.id,
                'product_id': product.productId,  // Changed from name
                'quantity': product.quantity,
                'completed': product.completed,
              });
        }),
      );

      return order;
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }

  Future<Order> getOrderById(String orderId) async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .select('''
            *,
            products:$_productsTable(*)
          ''')
          .eq('id', orderId)
          .single();

      return Order.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch order by ID: $e');
    }
  }

  Future<void> deleteCompletedOrders() async {
    try {
      await _supabaseService.client
          .from(_tableName)
          .delete()
          .eq('status', 'completed');
    } catch (e) {
      throw Exception('Failed to delete completed orders: $e');
    }
  }

  Future<List<Order>> getPendingOrders() async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .select('''
            *,
            products:$_productsTable(*)
          ''')
          .eq('status', 'queued')
          .order('due_date', ascending: true);

      return (response as List).map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch pending orders: $e');
    }
  }

  Future<Map<String, Map<String, dynamic>>> getOrderDetailsForProductions(
    List<String> orderIds
  ) async {
    try {
      if (orderIds.isEmpty) return {};

      final response = await _supabaseService.client
          .from('orders')
          .select('''
            id,
            client_name,
            display_id,
            priority,
            due_date,
            clients (
              id,
              name,
              phone
            )
          ''')
          .inFilter('id', orderIds);

      return Map.fromEntries(
        (response as List).map((order) => MapEntry(
          order['id'],
          {
            'clientName': order['clients']['name'] ?? order['client_name'],
            'displayId': order['display_id'],
            'priority': order['priority'],
            'dueDate': DateTime.parse(order['due_date']),
          },
        )),
      );
    } catch (e) {
      throw Exception('Failed to fetch order details: $e');
    }
  }

  Future<void> updateProductQuantity({
    required String orderId,
    required String productId,
    required int completedQuantity,
  }) async {
    try {
      // First check if the order is in an editable state
      final orderStatus = await _supabaseService.client
          .from('orders')
          .select('status')
          .eq('id', orderId)
          .single();

      final status = orderStatus['status'] as String;
      if (['ready', 'completed', 'shipped'].contains(status.toLowerCase())) {
        throw Exception('Cannot modify completed, ready or shipped orders');
      }

      // Update the product completion
      await _supabaseService.client
          .from('order_products')
          .update({
            'completed': completedQuantity,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', productId)
          .eq('order_id', orderId);

      // Call the stored procedure to check and update order status
      await _supabaseService.client.rpc(
        'check_order_completion',
        params: {'order_id_param': orderId}
      );
    } catch (e) {
      throw Exception('Failed to update product quantity: $e');
    }
  }

  Future<void> deleteAllFinishedOrders() async {
    try {
      await _supabaseService.client.rpc(
        'delete_finished_orders',
        params: {
          'status_list': ['completed', 'ready', 'shipped']
        }
      );
    } catch (e) {
      throw Exception('Failed to delete finished orders: $e');
    }
  }
}