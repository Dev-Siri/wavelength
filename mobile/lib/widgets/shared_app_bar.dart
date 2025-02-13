import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/bloc/auth/auth_bloc.dart";
import "package:wavelength/bloc/auth/auth_state.dart";

class SharedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SharedAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Text(
          "Feed",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      leading: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.only(left: 8, top: 8),
            child: ElevatedButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              style: ButtonStyle(
                alignment: Alignment.center,
                padding: WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.zero),
                backgroundColor: WidgetStatePropertyAll<Color>(
                  Colors.grey.shade800,
                ),
              ),
              child:
                  state.user == null
                      ? Icon(LucideIcons.user, color: Colors.white, size: 28)
                      : Placeholder(),
            ),
          );
        },
      ),
    );
  }
}
