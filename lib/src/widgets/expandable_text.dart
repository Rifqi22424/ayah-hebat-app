import 'package:flutter/material.dart';
import '../consts/app_styles.dart';

class ExpandableText extends StatefulWidget {
  final String body;

  const ExpandableText({
    Key? key,
    required this.body,
  }) : super(key: key);

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;
  bool tappable = false;

  String _getShortenedText(String text) {
    return text.substring(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.body.length > 100) {
      return RichText(
          text:
              TextSpan(style: AppStyles.labelTextStyle, children: <InlineSpan>[
        TextSpan(
          text: isExpanded ? widget.body : _getShortenedText(widget.body),
        ),
        if (tappable && isExpanded)
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: InkWell(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Text(
                '..persingkat',
                style:
                    AppStyles.heading3PrimaryTextStyle, 
              ),
            ),
          ),
        if (!isExpanded)
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: InkWell(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                  tappable = true;
                });
              },
              child: Text(
                '..selengkapnya',
                style:
                    AppStyles.heading3PrimaryTextStyle, 
              ),
            ),
          ),
      ]));
    } else {
      return Text(
        widget.body,
        softWrap: true,
        style: AppStyles.labelTextStyle,
      );
    }
  }
}

// import 'package:flutter/material.dart';

// import '../consts/app_styles.dart';

// class ExpandableText extends StatefulWidget {
//   final String body;

//   const ExpandableText({
//     Key? key,
//     required this.body,
//   }) : super(key: key);

//   @override
//   _ExpandableTextState createState() => _ExpandableTextState();
// }

// class _ExpandableTextState extends State<ExpandableText> {
//   bool isExpanded = false;

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         // Set maximum lines to 2 if not expanded
//         final textSpan = TextSpan(
//           text: widget.body,
//           style: AppStyles.medium2TextStyle,
//         );

//         final textPainter = TextPainter(
//           text: textSpan,
//           maxLines: isExpanded ? null : 2,
//           textDirection: TextDirection.ltr,
//         );

//         textPainter.layout(maxWidth: constraints.maxWidth);

//         // Check if text is overflowing
//         final isOverflowing = textPainter.didExceedMaxLines;

//         return RichText(
//           text: TextSpan(
//             style: AppStyles.medium2TextStyle,
//             children: [
//               TextSpan(
//                 text: isExpanded || !isOverflowing
//                     ? widget.body
//                     : widget.body.substring(0, textPainter.getPositionForOffset(Offset(constraints.maxWidth, textPainter.height)).offset) + '...',
//               ),
//               if (isOverflowing)
//                 WidgetSpan(
//                   alignment: PlaceholderAlignment.baseline,
//                   baseline: TextBaseline.alphabetic,
//                   child: GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         isExpanded = !isExpanded;
//                       });
//                     },
//                     child: Text(
//                       isExpanded ? ' Kecilkan' : '... Lihat Selengkapnya',
//                       style: TextStyle(
//                         color: Colors.blue, // Set the clickable text style
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
