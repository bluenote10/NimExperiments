

when true: # removing 'when' indentation => compiles

  iterator iter(): int {.closure.} =
    yield 0
    yield 1

  iterator wrappedIterator(it: iterator (): int): int {.closure.} =
    for x in it():
      yield x

  # Removing this loop => compiles, but
  # the behavior of the second loop is strange:
  # It is an infinite loop, always returning zero
  for x in iter():
    echo x

  # Removing this loop => compiles, and above
  # loop works fine.
  for x in iter.wrappedIterator:
    echo x
    
