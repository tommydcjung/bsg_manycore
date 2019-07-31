# Begin_DVE_Session_Save_Info
# DVE view(Wave.1 ) session
# Saved on Wed Jul 31 11:48:13 2019
# Toplevel windows open: 2
# 	TopLevel.1
# 	TopLevel.2
#   Wave.1: 22 signals
# End_DVE_Session_Save_Info

# DVE version: L-2016.06-SP2-15_Full64
# DVE build date: Mar 11 2018 22:07:39


#<Session mode="View" path="/mnt/bsg/diskbits/dcjung/bsg/bsg_manycore/software/spmd/striped_hello/session.vcdplus.vpd.tcl" type="Debug">

#<Database>

gui_set_time_units 1ps
#</Database>

# DVE View/pane content session: 

# Begin_DVE_Session_Save_Info (Wave.1)
# DVE wave signals session
# Saved on Wed Jul 31 11:48:13 2019
# 22 signals
# End_DVE_Session_Save_Info

# DVE version: L-2016.06-SP2-15_Full64
# DVE build date: Mar 11 2018 22:07:39


#Add ncecessay scopes

gui_set_time_units 1ps

set _wave_session_group_1 tile0_receive
if {[gui_sg_is_group -name "$_wave_session_group_1"]} {
    set _wave_session_group_1 [gui_sg_generate_new_name]
}
set Group1 "$_wave_session_group_1"

gui_sg_addsignal -group "$_wave_session_group_1" { {V1:spmd_testbench.DUT.y[1].x[0].tile.proc.h.z.vcore.clk_i} {V1:spmd_testbench.DUT.y[1].x[0].tile.proc.h.z.vcore.reset_i} {V1:spmd_testbench.DUT.y[1].x[0].tile.proc.h.z.vcore.remote_dmem_v_i} {V1:spmd_testbench.DUT.y[1].x[0].tile.proc.h.z.vcore.remote_dmem_w_i} {V1:spmd_testbench.DUT.y[1].x[0].tile.proc.h.z.vcore.remote_dmem_addr_i} {V1:spmd_testbench.DUT.y[1].x[0].tile.proc.h.z.vcore.remote_dmem_data_i} {V1:spmd_testbench.DUT.y[1].x[0].tile.proc.h.z.vcore.remote_dmem_yumi_o} {V1:spmd_testbench.DUT.y[1].x[0].tile.proc.h.z.endp.in_src_x_cord_o} {V1:spmd_testbench.DUT.y[1].x[0].tile.proc.h.z.endp.in_src_y_cord_o} }

set _wave_session_group_2 tile0_send
if {[gui_sg_is_group -name "$_wave_session_group_2"]} {
    set _wave_session_group_2 [gui_sg_generate_new_name]
}
set Group2 "$_wave_session_group_2"

gui_sg_addsignal -group "$_wave_session_group_2" { {V1:spmd_testbench.DUT.y[1].x[0].tile.proc.h.z.tx.clk_i} {V1:spmd_testbench.DUT.y[1].x[0].tile.proc.h.z.tx.reset_i} {V1:spmd_testbench.DUT.y[1].x[0].tile.proc.h.z.tx.out_v_o} {V1:spmd_testbench.DUT.y[1].x[0].tile.proc.h.z.tx.out_ready_i} {V1:spmd_testbench.DUT.y[1].x[0].tile.proc.h.z.tx.out_packet.y_cord} {V1:spmd_testbench.DUT.y[1].x[0].tile.proc.h.z.tx.out_packet.x_cord} {V1:spmd_testbench.DUT.y[1].x[0].tile.proc.h.z.tx.out_packet.payload} {V1:spmd_testbench.DUT.y[1].x[0].tile.proc.h.z.tx.out_packet.addr} {V1:spmd_testbench.DUT.y[1].x[0].tile.proc.h.z.tx.remote_req_i.write_not_read} {V1:spmd_testbench.DUT.y[1].x[0].tile.proc.h.z.vcore.exe_pc} {V1:spmd_testbench.DUT.y[1].x[0].tile.proc.h.z.vcore.exe_r.instruction} }

set _wave_session_group_3 Group3
if {[gui_sg_is_group -name "$_wave_session_group_3"]} {
    set _wave_session_group_3 [gui_sg_generate_new_name]
}
set Group3 "$_wave_session_group_3"

gui_sg_addsignal -group "$_wave_session_group_3" { {V1:spmd_testbench.DUT.y[2].x[1].tile.proc.h.z.vcore.clk_i} {V1:spmd_testbench.DUT.y[2].x[1].tile.proc.h.z.vcore.reset_i} }
if {![info exists useOldWindow]} { 
	set useOldWindow true
}
if {$useOldWindow && [string first "Wave" [gui_get_current_window -view]]==0} { 
	set Wave.1 [gui_get_current_window -view] 
} else {
	set Wave.1 [lindex [gui_get_window_ids -type Wave] 0]
if {[string first "Wave" ${Wave.1}]!=0} {
gui_open_window Wave
set Wave.1 [ gui_get_current_window -view ]
}
}

set groupExD [gui_get_pref_value -category Wave -key exclusiveSG]
gui_set_pref_value -category Wave -key exclusiveSG -value {false}
set origWaveHeight [gui_get_pref_value -category Wave -key waveRowHeight]
gui_list_set_height -id Wave -height 25
set origGroupCreationState [gui_list_create_group_when_add -wave]
gui_list_create_group_when_add -wave -disable
gui_marker_create -id ${Wave.1} M1 127300
gui_marker_create -id ${Wave.1} M2 127720
gui_marker_create -id ${Wave.1} M3 200440
gui_marker_create -id ${Wave.1} M4 205320
gui_marker_set_ref -id ${Wave.1}  C1
gui_wv_zoom_timerange -id ${Wave.1} 204089 204289
gui_list_add_group -id ${Wave.1} -after {New Group} [list ${Group1}]
gui_list_add_group -id ${Wave.1} -after {New Group} [list ${Group2}]
gui_list_add_group -id ${Wave.1} -after {New Group} [list ${Group3}]
gui_list_select -id ${Wave.1} {{spmd_testbench.DUT.y[1].x[0].tile.proc.h.z.vcore.exe_pc} }
gui_seek_criteria -id ${Wave.1} {Any Edge}


gui_set_pref_value -category Wave -key exclusiveSG -value $groupExD
gui_list_set_height -id Wave -height $origWaveHeight
if {$origGroupCreationState} {
	gui_list_create_group_when_add -wave -enable
}
if { $groupExD } {
 gui_msg_report -code DVWW028
}
gui_list_set_filter -id ${Wave.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Wave.1} -text {*}
gui_list_set_insertion_bar  -id ${Wave.1} -group ${Group2}  -item {spmd_testbench.DUT.y[1].x[0].tile.proc.h.z.vcore.exe_r.instruction} -position below

gui_marker_move -id ${Wave.1} {C1} 204120
gui_view_scroll -id ${Wave.1} -vertical -set 0
gui_show_grid -id ${Wave.1} -enable false
#</Session>

