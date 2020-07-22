#include "bsg_manycore_arch.h"
#include "bsg_manycore_asm.h"

bsg_asm_finish(0,0)
loop:
  beq x0, x0, loop


//    barrier routine
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



//    reduction
//    a0 = source array addr
//    a1 = final dest array addr
reduction:
  fcvt.s.w f0, x0
  la t0, __bsg_id
  lw t0, 0(t0)
  mov t1, a0
  addi t2, a0, 512    // limit addr
   
__reduction_loop:
  flw f1, 0(t1)
  flw f2, 4(t1)
  flw f3, 8(t1)
  flw f4, 12(t1)
  //fadd.son
  //fadd.son
  //fadd.son
  //fadd.son











