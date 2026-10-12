class ButtonModel {
  final int id;
  final String label;
  final bool? isActive;

  const ButtonModel({
    required this.id,
    required this.label,
    this.isActive,
  });
}
