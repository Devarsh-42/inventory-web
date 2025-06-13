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
      // Start a Supabase transaction
      final response = await _supabaseService.client.rpc('create_order_with_productions', 
        params: {
          'order_data': {
            'client_id': order.clientId,
            'client_name': order.clientName,
            'due_date': order.dueDate.toIso8601String(),
            'created_date': order.createdDate.toIso8601String(),
            'status': order.status.toString().split('.').last,
            'priority': order.priority.toString().split('.').last,
            'special_instructions': order.specialInstructions,
          },
          'products_data': order.products.map((product) => ({
            'name': product.name,
            'quantity': product.quantity,
            'completed': product.completed,
          })).toList(),
        }
      );

      // Fetch the complete order with products
      final completeOrder = await _supabaseService.client
          .from(_tableName)
          .select('''
            *,
            products:$_productsTable(*)
          ''')
          .eq('id', response['id'])
          .single();

      return Order.fromJson(completeOrder);
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
    String productName,
    int completedCount,
  ) async {
    try {
      await _supabaseService.client
          .from('order_products')
          .update({'completed': completedCount})
          .eq('order_id', orderId)
          .eq('name', productName);
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
        ..['status'] = OrderStatus.queued.toString().split('.').last;

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
                'name': product.name,
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
                'name': product.name,
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
}