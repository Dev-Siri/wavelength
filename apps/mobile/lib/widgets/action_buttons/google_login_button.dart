import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_svg/svg.dart";
import "package:vector_graphics/vector_graphics_compat.dart";
import "package:wavelength/bloc/auth/auth_bloc.dart";
import "package:wavelength/bloc/auth/auth_event.dart";
import "package:wavelength/widgets/ui/amplitude.dart";

class GoogleLoginButton extends StatelessWidget {
  const GoogleLoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AmplButton(
        color: Colors.white,
        onPressed: () => context.read<AuthBloc>().add(AuthLoginUserEvent()),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture(
              AssetBytesLoader("assets/vectors/google-logo.svg.vec"),
              height: 20,
            ),
            SizedBox(width: 6),
            Text("Sign in with Google", style: TextStyle(color: Colors.black)),
          ],
        ),
      ),
    );
  }
}
