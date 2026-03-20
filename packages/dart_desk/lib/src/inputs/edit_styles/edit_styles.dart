/// Base class for defining how array items are added and edited
sealed class EditStyles {
  const EditStyles();
}

/// Inline editing: Shows the editor directly in the list
class InlineEditStyles extends EditStyles {
  const InlineEditStyles();
}

/// Modal editing: Shows the editor in a dialog/modal
class ModalEditStyles extends EditStyles {
  const ModalEditStyles();
}
