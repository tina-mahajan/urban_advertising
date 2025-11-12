import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:urban_advertising/widgets/bottom_navbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Map<String, String>> banners = [
    {
      'image': 'assets/city2.jpg',
      'title': 'Experience Creative Advertising',
      'subtitle': 'Connecting brands with their audience through innovation.',
    },
    {
      'image': 'assets/banner2.jpg',
      'title': 'Grow Your Brand Visibility',
      'subtitle': 'Outdoor, digital, and print campaigns that deliver results.',
    },
    {
      'image': 'assets/banner4.jpg',
      'title': 'Your Campaign, Our Strategy',
      'subtitle': 'Seamless management from idea to execution.',
    },
  ];

  final List<Map<String, dynamic>> services = const [
    {
      'title': 'Video Production',
      'icon': Icons.videocam_outlined,
    },
    {
      'title': 'Outdoor Advertising',
      'icon': Icons.storefront_outlined,
    },
    {
      'title': 'Social Media Marketing',
      'icon': Icons.public_outlined,
    },
    {
      'title': 'Graphic Designing',
      'icon': Icons.palette_outlined,
    },
    {
      'title': 'Website Design',
      'icon': Icons.web_outlined,
    },
    {
      'title': 'Photo Shoots',
      'icon': Icons.camera_alt_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔹 HEADER CAROUSEL SECTION
            Stack(
              children: [
                CarouselSlider.builder(
                  itemCount: banners.length,
                  itemBuilder: (context, index, realIndex) {
                    final banner = banners[index];
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          banner['image']!,
                          fit: BoxFit.cover,
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black87],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, bottom: 80),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                banner['title']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                banner['subtitle']!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 20),
                              OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(
                                      color: Colors.white, width: 1.5),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 28, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(30)),
                                ),
                                child: const Text(
                                  'EXPLORE NOW',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                  options: CarouselOptions(
                    height: 680, // 🔹 Increased height
                    viewportFraction: 1.0,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 4),
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                ),

                // 🔹 "Urban Advertising" Title on top
                SafeArea(
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Urban Advertising",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.person, color: Colors.white),
                          onPressed: () =>
                              Navigator.pushNamed(context, '/profile'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 🔹 PAGE INDICATORS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: banners.asMap().entries.map((entry) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _currentIndex == entry.key ? 16 : 8,
                  height: 8,
                  margin:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: _currentIndex == entry.key
                        ? Colors.white
                        : Colors.grey,
                  ),
                );
              }).toList(),
            ),


            // 🌙 Active Plan Section (Dark Theme)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade800, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Active Plan',
                      style: TextStyle(color: Colors.white60, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Growth Plan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: 10 / 15, // dynamic value
                        backgroundColor: Colors.grey.shade900,
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF00C2FF)), // neon blue
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Limit used: 12/15',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C2FF).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF00C2FF)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          child: const Text(
                            'Renew Now',
                            style: TextStyle(
                              color: Color(0xFF00C2FF),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

// 🌌 Upcoming Slot Section (Dark Theme)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade800, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF00C885), // neon green background
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(10),
                      child: const Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '20 May 2025',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '02:00 PM to 04:00 PM',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),


            // 🔹 SERVICES SECTION
            const Padding(
              padding:
              EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Our Services',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: services.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, index) {
                  final service = services[index];
                  bool isHovered = false;

                  return StatefulBuilder(
                    builder: (context, setState) {
                      return MouseRegion(
                        onEnter: (_) => setState(() => isHovered = true),
                        onExit: (_) => setState(() => isHovered = false),
                        child: GestureDetector(
                          onTap: () {},
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isHovered
                                    ? [const Color(0xFF1E88E5), const Color(0xFF673AB7)]
                                    : [const Color(0xFF232323), const Color(0xFF121212)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                if (isHovered)
                                  BoxShadow(
                                    color: Colors.blueAccent.withOpacity(0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.white.withOpacity(0.1),
                                  child: Icon(service['icon'], color: Colors.white, size: 30),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  service['title'],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),


            const SizedBox(height: 60),





          ],
        ),
      ),


      // 🔹 Bottom Nav Bar
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        onTap: (i) {
          if (i == 0) return;
          if (i == 1) Navigator.pushNamed(context, '/slot_booking');
          if (i == 2) Navigator.pushNamed(context, '/subscription');
          if (i == 3) Navigator.pushNamed(context, '/profile');
        },
      ),
    );
  }
}



// 🔹 Hoverable Service Card (Works for both Web & Mobile)
class HoverServiceCard extends StatefulWidget {
  final Map<String, dynamic> service;
  const HoverServiceCard({super.key, required this.service});

  @override
  State<HoverServiceCard> createState() => _HoverServiceCardState();
}

class _HoverServiceCardState extends State<HoverServiceCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isHovered = true),
        onTapUp: (_) => setState(() => _isHovered = false),
        onTapCancel: () => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: _isHovered
              ? (Matrix4.identity()..scale(1.03))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: _isHovered
                ? const Color(0xFF2E8BFF).withOpacity(0.9)
                : const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
              _isHovered ? Colors.blueAccent : Colors.grey.shade800,
              width: 1,
            ),
            boxShadow: _isHovered
                ? [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ]
                : [],
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                widget.service['icon'],
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  widget.service['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

