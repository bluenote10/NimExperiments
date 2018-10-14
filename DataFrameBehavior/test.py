#!/usr/bin/env python

import pandas as pd
import numpy as np

if True:
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

