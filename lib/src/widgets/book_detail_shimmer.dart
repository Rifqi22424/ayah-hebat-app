import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../consts/padding_sizes.dart';

class BookDetailShimmer extends StatelessWidget {
  const BookDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      // appBar: AppBar(
      //   title: Container(
      //     height: 20,
      //     width: 100,
      //     color: Colors.white,
      //   ),
      //   leading: Icon(Icons.arrow_back, color: Colors.grey),
      // ),
      body: SafeArea(
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            children: [
              // Placeholder untuk gambar buku
              Container(
                height: height * 0.45,
                width: double.infinity,
                color: Colors.white,
              ),
              SizedBox(height: 16),
        
              // Placeholder untuk kategori dan stok
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Container(
                      height: 20,
                      width: 200,
                      color: Colors.white,
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 14,
                      width: 100,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
        
              // Placeholder untuk TabBar
              Container(
                height: 40,
                width: double.infinity,
                color: Colors.white,
              ),
              SizedBox(height: 16),
        
              // Placeholder untuk TabBarView (cerita singkat atau komentar)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Placeholder untuk gambar user
                              Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 16),
                              // Placeholder untuk nama user dan komentar
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 14,
                                      width: 150,
                                      color: Colors.white,
                                    ),
                                    SizedBox(height: 8),
                                    Container(
                                      height: 12,
                                      width: double.infinity,
                                      color: Colors.white,
                                    ),
                                    SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
                ),
              ),
        
              // Placeholder untuk tombol Pinjam Buku
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
