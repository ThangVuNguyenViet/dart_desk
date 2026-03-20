/// Interface for converting CMS configuration to a document format
mixin Serializable<T> {
  /// Convert this object to a JSON map representation
  ///
  /// Returns a `Map<String, dynamic>` that can be encoded to JSON string
  /// or stored in databases that support JSON/document storage.
  Map<String, dynamic> toMap();
}
