import "package:country_flags/country_flags.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:vector_graphics/vector_graphics_compat.dart";
import "package:wavelength/bloc/location/location_bloc.dart";
import "package:wavelength/bloc/location/location_state.dart";
import "package:wavelength/widgets/user_leading_icon.dart";

class SharedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SharedAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: AppBar(
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: SvgPicture(
            AssetBytesLoader("assets/vectors/logo.svg.vec"),
            height: 60,
            width: 100,
          ),
        ),
        leading: UserLeadingIcon(),
        actions: [
          BlocBuilder<LocationBloc, LocationState>(
            builder: (context, state) {
              return ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                child: CountryFlag.fromCountryCode(
                  state.countryCode,
                  height: 25,
                  width: 35,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
