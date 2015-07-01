-- package 	: ngx_static_merger
-- version  : 15.07.01
-- author   : https://github.com/grasses

local str = require "resty.string"
local resty_md5 = require "resty.md5"

local uri = ngx.var.uri
local cache_root = ngx.var.cache_root
local static_root = ngx.var.static_root

local M = {
    log_level = ngx.NOTICE,
    _VERSION = "15.07.01",
}

--[[
    @param string msg 
    @param string level => ngx.STDERR , ngx.EMERG , ngx.ALERT , ngx.CRIT , ngx.ERR , ngx.WARN , ngx.NOTICE , ngx.INFO , ngx.DEBUG
    @return nginx => log file
]]
M.log = function (msg, level)
    level = level or M.log_level
    ngx.log(level, msg)
end

--[[
    @param string str
    @param string split_char => split rule
    @return table split => string split array
]]
M.uri_split = function (str, split_char)
    local sub_str_tab = {}
    local i = 0
    local j = 0
    while true do
        j = string.find(str, split_char, i+1)
        if j == nil then
            if(table.getn(sub_str_tab)==0) then
                table.insert(sub_str_tab, str)
            end
            break
        end
        table.insert(sub_str_tab, string.sub(str, i+1, j-1))
        i = j
    end
    return sub_str_tab
end

--[[
    @param string uri => request uri
    @param string version => request param "v"
    @return fun => M.generate_file or M.return_file
    @function => check if cache file exist, if not, create it then retrun 
]]
M.check_version = function(uri, version)
    local md5 = resty_md5:new()
    if not md5 then
        M.log("Failed to create md5 object", ngx.ERR)
        return
    end

    local ok = md5:update(uri)
    if not ok then
        M.log("Check_version => md5 module => failed to add data", ngx.ERR)
        return
    end

    local digest = md5:final()
    local fpath = cache_root.."/"..str.to_hex(digest).."?v="..version
    --ngx.say("file path => ", fpath)
    local fp,err = io.open(fpath, "r")
    if fp~=nil then
        M.return_file(fp)
    else
        M.generate_file(fpath)
    end
end

--[[
    @param string fpath => cache file path
    @return string => return ngx.say(data)
	@function => generate cache file
]]
M.generate_file = function(fpath)
    local data = ""
    local parts = M.uri_split(uri.."", "")
    -- read table and get static data
    for key, value in ipairs(parts) do
        local fp1, err = io.open(static_root..value, "r")
        if fp1~=nil then
            data = data..fp1:read("*all")
            fp1:close()
        else
            M.log("Generate_file => file not exist => "..value, ngx.NOTICE)
        end
    end
    -- save cache file
    local fp2, err = io.open(fpath, "w")
   	if fp2~=nil then
        fp2:write(data)
        fp2:close()
    else
        M.log("Generate_file => file not exist => "..fpath, ngx.NOTICE)
    end
    -- return data to client
    ngx.say(data)
end

--[[
    @param string fp => file open pointer
    @return => return ngx.say(data)
]]
M.return_file = function(fp)
    if fp~=nil then
        ngx.say(fp:read("*all"))
        fp:close()
    else
        M.log("Return_file() => file not exist => "..v, ngx.NOTICE)
    end
end

M.main = function()
    -- check cache path
    local fp = io.open(cache_root, "r")
    if fp == nil then
        os.execute('mkdir '..cache_root)
        M.log("Main() => cache path not exist => "..cache_root, ngx.NOTICE)
    end
    local arg = ngx.req.get_uri_args()
    if arg["v"] ~= nil then
        M.check_version(uri, arg["v"])
    else
        M.check_version(uri, os.date("%Y-%m-%d"))
    end
end

M.main()