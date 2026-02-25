package filtering

// thanks go.
type Set[T comparable] map[T]struct{}

func NewSet[T comparable](elements ...T) Set[T] {
	s := make(Set[T])
	for _, elem := range elements {
		s.Add(elem)
	}
	return s
}

func (s Set[T]) Add(elem T) {
	s[elem] = struct{}{}
}

func (s Set[T]) Remove(elem T) {
	delete(s, elem)
}

func (s Set[T]) Contains(elem T) bool {
	_, ok := s[elem]
	return ok
}

func (s Set[T]) Size() int {
	return len(s)
}
