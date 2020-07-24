/**
 *    reduction.S
 *
 */


//    Reduction Routine
//    a0 = source array addr
//    a1 = final dest array addr
reduction:
  // horizontal
  fcvt.s.w ft4, x0    // const zero
  li t0, 0            // horz = 0, vert = 1
  addi t1, a0, 512    // limit addr
  move t2, a0         // read pointer
  move t3, a1         // write pointer

  la t4, __bsg_x
  lw t4, 0(t4)
  li t5, (bsg_tiles_X-1)
  bne t4, t5, __reduction_x_not_last
  // X = last
  csrrwi x0, CSR_SON_FADD, 0x09 // input = west, output = proc, 01_001


__reduction_last_loop:
  flw ft0, 0(t2)
  flw ft1, 4(t2)
  flw ft2, 8(t2)
  flw ft3, 12(t2)
  //fadd.son ft0, ft0, ft4
  //fadd.son ft1, ft1, ft4
  //fadd.son ft2, ft2, ft4
  //fadd.son ft3, ft3, ft4
  fsw ft0, 0(t3) 
  fsw ft1, 4(t3) 
  fsw ft2, 8(t3) 
  fsw ft3, 12(t3) 
  addi t2, t2, 16
  addi t3, t3, 16
  bne t1, t2, __reduction_last_loop
  
  // check if horizontal
  beq x0, t0, __reduction_reconfig
  ret
  
__reduction_reconfig:
  // check y
  la t4, __bsg_y
  lw t4, 0(t4)
  li t5, (bsg_tiles_Y-1)
  // use the accumulated data for vertical.
  move t2, a1
  move t3, a1
  addi t1, a1, 512
  bne t4, t5, __reduction_y_not_last
  // Y = last
  li t0, 1                      // set to vertical
  csrrwi x0, CSR_SON_FADD, 0x11 // input = north, output = proc, 10_001
  j __reduction_last_loop

__reduction_y_not_last:
  bne t4, x0, __reduction_y_not_zero
  // y = zero
  csrrwi x0, CSR_SON_FADD, 0x4  // input = rs1, output = south, 00_100 
  j __reduction_loop
  
__reduction_y_not_zero:
  // y = middle
  csrrwi x0, CSR_SON_FADD, 0x14  // input = north, output = south, 10_100 
  j __reduction_loop
  
__reduction_x_not_last:
  bne t4, x0, __reduction_x_not_zero
  // x = zero
  csrrwi x0, CSR_SON_FADD, 0x2 // input = rs1, output = east, 00_010
  j __reduction_loop

__reduction_x_not_zero:
  // x middle
  csrrwi x0, CSR_SON_FADD, 0xa // input = west, output = east, 01_010

__reduction_loop:
  flw ft0, 0(t2)
  flw ft1, 4(t2)
  flw ft2, 8(t2)
  flw ft3, 12(t2)
  //fadd.son ft0, ft0, ft4
  //fadd.son ft1, ft1, ft4
  //fadd.son ft2, ft2, ft4
  //fadd.son ft3, ft3, ft4
  addi t2, t2, 16
  bne t1, t2, __reduction_loop
  ret


