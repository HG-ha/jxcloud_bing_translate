-- 此模块用于解析消息是否触发命令

-- 前往config中配置该应用的所有指令
local COMMAND_LIST = require("config").COMMAND_LIST

-- 创建一个类或表以存储命令
local CommandHandler = {}

function CommandHandler:new()
    local instance = {}
    setmetatable(instance, self)
    self.__index = self
    instance.cmd_list = {}  -- 初始化命令列表
    return instance
end

-- 加载命令的方法, 可以设置多种命令支持模式
-- 如不想使用此方法请自行修改为模糊匹配
function CommandHandler:load_command()
    -- 遍历COMMAND_LIST中的每个命令
    for _, command in ipairs(COMMAND_LIST) do
        local atcmd = {
            command,
            "/" .. command,
            " " .. command,
            " /" .. command,
            command .. " ",
            "/" .. command .. " ",
            " " .. command .. " ",
            " /" .. command .. " "
        }
        
        for _, cmd in ipairs(atcmd) do
            self.cmd_list[cmd] = command
        end
    end
end

-- 检查是否为命令
function CommandHandler:is_command_prefix(message, at, group, c2c, data)

    -- 遍历 cmd_list，检查是否匹配
    for cmd, original_command in pairs(self.cmd_list) do

        if group and string.sub(message, 1, #cmd) == cmd then
            return true, original_command, string.gsub(message, "^" .. cmd, ""):gsub("^%s*(.-)%s*$", "%1")
        end

        if c2c and string.sub(message, 1, #cmd) == cmd then
            return true, original_command, string.gsub(message, "^" .. cmd, ""):gsub("^%s*(.-)%s*$", "%1")
        end

        if at then
            local mention_id = message:match("<@!(%d+)>")
            local message = string.gsub(message, "<@!" .. mention_id .. ">", "")
            if string.sub(message, 1, #cmd) == cmd then
                return true, original_command, string.gsub(message, "^" .. cmd, ""):gsub("^%s*(.-)%s*$", "%1")
            end
        end

        if not at and string.sub(message, 1, #cmd) == cmd then
            return true, original_command, string.gsub(message, "^" .. cmd, ""):gsub("^%s*(.-)%s*$", "%1")
        end
    end

    return false, "not command", "not cmdvalue"
end

return CommandHandler
