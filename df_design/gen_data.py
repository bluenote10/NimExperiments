#!/usr/bin/env python

from __future__ import division, print_function

import pandas as pd
import numpy as np
import time


def gen_data(N=10*1000*1000, num_int_cols=5, num_float_cols=5):

    data = {}

    for col in xrange(num_int_cols):
        data["int_col_{}".format(col)] = np.random.randint(0, 100, size=N)

    for col in xrange(num_int_cols):
        data["float_col_{}".format(col)] = np.random.uniform(0, 1, size=N)

    df = pd.DataFrame(data)
    df.to_csv("test_01.csv", index=False)


#gen_data()


class TimedContext(object):

    def __enter__(self):
        self.t1 = time.time()

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.t2 = time.time()
        print(self.t2 - self.t1)


"""
with TimedContext():
    count = 0
    for _ in open("test_01.csv").readlines():
        count += 1
    print(count)
"""

with TimedContext():
    df = pd.read_csv("test_01.csv")
    print(df.dtypes)