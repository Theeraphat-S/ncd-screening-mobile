import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// `context.read<T>()` that returns null when no provider of [T] is above
/// [context], for optional collaborators such as the attempt guard.
T? tryRead<T>(BuildContext context) {
  try {
    return context.read<T>();
  } on ProviderNotFoundException {
    return null;
  }
}
