!> \file    src/field.f90
!! \author  Scott Wales <scott.wales@unimelb.edu.au>
!! \brief   
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

module field_mod
    private
    public :: field, scalarfield, vectorfield
    public :: assignment(=)
    public :: operator(+)
    public :: operator(*)
    public :: operator(-)
    public :: operator(/)
    public :: grad
    public :: div

    type field
        integer :: placeholder
    end type

    type, extends(field) :: scalarfield
        contains
            procedure :: pattern
    end type

    type, extends(field) :: vectorfield
    end type

    interface assignment(=)
        procedure assign_real
        procedure assign_int
    end interface

    interface operator(+)
        procedure add_scalarfield
        procedure add_vectorfield
    end interface
    interface operator(*)
        procedure scale_pre_real_scalarfield
        procedure scale_post_real_scalarfield
        procedure scale_pre_int_scalarfield
        procedure scale_post_int_scalarfield
        procedure scale_pre_real_vectorfield
        procedure scale_post_real_vectorfield
        procedure scale_pre_int_vectorfield
        procedure scale_post_int_vectorfield
    end interface
    interface operator(-)
        procedure negate_scalarfield
        procedure negate_vectorfield
        procedure subtract_scalarfield
        procedure subtract_vectorfield
    end interface
    interface operator(/)
        procedure divide_real_scalarfield
        procedure divide_int_scalarfield
        procedure divide_real_vectorfield
        procedure divide_int_vectorfield
    end interface
contains
    
    subroutine assign_real(to, from)
        type(scalarfield), intent(out) :: to
        real, intent(in) :: from

        to = int(from)
    end subroutine
    subroutine assign_int(to, from)
        type(scalarfield), intent(out) :: to
        integer, intent(in) :: from

        to%placeholder = from
    end subroutine

    subroutine pattern(to, pat)
        class(scalarfield), intent(inout) :: to
        interface 
            function pat(u,v,w) result(z)
                real, intent(in) :: u, v, w
                real :: z
            end function
        end interface

        to = pat(0.,0.,0.)
    end subroutine

    function add_scalarfield(a, b) result(c)
        type(scalarfield) :: c
        type(scalarfield), intent(in) :: a, b

        c%placeholder = a%placeholder + b%placeholder
    end function
    function add_vectorfield(a, b) result(c)
        type(vectorfield) :: c
        type(vectorfield), intent(in) :: a, b

        c%placeholder = a%placeholder + b%placeholder
    end function

    function scale_post_real_scalarfield(a,b) result(c)
        type(scalarfield) :: c
        type(scalarfield), intent(in) :: a
        real, intent(in) :: b

        c = a * int(b)
    end function
    function scale_pre_real_scalarfield(a,b) result(c)
        type(scalarfield) :: c
        type(scalarfield), intent(in) :: b
        real, intent(in) :: a

        c = b * a
    end function
    function scale_post_int_scalarfield(a,b) result(c)
        type(scalarfield) :: c
        type(scalarfield), intent(in) :: a
        integer, intent(in) :: b

        c%placeholder = a%placeholder * b
    end function
    function scale_pre_int_scalarfield(a,b) result(c)
        type(scalarfield) :: c
        type(scalarfield), intent(in) :: b
        integer, intent(in) :: a

        c = b * a
    end function
    function scale_post_real_vectorfield(a,b) result(c)
        type(vectorfield) :: c
        type(vectorfield), intent(in) :: a
        real, intent(in) :: b

        c = a * int(b)
    end function
    function scale_pre_real_vectorfield(a,b) result(c)
        type(vectorfield) :: c
        type(vectorfield), intent(in) :: b
        real, intent(in) :: a

        c = b * a
    end function
    function scale_post_int_vectorfield(a,b) result(c)
        type(vectorfield) :: c
        type(vectorfield), intent(in) :: a
        integer, intent(in) :: b

        c%placeholder = a%placeholder * b
    end function
    function scale_pre_int_vectorfield(a,b) result(c)
        type(vectorfield) :: c
        type(vectorfield), intent(in) :: b
        integer, intent(in) :: a

        c = b * a
    end function

    function negate_scalarfield(a) result(c)
        type(scalarfield) :: c
        type(scalarfield), intent(in) :: a

        c = (-1) * a
    end function
    function negate_vectorfield(a) result(c)
        type(vectorfield) :: c
        type(vectorfield), intent(in) :: a

        c = (-1) * a
    end function

    function subtract_scalarfield(a, b) result(c)
        type(scalarfield) :: c
        type(scalarfield), intent(in) :: a, b

        c = a + (-b)
    end function
    function subtract_vectorfield(a, b) result(c)
        type(vectorfield) :: c
        type(vectorfield), intent(in) :: a, b

        c = a + (-b)
    end function

    function divide_int_scalarfield(a,b) result(c)
        type(scalarfield) :: c
        type(scalarfield), intent(in) :: a
        integer, intent(in) :: b

        c%placeholder = a%placeholder / b
    end function
    function divide_real_scalarfield(a,b) result(c)
        type(scalarfield) :: c
        type(scalarfield), intent(in) :: a
        real, intent(in) :: b

        c = a / int(b)
    end function
    function divide_int_vectorfield(a,b) result(c)
        type(vectorfield) :: c
        type(vectorfield), intent(in) :: a
        integer, intent(in) :: b

        c%placeholder = a%placeholder / b
    end function
    function divide_real_vectorfield(a,b) result(c)
        type(vectorfield) :: c
        type(vectorfield), intent(in) :: a
        real, intent(in) :: b

        c = a / int(b)
    end function

    function grad(s) result(v)
        type(scalarfield), intent(in) :: s
        type(vectorfield) :: v

        v%placeholder = s%placeholder
    end function
    function div(v) result(s)
        type(vectorfield), intent(in) :: v
        type(scalarfield) :: s

        s%placeholder = v%placeholder
    end function
end module
