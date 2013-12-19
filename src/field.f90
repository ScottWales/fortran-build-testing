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
    public scalarfield, fieldop_sf
    public vectorfield, fieldop_vf
    public assignment(=)
    public operator(*)
    public fieldop_multiply_s_sf
    public div, fieldop_div

    ! An operation that returns a scalar field
    type fieldop_sf
        integer :: dummy
    end type

    ! A base scalar field type
    type, extends(fieldop_sf) :: scalarfield
    end type

    ! A vector field type
    type vectorfield
        integer :: dummy
    end type

    ! An operation that returns a scalar field
    type fieldop_vf
        integer :: dummy
    end type

    type, extends(fieldop_sf) :: fieldop_multiply_s_sf
    end type

    type, extends(fieldop_vf) :: fieldop_div
    end type

    interface assignment(=)
        procedure assign_sf
        procedure assign_vf
    end interface

    interface operator(*)
        procedure multiply_s_sf
    end interface

    contains
        subroutine assign_sf(sf, op)
            class(fieldop_sf), intent(in) :: op
            type(scalarfield), intent(out) :: sf

            sf%dummy = op%dummy
        end subroutine
        subroutine assign_vf(vf, op)
            class(fieldop_vf), intent(in) :: op
            type(vectorfield), intent(out) :: vf

            vf%dummy = op%dummy
        end subroutine

        function multiply_s_sf(s, sf) result(r)
            real, intent(in) :: s
            class(fieldop_sf), intent(in) :: sf
            type(fieldop_multiply_s_sf) :: r

            r%dummy = s * sf%dummy
        end function

        function div(sf)
            class(fieldop_sf) :: sf
            type(fieldop_div) :: div

            div%dummy = sf%dummy
        end function
end module
