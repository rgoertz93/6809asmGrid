#!/usr/bin/python3

import re

lineNum = 100
fo = open("main.asm", "r")
for line in fo.readlines():
	line = line.replace("\n", "\t")
	line = re.sub(';.*$', '', line)
	if(len(line) == 1):
		continue
	print('{lineNum:05d} {line}'.format(lineNum=lineNum, line=line.upper()), end='\r\n')
	lineNum += 10

fo.close()
