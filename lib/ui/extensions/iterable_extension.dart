extension IterableExtension<E> on Iterable<E> {
  List<E> gapWith(E filler) {
    final List<E> result = <E>[];

    for (final E element in this) {
      result..add(element)..add(filler);
    }

    // Instead of taking length into consideration in iteration, just remove
    // last element.
    return result..removeLast();
  }
}
