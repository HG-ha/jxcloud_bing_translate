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

-- 加载命令的方法
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

-- 检查是否为命令前缀的异步方法
function CommandHandler:is_command_prefix(message, at, group, c2c, data)

    -- 提取 mentions 中的 ID
    local valid_mentions = {}
    if data and data.d and data.d.mentions then
        for _, mention in ipairs(data.d.mentions) do
            table.insert(valid_mentions, mention.id)
        end
    end

    -- 创建用于匹配 message_handle 的正则表达式
    local message_handle_pattern = "<@!(%d+)>"

    -- 遍历 cmd_list，检查是否匹配
    for cmd, original_command in pairs(self.cmd_list) do

        if group and string.sub(message, 1, #cmd) == cmd then
            return true, original_command, string.gsub(message, "^" .. cmd, ""):gsub("^%s*(.-)%s*$", "%1")
        end

        if c2c and string.sub(message, 1, #cmd) == cmd then
            return true, original_command, string.gsub(message, "^" .. cmd, ""):gsub("^%s*(.-)%s*$", "%1")
        end

        if at then
            -- 匹配 content 中的 @ 内容
            local mention_id = message:match(message_handle_pattern)
            if mention_id and valid_mentions[1] == mention_id then -- 检查第一个 mentions.id 是否与 @ 的 ID 一致
                for _, valid_id in ipairs(valid_mentions) do
                    if valid_id == mention_id then
                        return true, original_command, string.gsub(message, "^" .. "<@!" .. mention_id .. ">" .. cmd, ""):gsub("^%s*(.-)%s*$", "%1")
                    end
                end
            end
        end

        if not at and string.sub(message, 1, #cmd) == cmd then
            return true, original_command, string.gsub(message, "^" .. cmd, ""):gsub("^%s*(.-)%s*$", "%1")
        end
    end

    return false, "not command", "not cmdvalue"
end

return CommandHandler
