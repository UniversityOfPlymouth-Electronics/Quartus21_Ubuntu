transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/git/DigitalSystems/tasks/DE0-Nano-Template {C:/git/DigitalSystems/tasks/DE0-Nano-Template/pll_main.v}
vlog -vlog01compat -work work +incdir+C:/git/DigitalSystems/tasks/DE0-Nano-Template/db {C:/git/DigitalSystems/tasks/DE0-Nano-Template/db/pll_main_altpll.v}
vlog -sv -work work +incdir+C:/git/DigitalSystems/tasks/DE0-Nano-Template {C:/git/DigitalSystems/tasks/DE0-Nano-Template/clk_div_N.sv}

