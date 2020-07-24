/**
 *      scan.S
 *
 */


// CSR_SON_FADD is configured by caller.
// a0   = read array addr 
// a1   = write array addr
// a2   = length
// ft0  = sum
// ft1  = load val
// ft2  = scan of sum val
// ft3  = const zero
// t0   = read pointer
// t1   = write pointer
// t2   = limit addr


scan:
  fcvt.s.w ft0, x0
  fcvt.s.w ft2, x0
  fcvt.s.w ft3, x0
  // calculate limit addr
  // read addr + 4*length
  slli t2, a2, 2
  add t2, t2, a0
  // init read pointer
  move t0, a0

__scan_sum_loop:
  flw ft1 0(t0)
  fadd.s ft0, ft0, ft1
  addi t0, 4
  bne t0, t2, __scan_sum_loop

  // now everyone has a sum at ft0
  // calculate the "scan of (local) sum" using fadd.son.
  // the root tile uses rs1 (ft3 = const zero), whereas the non-roots use west.
  // add the local sum and pass it to east.
  fadd.son ft2, ft3, ft0

  // now everyone has a "scan of sum" at ft2
  // start from the end, subtract one entry at a time from the "scan of sum"
  // calculate limit addr
  slli t2, a2, 2  // LENGTH*4
  add t0, t2, a0 
  add t1, t2, a1
  
  
__scan_write_loop:
  flw ft1, -4(t0)
  fsub.s ft2, ft2, ft1
  fsw ft2, 0(t1)
  addi t0, -4
  addi t1, -4
  bne t0, a0, __scan_write_loop

  ret
