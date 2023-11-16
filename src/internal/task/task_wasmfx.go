//go:build scheduler.wasmfx

package task

import (
	"unsafe"
)

type state struct {}

//go:linkname runtimePanic runtime.runtimePanic
func runtimePanic(str string)

// start creates and starts a new goroutine with the given function and arguments.
// The new goroutine is immediately started.
func start(fn uintptr, args unsafe.Pointer, stackSize uintptr) {
	enqueueFn(uint32(fn), args)
}

//go:wasmimport wasmfx enqueueFn
func enqueueFn(fn uint32, args unsafe.Pointer)

//go:linkname align runtime.align
func align(p uintptr) uintptr

// initialize the state and prepare to call the specified function with the specified argument bundle.
func (s *state) initialize(fn uintptr, args unsafe.Pointer, stackSize uintptr) {
	runtimePanic("initialize called")
}

//go:linkname runqueuePushBack runtime.runqueuePushBack
func runqueuePushBack(*Task)

// currentTask is the current running task, or nil if currently in the scheduler.
var currentTask *Task

// Current returns the current active task.
func Current() *Task {
	return currentTask
}

// Pause suspends the current task and returns to the scheduler.
// This function may only be called when running on a goroutine stack, not when running on the system stack.
func Pause() {
	suspend()
}

func (t *Task) Resume() {
	runtimePanic("Resume should not be called for wasmfx target")
}

//go:wasmimport wasmfx suspend
func suspend()

// OnSystemStack returns whether the caller is running on the system stack.
func OnSystemStack() bool {
	// If there is not an active goroutine, then this must be running on the system stack.
	return Current() == nil
}
