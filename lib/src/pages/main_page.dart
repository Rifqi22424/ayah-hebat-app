import 'package:ayahhebat/src/pages/forum/forums_page.dart';
import 'package:flutter/material.dart';
import '../consts/app_colors.dart';
import '../consts/app_styles.dart';
import 'home_page.dart';
import 'news/news_page.dart';
import 'profiles/profile_page.dart';

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
    //  Provider.of<PostProvider>(context, listen: false).fetchPosts();
  }

  final List<Widget> _pages = [
    const HomePage(),
    const NewsPage(),
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

  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: _buildIcon(0, 'images/home-icon.png'),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(1, 'images/news-icon.png'),
            label: 'Berita',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(2, 'images/forums-icon.png'),
            label: 'Forum',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(3, 'images/profile-icon.png'),
            label: 'Profile',
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

  Widget _buildIcon(int index, String image) {
    return _currentIndex == index
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
