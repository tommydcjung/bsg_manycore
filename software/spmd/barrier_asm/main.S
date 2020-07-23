/**
 *    barrier.S
 *
 */


#include "bsg_manycore_arch.h"
#include "bsg_manycore_asm.h"

bsg_asm_finish(0,0)
loop:
  beq x0, x0, loop

#define CSR_SON_FMA   0x10
#define CSR_SON_FADD  0x11
#define CSR_SON_FBAR  0x12

//    Barrier Routine
//    a0 = reservation address
barrier:
  fence
  sw x0, 0(a0)
  //fbar.son f0, f0

  la t0, __bsg_id
  lw t0, 0(t0)
  li t1, (bsg_tiles_X*bsg_tiles_Y)-1  

  beq t0, t1, __barrier_last_tile
  bne t0, x0, __barrier_end

__barrier_root_tile_loop:
  lr.w t0, 0(a0)
  bne t0, x0, __barrier_root_tile_end
  lr.w.aq t0, 0(a0)
  beq t0, x0, __barrier_root_tile_loop

__barrier_root_tile_end:
  //fbar.son f0, f0
  ret

__barrier_last_tile:
  lui t0, 0x20000
  or t0, a0, t0                       // root tile's reservation addr
  sw t0, 0(t0)                        // wake up the root tile

__barrier_end: 
  //fbar.son f0, f0
  ret


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
  // use where the accumulated data is.
  move t2, a1
  move t3, a1
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





//  Convolution 3x3
//  a0 = is_source
//  a1 = activation array addr
//  a2 = write dest addr
//  a3 = CSR_SON_FMA write val
//  weights are already loaded in ft0~ft8
//  acc ft9-ft11
//  activation load register fa0-fa2
conv:
  fcvt.s.w ft9, x0
  fcvt.s.w ft10, x0
  fcvt.s.w ft11, x0
  csrrw x0, CSR_SON_FMA, a3

  beq a0, x0, __conv_non_source

__conv_source:
  flw fa0, 0(a1) 
  flw fa1, 4(a1) 
  flw fa2, 8(a1) 
  //fmadd.son ft9,  ft0, fa0, ft9
  //fmadd.son ft10, ft1, fa1, ft10
  //fmadd.son ft11, ft2, fa2, ft11
  flw fa0, 12(a1) 
  flw fa1, 16(a1) 
  flw fa2, 20(a1) 
  //fmadd.son ft9,  ft3, fa0, ft9
  //fmadd.son ft10, ft4, fa1, ft10
  //fmadd.son ft11, ft5, fa2, ft11
  flw fa0, 24(a1) 
  flw fa1, 28(a1) 
  flw fa2, 32(a1) 
  //fmadd.son ft9,  ft6, fa0, ft9
  //fmadd.son ft10, ft7, fa1, ft10
  //fmadd.son ft11, ft8, fa2, ft11
  fadd.s ft9, ft9, ft10
  fadd.s ft9, ft9, ft11
  fsw ft9, 0(a2)
  ret

// non-source should have rs2 supplied from the network.
// So it doesn't matter what operand is specified in the instruction
__conv_non_source:
  
  //fmadd.son ft9,  ft0, ft0, ft9
  //fmadd.son ft10, ft1, ft1, ft10
  //fmadd.son ft11, ft2, ft2, ft11
  //fmadd.son ft9,  ft3, ft3, ft9
  //fmadd.son ft10, ft4, ft4, ft10
  //fmadd.son ft11, ft5, ft5, ft11
  //fmadd.son ft9,  ft6, ft6, ft9
  //fmadd.son ft10, ft7, ft7, ft10
  //fmadd.son ft11, ft8, ft8, ft11
  fadd.s ft9, ft9, ft10
  fadd.s ft9, ft9, ft11
  fsw ft9, 0(a2)
  ret










