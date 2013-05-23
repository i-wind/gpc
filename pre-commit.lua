#!/usr/bin/env lua
-- encoding: utf-8
--[[
 @script   : pre-commit.lua
 @created  : 2013-05-18 01:47
 @changed  : 2013-05-18 14:50
 @revision : 5
 @about    : git pre-commit hook to follow script's
             timestamp and revision
]]

-- split string
function string:split(sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

--[[
git diff --cached --name-status
git diff --cached --name-only
git diff --cached --name-status | awk '$1 != "R" { print $2 }'
git diff --cached --name-only --diff-filter=ACM
]]

-- file names in the current commit (except removed)
local pipe = io.popen('git diff --cached --name-only --diff-filter=ACM', 'r')
local file_names = pipe:read '*a'
pipe:close()

for num, file_name in ipairs(file_names:split("\n")) do
    if file_name:match("%.py$") or file_name:match("%.rb$") or file_name:match("%.lua$") then
        local f = io.open(file_name, "r")
        local script = f:read("*all")
        f:close()

        -- replace change date
        script = string.gsub(script, "(@changed%s*:%s+)(%d+-%d+-%d+ %d+:%d+)",
                             "%1" .. os.date("%Y-%m-%d %H:%M"))
        -- increment revision
        local text, rev = string.match(script, "(@revision%s*:%s+)(%d+)")
        local revision = tonumber(rev) + 1
        script = string.gsub(script, "(@revision%s*:%s+)(%d+)", "%1" .. revision)

        f = io.open(file_name, "w")
        f:write(script)
        f:close()

        os.execute('git add ' .. file_name)
    end
end

-- if exit status other then 0 commit will fail
-- in an emergency the hook can be bypassed by passing –no-verify:
-- $ git commit --no-verify ...

os.exit(0)  -- exit success
