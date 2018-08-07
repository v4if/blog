#!/usr/bin/env python
# -*- coding: utf-8 -*-

# creating a dictionary of lists
>>> from collections import defaultdict
>>> d = defaultdict(list)
>>> for i in a:
...   for j in range(int(i), int(i) + 2):
...     d[j].append(i)
...
>>> d
defaultdict(<type 'list'>, {1: ['1'], 2: ['1', '2'], 3: ['2']})
>>> d.items()
[(1, ['1']), (2, ['1', '2']), (3, ['2'])]
