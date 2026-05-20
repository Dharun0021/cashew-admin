import 'package:flutter/material.dart';

class AppConstants {
  // UI Layout spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  
  // Animation durations
  static const Duration durationShort = Duration(milliseconds: 200);
  static const Duration durationMedium = Duration(milliseconds: 350);
  static const Duration durationLong = Duration(milliseconds: 500);

  // Screen breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1100.0;

  // App Meta
  static const String appName = 'Cashew Admin';
  static const String appVersion = '1.0.0';

  // Mock Products data
  static final List<Map<String, dynamic>> mockProducts = [
    {
      'id': 'p1',
      'name': 'Premium Roasted Cashews (Salted)',
      'sku': 'CSH-RST-SLT-500',
      'category': 'Roasted Cashews',
      'categoryId': 'cat1',
      'price': 14.99,
      'discountPrice': 12.49,
      'stock': 120,
      'status': 'Active',
      'isFeatured': true,
      'image': 'https://images.unsplash.com/photo-1508061253366-f7da158b6d46?w=400',
      'description': 'Handpicked premium cashews slow-roasted to perfection with a pinch of sea salt.',
    },
    {
      'id': 'p2',
      'name': 'Raw Organic Cashews (Whole)',
      'sku': 'CSH-RAW-ORG-1000',
      'category': 'Raw Cashews',
      'categoryId': 'cat2',
      'price': 24.99,
      'discountPrice': null,
      'stock': 5, // Low stock warning!
      'status': 'Active',
      'isFeatured': true,
      'image': 'https://images.unsplash.com/photo-1596515134807-a36f7bc2f009?w=400',
      'description': 'Pure whole raw cashews sourced from certified organic farms. Perfect for vegan recipes.',
    },
    {
      'id': 'p3',
      'name': 'Honey Glazed Cashew Clusters',
      'sku': 'CSH-HNY-GLZ-250',
      'category': 'Flavored Cashews',
      'categoryId': 'cat3',
      'price': 8.99,
      'discountPrice': 7.99,
      'stock': 0, // Out of Stock!
      'status': 'Out of Stock',
      'isFeatured': false,
      'image': 'https://images.unsplash.com/photo-1618260741893-6bf299a9cf3a?w=400',
      'description': 'Sweet and crunchy honey-glazed cashew pieces pressed into bite-sized snack clusters.',
    },
    {
      'id': 'p4',
      'name': 'Spicy Chili Lime Cashews',
      'sku': 'CSH-SPC-CHL-300',
      'category': 'Flavored Cashews',
      'categoryId': 'cat3',
      'price': 9.99,
      'discountPrice': null,
      'stock': 45,
      'status': 'Active',
      'isFeatured': false,
      'image': 'https://images.unsplash.com/photo-1600189020840-e9db18c375eb?w=400',
      'description': 'Zesty lime mixed with fiery chili seasoning creates the ultimate tangy, spicy kick.',
    },
    {
      'id': 'p5',
      'name': 'Cashew Butter (Creamy Smooth)',
      'sku': 'CSH-BTR-CRM-400',
      'category': 'Cashew Butter & Spreads',
      'categoryId': 'cat4',
      'price': 12.99,
      'discountPrice': 10.99,
      'stock': 65,
      'status': 'Active',
      'isFeatured': true,
      'image': 'https://images.unsplash.com/photo-1590080875515-8a3a8dc5735e?w=400',
      'description': '100% dry-roasted cashews ground into a luxurious, ultra-creamy nut butter spread.',
    },
    {
      'id': 'p6',
      'name': 'Chocolate Dusted Cashews',
      'sku': 'CSH-CHOC-DST-350',
      'category': 'Flavored Cashews',
      'categoryId': 'cat3',
      'price': 11.99,
      'discountPrice': null,
      'stock': 3, // Low stock!
      'status': 'Active',
      'isFeatured': false,
      'image': 'https://images.unsplash.com/photo-1581798459219-318e76aecc7b?w=400',
      'description': 'Plump roasted cashews dipped in dark chocolate and lightly dusted with rich cocoa powder.',
    }
  ];

