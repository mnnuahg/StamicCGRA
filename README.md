# Outline
This is an experimental project to implement dynamic dataflow execution on CGRA. In contrast to static dataflow execution, dynamic dataflow execution allows different iterations of a loop to be executed in parallel, with tags attached to tokens to differentiate the iterations they are beloning to. In this project we implement special instructions for the PEs (processing elements) of the CGRA to assign new tags to a token when the token enters a loop, to restore old tag to a token when the token leaves a loop, and to find tokens with matching tag when an operation requires multiple input tokens. The tag assignment/restore/matching are performed in static dataflow fashion by group of PEs with the special instructions.

This project is tested on the simulator of Icarus Verilog, but not yet on any FPGA or real chips.

# Architecture Outline
In this CGRA each PE has 8 full-duplex ports, namely U0, U1, D0, D1, L0, L1, R0, R1. Each port connects to (a corresponding port of) a neighbor PE. For example, R0 conntect to the PE on the right, and R1 connected to the PE two steps on the right. The other prefixes means UP, DOWN, and LEFT, respectively. Each PE can perform two instructions concurrently, but the two instructions can not share any input or output port. Each token is 16-bit wide, with higher 8 bits acts as tag and lower 8 bits acts as data. The tokens are buffered in FIFOs if the destination PEs are not ready to receive them. Each PE also has an internal 16-bit register for storing some internal state of the instructions.

# How to Build and Run an Example
This project requires MinGW and Icarus Verilog installed. Their executable path should be set to the path environment variable.
If ready, run the following command in cmd

run.bat example/popcount.csv

This will show a list of read and write of each FIFO of each PE, which effectively represents the tokens transmitted and received by each PE at each cycle.
