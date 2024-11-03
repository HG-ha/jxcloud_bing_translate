local config = {}

-- 镜芯API的URL
config.JXAPI_API = 'https://api2.wer.plus/api/'

-- 当前应用的指令，用于判断是否触发指令
config.COMMAND_LIST = {"翻译", "绑定key", "解绑key", "帮助"}

config.help = [[
使用前请先绑定镜芯API平台的key
如需换绑key，重新绑定即可

参考指令：
绑定key xxx
解绑key
翻译 hello world
]]

return config  -- 返回整个配置表