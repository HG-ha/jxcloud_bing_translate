-- 消息分发模块
local msgdist = require("msgdist")

-- 主函数
function main(event)

    -- 频道内@
    if event.t == "AT_MESSAGE_CREATE" and msgdist.AT_MESSAGE_CREATE then
        return msgdist.AT_MESSAGE_CREATE(event)
    end

    -- 频道私信
    if event.t == "DIRECT_MESSAGE_CREATE" and msgdist.DIRECT_MESSAGE_CREATE then
        return msgdist.DIRECT_MESSAGE_CREATE(event)
    end

    -- QQ私信
    if event.t == "C2C_MESSAGE_CREATE" and msgdist.C2C_MESSAGE_CREATE then
        return msgdist.C2C_MESSAGE_CREATE(event)
    end

    -- QQ群聊@
    if event.t == "GROUP_AT_MESSAGE_CREATE" and msgdist.C2C_MESSAGE_CREATE then
        return msgdist.C2C_MESSAGE_CREATE(event)
    end
    
end
