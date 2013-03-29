#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#@script   : pre-commit.rb
#@created  : 2013-03-29 10:15
#@changed  : 2013-03-30 01:36
#@revision : 5
#@about    :

# git diff --cached --name-status
# git diff --cached --name-only
# git diff --cached --name-status | awk '$1 != "R" { print $2 }'
# git diff --cached --name-only --diff-filter=ACM

fileNames = `git diff --cached --name-only --diff-filter=ACM`

fileNames.split(/\n/).each() { |name|
    if name =~ /(\.rb|\.py)$/
        puts name
        # change modification date
        time = Time.new
        ret = time.strftime("%Y-%m-%d %H:%M")
        `sed -i -r 's/(@changed\s*:\s+)[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}/\\1#{ret}/' #{name}`
        # change script revision
        digit = `cat #{name} | grep -Po '@revision\\s*:\\s+\\d+' | grep -Po '\\d+'`
        if digit
            value = digit.to_i + 1
            puts "Changing revision to #{value}"
            `sed -i -r 's/(@revision\s*:\s+)[[:digit:]]+/\\1#{value}/' #{name}`
        end
        # add changes to commit
        `git add #{name}`
    end
}

# if exit status other then
# 0 commit will fail
# In an emergency the hook can be bypassed by passing –no-verify:
# $ git commit --no-verify ...

exit(0)  # exit success
