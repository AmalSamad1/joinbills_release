import 'dart:convert';
import 'package:http/http.dart' as http;

class RazorpayRepo {
  final String apiKey;
  final String apiSecret;
  final bool sandbox;

  RazorpayRepo({required this.apiKey, required this.apiSecret, this.sandbox = true});

  String get domain => sandbox ? "https://api.razorpay.com/v1" : "https://api.razorpay.com/v1";

  Future<String> createOrder({required String amount, required String currency}) async {
    final url = Uri.parse('$domain/orders');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Basic ' + base64Encode(utf8.encode('$apiKey:$apiSecret')),
      },
      body: jsonEncode({
        'amount': amount, // Amount in paise
        'currency': currency,
        'receipt': 'receipt#1',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['id']; // Return the order ID
    } else {
      throw Exception('Failed to create order: ${response.body}');
    }
  }

  Future<String> getPaymentUrl({required String amount, required String currency}) async {
    try {
      String orderId = await createOrder(amount: amount, currency: currency);
      return orderId; // Use this ID to initiate the Razorpay checkout
    } catch (e) {
      print('Error creating Razorpay order: $e');
      return 'error';
    }
  }
}
