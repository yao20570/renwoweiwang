-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-04-13 11:47:52 星期四
-- Description: 玩家信息控制类
-----------------------------------------------------

local BagInfo = require("app.layer.bag.BagInfo")


--请求玩家背包基础数据回调
SocketManager:registerDataCallBack("loadBag",function ( __type, __msg )
	-- body
	--dump( __msg.body, "__msg.body", 100)	
	if __msg.head.state == SocketErrorType.success then
		if __msg.body then
			--dump( __msg.body,"bag=",100)
			--物品数据
			if __msg.body.item then
				--刷新玩家数据
				Player:getBagInfo():refreshItemsByService(__msg.body.item, 1)
			end
			--物品的当天使用情况
			if __msg.body.tus then
				Player:getBagInfo():refreshItemsUseInfo(__msg.body.tus, 1)
			end
			--发送消息刷新玩家界面
			sendMsg(gud_refresh_baginfo)
		end
	end
end)

--推送背包基础数据回调
SocketManager:registerDataCallBack("pushBag",function ( __type, __msg )
	-- dump(__msg.body, "pushBag __msg.body", 100)
	if __msg.head.state == SocketErrorType.success then
		if __msg.body then
			if __msg.body.ua then
				--推送玩家数据
				Player:getPlayerInfo():refreshDatasByService(__msg.body.ua)
				--发送消息刷新玩家界面
				sendMsg(gud_refresh_playerinfo)
			end		
			if __msg.body.ui then
				--推送玩家物品数据
				Player:getBagInfo():refreshItemsByService(__msg.body.ui, 2)
				--发送消息刷新玩家界面
				sendMsg(gud_refresh_baginfo)	
				--发送消息刷新加速道具
				for k, v in pairs(__msg.body.ui) do
					if v.i == e_item_ids.jzjs or v.i == e_item_ids.mbjs or v.i == e_item_ids.kyjs then
						--发送消息更新冒泡
						sendMsg(gud_refresh_build_bubble)
					end
				end			
			end	
			if __msg.body.uh then
				Player:getHeroInfo():refreshHeroListDatasByService(__msg.body.uh) --英雄列表
				sendMsg(gud_refresh_hero)
			end
			if __msg.body.mb then 	--养成建筑相关		
				Player:getBuildData():refreshDataByBagPush(__msg.body.mb)
				Player:getBuildData():getBuildById(e_build_ids.palace):refreshDatasByService(__msg.body.mb)		
				--处理主界面左边对联展示情况
				if __msg.body.mb.atm then
					--发送消息刷新对联
					local tObj = {}
					tObj.nType = 2
					sendMsg(ghd_refresh_homeitem_msg, tObj)					
					-- --自动建造
					-- local bShow = isShowItemHomeCollectFast(2,e_index_itemrl.l_zdjz)
					-- if __msg.body.mb.atm > 0 then
					-- 	if not bShow then
					-- 		--发送消息刷新对联
					-- 		local tObj = {}
					-- 		tObj.nType = 2
					-- 		sendMsg(ghd_refresh_homeitem_msg, tObj)
					-- 	end
					-- else
					-- 	if bShow then
					-- 		--发送消息刷新对联
					-- 		local tObj = {}
					-- 		tObj.nType = 2
					-- 		sendMsg(ghd_refresh_homeitem_msg, tObj)
					-- 	end
					-- end  
				end
				if __msg.body.mb.arm then
					--发送消息刷新对联
					local tObj = {}
					tObj.nType = 2
					sendMsg(ghd_refresh_homeitem_msg, tObj)					
					-- --守军补充
					-- local bShow = isShowItemHomeCollectFast(2,e_index_itemrl.l_sjbc)
					-- if __msg.body.mb.arm > 0 then
					-- 	if not bShow then
					-- 		--发送消息刷新对联
					-- 		local tObj = {}
					-- 		tObj.nType = 2
					-- 		sendMsg(ghd_refresh_homeitem_msg, tObj)
					-- 	end
					-- else
					-- 	if bShow then
					-- 		--发送消息刷新对联
					-- 		local tObj = {}
					-- 		tObj.nType = 2
					-- 		sendMsg(ghd_refresh_homeitem_msg, tObj)
					-- 	end
					-- end  
				end

			end
			if __msg.body.ue then --更新装备数据
				Player:getEquipData():updateEquipVos(__msg.body.ue)
				sendMsg(gud_equip_hero_equip_change)
			end
			if  __msg.body.ub then 	--buff相关
				-- dump(__msg.body.ub, "__msg.body.ub ==")
				Player:getBuffData():updateBuffVos(__msg.body.ub)
				sendMsg(gud_buff_update_msg)
			end

			if __msg.body.rb then  --buff移除相关
				-- dump(__msg.body.rb, "__msg.body.rb ==")
				Player:getBuffData():removeBuffVos(__msg.body.rb)
				sendMsg(gud_buff_update_msg)
			end
		end
	end
end)

