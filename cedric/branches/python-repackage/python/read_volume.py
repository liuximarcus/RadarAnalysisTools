#! /usr/bin/python

import sys
import logging
logging.basicConfig(level=logging.DEBUG)

import cedric
import matplotlib.pyplot as plt
import cedric.plots as cp

_dfile = "../testdata/spol/vol_20000629_233038_to_20000629_233433_SPOL_CRT.ced"

if __name__ == "__main__":

    filepath = _dfile
    if len(sys.argv) > 1:
        filepath = sys.argv[1]

    v = cedric.read_volume(filepath)
    cedric.stats()
    var = None
    for name in ['MAXDB', 'DBZ', 'DZ']:
        var = v.get(name)
        if var:
            break
    if not var:
        var = v.values()[0]
    iz = int((2.5 - v.grid.z.first + (v.grid.z.delta/2.0)) / v.grid.z.delta)
    iz = 15
    field = var[:,:,iz]
    print(field)
    cp.contourf(field)
    plt.show()
    cedric.quit()




