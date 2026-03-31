import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/bloc/auth/auth_bloc.dart";
import "package:wavelength/bloc/auth/auth_state.dart";
import "package:wavelength/screens/profile.dart";
import "package:wavelength/widgets/ui/amplitude.dart";

class UserLeadingIcon extends StatelessWidget {
  const UserLeadingIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return AmplIconButton(
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            enableDrag: true,
            backgroundColor: Colors.black,
            builder: (_) => const ProfileScreen(),
          ),
          padding: EdgeInsets.zero,
          icon: state is AuthStateAuthorized
              ? CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                    state.user.pictureUrl ?? "",
                  ),
                )
              : const Icon(LucideIcons.user, color: Colors.white, size: 28),
        );
      },
    );
  }
}
