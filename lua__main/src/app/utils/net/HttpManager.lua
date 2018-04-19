----------------------------------------------------- 
-- author: xieruidong
-- updatetime: 2017-01-12 18:12:52 
-- Description: http请求的管理类
-----------------------------------------------------

HttpManager = class("HttpManager")


-- 账号服返回的错误提示信息
local AccountStatusMsg = {
    err0 = getConvertedStr(1, 10002),
    err1 = getConvertedStr(1, 10003),
    err2 = getConvertedStr(1, 10004),
    err3 = getConvertedStr(1, 10005),
    err4 = getConvertedStr(1, 10006),
    err5 = getConvertedStr(1, 10007),
    err6 = getConvertedStr(1, 10008),
    err10 = getConvertedStr(1, 10009),
    err11 = getConvertedStr(1, 10010),
    err1024 = getConvertedStr(1, 10011)
}

local accountServerUrl = S_ACCOUNT_SERVER_ADDRESS -- 帐号服务器地址
--向账号服发送Get请求
-- __url    请求url
-- __param  请求参数
-- __func   回调函数
function HttpManager:doGetFunctionToHttpServer( __url, __param, __func )
	-- 以下参数需要调整为三国项目最终正式需要的参数(待正式化)
	-- 服务端做信息兼容
	if __param.token and string.len(__param.token) > 0 then
    	local json = require("framework.json")
		local  token = json.decode(__param.token)
		if token.new_sign or token.sign then
			__param["new_sign"] = token.new_sign or token.sign
		end
		if token.userId then
			__param["user_id"] = token.userId
		end
		if token.timestamp then
			__param["time"] = token.timestamp
		end
		if token.guid then
			__param["guid"] = token.guid
		end
		if token.cp_ext then
			__param["cp_ext"] = json.encode(token.cp_ext)
		end
	end
    __param["channel"] = AccountCenter.subcid
    -- __param["channelcid"] = AccountCenter.subpcid
    __param["channelcid"] = N_PACK_MODE or 0 -- 原subpcid作废，使用pack mode值来区分不同包的统计
    __param["imei"] = AccountCenter.imei
    __param["mac"] = AccountCenter.mac
    __param["idx"] = getSystemTime(true)
    __param["pagver"] = AccountCenter.sPackageVer or ""
    __param["presver"] = AccountCenter.sPackResVer or ""
    __param["os"] = AccountCenter.os or 1
    -- 对参数进行拼接，还需要执行encode
	local paramStr = ""
    local index = 0
    for k, v in pairs(__param) do
        index = index + 1
        if (index ~= 1) then
            paramStr = paramStr.."&"
        end
        -- 转义一下，防止出现解析字符包含url的特殊字符
        v = string.urlencode(v)
        paramStr = paramStr..k.."="..v
    end
    -- 构建最终需要请求的接口（加密后的）
    local url = ""
    if USING_ENCRYPT then
        paramStr = cc.Crypto:encryptXXTEA(paramStr, string.len(paramStr), 
        	ENCRYPT_KEY, string.len(ENCRYPT_KEY))
        paramStr = cc.Crypto:encodeBase64(paramStr, string.len(paramStr))
        paramStr = string.urlencode(paramStr)
        paramStr = string.gsub(paramStr, "%%00$", "")
        url = accountServerUrl..__url.."?".."p="..paramStr
    else
        url = accountServerUrl..__url.."?"..paramStr
    end
    --myprint("REQ: " .. url)
    showLoadingDlg()
    -- 正式调用http请求
	local request = network.createHTTPRequest(function ( event )
    	if(event.name == "progress") then -- 当前进度
    	elseif(event.name == "completed") then -- 接口连接成功
    		local revent = {}
    		revent.name = event.name
    		if(event.request) then
	    		revent.code = event.request:getResponseStatusCode()
		    	if(revent.code == 200) then
		    		local str = event.request:getResponseString()
		    		revent.data = json.decode(str)
                    if __func then
                        __func(revent)
                    end
                else
                    myprint("http code " .. revent.code .. " REQ: " .. url)
			    end
	    	end
            hideLoadingDlg()
    	elseif(event.name == "failed") then -- 接口连接失败
            local revent = {}
            revent.name = event.name
            if __func then
                __func(revent)
            end
			myprint("http failed REQ: " .. url)
            hideLoadingDlg()
        else
            hideLoadingDlg()
    	end
    end, url, "GET")
    request:setTimeout(getOuttimeForHttp())
    request:start()
end

