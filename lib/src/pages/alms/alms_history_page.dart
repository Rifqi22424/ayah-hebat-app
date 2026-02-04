import 'package:ayahhebat/src/consts/padding_sizes.dart';
import 'package:ayahhebat/src/providers/alms_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../consts/app_colors.dart';
import '../../widgets/app_bar_builder.dart';
import '../../widgets/alms_list_tile.dart';

class AlmsHistoryPage extends StatefulWidget {
  const AlmsHistoryPage({super.key});

  @override
  State<AlmsHistoryPage> createState() => _AlmsHistoryPageState();
}

class _AlmsHistoryPageState extends State<AlmsHistoryPage> {
  final ScrollController _almsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final almsProvider = context.read<AlmsProvider>();
        almsProvider.fetchAlmss();
        _almsScrollController.addListener(() async {
          if (_almsScrollController.position.pixels ==
                  _almsScrollController.position.maxScrollExtent &&
              almsProvider.hasMoreData &&
              !almsProvider.isAlmsLoading) {
            context.read<AlmsProvider>().fetchAlmss();
            print("fetch alms");
          }
        });
      });
    }
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
      body: Consumer<AlmsProvider>(
        builder: (context, value, child) {
          print("AlmsState: ${value.state}");

          if ((value.state == AlmsState.initial && value.almss.isEmpty) ||
              (value.state == AlmsState.loading && value.almss.isEmpty)) {
            return Center(
                child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ));
          }

          if (value.state == AlmsState.error) {
            return Center(
              child: TextButton(
                  onPressed: () => context.read<AlmsProvider>().refreshAlmss(),
                  child: Text("Retry"),
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.redColor,
                      disabledBackgroundColor: AppColors.halfRedColor)),
            );
          }

          if (value.state == AlmsState.loaded && value.almss.isEmpty) {
            return Center(child: Text("Belum ada iuran"));
          }

          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: PaddingSizes.medium),
            child: RefreshIndicator(
              color: AppColors.primaryColor,
              onRefresh: () => context.read<AlmsProvider>().refreshAlmss(),
              child: ListView.builder(
                controller: _almsScrollController,
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: value.almss.length + (value.hasMoreData ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == value.almss.length) {
                    if (value.hasMoreData) {
                      value.fetchAlmss();
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      );
                    }
                  }
                  return AlmsListTile(alms: value.almss[index]);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
