local JXAPI_API = require("config").JXAPI_API

-- 根据userid查询镜芯API key


-- 镜芯API方法封装
local jxapi = {}

---！！！！ -- 在调用数据库方法时应严格区分不同操作类型 -- !!!
-- 举例：删除userid为666的数据
-- mongodb.delete({
--    userId = '666'
-- })


-- 判断用户是否存在数据库
function jxapi.user_exit(userid)
    -- 获得用户信息
    local userInfo = mongodb.findOne({
        userId = userid
    })

    -- 首先判断是否存在用户记录
    if userInfo == nil then
        return false, ''
    end

    -- 用户存在则true
    return true, userInfo
end

-- 从userid解绑key
function jxapi.unbindkey(userid)

    local success, result = jxapi.getkey(userid)
    if not success then
        return false, '未绑定key'
    end

    local edit_timestamp = string.format("%d", os.time())
    local update = mongodb.update({
                -- 查询条件
                query = {
                    userId = userid
                },
                -- 更新操作
                update = {
                    ['$set'] = {
                        jxapi_key = '',
                        jxapi_key_update_time = edit_timestamp
                    }
                }
        })

    -- 查询key
    local success, result = jxapi.getkey(userid)

    if not success then
        return true, '解绑成功'
    end
    
end

-- 绑定镜芯API key到用户id
function jxapi.bindkey(params)

    local userid = params.userid
    local key = params.key
    
    if userid == nil or userid == "" then
        return false, '用户id异常'
    end

    if key == nil or key == "" then
        return false, 'key不能为空'
    end
    local key = string.gsub(key, "%s+", "")
    if #key < 18 or not key:match("^[%w]+$") then
        return false, 'key不合法'
    end

    -- 判断是否为第一次绑定，如果是则直接绑定
    local success, result = jxapi.user_exit(userid) -- 判断用户是否存在

    local edit_timestamp = string.format("%d", os.time())

    -- userid不存在说明是第一次绑定，直接绑定
    if not success then

        local bindresult = mongodb.insert({
                userId = userid,
                jxapi_key = key,
                jxapi_key_update_time = edit_timestamp
        })

        -- 查询key
        local success, result = jxapi.getkey(userid)

        if result == key then
            return true, '绑定key成功'
        else
            return false, '绑定key失败'
        end

    end
    
    -- 否则判断该API是否相同
    if result.jxapi_key == key then
        return true, '已绑定该key，请勿重复绑定'
        
    else -- 不同则说明要更改或绑定API
        local update = mongodb.update({
                query = {
                    userId = userid
                },
                update = {
                    ['$set'] = {
                        jxapi_key = key,
                        jxapi_key_update_time = edit_timestamp
                    }
                }
        })
        
    end

    return true, '绑定key成功'
end

-- 根据id获取用户的key
function jxapi.getkey(userid)

    local success, result = jxapi.user_exit(userid)
    if not success then
        return false, '未绑定key'
    end

    if result == nil or result == '' or result.jxapi_key == '' then
        return false, '未绑定key'
    end

    return true, tostring(result.jxapi_key)

end

-- 翻译接口
function jxapi.translate(params)
    --- 翻译文本
    -- @param params table 包含以下字段:
    --   source string 源文本的语言代码, 可选
    --   target string 目标语言代码, 可选，不写则默认为中文
    --   text string 要翻译的文本, 必填
    -- @return string

    local text = params.text
    local userid = params.userid

    if text == nil or text == "" then
        return false, '请输入要翻译的内容'
    end

    -- 是否绑定key
    local success, JXAPI_KEY = jxapi.getkey(userid)
    if not success then
        return false, '请先绑定镜芯API官方API'
    end

    -- 从参数中获取源语言和目标语言，未提供时使用默认值
    local source = params.source or ""  -- 默认源语言为自动检测
    local target = params.target or "zh-Hans"     -- 默认目标语言为中文

    local result = http.postForm({
        url = JXAPI_API .. 'translate',
        params = {
            key = JXAPI_KEY
        },
        body = {
            source = source,
            target = target,
            soutext = text
        }
    })

    if result.code ~= 200 then
        return false, '翻译失败'
    end
    if result.body.json.code ~= 200 then
        return false, '翻译失败'
    end
    
    return true, result.body.json.data.text
end

return jxapi
