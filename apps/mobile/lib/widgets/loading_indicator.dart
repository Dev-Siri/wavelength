import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:vector_graphics/vector_graphics.dart";

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(context).width / 8,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SvgPicture(AssetBytesLoader("assets/vectors/lambda.svg.vec")),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.sizeOf(context).width / 6,
            ),
            child: LinearProgressIndicator(
              borderRadius: BorderRadius.circular(100),
              backgroundColor: Colors.grey,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
