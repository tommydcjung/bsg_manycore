`include "bsg_manycore_packet.vh"

module dummy_cache
  #(parameter addr_width_p="inv"
    , parameter data_width_p="inv"
    , parameter load_id_width_p="inv"
    , parameter x_cord_width_p="inv"
    , parameter y_cord_width_p="inv"

    , parameter link_sif_width_lp=
      `bsg_manycore_link_sif_width(addr_width_p,data_width_p,x_cord_width_p,y_cord_width_p,load_id_width_p)
  )
  (
    input clk_i
    , input reset_i

    , input [link_sif_width_lp-1:0] link_sif_i
    , input [link_sif_width_lp-1:0] link_sif_o
  );




endmodule
