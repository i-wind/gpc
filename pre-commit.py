#!/usr/bin/env python
# -*- coding: utf-8 -*-
#@script   : pre-commit.py
#@created  : 2013-03-30 00:15
#@changed  : 2013-05-24 01:59
#@revision : 2
#@about    : git pre-commit hook to follow timestamp
#            and revision of python and ruby scripts

from __future__ import with_statement
import os, sys, re
import subprocess
from datetime import datetime


def system(*args, **kwargs):
    kwargs.setdefault('stdout', subprocess.PIPE)
    proc = subprocess.Popen(args, **kwargs)
    out, err = proc.communicate()
    return out


def now():
    return str(datetime.now())[:16]


def main():
    modified = re.compile('^[AM]+\s+(?P<name>.*\.py)', re.MULTILINE)
    files = modified.findall( system('git', 'status', '--porcelain') )

    def repl(m):
        return m.group(1) + now()

    def rev(m):
        return m.group(1) + str(int(m.group(2))+1)

    for name in files:
        # current script text
        with open(name, 'r') as fd:
            script = fd.read()
        # change modification date
        script = re.sub('(@changed\s*:\s+)\d{4}-\d{2}-\d{2} \d{2}:\d{2}', repl, script)
        # change script revision
        script = re.sub('(@revision\s*:\s+)(\d+)', rev, script)
        # write back to script
        with open(name, 'w') as fd:
            fd.write(script)
        # add changes to commit
        system('git', 'add', name)


if __name__ == '__main__':
    main()
