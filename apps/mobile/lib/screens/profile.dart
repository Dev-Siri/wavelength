import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/bloc/auth/auth_bloc.dart";
import "package:wavelength/bloc/auth/auth_event.dart";
import "package:wavelength/bloc/auth/auth_state.dart";
import "package:wavelength/bloc/location/location_bloc.dart";
import "package:wavelength/bloc/location/location_state.dart";
import "package:wavelength/widgets/action_buttons/google_login_button.dart";
import "package:wavelength/widgets/ui/amplitude.dart";

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height / 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthStateAuthorized) {
              return Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      CircleAvatar(
                        radius: 30,
                        foregroundImage: CachedNetworkImageProvider(
                          state.user.pictureUrl ?? "",
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.8,
                        child: Text.rich(
                          TextSpan(
                            text: "Hello, ",
                            style: const TextStyle(fontSize: 18),
                            children: [
                              TextSpan(
                                text: state.user.displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(text: "!"),
                            ],
                          ),
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  BlocBuilder<LocationBloc, LocationState>(
                    builder: (context, state) {
                      return AmplListTile(
                        onTap: () => context.push("/settings"),
                        leading: const Icon(
                          LucideIcons.settings,
                          color: Colors.white,
                        ),
                        title: const Text(
                          "Settings",
                          style: TextStyle(fontSize: 17),
                        ),
                      );
                    },
                  ),
                  AmplListTile(
                    onTap: () =>
                        context.read<AuthBloc>().add(AuthLogoutUserEvent()),
                    leading: const Icon(LucideIcons.logOut),
                    title: const Text("Logout", style: TextStyle(fontSize: 17)),
                  ),
                ],
              );
            }

            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                    child: Text(
                      "Login to Wavelength",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  GoogleLoginButton(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
