import 'package:cobalt/errors/backend_error.dart';

typedef ErrorConsturctor = BackendError Function({
  required String errorCode,
  required String message,
});

class ErrorBuilder {
  final String errorCode;
  final String message;
  final BackendError Function(String, String) constructor;

  ErrorBuilder({
    required this.errorCode,
    required this.message,
    required this.constructor,
  });

  BackendError build(List<String?>? args) {
    String _message = message;
    if (args != null) {
      for (String? arg in args) {
        _message = _message.replaceFirst('%s', arg ?? 'null');
      }
    }
    return constructor(errorCode, _message);
  }
}

mixin ErrorManagerMixin {
  void addError<T extends BackendError>({
    required String errorCode,
    required String message,
    required T Function(String, String) constructor,
  });

  BackendError getError(String errorCode, {List<String?>? args});

  void throwError(String errorCode, {List<String?>? args});
}

class ErrorManager with ErrorManagerMixin {
  final Map<String, ErrorBuilder> _errors = {};

  @override
  void addError<T extends BackendError>({
    required String errorCode,
    required String message,
    required T Function(String, String) constructor,
  }) {
    if (_errors.containsKey(errorCode)) {
      throw Exception('Duplicate error code: $errorCode');
    }

    _errors[errorCode] = ErrorBuilder(
      errorCode: errorCode,
      message: message,
      constructor: constructor,
    );
  }

  @override
  BackendError getError(String errorCode, {List<String?>? args}) {
    if (!_errors.containsKey(errorCode)) {
      throw Exception('Unknown error code: $errorCode');
    }

    return _errors[errorCode]!.build(args);
  }

  @override
  void throwError(String errorCode, {List<String?>? args}) {
    throw getError(errorCode, args: args);
  }
}
