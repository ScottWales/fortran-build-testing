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
    type field
        integer :: placeholder
    end type

    interface assignment(=)
        procedure assign_real
        procedure assign_int
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
end module