--使用物品
SocketManager:registerDataCallBack("useStuff", function( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		if __msg.body then

		end
	end
end)

--[-2305]物品今天使用次数重置推送
--MsgType.clearItemDayUseInfo = {id = -2305, keys = {}}
SocketManager:registerDataCallBack("clearItemDayUseInfo", function( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		Player:getBagInfo():clearItemsDayUseInfo()
	end
end)
--[-2306]物品今天使用次数更新推送
--MsgType.pushItemDayUseInfo = {id = -2306, keys = {}}
SocketManager:registerDataCallBack("pushItemDayUseInfo", function( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		if __msg.body and __msg.body.us then
			Player:getBagInfo():refreshItemsUseInfo(__msg.body.us, 2)
		end
	end
end)

--[4114][2028 纣王试炼碎片合成武将]
SocketManager:registerDataCallBack("makeHerobyZhowwangPiece", function( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		
	else		
		TOAST(SocketManager:getErrorStr(__msg.head.state))		
	end
end)



--物品效果类型
e_speed_effect_type = {
	build_speed		= 1,			--建筑加速
	camp_speed 		= 6,			--募兵加速
	tnoly_speed 	= 7				--科研加速
}

--物品id
e_item_ids = {
	jbjs 			= 		100097, 			--金币加速
	xxjzd 			= 		100098, 			--小型建造队
	dxjzd 			= 		100099, 			--大型建造队
	gmt				=		100079,				--改名贴
	gjcj            = 		100101,				--高级重建物资
	zdjz            = 		100095,				--自动建造
	bccf            = 		100096,				--补充城防
	jzjs            = 		100116,				--建筑加速
	mbjs            = 		100117,				--募兵加速
	kyjs            = 		100118,				--科研加速
	sdw				=		100162,				--圣诞袜
	cjzhq			=		100154,				--初级纣王召唤券
	gjzhq			=		100155,				--高级纣王召唤券
	blessstone		=		100175,				--祝福石
	strengthstone	=		100176,				--突破石
	zhouwangBox 	= 		100215,				--纣王宝箱
}

--物品类型
e_item_types = {
	consum 			= 		1, --消耗品
	material 		= 		2, --材料
	other 			= 		3, --其他
}

--资源id
e_resdata_ids = {
	energy 			= 		1, 					--体力能量
	lc 				= 		2, 					--粮草
	yb 				= 		3, 					--银币
	mc 				= 		4, 					--木材
	bt 	 			= 		5, 					--镔铁
	bb 				= 		6, 					--步兵
	qb 				= 		7, 					--骑兵
	gb 				= 		8, 					--弓兵
	rk 				= 		9, 					--入口
	ybao 			= 		10, 				--黄金
	ww 				= 		11, 				--威望
	jy 				= 		12, 				--经验
	vipexp 			= 		13, 				--Vip点数 	
	medal			= 		18,                 --奖章
	killheroexp 	=		19,					--斩将积分
	countrycoin 	=		21,					--国家贡献
}

--获得玩家背包信息单例
function Player:getBagInfo(  )
	-- body
	if not Player.pBagData then
		self:initBagInfo()
	end
	return Player.pBagData
end

-- 初始化玩家背包信息
function Player:initBagInfo(  )
	if not Player.pBagData then
		Player.pBagData = BagInfo.new() --玩家的基础信息表
	end
	return "Player.pBagData"
end

--释放玩家背包信息
function Player:releaseBagInfo(  )
	if Player.pBagData then
		Player.pBagData = nil --玩家的基础信息
	end
	return "Player.pBagData"
end




