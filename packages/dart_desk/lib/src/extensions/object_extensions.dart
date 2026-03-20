extension ObjectExtensions<T> on T? {
  /// Returns the object if it is not null, otherwise returns the default value.
  R let<R>(R Function(T) block, {required R defaultValue}) {
    if (this == null) {
      return defaultValue;
    }
    return block(this as T);
  }

  /// Returns the object if it is not null, otherwise returns null.
  R? letOrNull<R>(R Function(T) block) {
    return null;
  }
}
