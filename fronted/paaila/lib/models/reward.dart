import 'package:flutter/material.dart';

class Reward {
  final String id;
  final String title;
  final String description;
  final String category; // 'gym', 'cafe', 'trek', 'merchandise'
  final int pointsCost;
  final String partnerName;
  final String partnerLogo;
  final String validUntil;
  final List<String> images;
  final List<String> terms;
  final String location;
  final bool isSponsored;
  final bool isLimited;
  final int? stockLeft;

  const Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.pointsCost,
    required this.partnerName,
    this.partnerLogo = '',
    this.validUntil = '',
    this.images = const [],
    this.terms = const [],
    this.location = '',
    this.isSponsored = false,
    this.isLimited = false,
    this.stockLeft,
  });

  // Get category icon
  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'gym':
        return Icons.fitness_center_rounded;
      case 'cafe':
        return Icons.local_cafe_rounded;
      case 'trek':
        return Icons.terrain_rounded;
      case 'merchandise':
        return Icons.redeem_rounded;
      default:
        return Icons.card_giftcard_rounded;
    }
  }

  // Get category color
  static int getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'gym':
        return 0xFF7C4DFF; // Purple
      case 'cafe':
        return 0xFFFF7043; // Orange
      case 'trek':
        return 0xFF00A86B; // Green
      case 'merchandise':
        return 0xFF29B6F6; // Blue
      default:
        return 0xFF9CA3AF; // Gray
    }
  }

  // Sample rewards data
  static List<Reward> sampleRewards = [
    // GYM VOUCHERS
    Reward(
      id: '1',
      title: '1 Month Gym Pass',
      description:
          'Get a full month of unlimited access to FitZone Gym! This voucher includes access to all gym equipment, group fitness classes, and locker facilities.\n\nPerfect for those looking to take their fitness journey to the next level. Whether you\'re a beginner or an experienced athlete, FitZone has everything you need to achieve your goals.\n\nThe pass is valid at any FitZone location in Kathmandu Valley.',
      category: 'gym',
      pointsCost: 500,
      partnerName: 'FitZone Gym',
      validUntil: 'March 31, 2026',
      images: [
        'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
        'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=800',
      ],
      terms: [
        'Valid for new members only',
        'Must be activated within 30 days of redemption',
        'Cannot be combined with other offers',
        'One voucher per person',
      ],
      location: 'Thamel, Lazimpat, Baluwatar',
      isSponsored: true,
    ),
    Reward(
      id: '2',
      title: '5 Personal Training Sessions',
      description:
          'Get personalized fitness guidance with 5 one-on-one sessions with a certified personal trainer at Iron Body Fitness.\n\nYour trainer will create a customized workout plan based on your fitness goals, whether it\'s weight loss, muscle building, or improving overall health. Each session is 60 minutes long.\n\nIncludes initial fitness assessment and progress tracking.',
      category: 'gym',
      pointsCost: 750,
      partnerName: 'Iron Body Fitness',
      validUntil: 'April 15, 2026',
      images: [
        'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800',
        'https://images.unsplash.com/photo-1581009146145-b5ef050c149a?w=800',
      ],
      terms: [
        'Sessions must be used within 60 days',
        'Advance booking required (24 hours)',
        'Cancellation allowed up to 12 hours before',
        'Valid at Patan branch only',
      ],
      location: 'Patan, Lalitpur',
      isLimited: true,
      stockLeft: 15,
    ),

    // CAFE DISCOUNTS
    Reward(
      id: '3',
      title: '50% Off Coffee & Smoothies',
      description:
          'Enjoy a refreshing post-workout drink at Himalayan Java! This voucher gives you 50% off on any coffee or smoothie of your choice.\n\nFrom energizing espresso drinks to protein-packed smoothies, treat yourself after your run or walk. Valid for drinks up to NPR 500.\n\nPerfect way to rehydrate and refuel while enjoying the cozy cafe atmosphere.',
      category: 'cafe',
      pointsCost: 150,
      partnerName: 'Himalayan Java',
      validUntil: 'February 28, 2026',
      images: [
        'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800',
        'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=800',
      ],
      terms: [
        'Valid on drinks up to NPR 500',
        'One voucher per visit',
        'Cannot be used on food items',
        'Valid at all Kathmandu locations',
      ],
      location: 'Multiple locations in Kathmandu',
    ),
    Reward(
      id: '4',
      title: 'Free Healthy Breakfast',
      description:
          'Start your day right with a complimentary healthy breakfast at Green Leaf Cafe! Choose from our selection of nutritious options including avocado toast, acai bowls, overnight oats, and fresh fruit platters.\n\nPerfect for those early morning runs - redeem your breakfast within 2 hours of your morning activity for bonus freshness!\n\nIncludes one breakfast item and a fresh juice of your choice.',
      category: 'cafe',
      pointsCost: 200,
      partnerName: 'Green Leaf Cafe',
      validUntil: 'March 15, 2026',
      images: [
        'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=800',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800',
      ],
      terms: [
        'Valid for breakfast menu items only',
        'Redeemable between 7 AM - 11 AM',
        'Includes one drink (juice/tea/coffee)',
        'Reservation recommended',
      ],
      location: 'Jhamsikhel, Lalitpur',
    ),

    // SPONSORED TREK TRIPS
    Reward(
      id: '5',
      title: 'Langtang Valley Trek',
      description:
          'Experience the breathtaking beauty of Langtang Valley with this fully sponsored 5-day trek! This once-in-a-lifetime opportunity includes transportation, accommodation, meals, and an experienced guide.\n\nThe Langtang Valley, known as the "Valley of Glaciers," offers stunning mountain views, rich Tamang culture, and diverse wildlife. Trek through rhododendron forests, visit ancient monasteries, and witness the majestic Langtang Lirung.\n\nThis sponsored trek is our way of rewarding our most dedicated community members. Limited spots available!',
      category: 'trek',
      pointsCost: 5000,
      partnerName: 'Paaila Adventures',
      validUntil: 'May 31, 2026',
      images: [
        'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=800',
        'https://images.unsplash.com/photo-1486911278844-a81c5267e227?w=800',
        'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800',
      ],
      terms: [
        'Must have completed 100+ km total distance',
        'Minimum 30-day streak required',
        'Subject to weather conditions',
        'Travel insurance required',
        'Dates: April 15-20, 2026',
      ],
      location: 'Langtang National Park',
      isSponsored: true,
      isLimited: true,
      stockLeft: 5,
    ),
    Reward(
      id: '6',
      title: 'Nagarkot Sunrise Hike',
      description:
          'Join us for a magical sunrise hike to Nagarkot with panoramic Himalayan views! This day trip includes transportation, breakfast, and a guided nature walk.\n\nWake up early and journey to Nagarkot, one of the best spots to view the sunrise over the Himalayas. On a clear day, you can see peaks from Annapurna to Everest. After the sunrise, enjoy a hearty mountain breakfast and explore the surrounding trails.\n\nPerfect for a weekend adventure without the commitment of a multi-day trek.',
      category: 'trek',
      pointsCost: 1500,
      partnerName: 'Paaila Adventures',
      validUntil: 'April 30, 2026',
      images: [
        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
        'https://images.unsplash.com/photo-1454496522488-7a8e488e8606?w=800',
      ],
      terms: [
        'Minimum 7-day streak required',
        'Pickup from Kathmandu at 4 AM',
        'Includes breakfast and snacks',
        'Weather dependent',
      ],
      location: 'Nagarkot, Bhaktapur',
      isSponsored: true,
    ),

    // MERCHANDISE
    Reward(
      id: '7',
      title: 'Paaila Running T-Shirt',
      description:
          'Show your Paaila pride with our official running t-shirt! Made from moisture-wicking fabric that keeps you cool and comfortable during your activities.\n\nFeatures the Paaila logo on the front and "Every Step Counts" motto on the back. Available in multiple sizes and colors.\n\nPerfect for your morning runs or casual wear!',
      category: 'merchandise',
      pointsCost: 300,
      partnerName: 'Paaila Official',
      validUntil: 'December 31, 2026',
      images: [
        'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800',
        'https://images.unsplash.com/photo-1503341504253-dff4815485f1?w=800',
      ],
      terms: [
        'Available sizes: S, M, L, XL',
        'Colors: Green, White, Black',
        'Delivery within Kathmandu Valley',
        'Allow 5-7 days for delivery',
      ],
      location: 'Delivery to your address',
    ),
    Reward(
      id: '8',
      title: 'Premium Water Bottle',
      description:
          'Stay hydrated with our insulated stainless steel water bottle! Keeps drinks cold for 24 hours or hot for 12 hours.\n\n750ml capacity with leak-proof lid and easy-carry handle. Features the Paaila logo engraving.\n\nEco-friendly choice for the health-conscious runner!',
      category: 'merchandise',
      pointsCost: 250,
      partnerName: 'Paaila Official',
      validUntil: 'December 31, 2026',
      images: [
        'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=800',
      ],
      terms: [
        'Color: Matte Black with green logo',
        '750ml capacity',
        'Delivery within Kathmandu Valley',
        'Allow 5-7 days for delivery',
      ],
      location: 'Delivery to your address',
    ),
  ];
}
