del genPE2Test.exe
del pe2_test.v
del pe2_test
g++ -g -o genPE2Test genPE2Test.cpp -std=c++11
genPE2Test %1 > pe2_test.v
iverilog -o pe2_test pe2_test.v
vvp pe2_test