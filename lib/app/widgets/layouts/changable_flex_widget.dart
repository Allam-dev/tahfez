import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:tahfez/core/extensions/context/media_query.dart';

class ChangableFlexWidget extends StatefulWidget {
  final int initFlex;
  final int maxFlex;
  final int minFlex;
  final Widget child1;
  final Widget child2;
  final Color dividerColor;
  final Color primaryColor;
  final double dividerWidth;
  final double dividerThikness;
  final double dividerPadding;

  const ChangableFlexWidget({
    super.key,
    this.initFlex = 40,
    this.maxFlex = 80,
    this.minFlex = 20,
    required this.child1,
    required this.child2,
    this.dividerColor = Colors.black,
    this.primaryColor = Colors.blue,
    this.dividerWidth = 20,
    this.dividerThikness = 1,
    this.dividerPadding = 0,
  });

  @override
  State<ChangableFlexWidget> createState() => _ChangableFlexWidgetState();
}

class _ChangableFlexWidgetState extends State<ChangableFlexWidget> {
  bool isDraging = false;

  @override
  Widget build(BuildContext context) {
    bool isRTL = Directionality.of(context) == TextDirection.rtl;

    return BlocProvider<_Cubit>(
      create: (context) => _Cubit(widget.initFlex),

      child: Builder(
        builder: (context) {
          final cubit = context.read<_Cubit>();

          return BlocBuilder<_Cubit, int>(
            builder: (context, state) => Row(
              children: [
                Expanded(
                  flex: (isRTL ? 100 - state : state).clamp(
                    widget.minFlex,
                    widget.maxFlex,
                  ),
                  child: widget.child1,
                ),
                GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    cubit.changeFlex(
                      (details.globalPosition.dx / context.screenWidth * 100)
                          .toInt(),
                    );
                  },
                  onHorizontalDragStart: (details) {
                    cubit.changeFlex(
                      (details.globalPosition.dx / context.screenWidth * 100)
                          .toInt(),
                    );
                    setState(() {
                      isDraging = true;
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    setState(() {
                      isDraging = false;
                    });
                  },
                  onHorizontalDragCancel: () {
                    setState(() {
                      isDraging = false;
                    });
                  },
                  child: VerticalDivider(
                    color: isDraging
                        ? widget.primaryColor
                        : widget.dividerColor,
                    width: widget.dividerWidth,
                    thickness: widget.dividerThikness,
                    indent: widget.dividerPadding,
                    endIndent: widget.dividerPadding,
                  ),
                ),
                Expanded(
                  flex: (isRTL ? state : 100 - state).clamp(
                    widget.minFlex,
                    widget.maxFlex,
                  ),
                  child: widget.child2,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Cubit extends HydratedCubit<int> {
  final int initFlex;

  _Cubit(this.initFlex) : super(initFlex) {
    emit(state);
  }

  void changeFlex(int flex) => emit(flex);

  @override
  int? fromJson(Map<String, dynamic> json) => json['flex'] ?? initFlex;

  @override
  Map<String, dynamic>? toJson(int state) => {'flex': state};
}
