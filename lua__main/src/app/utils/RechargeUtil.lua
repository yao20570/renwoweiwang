----------------------------------------------------- 
-- author: xieruidong
-- updatetime: 2017-07-26 16:57:20 
-- Description: 充值的工具类
-----------------------------------------------------
local function createGameOrder ( _data, _callback )
	local url = nil
	local param = {}
	if(AccountCenter.platformData) then
		url = AccountCenter.platformData.orderUrl
	end
	if(not url) then
		print("没有定义创建订单的url")
		return
	end
	param.productId = _data.pid  -- 商品ID
	param.acc = AccountCenter.acc -- 账户
	param.aid = Player:getPlayerInfo().pid -- 角色ID
	param.money = _data.price -- 订单金额
	param.channel = AccountCenter.subcid -- 订单创建渠道
	param.rechtype = _data.type -- 充值类型
	param.serid = AccountCenter.nowServer.id -- 订单创建服务器
	HttpManager:doGetFunctionToHttpServer(url, param, function ( _event )
		if(_event.name == "completed" and _event.data and _event.data.s == 0) then
			if(not _event.data.r or string.len(_event.data.r) <= 0) then
				print("游戏创建订单id为空")
				return
			end
			if(_callback) then
				_callback(_event.data.r)
			end
		elseif(_event.name == "failed") then
			TOAST("创建订单失败")
		end
	end)
end
-- 执行充值行为
-- _data(table): 当前档次的数据
function startRecharge( _data )
	if(not _data) then
		print("选择的充值档次没有数据")
		return
	end
	-- 设置充值回调的域名地址
	checkHttpAddress()
	-- 创建游戏服的订单
	-- _orderResult(string): 订单id
	createGameOrder(_data, function ( _orderResult )
		local params = {}
		params.money = _data.price -- 价格
		params.serverId = AccountCenter.nowServer.id -- 订单创建服务器
		params.roleId = Player:getPlayerInfo().pid .. "" -- 角色ID
		params.roleName = Player:getPlayerInfo().sName -- 角色名称
		params.rate = 10 -- 汇率
		params.productName = "金币" -- 商品名称
		params.serverName = AccountCenter.nowServer.ne -- 服务器名称
		params.order = _orderResult -- 订单id
		params.productId = _data.pid -- 商品ID
		params.roleLevel = Player:getPlayerInfo().nLv -- 角色等级
		params.vipLevel = Player:getPlayerInfo().nVip -- vip等级
		params.balance = Player:getPlayerInfo().nMoney -- 玩家拥有的金币数
		params.chargeCount = _data.gold -- 获得的游戏币值
		params.unionName = "" -- 联盟名称
		params.sdes = "" -- 扩充字段
		-- 执行SDK的充值行为
		if(device.platform == "android") then
			local className = "com/game/quickmgr/QuickMgr"
	        local methodName = "doRealPay"
	        local result, ret = luaj.callStaticMethod(className, methodName, 
	        	{json.encode(params)}, 
	        	"(Ljava/lang/String;)V");
	    elseif(device.platform == "ios") then
	    	-- 充值档次列表
	    	params.rechId = getRechProductId(_data) -- 获取充值档次id
            params.rechList = getRechargeIdListForIos()
            --
            local luaoc = require("framework.luaoc")
            luaoc.callStaticMethod("PlatformSDK", "pay", params)
		end
	end)
end
-- 从充值档次数据中读取对应平台的商品档次id(ios的商品id)
function getRechProductId( _pRecData )
	if (not _pRecData) then
		return nil 
	end
	local nReType = tonumber(getStringDataCfg("rechargeType")) or 0 -- 获取包的充值类型
	if (nReType == 1) then -- ios
		return _pRecData.rechid1
	elseif (nReType == 2) then -- ios--权谋者
		return _pRecData.rechid2
	elseif (nReType == 3) then -- ios--烽烟三国 （废弃）
		return _pRecData.rechid3
	elseif (nReType == 4) then -- ios--大军师
		return _pRecData.rechid4
	elseif (nReType == 5) then -- ios--攻城ol
		return _pRecData.rechid5
	elseif (nReType == 6) then -- ios--帝王传
		return _pRecData.rechid6
	elseif (nReType == 7) then -- ios--荣耀战记
		return _pRecData.rechid7
	elseif (nReType == 8) then -- ios--江山之主
		return _pRecData.rechid8
	elseif (nReType == 9) then -- ios--秦末汉楚
		return _pRecData.rechid9
	elseif (nReType == 10) then -- ios--战火三国
		return _pRecData.rechid10
	elseif (nReType == 11) then
		return _pRecData.rechid11
	elseif (nReType == 12) then
		return _pRecData.rechid12
	else 
		return _pRecData.pid
	end
end
-- 设置回调地址的域名
function checkHttpAddress(  )
	if(not g_hasSetHttpAddress) then
		g_hasSetHttpAddress = true
		if(device.platform == "android") then
			local className = "com/game/quickmgr/QuickMgr"
	        local methodName = "setHttpAddress"
	        local result, ret = luaj.callStaticMethod(className, methodName, 
	        	{S_ACCOUNT_SERVER_ADDRESS}, 
	        	"(Ljava/lang/String;)V");
	    elseif(device.platform == "ios") then
	    	local luaoc = require("framework.luaoc")
            luaoc.callStaticMethod("PlatformSDK", "setHttpAddress", 
            	{url=S_ACCOUNT_SERVER_ADDRESS})
		end
	end
end

-- 请求充值
-- _data(table): 当前档次的数据
function reqRecharge( _data )
	-- body
	if(b_open_recharge) then
		if(device.platform == "windows") then
			TOAST("电脑版不存在充值功能")
		else
			if(_data) then
				startRecharge(_data)
			else
				TOAST("充值项的数据获取失败")
			end
		end
	else
		TOAST("充值功能暂未开放")
	end
end