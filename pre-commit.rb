#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#@script   : pre-commit.rb
#@created  : 2013-03-29 10:15
#@changed  : 2013-03-29 12:26
#@revision : 1
#@about    :

# git diff --cached --name-status
# git diff --cached --name-only
# git diff --cached --name-status | awk '$1 != "R" { print $2 }'
# git diff --cached --name-only --diff-filter=ACM

# perl
# git diff --cached --name-status | while read st file; do
#        # skip deleted files
#        if [ "$st" == 'D' ]; then continue; fi
#        # do a check only on the perl files
#        if [[ "$file" =~ "(.pm|.pl)$" ]] && ! perl -c "$file"; then
#                echo "Perl syntax check failed for file: $file"
#                exit 1
#        fi
# done
puts "Successfull commit"

fileNames = `git diff --cached --name-only --diff-filter=ACM`
puts fileNames

fileNames.split(/\n/).each() { |name|
    if name =~ /(\.rb|\.py)$/
        puts name
        # change modification date
        time = Time.new
        ret = time.strftime("%Y-%m-%d %H:%M")
        `sed -i -r 's/\@changed  : [0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}/\@changed  : #{ret}/' #{name}`
        # change script revision
        #Regexp.new("@revision : \d+").match(string)
    end
}

# if exit status other then
# 0 commit will fail
# In an emergency the hook can be bypassed by passing –no-verify:
# $ git commit --no-verify ...

exit(0)  # exit success
