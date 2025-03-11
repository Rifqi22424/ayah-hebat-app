import 'package:ayahhebat/src/consts/padding_sizes.dart';
import 'package:ayahhebat/src/providers/infaq_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../consts/app_colors.dart';
import '../../widgets/app_bar_builder.dart';
import '../../widgets/infaq_list_tile.dart';

class InfaqHistoryPage extends StatefulWidget {
  const InfaqHistoryPage({super.key});

  @override
  State<InfaqHistoryPage> createState() => _InfaqHistoryPageState();
}

class _InfaqHistoryPageState extends State<InfaqHistoryPage> {
  final ScrollController _infaqScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<InfaqProvider>().fetchInfaqs();
    _infaqScrollController.addListener(() {
      if (_infaqScrollController.position.pixels ==
          _infaqScrollController.position.maxScrollExtent) {
        context.read<InfaqProvider>().fetchInfaqs();
        print("fetch infaq");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarBuilder(
        title: "Riwayat Iuran",
        showBackButton: true,
        showCancelButton: false,
        onBackButtonPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Consumer<InfaqProvider>(
        builder: (context, value, child) {
          print("InfaqState: ${value.state}");

          if ((value.state == InfaqState.initial && value.infaqs.isEmpty) ||
              (value.state == InfaqState.loading && value.infaqs.isEmpty)) {
            return Center(
                child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ));
          }

          if (value.state == InfaqState.error) {
            return Center(
              child: TextButton(
                  onPressed: () =>
                      context.read<InfaqProvider>().refreshInfaqs(),
                  child: Text("Retry"),
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.redColor,
                      disabledBackgroundColor: AppColors.halfRedColor)),
            );
          }

          if (value.state == InfaqState.loaded && value.infaqs.isEmpty) {
            return Center(child: Text("Belum ada infaq"));
          }

          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: PaddingSizes.small),
            child: RefreshIndicator(
              color: AppColors.primaryColor,
              onRefresh: () => context.read<InfaqProvider>().refreshInfaqs(),
              child: ListView.builder(
                controller: _infaqScrollController,
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: value.infaqs.length + 1,
                itemBuilder: (context, index) {
                  if (index == value.infaqs.length) {
                    if (value.hasMoreData) {
                      value.fetchInfaqs();
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      );
                    } else {
                      return SizedBox.shrink();
                    }
                  }
                  return InfaqListTile(infaq: value.infaqs[index]);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // Future<void> _onRefresh() async {
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     if (_infaqScrollController.position.maxScrollExtent <= 0) {
  //       context.read<InfaqProvider>().fetchInfaqs();
  //     }
  //   });
  // }
}
