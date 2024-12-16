import 'package:ayahhebat/src/pages/announcement/detail_announcement_page.dart';
import 'package:ayahhebat/src/pages/deleteAccount/input_verification_code_page.dart';
import 'package:ayahhebat/src/pages/deleteAccount/send_verification_code_page.dart';
import 'package:ayahhebat/src/pages/deleteAccount/submit_account_deletion_page.dart';
import 'package:ayahhebat/src/pages/detail_story_page.dart';
import 'package:ayahhebat/src/pages/faq_page.dart';
import 'package:ayahhebat/src/pages/forum/comments_page.dart';
import 'package:ayahhebat/src/pages/message_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../pages/add_book_page.dart';
import '../pages/announcement/announcement_page.dart';
import '../pages/book/book_detail_page.dart';
import '../pages/book/borrow_book_detail_page.dart';
import '../pages/book/donation_book_detail_page.dart';
import '../pages/book/manage_books_page.dart';
import '../pages/change_password_page.dart';
import '../pages/my_ranking_page.dart';
import '../pages/news_content_page.dart';
import '../pages/profiles/edit_profile_page.dart';
import '../pages/story_page.dart';
import '../pages/login_page.dart';
import '../pages/main_page.dart';
import '../pages/profiles/add_profile_page.dart';
import '../pages/regist_page.dart';
import '../pages/splash_page.dart';
import '../pages/verification_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "/":
        return MaterialPageRoute(builder: (context) => const SplashPage());
      case "/login":
        return MaterialPageRoute(builder: (context) => const LoginPage());
      case "/regist":
        return MaterialPageRoute(builder: (context) => const RegistPage());
      case "/verification":
        final args = settings.arguments as Map<String, dynamic>;
        final String email = args['email'];
        return MaterialPageRoute(
            builder: (context) => VerificationPage(
                  email: email,
                ));

      case "/book":
        return MaterialPageRoute(
            builder: (context) => const MainPage(index: 2));
      case "/bookDetail":
        final args = settings.arguments as Map<String, dynamic>;
        final int bookId = args['bookId'];
        return MaterialPageRoute(
            builder: (context) => BookDetailPage(bookId: bookId));
      case "/addBook":
        return MaterialPageRoute(builder: (context) => AddBookPage());
      case "/borrowBookDetail":
        final args = settings.arguments as Map<String, dynamic>;
        final int borrowId = args['borrowId'];
        final String fromPage = args['fromPage'];
        return MaterialPageRoute(
            builder: (context) =>
                BorrowBookDetailPage(borrowId: borrowId, fromPage: fromPage));
      case "/donationBookDetail":
        final args = settings.arguments as Map<String, dynamic>;
        final int bookId = args['bookId'];
        return MaterialPageRoute(
            builder: (context) => DonationBookDetailPage(bookId: bookId));
      case "/manageBooks":
        return MaterialPageRoute(builder: (context) => ManageBooksPage());
      case "/profile":
        return MaterialPageRoute(
            builder: (context) => const MainPage(index: 4));
      case "/addProfile":
        return MaterialPageRoute(builder: (context) => const AddProfilePage());
      case "/editProfile":
        return MaterialPageRoute(builder: (context) => const EditProfilePage());
      case "/changePassword":
        return MaterialPageRoute(
            builder: (context) => const ChangePasswordPage());
      case "/announcement":
        return MaterialPageRoute(
            builder: (context) => const AnnouncementPage());
      case "/detailAnnouncement":
        final args = settings.arguments as Map<String, dynamic>;
        final int announcementId = args['announcementId'];
        return MaterialPageRoute(
            builder: (context) =>
                DetailAnnouncementPage(announcementId: announcementId));
      case "/story":
        return MaterialPageRoute(builder: (context) => const StoryPage());
      case "/detailStory":
        final args = settings.arguments as Map<String, dynamic>;
        final int kegiatanId = args['kegiatanId'];
        return MaterialPageRoute(
            builder: (context) => DetailStoryPage(
                  kegiatanId: kegiatanId,
                ));
      case "/ranking":
        return MaterialPageRoute(builder: (context) => const MyRangkingPage());
      case "/home":
        return MaterialPageRoute(
            builder: (context) => const MainPage(
                  index: 0,
                ));
      case "/news":
        return MaterialPageRoute(
            builder: (context) => const MainPage(
                  index: 1,
                ));
      case "/forum":
        return MaterialPageRoute(
            builder: (context) => const MainPage(
                  index: 3,
                ));
      case "/comments":
        final args = settings.arguments as Map<String, dynamic>;
        final int indexPostProvider = args['indexPostProvider'];
        final Post post = args['post'];
        final bool autoFocus = args['autoFocus'];
        return MaterialPageRoute(
            builder: (context) => CommentsPage(
                indexPostProv: indexPostProvider,
                post: post,
                autoFocus: autoFocus));
      case "/newsContent":
        final args = settings.arguments as Map<String, dynamic>;
        final int newsId = args['newsId'];
        return MaterialPageRoute(
            builder: (context) => NewsContentPage(newsId: newsId));
      case "/faq":
        return MaterialPageRoute(builder: (context) => const FaqPage());
      case "/message":
        final message = settings.arguments as RemoteMessage;
        return MaterialPageRoute(
            builder: (context) => MessagePage(
                  message: message,
                ));
      case "/sendVerificationCode":
        return MaterialPageRoute(
            builder: (context) => const SendVerificationCodePage());
      case "/inputVerificationCode":
        final args = settings.arguments as Map<String, dynamic>;
        final String email = args['email'];
        return MaterialPageRoute(
            builder: (context) => InputVerificationCodePage(
                  email: email,
                ));
      case "/submitAccountDeletion":
        return MaterialPageRoute(
            builder: (context) => const SubmitAccountDeletionPage());
    }
    return _errorRoute();
  }
}

Route<dynamic> _errorRoute() {
  return MaterialPageRoute(
    builder: (context) {
      return const Scaffold(
        body: Center(
          child: Text('Error Route'),
        ),
      );
    },
  );
}