  // Mock Categories data
  static final List<Map<String, dynamic>> mockCategories = [
    {
      'id': 'cat1',
      'name': 'Roasted Cashews',
      'image': 'https://images.unsplash.com/photo-1508061253366-f7da158b6d46?w=400',
      'productCount': 12,
    },
    {
      'id': 'cat2',
      'name': 'Raw Cashews',
      'image': 'https://images.unsplash.com/photo-1596515134807-a36f7bc2f009?w=400',
      'productCount': 8,
    },
    {
      'id': 'cat3',
      'name': 'Flavored Cashews',
      'image': 'https://images.unsplash.com/photo-1600189020840-e9db18c375eb?w=400',
      'productCount': 18,
    },
    {
      'id': 'cat4',
      'name': 'Cashew Butter & Spreads',
      'image': 'https://images.unsplash.com/photo-1590080875515-8a3a8dc5735e?w=400',
      'productCount': 5,
    }
  ];

  // Mock Orders data
  static final List<Map<String, dynamic>> mockOrders = [
    {
      'id': 'ORD-9823',
      'customerName': 'Jane Cooper',
      'customerEmail': 'jane.cooper@example.com',
      'customerPhone': '+1 (555) 019-2834',
      'date': '2026-05-19T14:32:00Z',
      'status': 'Pending',
      'paymentStatus': 'Paid',
      'paymentMethod': 'Credit Card',
      'total': 49.96,
      'items': [
        {'productId': 'p1', 'name': 'Premium Roasted Cashews (Salted)', 'quantity': 2, 'price': 12.49},
        {'productId': 'p2', 'name': 'Raw Organic Cashews (Whole)', 'quantity': 1, 'price': 24.98}
      ],
      'shippingAddress': '123 cashew ln, Cashew Valley, CA 90210'
    },
    {
      'id': 'ORD-9822',
      'customerName': 'Wade Warren',
      'customerEmail': 'wade.warren@example.com',
      'customerPhone': '+1 (555) 014-9382',
      'date': '2026-05-18T10:15:00Z',
      'status': 'Packed',
      'paymentStatus': 'Paid',
      'paymentMethod': 'PayPal',
      'total': 21.98,
      'items': [
        {'productId': 'p5', 'name': 'Cashew Butter (Creamy Smooth)', 'quantity': 2, 'price': 10.99}
      ],
      'shippingAddress': '456 Nutmeg st, Walnut Creek, CA 94596'
    },
    {
      'id': 'ORD-9821',
      'customerName': 'Albert Flores',
      'customerEmail': 'albert.f@example.com',
      'customerPhone': '+1 (555) 018-3829',
      'date': '2026-05-17T16:45:00Z',
      'status': 'Shipped',
      'paymentStatus': 'Paid',
      'paymentMethod': 'Apple Pay',
      'total': 34.46,
      'items': [
        {'productId': 'p1', 'name': 'Premium Roasted Cashews (Salted)', 'quantity': 1, 'price': 12.49},
        {'productId': 'p6', 'name': 'Chocolate Dusted Cashews', 'quantity': 1, 'price': 11.99},
        {'productId': 'p4', 'name': 'Spicy Chili Lime Cashews', 'quantity': 1, 'price': 9.98}
      ],
      'shippingAddress': '789 Almond rd, Pistachio Grove, TX 75001'
    },
    {
      'id': 'ORD-9820',
      'customerName': 'Bessie Cooper',
      'customerEmail': 'bessie.c@example.com',
      'customerPhone': '+1 (555) 011-8930',
      'date': '2026-05-15T09:30:00Z',
      'status': 'Delivered',
      'paymentStatus': 'Paid',
      'paymentMethod': 'Credit Card',
      'total': 124.90,
      'items': [
        {'productId': 'p1', 'name': 'Premium Roasted Cashews (Salted)', 'quantity': 10, 'price': 12.49}
      ],
      'shippingAddress': '101 Macadamia blvd, Pecan Cove, FL 33101'
    },
    {
      'id': 'ORD-9819',
      'customerName': 'Kristin Watson',
      'customerEmail': 'kristin.w@example.com',
      'customerPhone': '+1 (555) 017-4829',
      'date': '2026-05-14T11:00:00Z',
      'status': 'Cancelled',
      'paymentStatus': 'Refunded',
      'paymentMethod': 'Google Pay',
      'total': 18.98,
      'items': [
        {'productId': 'p3', 'name': 'Honey Glazed Cashew Clusters', 'quantity': 2, 'price': 7.99}
      ],
      'shippingAddress': '202 Pine Nut dr, Hazelnut Ridge, OR 97201'
    }
  ];

