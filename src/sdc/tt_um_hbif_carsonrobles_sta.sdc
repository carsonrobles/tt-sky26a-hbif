set CLOCK_PERIOD      10.000
set CLOCK_TRANS        0.150
set CLOCK_UNCERTAINTY  0.250

create_clock -name clk -period $CLOCK_PERIOD [get_ports {clk}]
set_clock_transition $CLOCK_TRANS [get_clocks {clk}]
set_clock_uncertainty $CLOCK_UNCERTAINTY clk

# all IOs considered asynchronous
set_false_path -from [get_ports {rst_n}]
set_false_path -from [get_ports {ena}]
set_false_path -to   [get_ports {uio_oe*}]
set_false_path -from [get_ports {uio_in*}]
set_false_path -to   [get_ports {uio_out*}]

#set_false_path -from [get_ports {ui_in*}]
#set_false_path -to   [get_ports {uo_out*}]

# TODO: what do I actually want here.
set TTHBIF_MAX_DELAY $CLOCK_PERIOD

#set_max_delay $TTHBIF_MAX_DELAY -from [get_ports {ui_in*}]
#set_max_delay $TTHBIF_MAX_DELAY -to   [get_ports {uo_out*}]

create_clock -name io_virt_clk -period $CLOCK_PERIOD

set_input_delay  0 -clock [get_clocks {io_virt_clk}] [get_ports {ui_in*}]
set_output_delay 0 -clock [get_clocks {io_virt_clk}] [get_ports {uo_out*}]
