import 'package:flutter/material.dart';

import '../consts/app_colors.dart';
import '../consts/app_styles.dart';
import '../providers/ranking_provider.dart';

class RankingPeriodFilter extends StatelessWidget {
  const RankingPeriodFilter({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  final RankingPeriod selectedPeriod;
  final ValueChanged<RankingPeriod> onPeriodChanged;

  Alignment _tabAlignment() {
    switch (selectedPeriod) {
      case RankingPeriod.daily:
        return Alignment.centerLeft;
      case RankingPeriod.weekly:
        return Alignment.center;
      case RankingPeriod.monthly:
        return Alignment.centerRight;
    }
  }

  String _activeLabel() {
    switch (selectedPeriod) {
      case RankingPeriod.daily:
        return 'Daily';
      case RankingPeriod.weekly:
        return 'Monthly';
      case RankingPeriod.monthly:
        return 'Ever';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Container(
          width: 343,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 30,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Tab labels row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onPeriodChanged(RankingPeriod.daily),
                      child: Center(
                        child: Text('Daily', style: AppStyles.labelTextStyle),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onPeriodChanged(RankingPeriod.weekly),
                      child: Center(
                        child: Text('Monthly', style: AppStyles.labelTextStyle),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onPeriodChanged(RankingPeriod.monthly),
                      child: Center(
                        child: Text('Ever', style: AppStyles.labelTextStyle),
                      ),
                    ),
                  ),
                ],
              ),
              // Animated active pill
              AnimatedAlign(
                alignment: _tabAlignment(),
                duration: const Duration(milliseconds: 300),
                child: IgnorePointer(
                  child: Container(
                    width: 343 / 3,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Center(
                      child: Text(
                        _activeLabel(),
                        style: AppStyles.heading3WhiteTextStyle,
                      ),
                    ),
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
