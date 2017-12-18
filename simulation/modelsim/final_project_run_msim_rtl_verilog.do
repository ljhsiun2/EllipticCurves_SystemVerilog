transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/Lucas/Documents/ece385/final_project {C:/Users/Lucas/Documents/ece385/final_project/reg_256.sv}
vlog -sv -work work +incdir+C:/Users/Lucas/Documents/ece385/final_project {C:/Users/Lucas/Documents/ece385/final_project/add.sv}
vlog -sv -work work +incdir+C:/Users/Lucas/Documents/ece385/final_project {C:/Users/Lucas/Documents/ece385/final_project/multiplier.sv}
vlog -sv -work work +incdir+C:/Users/Lucas/Documents/ece385/final_project {C:/Users/Lucas/Documents/ece385/final_project/modular_inverse.sv}
vlog -sv -work work +incdir+C:/Users/Lucas/Documents/ece385/final_project {C:/Users/Lucas/Documents/ece385/final_project/square_root.sv}
vlog -sv -work work +incdir+C:/Users/Lucas/Documents/ece385/final_project {C:/Users/Lucas/Documents/ece385/final_project/point_double.sv}
vlog -sv -work work +incdir+C:/Users/Lucas/Documents/ece385/final_project {C:/Users/Lucas/Documents/ece385/final_project/point_add.sv}
vlog -sv -work work +incdir+C:/Users/Lucas/Documents/ece385/final_project {C:/Users/Lucas/Documents/ece385/final_project/gen_point.sv}
vlog -sv -work work +incdir+C:/Users/Lucas/Documents/ece385/final_project {C:/Users/Lucas/Documents/ece385/final_project/elg_decrypt.sv}
vlog -sv -work work +incdir+C:/Users/Lucas/Documents/ece385/final_project {C:/Users/Lucas/Documents/ece385/final_project/elg_encrypt.sv}
vlog -sv -work work +incdir+C:/Users/Lucas/Documents/ece385/final_project {C:/Users/Lucas/Documents/ece385/final_project/final_top.sv}

vlog -sv -work work +incdir+C:/Users/Lucas/Documents/ece385/final_project/testbenches {C:/Users/Lucas/Documents/ece385/final_project/testbenches/top_level_testbench.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  top_level_testbench

add wave *
view structure
view signals
run -all
