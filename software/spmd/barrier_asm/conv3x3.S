
//  Convolution 3x3
//  a0 = is_source
//  a1 = activation array addr
//  a2 = write dest addr
//  a3 = CSR_SON_FMA write val
//  weights are already loaded in ft0~ft8
//  acc ft9-ft11
//  activation load register fa0-fa2
conv3x3:
  fcvt.s.w ft9, x0
  fcvt.s.w ft10, x0
  fcvt.s.w ft11, x0
  csrrw x0, CSR_SON_FMA, a3

  beq a0, x0, __conv_non_source

__conv3x3_source:
  flw fa0, 0(a1) 
  flw fa1, 4(a1) 
  flw fa2, 8(a1) 
  fmadd.son ft9,  ft0, fa0, ft9
  fmadd.son ft10, ft1, fa1, ft10
  fmadd.son ft11, ft2, fa2, ft11

  flw fa0, 12(a1) 
  flw fa1, 16(a1) 
  flw fa2, 20(a1) 
  fmadd.son ft9,  ft3, fa0, ft9
  fmadd.son ft10, ft4, fa1, ft10
  fmadd.son ft11, ft5, fa2, ft11

  flw fa0, 24(a1) 
  flw fa1, 28(a1) 
  flw fa2, 32(a1) 
  fmadd.son ft9,  ft6, fa0, ft9
  fmadd.son ft10, ft7, fa1, ft10
  fmadd.son ft11, ft8, fa2, ft11

  fadd.s ft9, ft9, ft10
  fadd.s ft9, ft9, ft11
  fsw ft9, 0(a2)
  ret

// non-source should have rs2 supplied from the network.
// So it doesn't matter what operand is specified in the instruction
__conv3x3_non_source:
  
  fmadd.son ft9,  ft0, ft0, ft9
  fmadd.son ft10, ft1, ft1, ft10
  fmadd.son ft11, ft2, ft2, ft11
  fmadd.son ft9,  ft3, ft3, ft9
  fmadd.son ft10, ft4, ft4, ft10
  fmadd.son ft11, ft5, ft5, ft11
  fmadd.son ft9,  ft6, ft6, ft9
  fmadd.son ft10, ft7, ft7, ft10
  fmadd.son ft11, ft8, ft8, ft11
  fadd.s ft9, ft9, ft10
  fadd.s ft9, ft9, ft11
  fsw ft9, 0(a2)
  ret




