class PopularRoute {
  final String id;
  final String name;
  final String distance;
  final String difficulty;
  final String owner;
  final String description;
  final String estimatedTime;
  final String elevation;
  final List<String> tags;
  final List<String> images;
  final List<String> highlights;
  final String terrain;
  final String bestTime;
  final double rating;
  final int reviewCount;

  const PopularRoute({
    required this.id,
    required this.name,
    required this.distance,
    required this.difficulty,
    required this.owner,
    this.description = '',
    this.estimatedTime = '',
    this.elevation = '',
    this.tags = const [],
    this.images = const [],
    this.highlights = const [],
    this.terrain = '',
    this.bestTime = '',
    this.rating = 0.0,
    this.reviewCount = 0,
  });

  // Sample routes data
  static List<PopularRoute> sampleRoutes = [
    PopularRoute(
      id: '1',
      name: 'Thamel Circuit',
      distance: '2.5 km',
      difficulty: 'Easy',
      owner: 'You',
      description:
          'The Thamel Circuit is a vibrant urban route that takes you through the heart of Kathmandu\'s most famous tourist district. This easy walk winds through narrow streets filled with colorful shops, cafes, and historic buildings.\n\nThe route begins at the main Thamel Chowk and loops around the neighborhood, passing through quieter back alleys and emerging onto the main streets. Along the way, you\'ll experience the unique blend of traditional Nepali culture and modern tourist amenities that makes Thamel so special.\n\nPerfect for morning walks or evening strolls, this route offers a sensory feast of sights, sounds, and smells. From incense-filled temple corners to the aroma of fresh momos from street vendors, every step brings something new.',
      estimatedTime: '30-40 min',
      elevation: 'Flat',
      tags: ['Urban', 'Cultural', 'Beginner-friendly'],
      images: [
        'https://images.unsplash.com/photo-1582654291650-f2a2c8b49ae0?w=800',
        'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=800',
        'https://images.unsplash.com/photo-1605640840605-14ac1855827b?w=800',
      ],
      highlights: [
        'Historic Thamel streets',
        'Local shops and cafes',
        'Temple views',
        'Street food scene',
      ],
      terrain: 'Paved streets, some cobblestone',
      bestTime: 'Early morning or evening',
      rating: 4.5,
      reviewCount: 128,
    ),
    PopularRoute(
      id: '2',
      name: 'Swayambhu Trail',
      distance: '4.1 km',
      difficulty: 'Medium',
      owner: 'Priya S.',
      description:
          'The Swayambhu Trail is a spiritual journey that leads you to one of Nepal\'s most sacred Buddhist sites - the famous Monkey Temple. This medium-difficulty route combines urban walking with a challenging climb up 365 stone steps.\n\nStarting from Sorahkhutte, the trail follows the traditional pilgrim path used for centuries. As you ascend, you\'ll pass ancient stone carvings, prayer flags, and small shrines that dot the hillside. The playful monkeys that give the temple its nickname are a constant presence.\n\nAt the summit, you\'re rewarded with panoramic views of the Kathmandu Valley and the magnificent white stupa with its all-seeing eyes. The descent can be made via a different route, creating a complete loop experience.',
      estimatedTime: '1-1.5 hours',
      elevation: '77m climb',
      tags: ['Spiritual', 'Scenic', 'Historic'],
      images: [
        'https://images.unsplash.com/photo-1565073624497-7144969d0a07?w=800',
        'https://images.unsplash.com/photo-1585938389612-a552a28d6914?w=800',
        'https://images.unsplash.com/photo-1609766857041-ed402ea8069a?w=800',
      ],
      highlights: [
        'Ancient Buddhist stupa',
        'Panoramic valley views',
        'Friendly monkeys',
        '365 historic steps',
      ],
      terrain: 'Stone steps, paved paths',
      bestTime: 'Sunrise for best views',
      rating: 4.8,
      reviewCount: 256,
    ),
    PopularRoute(
      id: '3',
      name: 'Balaju Park Path',
      distance: '1.9 km',
      difficulty: 'Easy',
      owner: 'Sanjay M.',
      description:
          'Balaju Park Path offers a peaceful escape from the city bustle within the beautiful Balaju Water Garden. This easy, family-friendly route takes you through manicured gardens, past historic water spouts, and along shaded walkways.\n\nThe park features the famous 22 stone waterspouts (hitis) carved with crocodile heads, a tradition dating back to the 18th century. The route loops around the main garden, passing the swimming pool, picnic areas, and the serene Narayanthan Temple.\n\nIdeal for a leisurely walk or light jog, this path is well-maintained and suitable for all fitness levels. The abundant shade makes it comfortable even during warmer days.',
      estimatedTime: '25-30 min',
      elevation: 'Flat',
      tags: ['Park', 'Family-friendly', 'Relaxing'],
      images: [
        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
        'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800',
        'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=800',
      ],
      highlights: [
        '22 historic water spouts',
        'Beautiful gardens',
        'Shaded walkways',
        'Peaceful atmosphere',
      ],
      terrain: 'Paved pathways, garden trails',
      bestTime: 'Morning or late afternoon',
      rating: 4.3,
      reviewCount: 89,
    ),
    PopularRoute(
      id: '4',
      name: 'Patan Durbar Loop',
      distance: '3.2 km',
      difficulty: 'Medium',
      owner: 'Anjali B.',
      description:
          'The Patan Durbar Loop is a cultural immersion into the ancient city of Lalitpur. This medium-difficulty urban trail circles through the UNESCO World Heritage Site of Patan Durbar Square and its surrounding traditional neighborhoods.\n\nThe route showcases the finest Newari architecture in Nepal, from the intricately carved wooden windows of ancient houses to the stunning temples of the Durbar Square. You\'ll pass artisan workshops where traditional metalwork and wood carving continue as they have for generations.\n\nThis walk is as much an education as exercise, with every corner revealing historical treasures. The route includes some narrow passages and occasional steps, adding variety to the terrain.',
      estimatedTime: '45-60 min',
      elevation: 'Minimal',
      tags: ['Heritage', 'Architecture', 'Cultural'],
      images: [
        'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=800',
        'https://images.unsplash.com/photo-1605640840605-14ac1855827b?w=800',
        'https://images.unsplash.com/photo-1582654291650-f2a2c8b49ae0?w=800',
      ],
      highlights: [
        'UNESCO World Heritage Site',
        'Ancient temples',
        'Traditional craft workshops',
        'Newari architecture',
      ],
      terrain: 'Brick-paved squares, narrow lanes',
      bestTime: 'Morning for fewer crowds',
      rating: 4.7,
      reviewCount: 198,
    ),
    PopularRoute(
      id: '5',
      name: 'Boudha Circle',
      distance: '2.8 km',
      difficulty: 'Easy',
      owner: 'Rajesh K.',
      description:
          'Boudha Circle is a meditative walking route around the sacred Boudhanath Stupa, one of the largest Buddhist stupas in the world. This easy route follows the traditional kora (circumambulation) path that pilgrims have walked for centuries.\n\nThe outer circuit takes you past monasteries, butter lamp offerings, and shops selling Tibetan handicrafts. The inner circle brings you closer to the massive white dome, with its golden spire and prayer flags stretching toward the sky. Many choose to spin the prayer wheels as they walk, adding a spiritual dimension to their exercise.\n\nThe area is especially magical during morning and evening prayers when monks chant and devotees light butter lamps. Multiple loops can easily extend your walk while maintaining the peaceful, contemplative atmosphere.',
      estimatedTime: '35-45 min',
      elevation: 'Flat',
      tags: ['Spiritual', 'Peaceful', 'Historic'],
      images: [
        'https://images.unsplash.com/photo-1609766857041-ed402ea8069a?w=800',
        'https://images.unsplash.com/photo-1565073624497-7144969d0a07?w=800',
        'https://images.unsplash.com/photo-1585938389612-a552a28d6914?w=800',
      ],
      highlights: [
        'Boudhanath Stupa',
        'Prayer wheels',
        'Tibetan monasteries',
        'Spiritual atmosphere',
      ],
      terrain: 'Paved circular path',
      bestTime: 'Early morning or dusk',
      rating: 4.9,
      reviewCount: 312,
    ),
    PopularRoute(
      id: '6',
      name: 'Nagarjun Forest Hike',
      distance: '5.5 km',
      difficulty: 'Hard',
      owner: 'Bikash T.',
      description:
          'The Nagarjun Forest Hike is a challenging trail through the Shivapuri Nagarjun National Park, offering a true wilderness experience just minutes from Kathmandu city. This route climbs through dense forest to reach the summit with stunning Himalayan views.\n\nThe trail begins at the park entrance and ascends steadily through oak, rhododendron, and pine forests. Wildlife sightings are common, including langur monkeys, pheasants, and occasionally deer. The forest canopy provides welcome shade for most of the climb.\n\nAt the top, on clear days, you can see the snow-capped peaks of the Langtang range. The descent can be challenging on tired legs, so poles are recommended. This is a rewarding workout for experienced hikers.',
      estimatedTime: '2.5-3 hours',
      elevation: '450m climb',
      tags: ['Forest', 'Wildlife', 'Challenging'],
      images: [
        'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800',
        'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=800',
        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
      ],
      highlights: [
        'Dense forest trails',
        'Himalayan views',
        'Wildlife encounters',
        'Summit achievement',
      ],
      terrain: 'Forest trails, steep sections',
      bestTime: 'Early morning start',
      rating: 4.6,
      reviewCount: 145,
    ),
  ];
}
