import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_svg/svg.dart";
import "package:vector_graphics/vector_graphics_compat.dart";
import "package:wavelength/bloc/auth/auth_bloc.dart";
import "package:wavelength/bloc/auth/auth_event.dart";

class GoogleLoginButton extends StatelessWidget {
  const GoogleLoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll<Color>(Colors.white),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ),
        onPressed: () => context.read<AuthBloc>().add(AuthLoginUserEvent()),
        icon: SvgPicture(
          AssetBytesLoader("assets/vectors/google-logo.svg.vec"),
          height: 20,
        ),
        label: Text(
          "Sign in with Google",
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
