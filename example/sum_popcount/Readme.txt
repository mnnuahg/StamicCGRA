This example computes sum(popcount(i)) for x<=i<=16, where x is the input token.
The input and output PEs are 1B and 16B, you can search pe_16B.outFIFO_L0 in the output log.
This DFG can also be re-entered by multiple tokens, actually we have 0x500 and 0x605 as the initial input token,
which means the tags are 0x5 and 0x6, and the data are 0x0 and 0x5, respectively.
This DFG is an out-of-order operation, you can find that the token with tag 0x6 is outputted first despite of the fact
that token with tag 0x5 enters the DFG first.