import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/bloc/download/download_bloc.dart";
import "package:wavelength/bloc/download/download_state.dart";

class DownloadNotificationButton extends StatelessWidget {
  const DownloadNotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloadBloc, DownloadState>(
      builder: (context, state) {
        return Badge.count(
          isLabelVisible: state.inQueue.isNotEmpty,
          count: state.inQueue.length,
          alignment: Alignment.topLeft,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              shape: BoxShape.circle,
            ),
            height: 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              color: Colors.grey.shade400,
              icon: const Icon(LucideIcons.download, size: 18),
              onPressed: () => context.push("/downloads"),
            ),
          ),
        );
      },
    );
  }
}
