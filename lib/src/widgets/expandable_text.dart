import 'package:flutter/material.dart';
import '../consts/app_styles.dart';

class ExpandableText extends StatefulWidget {
  final String body;
  final bool isPost;

  const ExpandableText({
    Key? key,
    required this.body,
    required this.isPost,
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
          textAlign: TextAlign.justify,
          text:
              TextSpan(style: AppStyles.labelTextStyle, children: <InlineSpan>[
            TextSpan(
              text: isExpanded ? widget.body : _getShortenedText(widget.body),
              style:
                  // widget.isPost
                  //     ? AppStyles.medium2TextStyle
                  //     :
                  AppStyles.labelTextStyle,
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
                        // widget.isPost
                        //     ? AppStyles.heading2PrimaryTextStyle
                        //     :
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
                        // widget.isPost
                        //     ? AppStyles.heading2PrimaryTextStyle
                        //     :
                        AppStyles.heading3PrimaryTextStyle,
                  ),
                ),
              ),
          ]));
    } else {
      return Text(
        widget.body,
        softWrap: true,
        style:
            // widget.isPost
            //     ? AppStyles.medium2TextStyle
            //     :
            AppStyles.labelTextStyle,
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

// import 'package:flutter/material.dart';
// import '../consts/app_colors.dart';

// class ExpandableText extends StatefulWidget {
//   final String text;
//   final TextStyle style;
//   final TextStyle linkStyle;
//   final int trimLines;

//   const ExpandableText({
//     Key? key,
//     required this.text,
//     required this.style,
//     required this.linkStyle,
//     this.trimLines = 2,
//   }) : super(key: key);

//   @override
//   _ExpandableTextState createState() => _ExpandableTextState();
// }

// class _ExpandableTextState extends State<ExpandableText> {
//   bool _isExpanded = false;

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final painter = TextPainter(
//           text: TextSpan(text: widget.text, style: widget.style),
//           maxLines: widget.trimLines,
//           textDirection: TextDirection.ltr,
//         );
//         painter.layout(maxWidth: constraints.maxWidth);

//         if (painter.didExceedMaxLines) {
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 widget.text,
//                 style: widget.style,
//                 maxLines: _isExpanded ? null : widget.trimLines,
//                 overflow: _isExpanded ? null : TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: 4),
//               GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     _isExpanded = !_isExpanded;
//                   });
//                 },
//                 child: Text(
//                   _isExpanded ? 'Tutup' : '...selengkapnya',
//                   style: widget.linkStyle,
//                 ),
//               ),
//             ],
//           );
//         } else {
//           return Text(widget.text, style: widget.style);
//         }
//       },
//     );
//   }
// }