--获取状态码信息
--__status：状态码
function HttpManager:getStatusMsg(__status)
    local key = "err"..__status
    if AccountStatusMsg[key] ~= nil then
        return AccountStatusMsg[key]
    else
        return getConvertedStr(1, 10001) .. __status
    end
end

--账号服-登陆
-- __acc    帐号
-- __pass   密码
-- __func   回调函数
function HttpManager:doLogin(__acc, __pass, __func)
    local __param = {acc=__acc, pwd=__pass}
    self:doGetFunctionToHttpServer("/action/user/login", __param, __func)
end

--账号服-注册
-- __acc    帐号
-- __pass   密码
-- __func   回调函数
function HttpManager:doRegist(__acc, __pass, __func)
    local __param = {acc=__acc, pwd=__pass, em="email"}
    self:doGetFunctionToHttpServer("/action/user/register", __param, __func)
end

--帐号服-一键注册
-- __func   回调函数
function HttpManager:doRegistFast( __func )
    -- body
    local __param = {em="email"}
    self:doGetFunctionToHttpServer("/action/user/fastReg", __param, __func)
end

--账号服-修改密码
-- __acc    帐号
-- __pass   密码
-- __func   回调函数
function HttpManager:doChangePass(__acc, __oldPass, __newPass, __func)
    local __param = {acc=__acc, pwd=__oldPass, newpwd=__newPass, email="email", isver=2}
    self:doGetFunctionToHttpServer("/action/user/updatePassword", __param, __func)
end

-- 从后台获取功能的开关
function HttpManager:doGetSwitchesFromServer( __func )
    self:doGetFunctionToHttpServer("/action/user/extFunInfo", {}, __func)
end

--账号服-创建订单信息
-- __acc    帐号
-- __pass   密码
-- __func   回调函数
-- __url    创建订单url
-- function HttpManager:doCreateOrder(__acc, __serid, __money, __rechtype, __regid, __subject, __func, __url)
--     -- 名称包含中文，要urlencode
--     subject = string.urlencode(subject)
--     local __param = {acc=__acc, serid=__serid, money=__money, 
--         channelId=__regid, rechtype=__rechtype}
--     self:doGetFunctionToHttpServer(__url or "/action/recharge/createOrder", __param, __func)
-- end

--帐号服-步骤打点
-- __channelId    渠道id
-- __imei         imei
-- __mac          mac
-- __step         步骤
-- __func         回调函数
-- function HttpManager:doUIStep( __channelId, __imei, __mac, __step, __func )
--     -- body
--     local __param = {channelId=__channelId, imei=__imei, mac=__mac, step=__step}
--     self:doGetFunctionToHttpServer("/action/user/uiStep", __param, __func)
-- end

--新功能-点击统计
-- __channelId    渠道id
-- __sid          服务器id
-- __step         步骤
-- __func         回调函数
-- function HttpManager:doClickCount( __sid, __channelId, __step, __func )
--     -- body
--     local __param = {sid=__sid, channelId=__channelId, step=__step}
--     self:doGetFunctionToHttpServer("/action/user/clickCount", __param, __func)
-- end

-- 发送idfa给后台
function HttpManager:doFlushIdfaToServer( __func )
    local __param = {idfa = AccountCenter.sIdfa, 
        devModel=AccountCenter.sDevModel}
    self:doGetFunctionToHttpServer("/action/user/idfaFlush", __param, __func)
end

-- 获取最新的客服中心地址
-- function HttpManager:doGetNewGameServiceAddress( __func )
--     local sNewVer = AccountCenter.getStringData("snewver")
--     local __param = {paramVer=tonumber(sNewVer), uid=AccountCenter.acc}
--     self:doGetFunctionToHttpServer("/action/user/cusSerUrl", __param, __func)
-- end

-- 获取渠道开关
-- function HttpManager:doGetChannelInfo( __func )
--     local __param = {}
--     self:doGetFunctionToHttpServer("/action/user/extraChannelInfo", __param, __func)
-- end

-- 获取翻译后的内容
-- _sContent(string):需要翻译的内容
-- _sLan(string):需要翻译的目标语言
-- __func(function): 回调函数
-- function HttpManager:doTranslateToLocalLan( _sContent, _sLan, __func )
--     local __param = {serverurl="http://translate.tmsjyx.net/", content=_sContent, lang=_sLan}
--     self:doGetFunctionToHttpServer("tran/translate", __param, __func)
-- end

--设置账号服地址
-- __url    服务器地址
function HttpManager:setAccountServerUrl(__url)
    accountServerUrl = __url or accountServerUrl
end

--获取账号服地址
function HttpManager:getAccountServerUrl()
    return accountServerUrl
end

return HttpManager
