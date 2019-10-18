`include "bsg_manycore_packet.vh"


module testbench();
  import bsg_non_pkg::*;

  logic clk;
  logic reset;


  bsg_nonsynth_clock_gen #(
    .cycle_time_p(10)
  ) cg (
    .o(clk)
  );

  bsg_nonsynth_reset_gen #(
    .reset_cycles_lo_p(0)
    ,.reset_cycles_hi_p(10)
  ) rg (
    .clk_i(clk)
    ,.async_reset_o(reset)
  );

  parameter num_tiles_x_p = 1;
  parameter num_tiles_y_p = 4;
  parameter y_cord_width_lp=`BSG_SAFE_CLOG2(num_tiles_y_p+1); // including cache node
  parameter x_cord_width_lp=`BSG_SAFE_CLOG2(num_tiles_x_p);
  parameter addr_width_p=32;
  parameter data_width_p=32;
  parameter load_id_width_p=12;

  `declare_bsg_manycore_link_sif_s(addr_width_p,data_width_p,x_cord_width_lp,
    y_cord_width_lp,load_id_width_p);
  bsg_manycore_link_sif_s [E:W][num_tiles_y_p-1:0] hor_link_li;
  bsg_manycore_link_sif_s [E:W][num_tiles_y_p-1:0] hor_link_lo;
  bsg_manycore_link_sif_s [S:N][num_tiles_x_p-1:0] ver_link_li;
  bsg_manycore_link_sif_s [S:N][num_tiles_x_p-1:0] ver_link_lo;
  bsg_manycore_link_sif_s [num_tiles_y_p-1:0] proc_link_li;
  bsg_manycore_link_sif_s [num_tiles_y_p-1:0] proc_link_lo;


  bsg_manycore_mesh #(
    .num_tiles_x_p(num_tiles_x_p)
    ,.num_tiles_y_p(num_tiles_y_p)
    ,.addr_width_p(addr_width_p)
    ,.data_width_p(data_width_p)
    ,.load_id_width_p(load_id_width_p)
  ) mesh (

    .clk_i(clk)
    ,.reset_i(reset)

    ,.hor_link_sif_i(hor_link_li)
    ,.hor_link_sif_o(hor_link_lo)

    ,.ver_link_sif_i(ver_link_li)
    ,.ver_link_sif_o(ver_link_lo)

    ,.proc_link_sif_i(proc_link_li)
    ,.proc_link_sif_o(proc_link_lo)
    
  ); 


  // tieoff
  //
  for (genvar i = 0; i < num_tiles_x_p; i++) begin
    bsg_manycore_link_sif_tieoff #(
      .addr_width_p(addr_width_p)
      ,.data_width_p(data_width_p)
      ,.load_id_width_p(load_id_width_p)
      ,.x_cord_width_p(x_cord_width_lp)
      ,.y_cord_width_p(y_cord_width_lp)  
    ) tieoff_n (
      .clk_i(clk)
      ,.reset_i(reset)
      ,.link_sif_i(ver_link_lo[N][i])
      ,.link_sif_o(ver_link_li[N][i])
    );
  end

  for (genvar i = 0; i < num_tiles_y_p; i++) begin
    bsg_manycore_link_sif_tieoff #(
      .addr_width_p(addr_width_p)
      ,.data_width_p(data_width_p)
      ,.load_id_width_p(load_id_width_p)
      ,.x_cord_width_p(x_cord_width_lp)
      ,.y_cord_width_p(y_cord_width_lp)  
    ) tieoff_e (
      .clk_i(clk)
      ,.reset_i(reset)
      ,.link_sif_i(hor_link_lo[E][i])
      ,.link_sif_o(hor_link_li[E][i])
    );

    bsg_manycore_link_sif_tieoff #(
      .addr_width_p(addr_width_p)
      ,.data_width_p(data_width_p)
      ,.load_id_width_p(load_id_width_p)
      ,.x_cord_width_p(x_cord_width_lp)
      ,.y_cord_width_p(y_cord_width_lp)  
    ) tieoff_w (
      .clk_i(clk)
      ,.reset_i(reset)
      ,.link_sif_i(hor_link_lo[W][i])
      ,.link_sif_o(hor_link_li[W][i])
    );
  end

  // dummy cache
  //
  dummy_cache #(
    
  ) dcache (
    .clk_i(clk)
    ,.reset_i(reset)
    ,.link_sif_i(ver_link_lo[S][0])
    ,.link_sif_o(ver_link_li[S][0])
  );


  initial begin
    #1000000;
    $finish();
  end

endmodule
