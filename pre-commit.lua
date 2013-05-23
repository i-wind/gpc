#!/usr/bin/env lua
-- encoding: utf-8
--[[
 @script   : pre-commit.lua
 @created  : 2013-05-18 01:47
 @changed  : 2013-05-24 02:52
 @revision : 8
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
    -- watching ruby | python | lua scripts
    if file_name:match("%.py$") or file_name:match("%.rb$") or file_name:match("%.lua$") then
        -- current script text
        local f = io.open(file_name, "r")
        local script = f:read("*all")
        f:close()
        -- replace change date
        script = script:gsub("(@changed%s*:%s+)(%d+-%d+-%d+ %d+:%d+)",
                             "%1" .. os.date("%Y-%m-%d %H:%M"))
        -- increment revision
        script = script:gsub("(@revision%s*:%s+)(%d+)", function(tag, rev)
                                    return tag .. tostring(tonumber(rev) + 1)
                                end)
        -- write back to script
        f = io.open(file_name, "w")
        f:write(script)
        f:close()
        -- add changes to commit
        os.execute('git add ' .. file_name)
    end
end

-- if exit status other then 0 commit will fail
-- in an emergency the hook can be bypassed by passing –no-verify:
-- $ git commit --no-verify ...

os.exit(0)  -- exit success
