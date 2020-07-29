# Outline
This is an experimental project to implement dynamic dataflow execution on CGRA. In contrast to static dataflow execution, dynamic dataflow execution allows different iterations of a loop to be executed in parallel, with tags attached to tokens to differentiate the iterations they are beloning to. In this project we implement special instructions for the PEs (processing elements) of the CGRA to assign new tags to a token when the token enters a loop, to restore old tag to a token when the token leaves a loop, and to find tokens with matching tag when an operation requires multiple input tokens. The tag assignment/restore/matching are performed in static dataflow fashion by group of PEs with the special instructions, hence the name StamicCGRA.

This project is tested on the simulator of Icarus Verilog, but not yet on any FPGA or real chips.

Please refer to [this slide](https://www.slideshare.net/ssuser0c5ec9/dynamic-dataflow-on-cgra-237372239) for more explaination.

# Architecture
In this CGRA each PE has 8 full-duplex ports, namely U0, U1, D0, D1, L0, L1, R0, R1. Each port connects to (a corresponding port of) a neighbor PE. For example, R0 conntect to the PE on the right, and R1 connected to the PE two steps on the right. The other prefixes means UP, DOWN, and LEFT, respectively. All PEs in a row are connected to a shared horizontal bus,
and all PEs in a column are connected to a shared vertical bus. Each PE can perform two instructions concurrently, but the two instructions can not share any input or output port. Each token is 16-bit wide, with higher 8 bits acts as tag and lower 8 bits acts as data. The tokens are buffered in FIFOs if the destination PEs are not ready to receive them. Each PE also has an internal 16-bit register for storing some internal state of the instructions.

# How to Build and Run an Example
This project requires MinGW and Icarus Verilog installed. Their executable path should be set to the path environment variable.
The ./examples directory contains several examples both in .csv and .xlsx format, .csv format are the actual acceptable format while .xlsx files contain more details.
You can obtain the same .csv files by saving the .xlsx files as .csv files. The ./example folder also contains DFGs.pdf which is more readable DFG for the examples.

To run the popcount1 example, type the following command in cmd

run.bat example/popcount/popcount1.csv 100

Where 100 is the number of cycles to be simulated, you can change it as you wish.
This will show a list of read and write of each FIFO of each PE, which effectively represents the tokens transmitted and received by each PE at each cycle.

# References
Dennis and Misunas, “A Preliminary Architecture for a Basic Data Flow Processor”\
Arvind and Nikhil, “Executing a Program on the MIT Tagged-Token Dataflow Architecture” 
