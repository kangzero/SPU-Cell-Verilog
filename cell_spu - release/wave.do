onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TB_SPE/spe/spu/if_id/clk
add wave -noupdate /TB_SPE/spe/spu/if_id/rst
add wave -noupdate /TB_SPE/spe/spu/if_id/if_inst
add wave -noupdate /TB_SPE/spe/spu/if_id/id_pc
add wave -noupdate /TB_SPE/spe/spu/if_id/id_inst
add wave -noupdate /TB_SPE/spe/spu/id/ra_do_e
add wave -noupdate /TB_SPE/spe/spu/id/rb_do_e
add wave -noupdate /TB_SPE/spe/spu/id/rt_addr_e
add wave -noupdate /TB_SPE/spe/spu/id/wreg_e
add wave -noupdate /TB_SPE/spe/spu/id/even
add wave -noupdate /TB_SPE/spe/spu/id/uid_e
add wave -noupdate /TB_SPE/spe/spu/id/ra_rd_e
add wave -noupdate /TB_SPE/spe/spu/id/rb_rd_e
add wave -noupdate /TB_SPE/spe/spu/id/inst_l
add wave -noupdate /TB_SPE/spe/spu/id/inst_h
add wave -noupdate /TB_SPE/spe/spu/id/op_l
add wave -noupdate /TB_SPE/spe/spu/id/op_h
add wave -noupdate /TB_SPE/spe/spu/id/imm_e
add wave -noupdate /TB_SPE/spe/spu/ex/o_rt_e
add wave -noupdate /TB_SPE/spe/spu/ex/o_rtaddr_e
add wave -noupdate /TB_SPE/spe/spu/ex/o_wreg_e
add wave -noupdate /TB_SPE/spe/spu/ff1/ff1_rtaddr_e
add wave -noupdate /TB_SPE/spe/spu/ff1/ff1_wreg_e
add wave -noupdate /TB_SPE/spe/spu/ff1/ff1_rt_e
add wave -noupdate /TB_SPE/spe/spu/ff2/ff2_rtaddr_e
add wave -noupdate /TB_SPE/spe/spu/ff2/ff2_wreg_e
add wave -noupdate /TB_SPE/spe/spu/ff2/ff2_rt_e
add wave -noupdate /TB_SPE/spe/spu/ff3/ff3_rtaddr_e
add wave -noupdate /TB_SPE/spe/spu/ff3/ff3_wreg_e
add wave -noupdate /TB_SPE/spe/spu/ff3/ff3_rt_e
add wave -noupdate /TB_SPE/spe/spu/ff4/ff4_rtaddr_e
add wave -noupdate /TB_SPE/spe/spu/ff4/ff4_wreg_e
add wave -noupdate /TB_SPE/spe/spu/ff4/ff4_rt_e
add wave -noupdate /TB_SPE/spe/spu/ff5/ff5_rtaddr_e
add wave -noupdate /TB_SPE/spe/spu/ff5/ff5_wreg_e
add wave -noupdate /TB_SPE/spe/spu/ff5/ff5_rt_e
add wave -noupdate /TB_SPE/spe/spu/ff6/ff6_rtaddr_e
add wave -noupdate /TB_SPE/spe/spu/ff6/ff6_wreg_e
add wave -noupdate /TB_SPE/spe/spu/ff6/ff6_rt_e
add wave -noupdate /TB_SPE/spe/spu/ff7/ff7_rtaddr_e
add wave -noupdate /TB_SPE/spe/spu/ff7/ff7_wreg_e
add wave -noupdate /TB_SPE/spe/spu/ff7/ff7_rt_e
add wave -noupdate /TB_SPE/spe/spu/mem/o_rtaddr_e
add wave -noupdate /TB_SPE/spe/spu/mem/o_wreg_e
add wave -noupdate /TB_SPE/spe/spu/mem/o_rt_e
add wave -noupdate /TB_SPE/spe/spu/regfile/rt_we_e
add wave -noupdate /TB_SPE/spe/spu/regfile/rt_addr_e
add wave -noupdate /TB_SPE/spe/spu/regfile/rt_data_e
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {278106 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 246
configure wave -valuecolwidth 192
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
WaveRestoreZoom {939417 ps} {1208452 ps}
