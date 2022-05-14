// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;

  final int maxLines;

  final TextStyle style;

  final bool expand;

  const ExpandableText({Key key, this.text, this.maxLines, this.style, this.expand}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  @override
  Widget build(BuildContext context) {
    bool expand = widget.expand ?? false;
    return LayoutBuilder(builder: (context, size) {
      final span = TextSpan(text: widget.text ?? '', style: widget.style);

      final tp = TextPainter(text: span, maxLines: widget.maxLines, textDirection: TextDirection.ltr);

      tp.layout(maxWidth: size.maxWidth);

      if (tp.didExceedMaxLines) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            setState(() {
              expand = !expand;
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Expanded(
                    child: Text(""),
                  ),
                  (expand)
                      ? const Icon(
                          Icons.arrow_drop_up,
                          size: 20,
                        )
                      : const Icon(
                          Icons.arrow_drop_down,
                          size: 20,
                        ),
                ],
              ),
              expand
                  ? Text(widget.text ?? '', style: widget.style)
                  : Text(widget.text ?? '',
                      maxLines: widget.maxLines, overflow: TextOverflow.ellipsis, style: widget.style),
            ],
          ),
        );
      } else {
        return Text(widget.text ?? '', style: widget.style);
      }
    });
  }
}
