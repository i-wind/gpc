#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#@script   : pre-commit.rb
#@created  : 2013-03-29 10:15
#@changed  : 2013-03-30 11:43
#@revision : 8
#@about    : git pre-commit hook to follow timestamp
#            and revision of python and ruby scripts

# git diff --cached --name-status
# git diff --cached --name-only
# git diff --cached --name-status | awk '$1 != "R" { print $2 }'
# git diff --cached --name-only --diff-filter=ACM

# file names in the current commit (except removed)
fileNames = `git diff --cached --name-only --diff-filter=ACM`

fileNames.split(/\n/).each() { |name|
    if name =~ /(\.rb|\.py)$/  # watching ruby & python scripts
        script = nil  # current script text
        File.open(name) {|f| script = f.read() }
        # change modification date
        time = Time.new
        now = time.strftime("%Y-%m-%d %H:%M")
        script.sub!(/(@changed\s*:\s+)\d{4}-\d{2}-\d{2} \d{2}:\d{2}/) {|m| $1 + now }
        # change script revision
        script.sub!(/(@revision\s*:\s+)(\d+)/) {|m| "%s%d" % [$1, $2.to_i + 1] }
        # write back to script
        File.open(name, 'w') {|f| f.write(script) }
        # add changes to commit
        `git add #{name}`
    end
}

# if exit status other then 0 commit will fail
# in an emergency the hook can be bypassed by passing –no-verify:
# $ git commit --no-verify ...

exit(0)  # exit success
