//go:build scheduler.wasmfx

package task

import (
	"unsafe"
)

type state struct {}

//go:linkname runtimePanic runtime.runtimePanic
func runtimePanic(str string)

//go:linkname printstring runtime.printstring
func printstring(str string)
//go:linkname printuint32 runtime.printuint32
func printuint32(str uint32)

// start creates and starts a new goroutine with the given function and arguments.
// The new goroutine is immediately started.
func start(fn uintptr, args unsafe.Pointer, stackSize uintptr) {
	enqueueFn(uint32(fn), args)
}

//go:wasmimport wasmfx enqueueFn
func enqueueFn(fn uint32, args unsafe.Pointer)

//go:wasmimport wasmfx tryGrow
func tryGrow() uint32

// initialize the state and prepare to call the specified function with the specified argument bundle.
func (s *state) initialize(fn uintptr, args unsafe.Pointer, stackSize uintptr) {
	runtimePanic("initialize called")
}

// Current returns the current active task.
func Current() *Task {
	return nil
}

// Pause suspends the current task and returns to the scheduler.
// This function may only be called when running on a goroutine stack, not when running on the system stack.
func Pause() {
    printstring("pause\n")
	suspend()
}

func (t *Task) Resume() {
	runtimePanic("Resume should not be called for wasmfx target")
}

//export call_indirect_impl
func call_indirect_impl(fn uint32, args uint32)

//export call_indirect
func call_indirect(fn uint32, args uint32) {
	call_indirect_impl(fn, args)
}

//go:wasmimport wasmfx suspend
func suspend()

// OnSystemStack returns whether the caller is running on the system stack.
func OnSystemStack() bool {
	runtimePanic("OnSystemStack should not be called for wasmfx target")
	return false
}
