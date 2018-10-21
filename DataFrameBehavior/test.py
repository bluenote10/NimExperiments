#!/usr/bin/env python

from __future__ import print_function

import pandas as pd
import numpy as np

if False:
    df = pd.DataFrame({
        "A": range(6),
        "B": range(3) * 2,
        "C": range(2) * 3,
    })
    print(df)
    mask = (df["A"] % 2) == 0
    print(mask)

    df.loc[mask, "A"] *= 100
    print(df)

if False:
    df = pd.DataFrame({
        "A": range(6),
        "B": range(3) * 2,
        "C": range(2) * 3,
    })
    print(df)
    mask = (df["A"] % 2) == 0
    print(mask)

    subdf = df.loc[mask, :]
    subdf["A"] *= 100
    #subdf.loc[:, "A"] *= 100
    print(subdf)
    print(df)

if False:
    a = np.array([1, 2, 3])
    b = a
    a[0] = 100
    print("a = ", a)
    print("b = ", b)

    a = pd.Series([1, 2, 3])
    b = a
    a.ix[0] = 100
    print("a = \n{}".format(a))
    print("b = \n{}".format(b))

if True:
    a = np.array([1, 2, 3])

    def test(a):
        a[0] = 100

    test(a)
    print("a = ", a)

    a = pd.Series([1, 2, 3])
    def test(a):
        a.ix[0] = 100

    test(a)
    print("a = \n{}".format(a))
