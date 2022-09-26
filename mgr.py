#!/usr/bin/env python3

# Purpose: make managing my workflow easier
# Usage: see main (at bottom) or run with no args

import sys
import libmgr.scripts as lib
import libmgr.utils as utils

def print_usage(operations):
    print("Usage: mgr.py <operation>")
    for op, val in operations.items():
        print(f" {op}\t{val[0]}")

def main():
    utils.check_platform()

    # Here's the available operations and their descriptions
    operations = {
        "link": ["symlinks configs for nvim and tmux", lib.link],
        "fresh": ["refresh nvim plugins and packages", lib.refresh_plugins],
    }

    # Make sure there's one arg, then execute its function
    if len(sys.argv) <= 1 or len(sys.argv) > 2:
        print_usage(operations)
        return 1
    operations[sys.argv[1]][1]()

if __name__=="__main__":
    main()
