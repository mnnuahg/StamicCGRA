The example computes the population count (number of bit 1) of 0 ~ 31. The population count of a number X is computed by iteratively execute X = X&(X-1) and count how many iterations are required for X to reach 0. Therefore, this example is actually a 2-level nested loop.

popcount.odg is the data flow graph, you may need LibreOffice to open it.

popcount1.xlsx and popcount2.xlsx are the implementation of the data flow graph on StamicCGRA with different tag control mechanism.

popcount1.csv and popcount2.csv are the result by saving the .xlsx files as .csv files.

The output of the computation are pairs of tokens (i, popcount(i)), which will eventually flow to the ST node. Thus we can check the correctness of the computation by examining the input of the ST node. Actually we let the simulator to print a message whenever the ST node is executed, you can search "Popcount" in the output message.
