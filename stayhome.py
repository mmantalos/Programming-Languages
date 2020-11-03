#!/usr/bin/env python

from collections import deque
import sys

def get_data(f):
    v = deque()
    s = deque()
    n, i, g, st, o, air = 0, 0, (0, 0), (0,0), [], []
    with open(f) as inStream:
        while 1:
            temp = inStream.read(1)
            if not temp:
                break
            elif temp == '.':
                o.append(0)
            elif temp == 'X':
                o.append(1)
            elif temp == 'A':
                o.append(-1)
                air.append((n, i))
            elif temp == 'W':
                o.append(1)
                v.appendleft((n, i, 2))    
            elif temp == 'S':
                o.append(-2)
                s.appendleft((n, i))
                st = (n, i)
            elif temp == 'T':
                o.append(0)
                g = (n, i)  
            else:
                n += 1
                i = 0
                continue
            i += 1
    return v, s, air, o, st, g, n, len(o)//n

def exists(x,y):
    return x >= 0 and x < N and y >= 0 and y < M

def locate(x,y):
    return x*M + y

def spread():
    size = len(V)
    for i in range(size):
        x, y, count = V.pop()
        count -= 1
        if count == 2:
            obstacles[locate(x,y)] = 1
        if not count:
            current = locate(x,y)
            for (xi,yi) in [(x+1,y),(x,y-1),(x,y+1),(x-1,y)]:
                t = locate(xi,yi)
                if exists(xi,yi) and obstacles[t] <= 0:
                    if obstacles[t] == -1 or obstacles[t] == -3:
                        take_off(xi,yi)
                    obstacles[t] = 1
                    V.appendleft((xi,yi,2))
        else:
            V.appendleft((x,y,count))

def move():
    size = len(S)
    for i in range(size):
        x, y = S.pop()
        current = locate(x,y)
        for (xi, yi) in [(x+1,y),(x,y-1),(x,y+1),(x-1,y)]:
            t = locate(xi,yi)
            if exists(xi,yi) and (obstacles[t] == 0 or obstacles[t] == -1):
                obstacles[t] -= 2
                parent[t] = current
                S.appendleft((xi,yi))

def take_off(x0,y0):
    for (x,y) in airports:
        if (x,y) != (x0,y0):
            V.appendleft((x,y,7))

def path():
    path = ''
    x,y = goal
    current = locate(x,y)  
    while parent[current] >= 0:
        prev = parent[current]
        for (a,b) in [(current+1,'L'),(current-1,'R'),(current+M,'U'),(current-M,'D')]:
            if prev == a:
                path += b
        current = prev
    return path

V, S, airports, obstacles, start, goal, N, M = get_data(sys.argv[1])
parent = [-1]*N*M
x,y = goal
end = locate(x,y)
while obstacles[end] == 0 and len(S):
    spread()
    move()

if parent[end] < 0:
    print('IMPOSSIBLE')
else:
    p = path()[::-1]
    print(len(p), p, sep = '\n')
