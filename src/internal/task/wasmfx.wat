(module

  (type $unit_unit)
  (type $i32_unit (param i32))
  (type $i32_i32_unit (param i32 i32))
  (type $resume (cont $unit_unit))
  (type $call_indirect_cont (cont $i32_i32_unit))
  (tag $reschedule)

  ;; Table as simple queue (keeping it simple, no ring buffer)
  (table $queue 0 (ref null $resume))
  (global $qdelta i32 (i32.const 10))
  (global $qback (mut i32) (i32.const 0))
  (global $qfront (mut i32) (i32.const 0))

  (func $queue-empty (result i32)
    (i32.eq (global.get $qfront) (global.get $qback))
  )

  (func $dequeue (result (ref null $resume))
    (local $i i32)
    (if (call $queue-empty)
      (then (return (ref.null $resume)))
    )
    (local.set $i (global.get $qfront))
    (global.set $qfront (i32.add (local.get $i) (i32.const 1)))
    (table.get $queue (local.get $i))
  )

  (func $enqueue (param $k (ref $resume))
    ;; Check if queue is full
    (if (i32.eq (global.get $qback) (table.size $queue))
      (then
        ;; Check if there is enough space in the front to compact
        (if (i32.lt_u (global.get $qfront) (global.get $qdelta))
          (then
            ;; Space is below threshold, grow table instead
            (drop (table.grow $queue (ref.null $resume) (global.get $qdelta)))
          )
          (else
            ;; Enough space, move entries up to head of table
            (global.set $qback (i32.sub (global.get $qback) (global.get $qfront)))
            (table.copy $queue $queue
              (i32.const 0)         ;; dest = new front = 0
              (global.get $qfront)  ;; src = old front
              (global.get $qback)   ;; len = new back = old back - old front
            )
            (table.fill $queue      ;; null out old entries to avoid leaks
              (global.get $qback)   ;; start = new back
              (ref.null $resume)      ;; init value
              (global.get $qfront)  ;; len = old front = old front - new front
            )
            (global.set $qfront (i32.const 0))
          )
        )
      )
    )
    (table.set $queue (global.get $qback) (local.get $k))
    (global.set $qback (i32.add (global.get $qback) (i32.const 1))))

  (func $scheduler (param $schedulerDone i32)
    block  ;; label = @1
      loop  ;; label = @2
        local.get $schedulerDone
        ;; check schedulerDone (which gets set at end of main)
        br_if 1 (;@1;)
        ;; pop the queue and resume the continuation
        call $dequeue
        br_on_null 1
        (block $coroutine_suspend (param (ref $resume)) (result (ref $resume))
          (resume $resume
            (tag $effect $coroutine_suspend))
          ;; it suspended, so continue without re-enqueuing
          br 1)
        ;; re-enqeue the coroutine. tinygo makes this the coroutine's job, but
        ;; we make it the scheduler's job
        call $enqueue
        br 0 (;@2;)
      end
      unreachable
    end)

  (func $suspend
    suspend $reschedule)

  (func $call_indirect (param i32) (param i32)
    (call_indirect (type $i32_unit) (local.get 1) (local.get 0)))

  (func $enqueueFn (param $fn i32) (param $args i32)
    (local.get $fn)
    (local.get $args)
    (cont.new $call_indirect_cont (ref.func $call_indirect))
    (cont.bind $call_indirect_cont $resume)
    call $enqueue)

  (elem $call_indirect)

)
