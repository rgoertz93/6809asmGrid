#!/usr/bin/python3

import re


def process_line(label, opcode, value="", *comment):
    fcb_items = []
    if opcode == 'fcb':
        fcb_items = value.split(',')

    processed_lines = []
    if len(fcb_items) > 0:
        first, rest = fcb_items[0], fcb_items[1:]
        processed_lines.append(f'{label.upper()}\t{opcode.upper()}\t{first.upper()}')

        for x in rest:
            processed_lines.append(f'\t{opcode.upper()}\t{x.upper()}')
    else:
        line = f'{label.upper()}\t{opcode.upper()}'
        if value:
            line = f'{line}\t{value.upper()}'
        processed_lines.append(line)
    return processed_lines


def process_file():
    line_num = 100
    fo = open("main.asm", "r")
    for line in fo.readlines():
        if len(line) <= 2:
            continue

        items = re.split('[\t ]', line.rstrip())
        items = [x for n, x in enumerate(items) if any(y is not None for y in items[n:])]
        processed_lines = process_line(*items)
        for i in processed_lines:
            print('{line_number:05d} {line}'.format(line_number=line_num, line=i), end='\r\n')

        line_num += 10

    fo.close()


process_file()
