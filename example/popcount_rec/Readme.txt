A recursive implementation of popcount: popcount(n) = n==0 ? 0 : 1+popcount(n&(n-1))
However, this implementation is not very useful because we can't separate the set of tags used by caller and callee.
