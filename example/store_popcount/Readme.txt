The example will use a loop to compute population count for 0 ~ 31. Since the computation of population count is done by a loop, this example is actually a 2-level nested loop.

store_popcount1.xlsx and store_popcount2.xlsx are the implementation of the data flow graph on StamicCGRA with different tag control mechanism.

store_popcount1.csv and store_popcount2.csv are the result by saving the .xlsx files as .csv files.

The pairs of tokens (i, popcount(i)) will eventually flow to the ST node. We let the simulator to print a message whenever the ST node is executed, you can search "Store" in the output message.
