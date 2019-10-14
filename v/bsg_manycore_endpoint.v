/**
 *    bsg_manycore_endpoint.v
 *
 */


module bsg_manycore_endpoint
  import bsg_manycore_pkg::*;
  #(parameter x_cord_width_p = "inv"
    , parameter y_cord_width_p = "inv"
    , parameter data_width_p = 32
    , parameter addr_width_p = "inv"
    , parameter load_id_width_p = "inv"

    , parameter fifo_els_p = "inv"

    , parameter link_sif_width_lp = 
      `bsg_manycore_link_sif_width(addr_width_p,data_width_p,x_cord_width_p,y_cord_width_p, load_id_width_p)
    , parameter packet_width_lp = 
      `bsg_manycore_packet_width(addr_width_p,data_width_p,x_cord_width_p,y_cord_width_p,load_id_width_p)
    , parameter return_packet_width_lp =
      `bsg_manycore_return_packet_width(x_cord_width_p,y_cord_width_p, data_width_p, load_id_width_p)
  )
  (
    input clk_i
    , input reset_i

    // link sif
    , input [link_sif_width_lp-1:0] link_sif_i
    , output logic [link_sif_width_lp-1:0] link_sif_o

    // incoming request
    , output logic [packet_width_lp-1:0] packet_o
    , output logic packet_v_o
    , input packet_yumi_i

    // outgoing response
    , input return_packet_v_i
    , input [return_packet_width_lp-1:0] return_packet_i
    , output logic return_packet_ready_o

    // outgoing request
    , input packet_v_i
    , input [packet_width_lp-1:0] packet_i
    , output logic packet_ready_o

    // incoming response
    , output logic return_packet_v_o
    , output logic [return_packet_width_lp-1:0] return_packet_o
    , output logic return_fifo_full_o
    , input return_packet_yumi_i
  );


  // declare struct
  //
  `declare_bsg_manycore_link_sif_s(addr_width_p,data_width_p,
    x_cord_width_p,y_cord_width_p,load_id_width_p);

  bsg_manycore_link_sif_s link_sif_in, link_sif_out;
  assign link_sif_in = link_sif_i;
  assign link_sif_o = link_sif_out;


  // Incoming request FIFO
  //
  bsg_fifo_1r1w_small #(
    .width_p(packet_width_lp)
    ,.els_p (fifo_els_p)
  ) in_req_fifo (
    .clk_i(clk_i)
    ,.reset_i(reset_i)

    ,.v_i(link_sif_in.fwd.v)
    ,.data_i(link_sif_in.fwd.data)
    ,.ready_o(link_sif_out.fwd.ready_and_rev)

    ,.v_o(packet_v_o)
    ,.data_o(packet_o)
    ,.yumi_i(packet_yumi_i)
  );


  // Outgoing response packet
  //
  assign link_sif_out.rev.v = return_packet_v_i;
  assign link_sif_out.rev.data = return_packet_i;
  assign return_packet_ready_o = link_sif_in.rev.ready_and_rev;


  // Outgoing request packet
  //
  assign link_sif_out.fwd.v = packet_v_i;
  assign link_sif_out.fwd.data = packet_i;
  assign packet_ready_o = link_sif_in.fwd.ready_and_rev;


  // Incoming response packet
  // Generally, response packets have to be accepted as soon as they become
  // available. We have a buffer FIFO to temporarily hold the incoming responses.
  // When this FIFO becomes full, it raises return_fifo_full_o signal.

  logic return_fifo_ready_lo;

  bsg_two_fifo #(
    .width_p(return_packet_width_lp)
    ,.allow_enq_deq_on_full_p(1)
  ) return_fifo (
    .clk_i(clk_i)
    ,.reset_i(reset_i)
    
    ,.v_i(link_sif_in.rev.v)
    ,.data_i(link_sif_in.rev.data)
    ,.ready_o(return_fifo_ready_lo)

    ,.v_o(return_packet_v_o)
    ,.yumi_i(return_packet_yumi_i)
    ,.data_o(return_packet_o)
  );

  assign return_fifo_full_o = ~return_fifo_ready_lo;

  
  // synopsys translate_off

  always_ff @ (negedge clk_i) begin
    if (~reset_i & return_packet_v_o & return_fifo_full_o) begin
      assert(return_packet_yumi_i)
        else $error("[BSG_ERROR] %m. When the return FIFO is full, the return packet has to be dequeued to prevent data loss. t=%t", $time);
    end
  end  

  // synopsys translate_on

endmodule


