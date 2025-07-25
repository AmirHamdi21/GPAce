import 'package:flutter/material.dart';
import 'package:gpa_calculator/SelectInput/select_input_page.dart';
import 'package:gpa_calculator/provider/theme_provider.dart';
import 'package:provider/provider.dart';

import '../GPA_history/gpa_save.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final screenWidth = MediaQuery.of(context).size.width;

    return Theme(
      data: Provider.of<ThemeProvider>(context).isDarkMode
          ? ThemeData.dark()
          : ThemeData.light(),
      child: Scaffold(
        backgroundColor: Provider.of<ThemeProvider>(context).isDarkMode
            ? const Color(0xFF1a1a1a)
            : Colors.white,
        body: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              leading: null,
              toolbarHeight: 70.0,
              backgroundColor: Provider.of<ThemeProvider>(context).isDarkMode
                  ? const Color(0xFF2d3748)
                  : Colors.white,
              elevation: 0,
              pinned: true,
              expandedHeight: 0,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  color: Provider.of<ThemeProvider>(context).isDarkMode
                      ? const Color(0xFF2d3748)
                      : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 40 : 20,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Logo
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4299e1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.school,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'GPA Calculator',
                              style: TextStyle(
                                fontSize: isTablet ? 20 : 18,
                                fontWeight: FontWeight.bold,
                                color: Provider.of<ThemeProvider>(context)
                                        .isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                        // Navigation
                        if (isTablet)
                          Row(
                            children: [
                              _buildNavItem('Home', true),
                              _buildNavItem('Input', false),
                              _buildNavItem('Result', false),
                              _buildNavItem('History', false),
                              const SizedBox(width: 20),
                              _buildThemeToggle(),
                            ],
                          )
                        else
                          Row(
                            children: [
                              ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Color(0xFF4299e1))),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const GPAHistoryPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "History",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 25),
                              _buildThemeToggle(),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Main Content
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      // Hero Section
                      _buildHeroSection(isTablet, screenWidth),
                      // Features Section
                      _buildFeaturesSection(isTablet, screenWidth),
                      // CTA Section
                      _buildCTASection(isTablet, screenWidth),
                      // Footer
                      _buildFooter(isTablet),
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

  Widget _buildNavItem(String title, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF4299e1) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isActive
              ? Colors.white
              : (Provider.of<ThemeProvider>(context).isDarkMode
                  ? Colors.white70
                  : Colors.black54),
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildThemeToggle() {
    return GestureDetector(
      onTap: () async {
        // Make the toggle async since toggleTheme is now async
        await Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Provider.of<ThemeProvider>(context).isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Provider.of<ThemeProvider>(context).isDarkMode
              ? Icons.light_mode
              : Icons.dark_mode,
          color: Provider.of<ThemeProvider>(context).isDarkMode
              ? Colors.white
              : Colors.black,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isTablet, double screenWidth) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF4299e1),
            Color(0xFF3182ce),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background circles
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(75),
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: 50,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            right: 100,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 60 : 24,
              vertical: isTablet ? 100 : 60,
            ),
            child: Column(
              children: [
                Text(
                  'GPA Calculator',
                  style: TextStyle(
                    fontSize: isTablet ? 48 : 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Track Your Academic Progress',
                  style: TextStyle(
                    fontSize: isTablet ? 24 : 18,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Text(
                  'Effort counts. GPA tracking made simple and smart.',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    color: Colors.white.withOpacity(0.8),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                _buildCTAButton('Get Started', isTablet),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(bool isTablet, double screenWidth) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 60 : 24,
        vertical: isTablet ? 80 : 60,
      ),
      color: Provider.of<ThemeProvider>(context).isDarkMode
          ? const Color(0xFF2d3748)
          : Colors.white,
      child: Column(
        children: [
          Text(
            'Why Choose Our GPA Calculator?',
            style: TextStyle(
              fontSize: isTablet ? 36 : 28,
              fontWeight: FontWeight.bold,
              color: Provider.of<ThemeProvider>(context).isDarkMode
                  ? Colors.white
                  : Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Experience the most intuitive and comprehensive GPA tracking solution\ndesigned for students.',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: Provider.of<ThemeProvider>(context).isDarkMode
                  ? Colors.white70
                  : Colors.black54,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          _buildFeatureGrid(isTablet),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid(bool isTablet) {
    final features = [
      {
        'icon': Icons.book,
        'title': 'Easy Subject Entry',
        'description':
            'Quickly add subjects with intuitive forms and validation',
      },
      {
        'icon': Icons.calculate,
        'title': 'Real-time GPA Calculation',
        'description':
            'See your GPA calculated instantly with accurate formulas',
      },
      {
        'icon': Icons.bar_chart,
        'title': 'Semester History',
        'description': 'Track your academic progress across multiple semesters',
      },
      {
        'icon': Icons.auto_awesome,
        'title': 'Beautiful & Clean UI',
        'description': 'Modern design with smooth animations and dark mode',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 4 : 2,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: isTablet
            ? 1.4
            : MediaQuery.of(context).size.height *
                0.0009, // Increased aspect ratio
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return _buildFeatureCard(
          feature['icon'] as IconData,
          feature['title'] as String,
          feature['description'] as String,
          isTablet,
        );
      },
    );
  }

  Widget _buildFeatureCard(
      IconData icon, String title, String description, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16), // Reduced padding
      decoration: BoxDecoration(
        color: Provider.of<ThemeProvider>(context).isDarkMode
            ? const Color(0xFF4a5568)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center content
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10), // Reduced padding
            decoration: BoxDecoration(
              color: const Color(0xFF4299e1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: isTablet ? 24 : 20, // Reduced icon size
            ),
          ),
          const SizedBox(height: 16), // Reduced spacing
          Flexible(
            // Allow text to be flexible
            child: Text(
              title,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14, // Reduced font size
                fontWeight: FontWeight.bold,
                color: Provider.of<ThemeProvider>(context).isDarkMode
                    ? Colors.white
                    : Colors.black,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8), // Reduced spacing
          Flexible(
            // Allow description to be flexible
            child: Text(
              description,
              style: TextStyle(
                fontSize: isTablet ? 12 : 10, // Reduced font size
                color: Provider.of<ThemeProvider>(context).isDarkMode
                    ? Colors.white70
                    : Colors.black54,
                height: 1.3, // Reduced line height
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTASection(bool isTablet, double screenWidth) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 60 : 24,
        vertical: isTablet ? 80 : 60,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF4299e1),
            Color(0xFF3182ce),
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            'Ready to Track Your Academic Success?',
            style: TextStyle(
              fontSize: isTablet ? 36 : 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            'Join thousands of students who trust our GPA calculator for their academic journey.',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildCTAButton('Calculate Your GPA Now', isTablet),
        ],
      ),
    );
  }

  Widget _buildCTAButton(String text, bool isTablet) {
    return ElevatedButton(
      onPressed: () {
        // // Navigate to input page
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('Navigating to $text...'),
        //     backgroundColor: const Color(0xFF4299e1),
        //   ),
        // );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const SubjectInputPage(),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF4299e1),
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 32 : 24,
          vertical: isTablet ? 16 : 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 8,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward, size: 20),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 60 : 24,
        vertical: isTablet ? 40 : 30,
      ),
      color: Provider.of<ThemeProvider>(context).isDarkMode
          ? const Color(0xFF2d3748)
          : Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Made with ❤️ by Amir Hamdi',
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      color: Provider.of<ThemeProvider>(context).isDarkMode
                          ? Colors.white70
                          : Colors.black54,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.email,
                      color: Provider.of<ThemeProvider>(context).isDarkMode
                          ? Colors.white70
                          : Colors.black54,
                      size: 20,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.code,
                      color: Provider.of<ThemeProvider>(context).isDarkMode
                          ? Colors.white70
                          : Colors.black54,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '© 2025 GPA Calculator. All rights reserved.',
            style: TextStyle(
              fontSize: isTablet ? 12 : 10,
              color: Provider.of<ThemeProvider>(context).isDarkMode
                  ? Colors.white70
                  : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
