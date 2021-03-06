onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TB_SPE/dut/spu/pc_reg/clk
add wave -noupdate /TB_SPE/dut/spu/pc_reg/rst
add wave -noupdate /TB_SPE/dut/spu/pc_reg/stall
add wave -noupdate /TB_SPE/dut/spu/pc_reg/pc
add wave -noupdate /TB_SPE/dut/spu/if_id/if_pc
add wave -noupdate /TB_SPE/dut/spu/if_id/if_inst
add wave -noupdate /TB_SPE/dut/spu/if_id/pipe_l
add wave -noupdate /TB_SPE/dut/spu/if_id/pipe_h
add wave -noupdate /TB_SPE/dut/spu/if_id/stall
add wave -noupdate /TB_SPE/dut/spu/if_id/id_pc
add wave -noupdate /TB_SPE/dut/spu/if_id/id_inst
add wave -noupdate /TB_SPE/dut/spu/if_id/inst_echo
add wave -noupdate /TB_SPE/dut/spu/id/pc_i
add wave -noupdate /TB_SPE/dut/spu/id/inst_i
add wave -noupdate /TB_SPE/dut/spu/id/ra_i_e
add wave -noupdate /TB_SPE/dut/spu/id/rb_i_e
add wave -noupdate /TB_SPE/dut/spu/id/ra_i_o
add wave -noupdate /TB_SPE/dut/spu/id/rb_i_o
add wave -noupdate /TB_SPE/dut/spu/id/id_pc
add wave -noupdate /TB_SPE/dut/spu/id/inst_l
add wave -noupdate /TB_SPE/dut/spu/id/inst_h
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
add wave -noupdate /TB_SPE/dut/spu/id/pipe_l
add wave -noupdate /TB_SPE/dut/spu/id/pipe_h
add wave -noupdate /TB_SPE/dut/spu/id/ra_addr_e
add wave -noupdate /TB_SPE/dut/spu/id/rb_addr_e
add wave -noupdate /TB_SPE/dut/spu/id/ra_rd_e
add wave -noupdate /TB_SPE/dut/spu/id/rb_rd_e
add wave -noupdate /TB_SPE/dut/spu/id/ra_addr_o
add wave -noupdate /TB_SPE/dut/spu/id/rb_addr_o
add wave -noupdate /TB_SPE/dut/spu/id/ra_rd_o
add wave -noupdate /TB_SPE/dut/spu/id/rb_rd_o
add wave -noupdate /TB_SPE/dut/spu/id/stallreq
add wave -noupdate /TB_SPE/dut/spu/id/op_l
add wave -noupdate /TB_SPE/dut/spu/id/op_h
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {238895 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 281
configure wave -valuecolwidth 100
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
WaveRestoreZoom {194136 ps} {486837 ps}
