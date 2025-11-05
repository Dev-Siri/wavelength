import "dart:io";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:go_router/go_router.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:vector_graphics/vector_graphics.dart";
import "package:wavelength/bloc/auth/auth_bloc.dart";
import "package:wavelength/bloc/auth/auth_event.dart";
import "package:wavelength/bloc/auth/auth_state.dart";
import "package:wavelength/bloc/location/location_bloc.dart";
import "package:wavelength/bloc/location/location_state.dart";
import "package:wavelength/widgets/google_login_button.dart";

class UserInfoDrawer extends StatelessWidget {
  const UserInfoDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                const SvgPicture(
                  AssetBytesLoader("assets/vectors/lambda.svg.vec"),
                ),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is! AuthStateAuthorized) {
                      return const SizedBox.shrink();
                    }

                    return Transform.translate(
                      offset: const Offset(-15, 0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / 2.3,
                        child: Text.rich(
                          TextSpan(
                            text: "Hello, ",
                            style: const TextStyle(fontSize: 18),
                            children: [
                              TextSpan(
                                text: state.user.displayName ?? "User",
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
                    );
                  },
                ),
              ],
            ),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthStateAuthorized) {
                  return Expanded(
                    child: Column(
                      children: [
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              BlocBuilder<LocationBloc, LocationState>(
                                builder: (context, state) {
                                  if (Platform.isIOS) {
                                    return CupertinoButton(
                                      onPressed: () =>
                                          context.push("/settings"),
                                      child: const Icon(
                                        LucideIcons.settings,
                                        color: Colors.white,
                                      ),
                                    );
                                  }

                                  return IconButton(
                                    onPressed: () => context.push("/settings"),
                                    icon: const Icon(
                                      LucideIcons.settings,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                              if (Platform.isIOS)
                                CupertinoButton(
                                  onPressed: () => context.read<AuthBloc>().add(
                                    AuthLogoutUserEvent(),
                                  ),
                                  child: const Icon(
                                    LucideIcons.logOut,
                                    color: Colors.red,
                                  ),
                                )
                              else
                                IconButton(
                                  onPressed: () => context.read<AuthBloc>().add(
                                    AuthLogoutUserEvent(),
                                  ),
                                  icon: const Icon(
                                    LucideIcons.logOut,
                                    color: Colors.red,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: GoogleLoginButton(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
