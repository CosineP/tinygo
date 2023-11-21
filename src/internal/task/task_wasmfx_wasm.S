.global  call_indirect_impl
.hidden  call_indirect_impl
.type    call_indirect_impl,@function
call_indirect_impl: // func call_indirect_impl(fnptr, argsptr)
    .functype call_indirect_impl (i32, i32) -> ()
    local.get 1
    local.get 0
    call_indirect (i32) -> ()
    return
    end_function

