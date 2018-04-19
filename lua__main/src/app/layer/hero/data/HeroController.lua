-----------------------------------------------------
-- author: liangzhaowei
-- Date: 2017-04-21 14:10:24
-- Description: 英雄信息控制类
-----------------------------------------------------

local HeroMgr = require("app.layer.hero.data.HeroMgr")


--请求英雄数据回调
SocketManager:registerDataCallBack("loadHeroData",function ( __type, __msg )
	--刷新英雄数据
	-- dump(__msg, "loadHeroData __msg")
	Player:getHeroInfo():refreshDatasByService(__msg.body)
	sendMsg(gud_refresh_hero) --通知刷新界面
end)

--请求英雄数据回调
SocketManager:registerDataCallBack("wipeteamset",function ( __type, __msg )
	--刷新英雄数据
	--dump(__msg, "wipeteamset __msg")
	Player:getHeroInfo():refreshDatasByService(__msg.body)
	sendMsg(gud_refresh_hero) --通知刷新界面
end)



--武将数据变化推送
SocketManager:registerDataCallBack("pushChangeHeroData",function ( __type, __msg )
	--刷新英雄数据
	-- dump(__msg.body,"pushChangeHeroData __msg.body",30)
	Player:getHeroInfo():refreshDatasByService(__msg.body)
	sendMsg(gud_refresh_hero) --通知刷新界面
end)

--自动补兵操作
SocketManager:registerDataCallBack("autoAddSoldier",function ( __type, __msg )
	--刷新英雄数据
	Player:getHeroInfo():refreshDatasByService(__msg.body)
	sendMsg(gud_refresh_hero) --通知刷新界面
end)

--武将进阶回调
SocketManager:registerDataCallBack("heroAdvance",function ( __type, __msg )
	--刷新英雄数据
	-- dump(__msg)
	-- Player:getEquipData()
	if __msg.body and __msg.body.es then
		Player:getEquipData():delEquipList(__msg.body.es)
	end
	
	Player:getHeroInfo():refreshDatasByService(__msg.body)
	sendMsg(gud_refresh_hero) --通知刷新界面
	sendMsg(ghd_hero_advance_success_msg,__msg.body)
end)


--培养英雄
SocketManager:registerDataCallBack("trainHero",function ( __type, __msg )
	--刷新英雄数据
	Player:getHeroInfo():refreshDatasByService(__msg.body)
	sendMsg(gud_refresh_hero) --通知刷新界面
end)


--英雄上阵
SocketManager:registerDataCallBack("goToFight",function ( __type, __msg )
	--刷新英雄数据
	Player:getHeroInfo():refreshDatasByService(__msg.body)
	Player:getHeroInfo():saveLocalHeroOrder()
	sendMsg(gud_refresh_hero) --通知刷新界面
end)


--武将推演
SocketManager:registerDataCallBack("buyHero",function ( __type, __msg )
	--刷新英雄数据
	Player:getHeroInfo():refreshDatasByService(__msg.body)
	sendMsg(gud_refresh_hero) --通知刷新界面
	sendMsg(gud_refresh_buy_hero) --通知拜将台数据
end)

--恢复武将免费培养次数
SocketManager:registerDataCallBack("renewTrainTimes",function ( __type, __msg )
	if __msg.head.state == SocketErrorType.success then
		if __msg.body then
			--刷新武将培养次数
			Player:getHeroInfo():refreshTrainTimes(__msg.body)
			sendMsg(gud_refresh_hero) --通知刷新界面
		end
	end
end)


--恢复武将城防耐力
SocketManager:registerDataCallBack("reqWalldefHeroRecover",function ( __type, __msg, __oldMsg )
	if __msg.head.state == SocketErrorType.success then
		if __msg.body then

			if __oldMsg then
				local nHeroId = __oldMsg[1]
				if nHeroId then
					local tHero = Player:getHeroInfo():getHero(nHeroId)
					if tHero then
						--耐力补满
						local tData = {
							s = tHero:getProperty(e_id_hero_att.bingli),
						}
						tHero:refreshDatasByService(tData)
						sendMsg(gud_refresh_hero) --通知刷新界面
					end
				end
			end
		end
	else
        --弹出错误提示语
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--武将星魂格子激活或突破
SocketManager:registerDataCallBack("reqHeroSoulActive",function ( __type, __msg )
	if __msg.head.state == SocketErrorType.success then
		if __msg.body then
			-- dump(__msg.body, "武将星魂格子激活 --", 100)
			--刷新英雄数据
			Player:getHeroInfo():refreshDatasByService(__msg.body)
			sendMsg(gud_refresh_hero) --通知刷新界面
		end
	else
		--弹出错误提示语
        TOAST(SocketManager:getErrorStr(__msg.head.state))
	end
end)

--武将星魂还原
SocketManager:registerDataCallBack("reqHeroSoulRecover",function ( __type, __msg )
	if __msg.head.state == SocketErrorType.success then
		if __msg.body then
			-- dump(__msg.body, "武将星魂还原 --", 100)
			--刷新英雄数据
			Player:getHeroInfo():refreshDatasByService(__msg.body)
			sendMsg(gud_refresh_hero) --通知刷新界面
		end
	else
		--弹出错误提示语
        TOAST(SocketManager:getErrorStr(__msg.head.state))
	end
end)



--获得英雄信息单例
function Player:getHeroInfo()
	if not Player.heroInfos then
		self:initHeroInfo()
	end
	return Player.heroInfos
end

-- 初始化英雄基础数据
function Player:initHeroInfo(  )
	if not Player.heroInfos then
		Player.heroInfos = HeroMgr.new() --英雄的基础信息表
	end
	return "Player.heroInfos"
end


--释放英雄基础数据
function Player:releaseHeroInfo(  )
	if Player.heroInfos then
		Player.heroInfos = nil --英雄的基础信息
	end

	return "Player.heroInfos"
end




