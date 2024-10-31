-- 引入镜芯API
local jxapi = require("jxapi")
local help = require("config").help
-- 消息分发
local msgdist = {}

-- 指令解析
local CommandHandler = require("cmd_tool")
-- 创建CommandHandler实例
local handler = CommandHandler:new()
-- 加载命令
handler:load_command()



-- 频道@
function msgdist.AT_MESSAGE_CREATE(event)

    -- 调用is_command_prefix方法判断是否触发指令，如果触发则获得指令关键字
    local is_command, command, cmd_value = handler:is_command_prefix(event.d.content, true, true, false)
    log.info('[频道@事件] 触发指令: [' .. tostring(is_command) .. ']    指令内容：[' .. command .. ']    指令参数：[' .. cmd_value .. ']')
    return prest_inst(event,is_command, command, cmd_value)
end

-- 私聊
function msgdist.DIRECT_MESSAGE_CREATE(event)

    local is_command, command, cmd_value = handler:is_command_prefix(event.d.content, false, true, true)
    log.info('[频道私聊事件] 触发指令: [' .. tostring(is_command) .. ']    指令内容：[' .. command .. ']    指令参数：[' .. cmd_value .. ']')
    return prest_inst(event,is_command, command, cmd_value)
end

-- QQ私信
function msgdist.C2C_MESSAGE_CREATE(event)

    local is_command, command, cmd_value = handler:is_command_prefix(event.d.content, false, false, true)
    log.info('[qq私聊事件] 触发指令: [' .. tostring(is_command) .. ']    指令内容：[' .. command .. ']    指令参数：[' .. cmd_value .. ']')
    return prest_inst(event,is_command, command, cmd_value)
end

-- 群聊@
function msgdist.GROUP_AT_MESSAGE_CREATE(event)

    local is_command, command, cmd_value = handler:is_command_prefix(event.d.content, true, false, false)
    log.info('[群聊@事件] 触发指令: [' .. tostring(is_command) .. ']    指令内容：[' .. command .. ']    指令参数：[' .. cmd_value .. ']')
    return prest_inst(event,is_command, command, cmd_value)
end

-- 统一消息处理，也可以根据具体需求在不同的事件中进行处理
function prest_inst(event,is_command,command,cmd_value)
    if not is_command or command == '帮助' then
        return message.replyTextMessageWithAtAuthor(help)
    end

    if is_command and command == '翻译' then

        if cmd_value == nil or cmd_value == "" then
            return message.replyTextMessageWithAtAuthor('请输入要翻译的内容')
        end

        local success, resu = jxapi.translate({ text = cmd_value, userid = event.d.author.id})
        if success then
            return message.replyTextMessageWithAtAuthor('翻译结果: \n' .. resu)
        else
            return message.replyTextMessageWithAtAuthor(resu)
        end
        
    end

    if is_command and command == '绑定key' then
        if cmd_value == nil or cmd_value == "" then
            return message.replyTextMessageWithAtAuthor('请输入有效的key')
        end

        local success, resu = jxapi.bindkey({ key = cmd_value, userid = event.d.author.id})

        return message.replyTextMessageWithAtAuthor('绑定结果: \n' .. resu)
    end

    if is_command and command == '解绑key' then
        local success, resu = jxapi.unbindkey(event.d.author.id)
        return message.replyTextMessageWithAtAuthor(resu)
    end
    
    local combined = string.format("收到你的消息了: %s", event.d.content)
    return message.replyTextMessageWithAtAuthor(combined)
end


return msgdist  -- 返回模块表