#!/usr/bin/env lua
-- encoding: utf-8
--[[
 @script   : pre-commit.lua
 @created  : 2013-05-18 01:47
 @changed  : 2013-05-18 02:30
 @revision : 1
 @about    : git pre-commit hook to follow script's
             timestamp and revision
]]

--[[
git diff --cached --name-status
git diff --cached --name-only
git diff --cached --name-status | awk '$1 != "R" { print $2 }'
git diff --cached --name-only --diff-filter=ACM
]]

-- file names in the current commit (except removed)
local f = io.popen('git diff --cached --name-only --diff-filter=ACM', 'r')
local file_names = f:read '*a'
f:close()

if file_names ~= "" then
    print(file_names)
else
    print("empty...")
end

os.exit(0)
