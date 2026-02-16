import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/resend_config.dart';

class ResendService {
  static final ResendService _instance = ResendService._internal();
  factory ResendService() => _instance;
  ResendService._internal();

  final Map<String, String> _headers = {
    'Authorization': 'Bearer ${ResendConfig.apiKey}',
    'Content-Type': 'application/json',
  };

  /// Send a generic email
  Future<bool> sendEmail({
    required String to,
    required String subject,
    required String htmlContent,
    String? textContent,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ResendConfig.baseUrl}/emails'),
        headers: _headers,
        body: jsonEncode({
          'from': '${ResendConfig.fromName} <${ResendConfig.fromEmail}>',
          'to': [to],
          'subject': subject,
          'html': htmlContent,
          ...?textContent != null ? {'text': textContent} : null,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error sending email: $e');
      return false;
    }
  }

  /// Send order confirmation email
  Future<bool> sendOrderConfirmation({
    required String customerEmail,
    required String customerName,
    required String orderId,
    required List<Map<String, dynamic>> items,
    required double total,
    required String shippingAddress,
  }) async {
    final itemsHtml = items.map((item) => '''
      <tr>
        <td style="padding: 12px; border-bottom: 1px solid #eee;">
          <img src="${item['image']}" alt="${item['name']}" width="60" height="60" style="border-radius: 8px; object-fit: cover;" />
        </td>
        <td style="padding: 12px; border-bottom: 1px solid #eee;">${item['name']}</td>
        <td style="padding: 12px; border-bottom: 1px solid #eee; text-align: center;">${item['quantity']}</td>
        <td style="padding: 12px; border-bottom: 1px solid #eee; text-align: right;">\$${item['price'].toStringAsFixed(2)}</td>
      </tr>
    ''').join('');

    final htmlContent = '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>
    <body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 0; background-color: #f5f5f5;">
      <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff;">
        <!-- Header -->
        <div style="background: linear-gradient(135deg, #1A1A2E 0%, #16213E 100%); padding: 40px 20px; text-align: center;">
          <h1 style="color: #ffffff; margin: 0; font-size: 28px;">JT Gadgets</h1>
          <p style="color: rgba(255,255,255,0.8); margin: 10px 0 0 0;">Order Confirmation</p>
        </div>

        <!-- Content -->
        <div style="padding: 40px 30px;">
          <h2 style="color: #1A1A2E; margin: 0 0 20px 0;">Thank you for your order, $customerName!</h2>
          <p style="color: #666; line-height: 1.6;">
            Your order <strong>#$orderId</strong> has been confirmed and is being processed.
          </p>

          <!-- Order Items -->
          <table style="width: 100%; border-collapse: collapse; margin: 30px 0;">
            <thead>
              <tr style="background-color: #f8f8f8;">
                <th style="padding: 12px; text-align: left;">Item</th>
                <th style="padding: 12px; text-align: left;">Product</th>
                <th style="padding: 12px; text-align: center;">Qty</th>
                <th style="padding: 12px; text-align: right;">Price</th>
              </tr>
            </thead>
            <tbody>
              $itemsHtml
            </tbody>
            <tfoot>
              <tr>
                <td colspan="3" style="padding: 15px 12px; text-align: right; font-weight: bold; font-size: 18px;">Total:</td>
                <td style="padding: 15px 12px; text-align: right; font-weight: bold; font-size: 18px; color: #1A1A2E;">\$${total.toStringAsFixed(2)}</td>
              </tr>
            </tfoot>
          </table>

          <!-- Shipping Address -->
          <div style="background-color: #f8f8f8; padding: 20px; border-radius: 12px; margin: 30px 0;">
            <h3 style="color: #1A1A2E; margin: 0 0 10px 0; font-size: 16px;">Shipping Address</h3>
            <p style="color: #666; margin: 0; line-height: 1.6;">$shippingAddress</p>
          </div>

          <p style="color: #666; line-height: 1.6;">
            We'll send you a shipping confirmation email once your order is on its way.
          </p>
        </div>

        <!-- Footer -->
        <div style="background-color: #f8f8f8; padding: 30px; text-align: center;">
          <p style="color: #999; margin: 0 0 10px 0; font-size: 14px;">
            Questions? Contact us at support@jtgadgets.com
          </p>
          <p style="color: #ccc; margin: 0; font-size: 12px;">
            &copy; 2024 JT Gadgets. All rights reserved.
          </p>
        </div>
      </div>
    </body>
    </html>
    ''';

    return sendEmail(
      to: customerEmail,
      subject: 'Order Confirmed - #$orderId',
      htmlContent: htmlContent,
    );
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail({
    required String email,
    required String resetLink,
  }) async {
    final htmlContent = '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>
    <body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 0; background-color: #f5f5f5;">
      <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff;">
        <!-- Header -->
        <div style="background: linear-gradient(135deg, #11998E 0%, #38EF7D 100%); padding: 40px 20px; text-align: center;">
          <h1 style="color: #ffffff; margin: 0; font-size: 28px;">JT Gadgets</h1>
          <p style="color: rgba(255,255,255,0.9); margin: 10px 0 0 0;">Password Reset</p>
        </div>

        <!-- Content -->
        <div style="padding: 40px 30px; text-align: center;">
          <div style="width: 80px; height: 80px; background-color: #f0f9f6; border-radius: 50%; margin: 0 auto 20px; display: flex; align-items: center; justify-content: center;">
            <span style="font-size: 40px;">🔐</span>
          </div>

          <h2 style="color: #1A1A2E; margin: 0 0 20px 0;">Reset Your Password</h2>
          <p style="color: #666; line-height: 1.6; margin: 0 0 30px 0;">
            We received a request to reset your password. Click the button below to create a new password.
          </p>

          <a href="$resetLink" style="display: inline-block; background: linear-gradient(135deg, #11998E 0%, #38EF7D 100%); color: #ffffff; text-decoration: none; padding: 15px 40px; border-radius: 12px; font-weight: 600; font-size: 16px;">
            Reset Password
          </a>

          <p style="color: #999; font-size: 14px; margin: 30px 0 0 0;">
            This link will expire in 1 hour. If you didn't request this, please ignore this email.
          </p>
        </div>

        <!-- Footer -->
        <div style="background-color: #f8f8f8; padding: 30px; text-align: center;">
          <p style="color: #999; margin: 0 0 10px 0; font-size: 14px;">
            Need help? Contact us at support@jtgadgets.com
          </p>
          <p style="color: #ccc; margin: 0; font-size: 12px;">
            &copy; 2024 JT Gadgets. All rights reserved.
          </p>
        </div>
      </div>
    </body>
    </html>
    ''';

    return sendEmail(
      to: email,
      subject: 'Reset Your Password - JT Gadgets',
      htmlContent: htmlContent,
    );
  }

  /// Send welcome email for new users
  Future<bool> sendWelcomeEmail({
    required String email,
    required String name,
  }) async {
    final htmlContent = '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>
    <body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 0; background-color: #f5f5f5;">
      <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff;">
        <!-- Header -->
        <div style="background: linear-gradient(135deg, #667EEA 0%, #764BA2 100%); padding: 40px 20px; text-align: center;">
          <h1 style="color: #ffffff; margin: 0; font-size: 28px;">Welcome to JT Gadgets!</h1>
        </div>

        <!-- Content -->
        <div style="padding: 40px 30px; text-align: center;">
          <div style="width: 80px; height: 80px; background-color: #f0f0ff; border-radius: 50%; margin: 0 auto 20px; display: flex; align-items: center; justify-content: center;">
            <span style="font-size: 40px;">🎉</span>
          </div>

          <h2 style="color: #1A1A2E; margin: 0 0 20px 0;">Hey $name!</h2>
          <p style="color: #666; line-height: 1.6; margin: 0 0 30px 0;">
            Thank you for joining JT Gadgets! We're excited to have you as part of our community.
            Explore our latest collection of premium electronics and gadgets.
          </p>

          <!-- Features -->
          <div style="text-align: left; background-color: #f8f8f8; padding: 25px; border-radius: 12px; margin: 20px 0;">
            <p style="margin: 0 0 15px 0; color: #1A1A2E;">
              <strong>✓</strong> Access to exclusive deals and offers
            </p>
            <p style="margin: 0 0 15px 0; color: #1A1A2E;">
              <strong>✓</strong> Fast and secure delivery
            </p>
            <p style="margin: 0 0 15px 0; color: #1A1A2E;">
              <strong>✓</strong> 30-day hassle-free returns
            </p>
            <p style="margin: 0; color: #1A1A2E;">
              <strong>✓</strong> 24/7 customer support
            </p>
          </div>
        </div>

        <!-- Footer -->
        <div style="background-color: #f8f8f8; padding: 30px; text-align: center;">
          <p style="color: #999; margin: 0 0 10px 0; font-size: 14px;">
            Questions? Contact us at support@jtgadgets.com
          </p>
          <p style="color: #ccc; margin: 0; font-size: 12px;">
            &copy; 2024 JT Gadgets. All rights reserved.
          </p>
        </div>
      </div>
    </body>
    </html>
    ''';

    return sendEmail(
      to: email,
      subject: 'Welcome to JT Gadgets! 🎉',
      htmlContent: htmlContent,
    );
  }

  /// Send shipping notification email
  Future<bool> sendShippingNotification({
    required String customerEmail,
    required String customerName,
    required String orderId,
    required String trackingNumber,
    required String carrier,
    required String trackingUrl,
  }) async {
    final htmlContent = '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>
    <body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 0; background-color: #f5f5f5;">
      <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff;">
        <!-- Header -->
        <div style="background: linear-gradient(135deg, #FF6B35 0%, #FF8E53 100%); padding: 40px 20px; text-align: center;">
          <h1 style="color: #ffffff; margin: 0; font-size: 28px;">JT Gadgets</h1>
          <p style="color: rgba(255,255,255,0.9); margin: 10px 0 0 0;">Your Order Has Shipped!</p>
        </div>

        <!-- Content -->
        <div style="padding: 40px 30px; text-align: center;">
          <div style="width: 80px; height: 80px; background-color: #fff5f0; border-radius: 50%; margin: 0 auto 20px; display: flex; align-items: center; justify-content: center;">
            <span style="font-size: 40px;">📦</span>
          </div>

          <h2 style="color: #1A1A2E; margin: 0 0 20px 0;">Good news, $customerName!</h2>
          <p style="color: #666; line-height: 1.6; margin: 0 0 30px 0;">
            Your order <strong>#$orderId</strong> is on its way to you!
          </p>

          <!-- Tracking Info -->
          <div style="background-color: #f8f8f8; padding: 25px; border-radius: 12px; margin: 20px 0;">
            <p style="color: #999; margin: 0 0 5px 0; font-size: 12px; text-transform: uppercase;">Carrier</p>
            <p style="color: #1A1A2E; margin: 0 0 20px 0; font-size: 18px; font-weight: 600;">$carrier</p>

            <p style="color: #999; margin: 0 0 5px 0; font-size: 12px; text-transform: uppercase;">Tracking Number</p>
            <p style="color: #1A1A2E; margin: 0; font-size: 18px; font-weight: 600;">$trackingNumber</p>
          </div>

          <a href="$trackingUrl" style="display: inline-block; background: linear-gradient(135deg, #FF6B35 0%, #FF8E53 100%); color: #ffffff; text-decoration: none; padding: 15px 40px; border-radius: 12px; font-weight: 600; font-size: 16px;">
            Track Your Order
          </a>
        </div>

        <!-- Footer -->
        <div style="background-color: #f8f8f8; padding: 30px; text-align: center;">
          <p style="color: #999; margin: 0 0 10px 0; font-size: 14px;">
            Need help? Contact us at support@jtgadgets.com
          </p>
          <p style="color: #ccc; margin: 0; font-size: 12px;">
            &copy; 2024 JT Gadgets. All rights reserved.
          </p>
        </div>
      </div>
    </body>
    </html>
    ''';

    return sendEmail(
      to: customerEmail,
      subject: 'Your Order Has Shipped! 📦',
      htmlContent: htmlContent,
    );
  }
}
