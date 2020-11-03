#!/usr/bin/env python

from collections import deque as dq
import sys

def read_stack(inStream):
    s = ''
    while(1):
        c = inStream.read(1)
        if c == '\n':
            return s
        else:
            s += c

def complement(string):
    comp = ''
    for i in string:
        if i == 'A':
            comp += 'U'
        elif i == 'U':
            comp += 'A'
        elif i == 'C':
            comp += 'G'
        elif i == 'G':
            comp += 'C'
    return comp 

def solve(S):
    seen = set()
    while(1):
        (vac, s1, s2) = S.pop()  
        state = (s1, s2)  
        if state not in seen:
            seen.add(state)

            if vac[-1] == 'p':
                S.appendleft((vac + 'c', complement(s1), s2))

            if s2[0] == s1[0] or s1[0] not in s2:
                vac_p = vac + 'p'
                s1_p = s1[1:]
                s2_p = s1[0] + s2
                S.appendleft((vac_p, s1_p, s2_p))
                if not len(s1_p):
                    #print(len(S))
                    return vac_p

            if vac[-1] != 'r':
                S.appendleft((vac + 'r', s1, s2[::-1]))

with open(sys.argv[1]) as inStream:
    N = int(inStream.read(1))
        
    if inStream.read(1) != '\n':
        N = 10
        inStream.read(1)

    for i in range(N):
        stack = read_stack(inStream)
        steps = len(stack)
        State = dq()
        State.appendleft(('p', stack[-2::-1], stack[-1]))
        print(solve(State))
