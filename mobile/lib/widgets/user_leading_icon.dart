import "dart:io";

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/bloc/auth/auth_bloc.dart";
import "package:wavelength/bloc/auth/auth_state.dart";

class UserLeadingIcon extends StatelessWidget {
  const UserLeadingIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(left: 8, top: 8),
          child: Platform.isIOS
              ? CupertinoButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  sizeStyle: CupertinoButtonSize.small,
                  padding: EdgeInsets.zero,
                  child: state is AuthStateAuthorized
                      ? CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(
                            state.user.photoUrl ?? "",
                          ),
                        )
                      : const Icon(
                          LucideIcons.user400,
                          color: Colors.white,
                          size: 28,
                        ),
                )
              : ElevatedButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  style: ButtonStyle(
                    alignment: Alignment.center,
                    padding: const WidgetStatePropertyAll<EdgeInsets>(
                      EdgeInsets.zero,
                    ),
                    backgroundColor: WidgetStatePropertyAll<Color>(
                      Colors.grey.shade800,
                    ),
                  ),
                  child: state is AuthStateAuthorized
                      ? CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(
                            state.user.photoUrl ?? "",
                          ),
                        )
                      : const Icon(
                          LucideIcons.user400,
                          color: Colors.white,
                          size: 28,
                        ),
                ),
        );
      },
    );
  }
}
