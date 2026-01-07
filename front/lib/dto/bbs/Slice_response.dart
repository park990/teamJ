class SliceResponse<T> {
  final List<T> content;
  final bool hasNext;

  SliceResponse({
    required this.content,
    required this.hasNext,
  });
}
