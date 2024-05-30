
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name Wishboneinterface -dir "D:/Gul Bahar Data/FPGAs/XILINX ISE/Wishbone Bus/Wishboneinterface/planAhead_run_1" -part xc6slx9tqg144-2
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property target_constrs_file "Wishbone_Controller.ucf" [current_fileset -constrset]
set hdlfile [add_files [list {ufifo.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {txuart.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {rxuart.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {wbuart.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {Wishbone_Controller.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set_property top Wishbone_Controller $srcset
add_files [list {Wishbone_Controller.ucf}] -fileset [get_property constrset [current_run]]
open_rtl_design -part xc6slx9tqg144-2
