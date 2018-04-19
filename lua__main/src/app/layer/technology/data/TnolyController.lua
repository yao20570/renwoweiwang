-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-05-09 15:42:17 星期二
-- Description: 科技管理类
-----------------------------------------------------

local TnolyData = require("app.layer.technology.data.TnolyData")

--请求科技数据回调
SocketManager:registerDataCallBack("loadTnolyDatas",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		Player:getTnolyData():refreshDatasByService(__msg.body)
		--发生消息刷新科技相关
		sendMsg(gud_refresh_tnoly_lists_msg)
	end
end)

--请求研究科技数据回调
SocketManager:registerDataCallBack("upTnoly",function ( __type, __msg, __oldMsg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		if __oldMsg and __oldMsg[1] then
			local tT = __msg.body
			tT.nid = __oldMsg[1]
			Player:getTnolyData():refreshUpingTnoly(tT)
			--发生消息刷新科技相关
			sendMsg(gud_refresh_tnoly_lists_msg)
		end
	end
end)

--请求科技操作数据回调
SocketManager:registerDataCallBack("actionTnoly",function ( __type, __msg, __oldMsg )
	-- body
	--dump(__msg, "__msg", 100)
	if __msg.head.state == SocketErrorType.success then
		if __msg.body and __msg.body.op then
			local tT = __msg.body
			Player:getTnolyData():refreshUpingTnolyByAction(tT, __msg.body.op,__oldMsg[1])
			--发生消息刷新科技相关
			sendMsg(gud_refresh_tnoly_lists_msg)
			if __oldMsg[1] == 1 then
				TOAST(getConvertedStr(7, 10122))
			end

			if __oldMsg[4] and __oldMsg[4] == 1 then  --是在建筑加速完成科技升级
				TOAST(getTipsByIndex(10072))  --提示科技加速成功
			end
		end
	end
end)


--科技推送数据回调
SocketManager:registerDataCallBack("pushTnoly",function ( __type, __msg, __oldMsg )
	-- body
	Player:getTnolyData():refreshByPush(1, __msg.body)
    local tUpingTnoly = Player:getTnolyData():getUpingTnoly()
    if tUpingTnoly then
    	tUpingTnoly:refreshUpingDatasByService(__msg.body)
    end

	--发生消息刷新科技相关

	sendMsg(gud_refresh_tnoly_lists_msg)
end)

--雇用研究员
SocketManager:registerDataCallBack("employResearcher", function ( __type, __msg, __oldMsg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		if __msg.body.cd then
			--刷新文官信息
			local tdata = {}
			tdata.rId = __oldMsg[1]
			tdata.rd  = __msg.body.cd		
			Player:getTnolyData():refreshResercherByService(tdata)	
		end	
	end
end)

--获得玩家建筑单例
function Player:getTnolyData(  )
	-- body
	if not Player.tnolyData then
		self:initTnolyData()
	end
	return Player.tnolyData
end

-- 初始化玩家建筑数据
function Player:initTnolyData(  )
	if not Player.tnolyData then
		Player.tnolyData = TnolyData.new() --玩家的基础信息表
	end
	return "Player.tnolyData"
end

--释放玩家建筑数据
function Player:releaseTnolyData(  )
	if Player.tnolyData then
		Player.tnolyData = nil --玩家的基础信息
	end
	return "Player.tnolyData"
end

--建筑id
e_tnoly_ids = {
	tdcj 			= 		3027, 			--土地重建
}



