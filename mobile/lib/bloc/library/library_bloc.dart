import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/bloc/library/library_event.dart";
import "package:wavelength/bloc/library/library_state.dart";

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  LibraryBloc() : super(LibraryStateDefault()) {}
}
