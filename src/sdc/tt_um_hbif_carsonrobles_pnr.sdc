create_clock -name clk -period 10.0000 [get_ports {clk}]
set_clock_transition 0.1500 [get_clocks {clk}]
set_clock_uncertainty 0.2500 clk

set_input_delay  5.0000 -clock [get_clocks {clk}] -add_delay [get_ports {rst_n}]

set_input_delay  5.0000 -clock [get_clocks {clk}] -add_delay [get_ports {ui_in*}]
set_output_delay 5.0000 -clock [get_clocks {clk}] -add_delay [get_ports {uo_out*}]

set_output_delay 5.0000 -clock [get_clocks {clk}] -add_delay [get_ports {uio_oe*}]
set_input_delay  5.0000 -clock [get_clocks {clk}] -add_delay [get_ports {uio_in*}]
set_output_delay 5.0000 -clock [get_clocks {clk}] -add_delay [get_ports {uio_out*}]
