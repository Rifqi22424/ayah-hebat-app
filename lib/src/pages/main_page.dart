import 'package:ayahhebat/src/pages/alms/alms_page.dart';
import 'package:ayahhebat/src/pages/forum/forums_page.dart';
import 'package:flutter/material.dart';
import '../consts/app_colors.dart';
import '../consts/app_styles.dart';
import 'book/book_page.dart';
import 'home_page.dart';
import 'infaq/infaq_page.dart';
import 'news/news_page.dart';
import 'profiles/profile_page.dart';
import 'watch/watch_page.dart';

class MainPage extends StatefulWidget {
  final int index;
  const MainPage({required this.index, super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
    // Provider.of<PostProvider>(context, listen: false).fetchPosts();
  }

  final List<Widget> _pages = [
    const HomePage(),
    const AlmsPage(),
    const WatchPage(),
    const NewsPage(),
    const BookPage(),
    const ForumsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return _buildFullModal(context);
      },
    );
  }

  Widget _buildFullModal(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 24),
            child: _buildMenuSheet(),
          ),
          Positioned(
            top: -40,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Color(0xFF2C2C2E),
                  size: 25,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFF3A3A3C),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Menu',
              style: AppStyles.heading3PrimaryTextStyle.copyWith(
                  color: AppColors.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.0,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _buildMenuGridItem(context,
                  icon: 'images/book.png', label: 'Buku', index: 4),
              _buildMenuGridItem(context,
                  icon: 'images/forums-icon.png', label: 'Forum', index: 5),
              _buildMenuGridItem(context,
                  icon: 'images/profile-icon.png', label: 'Profile', index: 6),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: 134,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFF3A3A3C),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMenuGridItem(BuildContext context,
      {required String icon, required String label, required int index}) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              icon,
              width: 32,
              height: 32,
              color: AppColors.textColor,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppStyles.heading3WhiteTextStyle
                  .copyWith(color: AppColors.textColor, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBar buildBottomNavigationBar() {
    int activeNavBarIndex = (_currentIndex <= 3) ? _currentIndex : 4;

    return BottomNavigationBar(
        currentIndex: activeNavBarIndex,
        onTap: (index) {
          if (index == 4) {
            _showMoreMenu(context);
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: _buildIcon(0, 'images/home-icon.png'),
            label: 'Home',
          ),
          BottomNavigationBarItem(
              icon: _buildIcon(1, 'images/infaq-icon.png'), label: 'WADA'),
          BottomNavigationBarItem(
              icon: _buildIcon(2, 'images/watch.png'), label: 'Konten'),
          BottomNavigationBarItem(
              icon: _buildIcon(3, 'images/news-icon.png'), label: 'Berita'),
          BottomNavigationBarItem(
            icon: _buildIcon(4, 'images/more.png'),
            label: 'More',
          ),
        ],
        backgroundColor: AppColors.textColor,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        unselectedItemColor: AppColors.whiteColor,
        selectedItemColor: AppColors.primaryColor,
        selectedLabelStyle: AppStyles.heading3PrimaryTextStyle,
        unselectedLabelStyle: AppStyles.heading3WhiteTextStyle);
  }

  Widget _buildIcon(int itemIndex, String image) {
    int activeNavBarIndex = (_currentIndex <= 3) ? _currentIndex : 4;
    bool isActive = (activeNavBarIndex == itemIndex);

    return isActive
        ? ColorFiltered(
            colorFilter: const ColorFilter.mode(
              AppColors.primaryColor,
              BlendMode.modulate,
            ),
            child: Image.asset(
              image,
              width: 28,
              height: 28,
            ),
          )
        : Image.asset(
            image,
            width: 28,
            height: 28,
          );
  }
}
