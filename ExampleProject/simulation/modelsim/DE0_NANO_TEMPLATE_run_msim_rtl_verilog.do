transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+/home/noutram/git/Quartus21_Ubuntu/ExampleProject {/home/noutram/git/Quartus21_Ubuntu/ExampleProject/pll_main.v}
vlog -vlog01compat -work work +incdir+/home/noutram/git/Quartus21_Ubuntu/ExampleProject/db {/home/noutram/git/Quartus21_Ubuntu/ExampleProject/db/pll_main_altpll.v}
vlog -sv -work work +incdir+/home/noutram/git/Quartus21_Ubuntu/ExampleProject {/home/noutram/git/Quartus21_Ubuntu/ExampleProject/clk_div_N.sv}

