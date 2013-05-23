#!/usr/bin/env lua
-- encoding: utf-8
--[[
 @script   : pre-commit.lua
 @created  : 2013-05-18 01:47
 @changed  : 2013-05-18 03:09
 @revision : 2
 @about    : git pre-commit hook to follow script's
             timestamp and revision
]]

--[[
git diff --cached --name-status
git diff --cached --name-only
git diff --cached --name-status | awk '$1 != "R" { print $2 }'
git diff --cached --name-only --diff-filter=ACM
]]

--[[
-- file names in the current commit (except removed)
local f = io.popen('git diff --cached --name-only --diff-filter=ACM', 'r')
local file_names = f:read '*a'
f:close()

if file_names ~= "" then
    print(file_names)
else
    print("empty...")
end
]]

local f = io.open("pre-commit.lua", "r")
local script = f:read("*all")
f:close()

-- replace change date
local text, dummy = string.match(script, "(@changed%s*:%s+)(%d+-%d+-%d+ %d+:%d+)")
local now = os.date("%Y-%m-%d %H:%M")
script = string.gsub(script, "(@changed%s*:%s+)(%d+-%d+-%d+ %d+:%d+)",
                     string.format("%s%s", text, now))
-- increment revision
local text, rev = string.match(script, "(@revision%s*:%s+)(%d+)")
local revision = tonumber(rev) + 1
script = string.gsub(script, "(@revision%s*:%s+)(%d+)",
                     string.format("%s%d", text, revision))

print(script)

os.exit(0)
