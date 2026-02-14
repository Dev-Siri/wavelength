import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/bloc/auth/auth_bloc.dart";
import "package:wavelength/bloc/auth/auth_state.dart";
import "package:wavelength/widgets/ui/amplitude.dart";

class UserLeadingIcon extends StatelessWidget {
  const UserLeadingIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(left: 8, top: 8),
          child: AmplButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            sizeStyle: CupertinoButtonSize.small,
            padding: EdgeInsets.zero,
            child: state is AuthStateAuthorized
                ? CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(
                      state.user.pictureUrl ?? "",
                    ),
                  )
                : const Icon(LucideIcons.user, color: Colors.white, size: 28),
          ),
        );
      },
    );
  }
}
