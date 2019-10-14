/**
 *    bsg_manycore_endpoint_standard.v
 *
 */


module bsg_manycore_endpoint_standard
  import bsg_manycore_pkg::*;
  #(parameter x_cord_width_p = "inv"
    , parameter y_cord_width_p = "inv"
    , parameter data_width_p = "inv"
    , parameter addr_width_p = "inv"
    , parameter load_id_width_p = "inv"

    , parameter max_out_credits_p = "inv"
    , parameter fifo_els_p = "inv"
    , parameter include_lock_ctrl_p = 0

    , parameter data_mask_width_lp = (data_width_p>>3)
    , parameter credit_counter_width_lp=$clog2(max_out_credits_p+1)

    , parameter packet_width_lp = 
      `bsg_manycore_packet_width(addr_width_p,data_width_p,x_cord_width_p,y_cord_width_p,load_id_width_p)
    , parameter return_packet_width_lp =
      `bsg_manycore_return_packet_width(x_cord_width_p,y_cord_width_p, data_width_p, load_id_width_p)
    , parameter link_sif_width_lp =
      `bsg_manycore_link_sif_width(addr_width_p,data_width_p,x_cord_width_p,y_cord_width_p, load_id_width_p)
  )
  (
    input clk_i
    , input reset_i

    // connection to mesh network.
    , input  [link_sif_width_lp-1:0] link_sif_i
    , output [link_sif_width_lp-1:0] link_sif_o

    // incoming request
    , output in_v_o
    , output in_we_o
    , output [addr_width_p-1:0] in_addr_o
    , output [data_width_p-1:0] in_data_o
    , output [data_mask_width_lp-1:0] in_mask_o
    , output [x_cord_width_p-1:0] in_src_x_cord_o
    , output [y_cord_width_p-1:0] in_src_y_cord_o
    , input in_yumi_i

    // outgoing response
    , input returning_v_i
    , input [x_cord_width_p-1:0] returning_x_cord_i
    , input [y_cord_width_p-1:0] returning_y_cord_i
    , input [data_width_p-1:0] returning_data_i

    // outgoing request
    , input out_v_i
    , input [packet_width_lp-1:0] out_packet_i
    , output out_ready_o

    // incoming response
    , output [data_width_p-1:0] returned_data_r_o
    , output [load_id_width_p-1:0] returned_load_id_r_o
    , output returned_v_r_o
    , input returned_yumi_i
    , output returned_fifo_full_o

    // credit
    , output [credit_counter_width_lp-1:0] out_credits_o

    // tile coordinates
    , input [x_cord_width_p-1:0] my_x_i
    , input [y_cord_width_p-1:0] my_y_i
  );


  // declare struct
  //
  `declare_bsg_manycore_packet_s(addr_width_p,data_width_p,
    x_cord_width_p,y_cord_width_p,load_id_width_p);


  // endpoint
  //
  bsg_manycore_packet_s packet_lo;
  logic packet_v_lo;
  logic packet_yumi_li;

  bsg_manycore_return_packet_s return_packet_li;
  logic return_packet_v_li;
  logic return_packet_ready_lo;

  bsg_manycore_packet_s packet_li;
  logic packet_v_li;
  logic packet_ready_lo;
  
  bsg_manycore_return_packet_s return_packet_lo;
  logic return_packet_v_lo;
  logic return_fifo_full_lo;
  logic return_packet_yumi_li;

  bsg_manycore_endpoint #(
    .addr_width_p(addr_width_p)
    ,.data_width_p(data_width_p)
    ,.x_cord_width_p(x_cord_width_p)
    ,.y_cord_width_p(y_cord_width_p)
    ,.load_id_width_p(load_id_width_p)
    ,.fifo_els_p(fifo_els_p)
  ) ep (
    .clk_i(clk_i)
    ,.reset_i(reset_i)
   
    ,.link_sif_i(link_sif_i)
    ,.link_sif_o(link_sif_o) 

    ,.packet_o(packet_lo)
    ,.packet_v_o(packet_v_lo)
    ,.packet_yumi_li(packet_yumi_li)

    ,.return_packet_i(return_packet_li)
    ,.return_packet_v_i(return_packet_v_li)
    ,.return_packet_ready_o(return_packet_ready_lo)

    ,.packet_i(packet_li)
    ,.packet_v_i(packet_v_li)
    ,.packet_ready_o(packet_ready_lo)

    ,.return_packet_o(return_packet_lo)
    ,.return_packet_v_o(return_packet_v_lo)
    ,.return_fifo_full_o(return_fifo_full_lo)
    ,.return_packet_yumi_i(return_packet_yumi_li)
  );

  // lock ctrl
  //
  if (include_lock_ctrl_p) begin: lock
    bsg_manycore_lock_ctrl #(
      .addr_width_p(addr_width_p)
      ,.data_width_p(data_width_p)
      ,.x_cord_width_p(x_cord_width_p)
      ,.y_cord_width_p(y_cord_width_p)
      ,.load_id_width_p(load_id_width_p)
    ) lock_ctrl (
    );
  end
  else begin: no_lock

  end


  // credit counter
  //
  logic counter_down;
  logic counter_up;

  bsg_counter_up_down #(
    .max_val_p(max_out_credits_p)
    ,.init_val_p(max_out_credits_p)
    ,.max_step_p(1)
  ) credit_counter (
    .clk_i(clk_i)
    ,.reset_i(reset_i)
    ,.down_i(counter_down)
    ,.up_i(counter_up)
    ,.count_o(out_credits_o)
  );


endmodule