  // Mock Customers data
  static final List<Map<String, dynamic>> mockCustomers = [
    {
      'id': 'c1',
      'name': 'Jane Cooper',
      'email': 'jane.cooper@example.com',
      'phone': '+1 (555) 019-2834',
      'totalOrders': 5,
      'totalSpend': 245.50,
      'status': 'Active',
      'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
      'joinDate': '2025-11-12'
    },
    {
      'id': 'c2',
      'name': 'Wade Warren',
      'email': 'wade.warren@example.com',
      'phone': '+1 (555) 014-9382',
      'totalOrders': 2,
      'totalSpend': 43.96,
      'status': 'Active',
      'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
      'joinDate': '2026-02-18'
    },
    {
      'id': 'c3',
      'name': 'Albert Flores',
      'email': 'albert.f@example.com',
      'phone': '+1 (555) 018-3829',
      'totalOrders': 8,
      'totalSpend': 412.30,
      'status': 'Active',
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      'joinDate': '2025-08-05'
    },
    {
      'id': 'c4',
      'name': 'Bessie Cooper',
      'email': 'bessie.c@example.com',
      'phone': '+1 (555) 011-8930',
      'totalOrders': 12,
      'totalSpend': 849.50,
      'status': 'Active',
      'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      'joinDate': '2025-01-20'
    },
    {
      'id': 'c5',
      'name': 'Kristin Watson',
      'email': 'kristin.w@example.com',
      'phone': '+1 (555) 017-4829',
      'totalOrders': 1,
      'totalSpend': 18.98,
      'status': 'Inactive',
      'avatar': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
      'joinDate': '2026-04-10'
    }
  ];

  // Mock Notification Logs data
  static final List<Map<String, dynamic>> mockNotifications = [
    {
      'id': 'n1',
      'title': 'Weekend Cashew Sale!',
      'body': 'Get 15% off all flavored cashew products this weekend with code CASHEW15.',
      'type': 'Push Notification',
      'targetGroup': 'All Customers',
      'sentDate': '2026-05-18T10:00:00Z',
      'status': 'Sent'
    },
    {
      'id': 'n2',
      'title': 'Order Shipment Notification Template',
      'body': 'Hi {{name}}, your order {{order_id}} has been shipped! Track it here: {{tracking_url}}',
      'type': 'WhatsApp Placeholder UI',
      'targetGroup': 'Shipped Orders',
      'sentDate': '2026-05-15T12:30:00Z',
      'status': 'Template Active'
    },
    {
      'id': 'n3',
      'title': 'Cashew Butter Stock Back!',
      'body': 'Good news! Our popular Creamy Cashew Butter is back in stock. Order now before it runs out!',
      'type': 'Broadcast Notification',
      'targetGroup': 'Butter Lovers Group',
      'sentDate': '2026-05-10T14:15:00Z',
      'status': 'Sent'
    }
  ];
}
