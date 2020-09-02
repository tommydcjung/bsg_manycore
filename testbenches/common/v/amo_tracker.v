module amo_tracker 
  import bsg_manycore_pkg::*;
  import bsg_cache_pkg::*;
  #(parameter link_addr_width_p="inv"
    , parameter data_width_p="inv"
    , parameter x_cord_width_p="inv"
    , parameter y_cord_width_p="inv"

    , parameter byte_offset_width_lp=`BSG_SAFE_CLOG2(data_width_p>>3)
    , parameter cache_addr_width_lp=(link_addr_width_p-1+byte_offset_width_lp)
  
    , parameter manycore_packet_width_lp=
      `bsg_manycore_packet_width(link_addr_width_p,data_width_p,x_cord_width_p,y_cord_width_p)

    , parameter bsg_cache_pkt_width_lp=
      `bsg_cache_pkt_width(cache_addr_width_lp,data_width_p)
  )
  (
    input clk_i
    , input reset_i
    
    , input v_o
    , input ready_i

    , input v_we_i

    , input [data_width_p-1:0] data_i
    , input v_i
    , input yumi_o

    , input [manycore_packet_width_lp-1:0] packet_lo

    , input [bsg_cache_pkt_width_lp-1:0] cache_pkt_o
  );


  `declare_bsg_manycore_packet_s(link_addr_width_p,data_width_p,x_cord_width_p,y_cord_width_p);
  bsg_manycore_packet_s packet_lo_cast;
  assign packet_lo_cast = packet_lo;


  `declare_bsg_cache_pkt_s(cache_addr_width_lp, data_width_p);
  bsg_cache_pkt_s cache_pkt_cast;
  assign cache_pkt_cast = cache_pkt_o;


  typedef struct packed {
    bsg_cache_opcode_e opcode;
    logic [cache_addr_width_lp-1:0] addr;
    logic [y_cord_width_p-1:0] y_cord;
    logic [x_cord_width_p-1:0] x_cord;
    logic [data_width_p-1:0] store_data;
  } info_s;

  info_s tl_info_r, tv_info_r;


  always_ff @ (posedge clk_i) begin
    if (reset_i) begin
      tl_info_r <= '0;
      tv_info_r <= '0;
    end
    else begin

      if (v_o & ready_i) begin
        tl_info_r <= '{
          opcode:     cache_pkt_cast.opcode,
          addr:       cache_pkt_cast.addr,
          y_cord:     packet_lo_cast.src_y_cord,
          x_cord:     packet_lo_cast.src_x_cord,
          store_data: cache_pkt_cast.data
        };
      end

      if (v_we_i) begin
        tv_info_r <= tl_info_r;
      end

    end
  end

 

  always_ff @ (negedge clk_i) begin
    if (~reset_i) begin

      if (v_i & yumi_o) begin
        if (tv_info_r.opcode == AMOSWAP_W && data_i == 0) begin
          $display("[AMO_TRACKER] lock acquired. t=%t x=%0d y=%0d addr=%0x",
            $time, tv_info_r.x_cord, tv_info_r.y_cord, tv_info_r.addr 
          );
        end

        if (tv_info_r.opcode == AMOSWAP_W && tv_info_r.store_data == 0) begin
          $display("[AMO_TRACKER] lock released. t=%t x=%0d y=%0d addr=%0x",
            $time, tv_info_r.x_cord, tv_info_r.y_cord, tv_info_r.addr
          );
        end
      end

    end
  end
 


  




endmodule
