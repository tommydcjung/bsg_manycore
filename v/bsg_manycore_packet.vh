`ifndef BSG_MANYCORE_PACKET_VH
`define BSG_MANYCORE_PACKET_VH

`include "bsg_noc_links.vh"

`define return_packet_type_width  1

`define  ePacketOp_remote_load    2'b00
`define  ePacketOp_remote_store   2'b01
`define  ePacketOp_remote_swap_aq 2'b10
`define  ePacketOp_remote_swap_rl 2'b11

`define  ePacketType_credit      `return_packet_type_width'(0)  
`define  ePacketType_data        `return_packet_type_width'(1)   


`define declare_bsg_manycore_packet_s(in_addr_width,in_data_width,in_x_cord_width,in_y_cord_width, load_id_width_mp) \
    typedef struct packed {                                                 \
       logic [`return_packet_type_width-1:0] pkt_type;                      \
       logic [(in_data_width)-1:0]           data  ;                        \
       logic [(load_id_width_mp)-1:0]        load_id;                       \
       logic [(in_y_cord_width)-1:0]         y_cord;                        \
       logic [(in_x_cord_width)-1:0]         x_cord;                        \
    } bsg_manycore_return_packet_s;                                         \
                                                                            \
    typedef union packed {                                                  \
        logic [(in_data_width)-1:0] data;                                   \
        struct packed {                                                     \
            logic [(in_data_width-load_id_width_mp)-1:0] load_info_padding; \
            logic [(load_id_width_mp)-1:0]               load_id;           \
        } load_info_s;                                                      \
    } bsg_manycore_packet_payload_u;                                        \
                                                                            \
    typedef struct packed {                                                 \
       logic [(in_addr_width)-1:0]    addr;                                 \
       logic [1:0]                    op;                                   \
       logic [(in_data_width>>3)-1:0] op_ex;                                \
       bsg_manycore_packet_payload_u  payload;                              \
       logic [(in_y_cord_width)-1:0]  src_y_cord;                           \
       logic [(in_x_cord_width)-1:0]  src_x_cord;                           \
       logic [(in_y_cord_width)-1:0]  y_cord;                               \
       logic [(in_x_cord_width)-1:0]  x_cord;                               \
    } bsg_manycore_packet_s

`define bsg_manycore_return_packet_width(in_x_cord_width,in_y_cord_width,in_data_width,load_id_width_mp) \
                                                                          ( (in_x_cord_width) \
                                                                           +(in_y_cord_width) \
                                                                           +(in_data_width  ) \
                                                                           +(`return_packet_type_width) \
                                                                           +(load_id_width_mp) \
                                                                          )

`define bsg_manycore_packet_width(in_addr_width,in_data_width,in_x_cord_width,in_y_cord_width,load_id_width_mp) \
        (                                     \
            ( 2 * (in_x_cord_width) )         \
          + ( 2 * (in_y_cord_width) )         \
          + ( in_data_width         )         \
          + ( 2                     )         \
          + ( (in_data_width) >> 3  )         \
          + ( in_addr_width         )         \
        )



// note op_ex above is the byte mask for writes.
// we put the addr at the top of the packet so that we can truncate it
// X must be lowest in the packet, and Y must be the next lowest for bsg_mesh_router to work.
//

`define bsg_manycore_link_sif_width(in_addr_width,in_data_width,in_x_cord_width, in_y_cord_width, load_id_width_mp)                              \
     (   `bsg_ready_and_link_sif_width(`bsg_manycore_packet_width(in_addr_width,in_data_width,in_x_cord_width,in_y_cord_width,load_id_width_mp))        \
       + `bsg_ready_and_link_sif_width(`bsg_manycore_return_packet_width(in_x_cord_width,in_y_cord_width, in_data_width,load_id_width_mp)) \
     )

`define declare_bsg_manycore_fwd_link_sif_s(in_addr_width,in_data_width,in_x_cord_width,in_y_cord_width,load_id_width_mp,name)  \
     `declare_bsg_ready_and_link_sif_s(`bsg_manycore_packet_width(in_addr_width,in_data_width,in_x_cord_width,in_y_cord_width,load_id_width_mp),name)

`define declare_bsg_manycore_rev_link_sif_s(in_x_cord_width,in_y_cord_width,in_data_width,load_id_width_mp,name)  \
     `declare_bsg_ready_and_link_sif_s(`bsg_manycore_return_packet_width(in_x_cord_width,in_y_cord_width, in_data_width, load_id_width_mp),name)

`define write_bsg_manycore_packet_s(PKT)                                                                                                     \
    $write("op=2'b%b, op_ex=4'b%b, addr=%-d'h%h data=%-d'h%h (x,y)=(%-d'b%b,%-d'b%b), return (x,y)=(%-d'b%b,%-d'b%b)"                        \
           , PKT.op, PKT.op_ex, $bits(PKT.addr), PKT.addr, $bits(PKT.payload), PKT.payload, $bits(PKT.x_cord), PKT.x_cord, $bits(PKT.y_cord), PKT.y_cord, $bits(PKT.src_x_cord), PKT.src_x_cord, $bits(PKT.src_y_cord), PKT.src_y_cord)

// defines bsg_manycore_fwd_link_sif, bsg_manycore_rev_link_sif, and the combination, bsg_manycore_link_sif_s
`define declare_bsg_manycore_link_sif_s(in_addr_width, in_data_width, in_x_cord_width, in_y_cord_width, load_id_width_mp) \
    `declare_bsg_manycore_fwd_link_sif_s(in_addr_width, in_data_width, in_x_cord_width, in_y_cord_width, load_id_width_mp, bsg_manycore_fwd_link_sif_s); \
    `declare_bsg_manycore_rev_link_sif_s(in_x_cord_width, in_y_cord_width,in_data_width, load_id_width_mp, bsg_manycore_rev_link_sif_s);  \
                                                                                                                                       \
   typedef struct packed {             \
      bsg_manycore_fwd_link_sif_s fwd; \
      bsg_manycore_rev_link_sif_s rev; \
   } bsg_manycore_link_sif_s


`endif // BSG_MANYCORE_PACKET_VH
