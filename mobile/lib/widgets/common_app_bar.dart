import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:go_router/go_router.dart";
import "package:vector_graphics/vector_graphics_compat.dart";

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;

  const CommonAppBar({super.key, this.actions});

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: BackButton(onPressed: () => context.pop()),
      centerTitle: true,
      title: const SvgPicture(
        AssetBytesLoader("assets/vectors/lambda.svg.vec"),
        height: 45,
        width: 45,
      ),
      actions: actions,
    );
  }
}
