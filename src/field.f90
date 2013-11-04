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
        contains
            procedure :: pattern
    end type

    type, extends(field) :: scalarfield
    end type

    type, extends(field) :: vectorfield
    end type

    interface assignment(=)
        procedure assign_real
        procedure assign_int
    end interface

    interface operator(+)
        procedure add_field
    end interface
    interface operator(*)
        procedure scale_pre_real
        procedure scale_post_real
        procedure scale_pre_int
        procedure scale_post_int
    end interface
    interface operator(-)
        procedure negate
        procedure subtract_field
    end interface
    interface operator(/)
        procedure divide_real
        procedure divide_int
    end interface
contains
    
    subroutine assign_real(to, from)
        type(field), intent(out) :: to
        real, intent(in) :: from

        to%placeholder = int(from)
    end subroutine
    subroutine assign_int(to, from)
        type(field), intent(out) :: to
        integer, intent(in) :: from

        to%placeholder = from
    end subroutine

    subroutine pattern(to, pat)
        class(field), intent(inout) :: to
        interface 
            function pat(u,v,w) result(z)
                real, intent(in) :: u, v, w
                real :: z
            end function
        end interface

        to = pat(0.,0.,0.)
    end subroutine

    function add_field(a, b) result(c)
        type(field) :: c
        type(field), intent(in) :: a, b

        c%placeholder = a%placeholder + b%placeholder
    end function

    function scale_post_real(a,b) result(c)
        type(field) :: c
        type(field), intent(in) :: a
        real, intent(in) :: b

        c%placeholder = a%placeholder * int(b)
    end function
    function scale_pre_real(a,b) result(c)
        type(field) :: c
        type(field), intent(in) :: b
        real, intent(in) :: a

        c = b * a
    end function
    function scale_post_int(a,b) result(c)
        type(field) :: c
        type(field), intent(in) :: a
        integer, intent(in) :: b

        c%placeholder = a%placeholder * b
    end function
    function scale_pre_int(a,b) result(c)
        type(field) :: c
        type(field), intent(in) :: b
        integer, intent(in) :: a

        c = b * a
    end function

    function negate(a) result(c)
        type(field) :: c
        type(field), intent(in) :: a

        c = (-1) * a
    end function

    function subtract_field(a, b) result(c)
        type(field) :: c
        type(field), intent(in) :: a, b

        c = a + (-b)
    end function

    function divide_int(a,b) result(c)
        type(field) :: c
        type(field), intent(in) :: a
        integer, intent(in) :: b

        c%placeholder = a%placeholder / b
    end function
    function divide_real(a,b) result(c)
        type(field) :: c
        type(field), intent(in) :: a
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
