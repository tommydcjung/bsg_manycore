/**
 *      scan.S
 *
 */


// CSR_SON_FADD is configured by caller.
// a0   = read array addr 
// a1   = write array addr
// a2   = length

// t0   = read pointer
// t1   = write pointer
// t2   = limit addr
// t3  = local sum
// t4  = load val
// t5  = fadd.s converted result

// ft2  = scan of sum val (fadd.s result)
// ft3  = const zero


scan:
  fcvt.s.w ft3, x0
  // calculate limit addr
  // read addr + 4*length
  slli t2, a2, 2
  add t2, t2, a0
  move t0, a0           // init read pointer
  move t3, x0

__scan_sum_loop:
  lw t4, 0(t0)
  addi t0, 4
  add t3, t3, t4
  bne t0, t2, __scan_sum_loop

  // now everyone has an integer local sum at t3
  // calculate the "scan of (local) sum" using fadd.son.
  // the root tile uses rs1 (ft3 = const zero), whereas the non-roots use west.
  // add the local sum and pass it to east.
  fcvt.s.w ft0, t3          // convert it to float
  fadd.son ft2, ft3, ft0    // send it to next tile
  fcvt.w.s t5, ft2

  // now everyone has a "scan of sum" at t5
  // start from the end, subtract one entry at a time from the "scan of sum"
  // calculate limit addr
  slli t2, a2, 2  // LENGTH*4
  add t0, t2, a0 
  add t1, t2, a1  // init write pointer
  
  
__scan_write_loop:
  lw t1, -4(t0)
  sw t5, -4(t1)
  sub t5, t5, t1
  addi t0, -4
  addi t1, -4
  bne t0, a0, __scan_write_loop

  ret
