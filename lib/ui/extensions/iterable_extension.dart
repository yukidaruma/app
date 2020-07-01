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

  Map<K, List<E>> groupBy<K>(K Function(E element) keyComputation) {
    final Map<K, List<E>> map = <K, List<E>>{};

    for (final E element in this) {
      final K key = keyComputation(element);

      if (!map.containsKey(key)) {
        map[key] = <E>[];
      }

      map[key].add(element);
    }

    return map;
  }

  List<E> sortBy<V extends Comparable<V>>(V Function(E element) valueComputation) {
    return toList()..sort((E a, E b) => valueComputation(a).compareTo(valueComputation(b)));
  }
}
