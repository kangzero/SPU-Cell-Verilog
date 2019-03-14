onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TB_SPE/dut/spu/pc_reg/clk
add wave -noupdate /TB_SPE/dut/spu/pc_reg/rst
add wave -noupdate /TB_SPE/dut/spu/pc_reg/pc
add wave -noupdate /TB_SPE/dut/spu/if_id/if_inst
add wave -noupdate /TB_SPE/dut/spu/id/id_pc
add wave -noupdate /TB_SPE/dut/spu/id/inst_l
add wave -noupdate /TB_SPE/dut/spu/id/inst_h
add wave -noupdate /TB_SPE/dut/spu/id/pipe_l
add wave -noupdate /TB_SPE/dut/spu/id/pipe_h
add wave -noupdate /TB_SPE/dut/spu/id/op_code_e
add wave -noupdate /TB_SPE/dut/spu/id/ra_do_e
add wave -noupdate /TB_SPE/dut/spu/id/rb_do_e
add wave -noupdate /TB_SPE/dut/spu/id/rt_addr_e
add wave -noupdate /TB_SPE/dut/spu/id/wreg_e
add wave -noupdate /TB_SPE/dut/spu/id/op_code_o
add wave -noupdate /TB_SPE/dut/spu/id/ra_do_o
add wave -noupdate /TB_SPE/dut/spu/id/rb_do_o
add wave -noupdate /TB_SPE/dut/spu/id/rt_addr_o
add wave -noupdate /TB_SPE/dut/spu/id/wreg_o
add wave -noupdate /TB_SPE/dut/spu/ex_even/o_rt_e
add wave -noupdate /TB_SPE/dut/spu/ex_even/o_rtaddr_e
add wave -noupdate /TB_SPE/dut/spu/ex_even/o_wreg_e
add wave -noupdate /TB_SPE/dut/spu/ex_even/o_uid_e
add wave -noupdate /TB_SPE/dut/spu/ex_odd/o_rt_o
add wave -noupdate /TB_SPE/dut/spu/ex_odd/o_rtaddr_o
add wave -noupdate /TB_SPE/dut/spu/ex_odd/o_wreg_o
add wave -noupdate /TB_SPE/dut/spu/ex_odd/o_uid_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {267589 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 229
configure wave -valuecolwidth 225
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {930548 ps} {1208919 ps}
