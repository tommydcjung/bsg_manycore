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
// ft2  = prescan val
// ft3  = const zero
// t0   = read pointer
// t1   = write pointer
// t2   = limit addr


scan:
  fcvt.s.w ft0, x0
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
  fadd.son ft2, ft3, ft0
  // now everyone has a prescan at ft2
  // calculate limit addr
  fcvt.s.w ft0, x0
  slli t2, a2, 2
  add t2, t2, a0
  // init read/write pointer
  move t0, a0
  move t1, a1
  
  
__scan_write_loop:
  flw ft1, 0(t0)
  fadd.s ft0, ft0, ft1
  fsw ft0, 0(t1)
  addi t0, 4
  addi t1, 4
  bne t0, t2, __scan_write_loop

  ret
