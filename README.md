An experiment in syntax simplification
======================================

This does something similar to expression templates in C++ - instead of
evaluating operations on a field immediately it saves them as an expression
tree, only doing the evaluation when it's needed.

This means users of the library have a simple interface, e.g.

```
use mod_field
type(scalarfield) :: p, rho
type(vectorfield) :: DuDt, G

DuDt = 1.0/rho * grad(p) + G
```

while behind the scenes this gets parallelised & loop unrolled

```
!$omp parallel do
do i=1,nx
   do j=1,ny
      DuDt(:,j,i) = 1.0/rho(:,j,i) * ((p(:,j-1,i) - p(:,j+1,i))/dx ...
   end do
end do
```

See src/fieldops.pf for some more examples, and src/field.f90 for a partial
implementation of the idea.

To build:
=========

    $ make

Tests
=====

Tests use pFunit & require the PFUNIT environment variable to be set.
Tests are run automatically when building the program.


