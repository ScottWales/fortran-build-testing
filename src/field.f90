!> \file    src/field.f90
!! \author  Scott Wales <scott.wales@unimelb.edu.au>
!! \brief   Interface types for scalar and vector fields
!! 
!! Copyright 2013 Scott Wales
!! 
!! Licensed under the Apache License, Version 2.0 (the "License");
!! you may not use this file except in compliance with the License.
!! You may obtain a copy of the License at
!! 
!!     http://www.apache.org/licenses/LICENSE-2.0
!! 
!! Unless required by applicable law or agreed to in writing, software
!! distributed under the License is distributed on an "AS IS" BASIS,
!! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
!! See the License for the specific language governing permissions and
!! limitations under the License.
!! 
!! =============================================================================
!!
!! This module provides two basic types for scalar and vector fields. The aim is
!! to provide a clear boundary between the science and technical side - a
!! scientist uses the interface provided here to program a model, while any
!! optimisations and parallelisation are done by the implementor of the
!! interface.
!!
!! The interfaces provide basic arithmetic for whole fields, e.g. + - * /, as
!! well as operators to convert between the two types, e.g. grad() div().
!! Additionally a pattern() type procedure is available to set the field values
!! according to a custom function.
!!
!! =============================================================================

module field_mod
    private
    public scalarfield
    public vectorfield
    public assignment(=)
    public operator(*)
    public operator(/)
    public operator(+)
    public operator(-)
    public operator(==)
    public grad
    public div

    ! Types for implementing operation chaining and lazy evaluation
    ! These should not be instantiated directly
    public fieldop_sf
    public fieldop_vf
    public fieldop_multiply_s_sf
    public fieldop_multiply_s_vf
    public fieldop_multiply_sf_vf
    public fieldop_add_vf_vf
    public fieldop_add_sf_sf
    public fieldop_divide_elements_s_sf
    public fieldop_negate_sf
    public fieldop_negate_vf
    public fieldop_div
    public fieldop_grad

    ! An operation that returns a scalar field
    type fieldop_sf
        ! This would be abstracted via a mesh in a real model
        real, dimension(100,20,20) :: dummy
        contains
            ! This function evaluates the operation at a single point
            procedure :: evaluate => evaluate_sfop
    end type

    ! A base scalar field type
    type, extends(fieldop_sf) :: scalarfield
        contains
            ! Return the actual value of the field
            procedure :: evaluate => evaluate_sf
    end type

    ! An operation that returns a scalar field
    type fieldop_vf
        ! This would be abstracted via a mesh in a real model
        real, dimension(100,20,20) :: dummy
    end type

    ! A vector field type
    type, extends(fieldop_vf) :: vectorfield
    end type


    ! Types for various operations - they are classified by their return type
    type, extends(fieldop_sf) :: fieldop_divide_elements_s_sf
        ! Arguments to the operation
        real :: a
        class (fieldop_sf), pointer :: b
        contains
            ! Evaluate the opearation at a point
            procedure :: evaluate => evaluate_divide_elements_s_sf
    end type

    type, extends(fieldop_sf) :: fieldop_multiply_s_sf
    end type
    type, extends(fieldop_vf) :: fieldop_multiply_s_vf
    end type
    type, extends(fieldop_vf) :: fieldop_multiply_sf_vf
    end type
    type, extends(fieldop_vf) :: fieldop_add_vf_vf
    end type
    type, extends(fieldop_sf) :: fieldop_add_sf_sf
    end type
    type, extends(fieldop_sf) :: fieldop_negate_sf
    end type
    type, extends(fieldop_vf) :: fieldop_negate_vf
    end type
    type, extends(fieldop_sf) :: fieldop_div
    end type
    type, extends(fieldop_vf) :: fieldop_grad
    end type

    ! Operator overloads
    interface assignment(=)
        procedure assign_sf
        procedure assign_vf
        procedure set_sf
    end interface
    interface operator(*)
        procedure multiply_s_sf
        procedure multiply_s_vf
        procedure multiply_sf_vf
    end interface
    interface operator(+)
        procedure add_vf_vf
        procedure add_sf_sf
    end interface
    interface operator(-)
        procedure negate_sf
        procedure negate_vf
    end interface
    interface operator(/)
        procedure divide_elements_s_sf
    end interface
    interface operator(==)
        procedure equal_sf
    end interface

    contains
        ! Parallelisation, loop unrolling etc. happens here
        subroutine assign_sf(sf, op)
            class(fieldop_sf), intent(in) :: op
            type(scalarfield), intent(out) :: sf

            integer :: i, j

            !$omp parallel do
            do i=1,20
                do j=1,20
                    ! Evaluating here ensures we load all the data for a grid
                    ! point at once, we're not loading an area multiple times
                    ! in different loops
                    sf%dummy(:,j,i) = op%evaluate(j,i)
                end do
            end do
        end subroutine

        pure function evaluate_sf(this,j,i) result(r)
            class(scalarfield), intent(in) :: this
            integer, intent(in) :: j, i
            real, dimension(100) :: r
            ! A scalarfield holds actual values, just return them
            ! We're doing things by column in this example, but this could be
            ! flexible - e.g. block the column to take advantage of SSE
            r = this%dummy(:,j,i)
        end function

        ! Example function
        ! Here we're getting the inverse of a field multiplied by a real
        ! Looks like `a = 1.0/b`
        function divide_elements_s_sf(s, sf) result(r)
            real, intent(in) :: s
            class(fieldop_sf), intent(in), target :: sf
            type(fieldop_divide_elements_s_sf) :: r

            ! Set the arguments in the fieldop, no computation is done here.
            ! We're just creating the expression tree at this point
            r%a = s
            r%b => sf
        end function
        pure function evaluate_divide_elements_s_sf(this,j,i) result(r)
            class(fieldop_divide_elements_s_sf), intent(in) :: this
            integer, intent(in) :: j, i
            real, dimension(100) :: r

            ! Here one of the arguments is a fieldop, so it needs to be
            ! evaluated before we can return
            r = this%a / this%b%evaluate(j,i)
        end function

        subroutine assign_vf(vf, op)
            class(fieldop_vf), intent(in) :: op
            type(vectorfield), intent(out) :: vf

            vf%dummy = op%dummy
        end subroutine
        subroutine set_sf(sf, s)
            real, intent(in) :: s
            type(scalarfield), intent(out) :: sf

            sf%dummy = s
        end subroutine

        function multiply_s_sf(s, sf) result(r)
            real, intent(in) :: s
            class(fieldop_sf), intent(in) :: sf
            type(fieldop_multiply_s_sf) :: r

            r%dummy = s * sf%dummy
        end function
        function multiply_s_vf(s, vf) result(r)
            real, intent(in) :: s
            class(fieldop_vf), intent(in) :: vf
            type(fieldop_multiply_s_vf) :: r

            r%dummy = s * vf%dummy
        end function
        function multiply_sf_vf(sf, vf) result(r)
            class(fieldop_sf), intent(in) :: sf
            class(fieldop_vf), intent(in) :: vf
            type(fieldop_multiply_sf_vf) :: r

            r%dummy = vf%dummy * sf%dummy
        end function
        function add_vf_vf(a,b) result(r)
            class(fieldop_vf), intent(in) :: a
            class(fieldop_vf), intent(in) :: b
            type(fieldop_add_vf_vf) :: r

            r%dummy = a%dummy * b%dummy
        end function
        function add_sf_sf(a,b) result(r)
            class(fieldop_sf), intent(in) :: a
            class(fieldop_sf), intent(in) :: b
            type(fieldop_add_sf_sf) :: r

            r%dummy = a%dummy + b%dummy
        end function
        function negate_sf(sf) result(r)
            class(fieldop_sf), intent(in) :: sf
            type(fieldop_negate_sf) :: r

            r%dummy = -sf%dummy
        end function
        function negate_vf(vf) result(r)
            class(fieldop_vf), intent(in) :: vf
            type(fieldop_negate_vf) :: r

            r%dummy = -vf%dummy
        end function

        function div(vf)
            class(fieldop_vf) :: vf
            type(fieldop_div) :: div

            div%dummy = vf%dummy
        end function
        function grad(sf)
            class(fieldop_sf) :: sf
            type(fieldop_grad) :: grad

            grad%dummy = sf%dummy
        end function

        ! This is mainly for testing
        function equal_sf(a,b) result(r)
            class(scalarfield), intent(in) :: a, b
            logical :: r

            r = maxval(abs(a%dummy - b%dummy)) < 0.01
        end function

        ! Default operation, would be abstract in a full implementation
        pure function evaluate_sfop(this,j,i) result(r)
            class(fieldop_sf), intent(in) :: this
            integer, intent(in) :: j, i
            real, dimension(100) :: r
            r = this%dummy(:,j,i)
        end function

end module
