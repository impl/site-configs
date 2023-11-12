# SPDX-FileCopyrightText: 2023 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

import contextlib
import sys

import configobj


if __name__ == '__main__':
    if len(sys.argv) < 3:
        print(
            f"Usage: {sys.argv[0]} <output> <input1> [<input2> [...]]",
            file=sys.stderr,
        )
        sys.exit(1)

    base = configobj.ConfigObj(encoding='utf-8')
    for infile in sys.argv[2:]:
        with (
            open(infile, 'r', encoding='utf-8')
            if infile != '-'
            else contextlib.nullcontext(sys.stdin) as fp
        ):
            base.merge(configobj.ConfigObj(infile=infile, encoding='utf-8'))

    outfile = sys.argv[1]
    with (
        open(outfile, 'wb')
        if outfile != '-'
        else contextlib.nullcontext(sys.stdout) as fp
    ):
        base.write(fp)
