require("programs.none")
require("programs.lua-executor")
require("programs.storage-controller")

-- http://stackoverflow.com/questions/14942472/create-suite-of-interdependent-lua-files-without-affecting-the-global-namespace

local root = require "root"
local index = {}

local n = 0
for k, v in pairs(root) do  
	n = n + 1
	index[n] = k
end

-- return the common table
return function() return root, index end -- return require "root" 