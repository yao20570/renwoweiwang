-----------------------------------------------------
-- author: liangzhaowei
-- Date: 2017-06-19 15:12:28
-- Description: 活动信息控制类
-----------------------------------------------------
tActivityDataList = {}--所有活动数据创建的列表

--活动a
local DataNanBeiWar = require("app.layer.activitya.nanbeiwar.DataNanBeiWar")
local DataExpeditefuben = require("app.layer.activitya.expeditefuben.DataExpeditefuben")
local DataEnemyDrawing = require("app.layer.activitya.enemydrawing.DataEnemyDrawing")
local DataExpediteWorkshop = require("app.layer.activitya.expediteworkshop.DataExpediteWorkshop")
local DataEnemyResource = require("app.layer.activitya.enemyresource.DataEnemyResource")
local DataRechargeGift = require("app.layer.activitya.giftrecharge.DataRechargeGift")
local DataCountryFight = require("app.layer.activitya.countryfight.DataCountryFight")
local DataForgeRank = require("app.layer.activitya.forgerank.DataForgeRank")
local DataDoubleExp = require("app.layer.activitya.doubleexp.DataDoubleExp")
local DataExpediteProducts = require("app.layer.activitya.expediteproducts.DataExpediteProducts")
local DataExpeditEnemy = require("app.layer.activitya.expeditenemy.DataExpeditEnemy")
local DataEnemyRemoval = require("app.layer.activitya.enemyremoval.DataEnemyRemoval")
local DataDoubleCollect = require("app.layer.activitya.doublecollect.DataDoubleCollect")

local DataArmyRank = require("app.layer.activitya.armyrank.DataArmyRank")
local DataSuccinct = require("app.layer.activitya.succinctrank.DataSuccinct")
local DataSevenDayLog = require("app.layer.activitya.sevendaylog.DataSevenDayLog")
local DataFoodStore = require("app.layer.activitya.foodstore.DataFoodStore")
local DataIronStore = require("app.layer.activitya.ironstore.DataIronStore")
local DataCityFight = require("app.layer.activitya.cityfight.DataCityFight")
local DataConsumeGift = require("app.layer.activitya.consumegift.DataConsumeGift")
local DataTotalRecharge = require("app.layer.activitya.totalrecharge.DataTotalRecharge")
local DataDayRebate = require("app.layer.activitya.dayrebate.DataDayRebate")
local DataEatChicken = require("app.layer.activitya.eatchicken.DataEatChicken")
local DataSevenKing = require("app.layer.activitya.sevenking.DataSevenKing")
local DataRedPacket = require("app.layer.activitya.redpacket.DataRedPacket")
local DataPhoneBind = require("app.layer.activitya.phonebind.DataPhoneBind")
local DataRealNameCheck = require("app.layer.activitya.realnamecheck.DataRealNameCheck")
local DataFreeCall = require("app.layer.activitya.freecall.DataFreeCall")
local DataMagicCrit = require("app.layer.activitya.magiccrit.DataMagicCrit")
local DataPalaceCollect = require("app.layer.activitya.palacecollect.DataPalaceCollect")
local DataDoubleEgg = require("app.layer.activitya.doubleegg.DataDoubleEgg")
local DataRoyaltyCollect = require("app.layer.activitya.royaltycollect.DataRoyaltyCollect")
local DataEnergyDiscount = require("app.layer.activitya.energydiscount.DataEnergyDiscount")
local DataOnlineWelfare = require("app.layer.activitya.onlinewelfare.DataOnlineWelfare")
local DataPacketShowRes = require("app.layer.activitya.packetgift.DataPacketShowRes")
local DataNewRoyaltyCollect = require("app.layer.activitya.royaltycollect.DataNewRoyaltyCollect")
local DataEquipMake = require("app.layer.activitya.equipmake.DataEquipMake")
local DataFubenPass = require("app.layer.activitya.fubenpass.DataFubenPass")
local DataPlayerLvUp = require("app.layer.activitya.playerlvup.DataPlayerLvUp")
local DataPlayerLvUp = require("app.layer.activitya.blueequipmake.DataBlueEquipMake")
local DataEquipRefine = require("app.layer.activitya.equiprefine.DataEquipRefine")
local DataArtifactMake = require("app.layer.activitya.artifactmake.DataArtifactMake")
local DataAttackVillage = require("app.layer.activitya.attackvillage.DataAttackVillage")
local DataNationPillars = require("app.layer.activitya.nationpillars.DataNationPillars")
local DataRegress = require("app.layer.activitya.regress.DataRegress")

--活动b
local DataGrowthFound = require("app.layer.activityb.growthfound.DataGrowthFound")
local DataHeroMansion = require("app.layer.activityb.heromansion.DataHeroMansion")
local DataFirstRecharge = require("app.layer.activityb.firstrecharge.DataFirstRecharge")
local DataUpdatePlace = require("app.layer.activityb.updateplace.DataUpdatePlace")
local DataSpecialSale = require("app.layer.activityb.specialsale.DataSpecialSale")
local DataPeopleRebate = require("app.layer.activityb.peoplerebate.DataPeopleRebate")
local DataSnatchturn = require("app.layer.activityb.snatchturn.DataSnatchturn")
local DataFreeBenefits = require("app.layer.activityb.freebenefits.DataFreeBenefits")
local DataActTreasureShop = require("app.layer.activityb.acttreasureshop.DataActTreasureShop")
local DataFarmTroopsPlan = require("app.layer.activityb.farmtroopsplan.DataFarmTroopsPlan")
local DataBlessWorld = require("app.layer.activityb.blessworld.DataBlessWorld")
local DataConsumeiron = require("app.layer.activityb.consumeiron.DataConsumeiron")
local DataDayLoginAward = require("app.layer.activityb.dayloginaward.DataDayLoginAward")
local DataWuWang = require("app.layer.activityb.wuwang.DataWuWang")
local DataNewFirstRecharge = require("app.layer.activityb.newfirstrecharge.DataNewFirstRecharge")
local DataDragonTreasure = require("app.layer.activityb.dragontreasure.DataDragonTreasure")
local DataSeveralRecharge = require("app.layer.activityb.severalrecharge.DataSeveralRecharge")
local DataRechargeSign = require("app.layer.activitya.rechargesign.DataRechargeSign")
local DataNewGrowthFound = require("app.layer.activityb.growthfound.DataNewGrowthFound")
local DataEverydayPreference = require("app.layer.activityb.everydaypreference.DataEverydayPreference")
local DataWuWangForcast = require("app.layer.activityb.wuwang.DataWuWangForcast")
local DataLaba = require("app.layer.activityb.laba.DataLaba")
local DataSearchBeauty = require("app.layer.activityb.searchbeauty.DataSearchBeauty")
local DataAttkCity = require("app.layer.attackcity.DataAttkCity")
local DataExamActivity = require("app.layer.activityb.exam.DataExamActivity")
local DataNianAttack = require("app.layer.activityb.nianattack.DataNianAttack")
local DataMonthCard = require("app.layer.activityb.monthcard.DataMonthCard") --月卡
local DataMonthWeekCard = require("app.layer.activityb.monthweekcard.DataMonthWeekCard") --月卡周卡
local DataLuckyStar = require("app.layer.activityb.luckystar.DataLuckyStar")
local DataSciencePromote = require("app.layer.activityb.sciencepromote.DataSciencePromote")
local DataMingjie = require("app.layer.activityb.mingjie.DataMingjie")
local DataHeroCollect = require("app.layer.activitya.herocollect.DataHeroCollect")
local DataTLBoss = require("app.layer.activityb.tlboss.DataTLBoss")
local DataZhouwangTrial = require("app.layer.activityb.zhouwangtrial.data.DataZhouwangTrial")
local DataDevelopGift = require("app.layer.activityb.developgift.data.DataDevelopGift")
local DataWelcomeBack = require("app.layer.activityb.welcomeback.DataWelcomeBack")


--不在活动列表里显示的活动
local tNoShowDict = {
		[e_id_activity.specialsale] = true,
		[e_id_activity.newfirstrecharge] = true,
		[e_id_activity.tlboss] = true,
		[e_id_activity.exam] = true,
		[e_id_activity.mingjie] = true,
	}

--请求活动数据回调
SocketManager:registerDataCallBack("loadActivity",function ( __type, __msg )
	-- dump(__msg.body,"loadActivity")
	if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.loadActivity.id then
			Player:refreshActData(__msg.body, true)	
            --for (k , v in pairs(_msg.body))
            --TOAST(__msg.body, "loadActivity",)	
		end
	end
end)


--增加运营活动
SocketManager:registerDataCallBack("pushOpenActivity",function ( __type, __msg )
	-- dump(__msg.body,"pushOpenActivity")
	Player:addActData(__msg.body)
end)

--运营活动关闭推送
SocketManager:registerDataCallBack("pushCloseActivity",function ( __type, __msg )
	-- dump(__msg.body,"pushCloseActivity")
	Player:closeAct(__msg.body)
end)

--运营活动移除推送
SocketManager:registerDataCallBack("pushRemoveActivity",function ( __type, __msg )
	-- dump(__msg.body,"pushRemoveActivity")
	if __msg.body then
		Player:removeActById(__msg.body.id)
		sendMsg(gud_refresh_activity) --通知刷新界面
	end
end)

--定点重置推送
SocketManager:registerDataCallBack("pushZeroActivity",function ( __type, __msg )
	-- dump(__msg.body,"pushZeroActivity",30)
	if __msg.body then
		Player:pushZeroActData(__msg.body)
	end
end)


--运营活动数据刷新推送
SocketManager:registerDataCallBack("pushRefreshActivity",function ( __type, __msg )
	-- dump(__msg.body,"pushRefreshActivity",30)
	Player:pushRefreshActData(__msg.body)
end)



--单个活动协议(协议中必须带活动id)
local tActSingleProtocol = {
	"getFirstRecharge",      		 --领取首冲奖励协议
	"pushFirstRecharge",     		 --首冲奖励协议推送	 
	"getUpdatePlace",        		 --领取王宫升级奖励
	"reqBuyFoundsPlayerNum", 		 --请求已购买基金人数
	"reqBuyGrowFounds",      		 --请求购买基金
	"reqGetFoundsAwards",    		 --获取基金奖励
	"reqRechargeGift",       		 --请求兑换礼包
	"reqNanBeiWarReward",    		 --请求获取任务奖励
	"reqGZRankPrize", 		 		 --请求国战排行奖励
	"reqDZRankPrize", 		 		 --请求锻造排行奖励
	"reqBLRankPrize", 		 		 --请求兵力排行奖励
	"reqXLRankPrize",		 		 --请求洗练排行奖励
	"reqTLRankPrize",		 		 --请求屯粮排行奖励
	"reqTTRankPrize",		 		 --请求屯铁排行奖励
	"reqGCRankPrize",		 		 --请求攻城排行奖励
	"reqSevenDayAwards",     		 --请求领取七天登录奖励
	"reqNanBeiWarReward",    		 --请求南北征战奖励
	"reqPeopleRebateReward", 		 --请求全民返利奖励
	"reqBuySaleGoods",       		 --请求购买特价商品
	"reqConsumeAwards",      		 --请求领取消费好礼奖励
	"reqSnatchturn",         		 --请求夺宝转盘
	"buyHeroMansion",        		 --购买登坛拜将物品
	"reqBuyFarmPlan",        		 --请求购买屯田计划
	"freshHeroMansion",      		 --登坛拜将刷新物品
	"reqGetFarmPlanAwards",  		 --请求领取计划奖励
	"freeHeroMansion",       		 --登坛拜将恢复免费次数
	"recruitHeroMansion",    		 --登坛拜将招募武将
	"reloadpeoplerebate",	 		 --全民返利刷新数据
	"getDayRebatReward",	 		 --每日返利领取奖励数据 
	"getTotalRechargeReward",		 --累计充值领取奖励数据 
	"getBlessWorldReward",		 	 --福泽天下领取奖励数据
	"reqConsumeironTurn",    		 --耗铁有礼转盘
	"getActDayLoginReward",  		 --每日收贡领取奖励
	"reloadBlessWorldData",  		 --福泽天下刷新数据
	"reqEnemySpeed",				 --请求活动加速(乱军加速活动掉落的道具加速buff)
	"reqEatChicken",         		 --吃鸡
	"reqFillChicken",        		 --补鸡
	"reqWuWangExchange",     		 --兑换武王奖励
	"reqSevenkingS",		 		 --7日登基[13.科技排行]领取科技排行奖励
	"reqSevenkingC",   		 		 --7日登基[16.攻城排行]领取攻城排行奖励
	"reqSevenkingE",		 		 --7日登基[17.装备排行]领取装备排行奖励
	"reqSevenkingD",		 		 --19.副本排行]领取副本排行奖励
	"reqSevenkingP",		 		 --7日登基[20.王宫排行]领取王宫排行奖励
	"reqSevenkingZ",		 		 --7日登基[21.权倾天下]领取战力排行奖励
	"reqDailyLoginAwd",		 		 --7日登基[1.每日登录]领取登录奖励
	"reqLevelAwd",			 		 --7日登基[2.主公等级]领取等级奖励
	"reqKillArmyAwd",		 		 --7日登基[3.初战天下]领取击杀乱军奖励
	"reqTnolyupAwd",		 		 --7日登基[4.科技升级]领取科技奖励
	"reqRecruitHeroAwd",	 		 --7日登基[5.觅得良将]领取武将奖励
	"reqKikkBossAwd",		 		 --7日登基[6.再战天下]领取BOSS奖励
	"reqEquipAwd",			 		 --7日登基[7.备战天下]领取装备奖励
	"reqFubenAwd",			 		 --7日登基[8.副本推进]领取副本通关的奖励
	"reqCityFightAwd",		 		 --7日登基[9.逐鹿天下]领取城战胜利的奖励
	"reqItemSpeedAwd",		 		 --7日登基[10.全力冲刺]领取道具加速奖励
	"reqCampAwd",			 		 --7日登基[11.军事升级]领取兵营奖励
	"reqShenbingAwd",		 		 --7日登基[12.神兵之威]领取神兵奖励
	"reqTroopsAwd",			 		 --7日登基[14.兵强马壮]领取募兵奖励
	"reqResourceAwd",		 		 --7日登基[15.国泰民安]领取资源田奖励
	"reqSuccinctAwd",		 		 --7日登基[18.装备洗炼]领取洗炼奖励
	"getNewFirstRechargeAwards",     --领取首冲奖励协议
	"reqredpacket", 				 --[6012][红包馈赠1026]领取红包馈赠
	"onlineWelfare",				 --在线福利
	"phoneBind", 				     --手机绑定
	"realNameCheck", 				 --实名认证
	"reqDragonTreasure", 		     --请求寻龙夺宝抽取
	"doubleEgg",					 --双旦活动
	"reqroyaltycollect", 			 --[4078]王权征收获取奖励
	"reqGetNewFoundsAwards",    	 --(新版成长基金)请求获取奖励
	"searchBeautyOne",				 --寻访美人，寻访一次
	"searchBeautyTen",				 --寻访美人，寻访十次
	"getBeauty",					--寻访美人，招募美人
	"reqNianAttack",				--年兽来袭
	"reqNianHurtGift",				--年兽来袭
	"reqNianHp",				    --年兽血量
	"reqnewroyaltycollect", 		--[4097]新王权征收获取奖励
	"equipmake",					--1036装备打造
	"reqFubenPassReward",			--[4101]1038副本推进奖励
	"reqPlayerLvUpReward",			--[4102]1039主公升级奖励
	"reqEquipRefineReward",			--[4103]1040装备洗炼奖励
	"blueequipmake", 				--[4104]1041蓝装打造
	"reqArtifactMakeReward",		--[4105]1042神器升级奖励
	"reqAttackVillage", 			--[4106][1043] 攻城拔寨领取奖励
	"monthweekcard",				--[4107][2025月卡周卡活动]领取奖励
	"sciencepromote", 				--科技兴国
	"sciencepromoteaward",			--科技兴国终极领取
	"reqNationPillars", 			--[4110][1044]国家栋梁领取奖励
	"reqZhouwangCountryRank",       --[4113][2028 纣王试炼获取国家积分排行]
	"reqZhouwangCountryPrize",		--[4115][2028 纣王试炼领取排行奖励]
	"reqZhouwangRankPrize",			--[4116][2028 纣王试炼领取国家奖励]
	"regressGet",					--[6420][回归签到1046]领取奖励
	"reqWelcomebackAwards",			--[4118]2030王者归来领取奖励
}

--显示永久活动 1 (没有倒计时)
--显示限购活动（剩余时间）2 （有倒计时）
--显示时间（剩余时间）3 （有倒计时）
e_ac_time_type = {
	forerver = 1,
	limit = 2,
	normal = 3,
}

--根据协议来注册消息
for k,v in pairs(tActSingleProtocol) do
	SocketManager:registerDataCallBack(v,function ( __type, __msg, __oldMsg )
		-- dump(__msg.body,"tActSingleProtocol",30)
		if __msg.head.state == SocketErrorType.success then
			--特殊处理(服务器传过来数据缺少其他活动相关的数据)
			if __msg.head.type == MsgType.reqWuWangExchange.id then
				if __msg.body.ext then
					local tActData = Player:getActById(e_id_activity.wuwang)
					if tActData and tActData.tExchangeMsg then
						local nId = __msg.body.ext.k
						local nExchanged = __msg.body.ext.v
						tActData.tExchangeMsg:setExchanged(nId, nExchanged)
						Player:getActRedNums()
						sendMsg(gud_refresh_activity) --通知刷新界面
					end
				end

				--奖励动画展示	--znftodo 以为有机会，重整		
				local tHero = nil
				for k, v in pairs(__msg.body.ob) do
					if v.k >= 200001 and v.k <= 299999 then
						tHero = copyTab(v)
						break
					end
				end
				if tHero then
					local tDataList = {}
					local tReward = {}
					tReward.d = {}
					tReward.g = {}
					table.insert(tReward.d, copyTab(tHero))
					table.insert(tReward.g, copyTab(tHero))
					table.insert(tDataList, tReward)

					--dump(tDataList, "tDataList", 100)
					--打开招募展示英雄对话框
				    local tObject = {}
				    tObject.nType = e_dlg_index.showheromansion --dlg类型
				    tObject.tReward = tDataList
				    tObject.nHandler = handler(self, function ( ... )
				    	-- body
				    	showGetAllItems(__msg.body.ob, 1)
				    end)
				    sendMsg(ghd_show_dlg_by_type,tObject)
				else
					--播放获得物品
					showGetAllItems(__msg.body.ob)
				end
			else
				Player:pushRefreshActData(__msg.body)
			end
			if __msg.head.type == MsgType.reqEnemySpeed.id then
				TOAST(getConvertedStr(7, 10225))
				if __oldMsg and __oldMsg[1] then
					local nType = __oldMsg[1]
					local nCell = nil 
					if nType == e_item_ids.kyjs then
						nCell = e_build_cell.tnoly
					else
						if __oldMsg[2] then
							nCell = __oldMsg[2]
						end
					end
	                -- 气泡点击响应
					local tOb = {}
					tOb.nCell = nCell
					sendMsg(ghd_build_bubble_clicktx_msg, tOb)
				end
			end
		else
			TOAST(SocketManager:getErrorStr(__msg.head.state))
		end
	end)
end




--刷新运营活动数据 
function Player:refreshActData( _tData, bDelOld)
	--dump(_tData.list,"_tData",100)
	if _tData and _tData.tl then		
		Player:getPlayerInfo().nFirstLogin = _tData.tl --第一次登录				
		-- Player:getPlayerInfo().nFirstLogin = 1 --第一次登录				
		if _tData.tl == 1 then
			saveLocalInfo("tuiyanTx"..Player:getPlayerInfo().pid,"0")--推演特效
		end
	end
	
	local tIds = {}
	if _tData and _tData.list then
		for k,v in pairs(_tData.list) do
			Player:addActDataByServer(v)
			if v.id then
				tIds[v.id] = true
			end
		end	
	end

    

	--删除旧数据
	if bDelOld then
		local tActDatas = Player:getActivitys()
		for i=#tActDatas,1, -1 do
			local nId = tActDatas[i].nId 
			if not tIds[nId] then
				table.remove(tActDatas,i)
			end
		end
	end

	--获取活动红点
	Player:getActRedNums()
	sendMsg(gud_refresh_activity) --通知刷新界面	
	-- sendMsg(gud_refresh_actlist) --移除活动模板a中的活动

	--dump(_tData.tl, "_tData.tl", 100)
	-- if _tData.tl then		
	-- 	Player:getPlayerInfo().nFirstLogin = _tData.tl --第一次登录				
	-- 	-- Player:getPlayerInfo().nFirstLogin = 1 --第一次登录				
	-- 	if _tData.tl == 1 then
	-- 		saveLocalInfo("tuiyanTx"..Player:getPlayerInfo().pid,"0")--推演特效
	-- 	end
	-- end


	-- dump(Player:getActivitys(),"Player:getActivitys()",30)

end

--根据id添加活动
function Player:addActDataByServer(_tData)
	if not _tData then
		return
	end
	local pActData = nil --活动数据
	if _tData.id  then
		pActData = Player:getActById(_tData.id) --单个活动
		if not pActData then
			if(tActivityDataList[_tData.id]) then
				pActData =  tActivityDataList[_tData.id]()
			else
				print("请注册tActivityDataList".._tData.id.."方法!!!!")
				return
			end
		end

	end

	if pActData then
		pActData:refreshDatasByServer(_tData)
		local bIsHave = false
		local tActDatas = Player:getActivitys()
		for k,v in pairs(tActDatas) do
			if v.nId ==pActData.nId then
				bIsHave = true
				break
			end
		end
		if not bIsHave then
			-- if (pActData.nId ~= e_id_activity.heromansion )then
			-- 	table.insert(Player:getActivitys(), pActData)
			-- end				
			table.insert(tActDatas, pActData)
		end				
	end				

end


--获取活动红点  用于活动入口的红点
function Player:getActRedNums()
	local nActANums = 0
	local nActBNums = 0

	local tActData = Player:getActivitys()

	if tActData then
		for k,v in pairs(tActData) do
			if v.nId  then
				if not tNoShowDict[v.nId] then
					if v.getRedNums then
						Player:getFirstRedNum(v)--获取第一次登录红点
						local nTyId = math.floor(tonumber(v.nId)/1000)
						if nTyId == 1 then
							if v:getRedNums() > 0 then
								nActANums = nActANums + 1
							end
						elseif nTyId == 2 then
							if v:getRedNums() > 0 then
								nActBNums = nActBNums + 1
							end
						-- elseif nTyId == 3 then--待添加
						-- 	
						end
					else
						myprint(v.sName.."..活动数据体未实现 getRedNums函数")
					end
				end
			end
		end
	end
	--记录登陆红点之后清除首次登陆状态
	if Player:getPlayerInfo().nFirstLogin == 1 then
		Player:getPlayerInfo().nFirstLogin = 0
	end
	if nActANums ~= Player.nActARedNums then
		local tObject = {} 
		tObject.nType = e_index_itemrl.r_hd --对联类型
		tObject.nRedType = 0 --红点类型
		tObject.nRedNums = nActANums--红点个数
		sendMsg(gud_refresh_homelr_red,tObject)
	end

	if nActBNums~= Player.nActBRedNums then
		local tObject = {} 
		tObject.nType = e_index_itemrl.r_fl--对联类型
		tObject.nRedType = 0--红点类型
		tObject.nRedNums = nActBNums--红点个数
		sendMsg(gud_refresh_homelr_red,tObject)
	end


	-- 活动a的红点数
	Player.nActARedNums   = nActANums  
	-- 活动b的红点数           
	Player.nActBRedNums   = nActBNums   

	return nActANums,nActBNums

end

--获取第一次登录红点
function Player:getFirstRedNum(_tData)
	local nRedNums = 0
	if _tData and _tData.nLoginState and _tData.nTips  then
		--if _tData.nLoginState == 0 and Player:getPlayerInfo().nFirstLogin  then
			--每天登录红点
			if _tData.nTips == 1 then				
				if Player:getPlayerInfo().nFirstLogin ==1 then
					--Player:getPlayerInfo().nFirstLogin = 0
					nRedNums = 1
					_tData.nLoginState = 1
					saveLocalInfo(_tData.nId..Player:getPlayerInfo().pid,"1")
				else
					--只登陆一次红点
					local nLocal = getLocalInfo(_tData.nId..Player:getPlayerInfo().pid,"1")
					nRedNums = tonumber(nLocal) 
					_tData.nLoginState =1
				end
			else
				if _tData.nLoginState == 0 then
					--只登陆一次红点
					local nLocal = getLocalInfo(_tData.nId..Player:getPlayerInfo().pid,"1")
					nRedNums = tonumber(nLocal) 
					_tData.nLoginState =1
				end
			end
			--记录第一次登录红点
			if _tData and _tData.nLoginRedNums then
				_tData.nLoginRedNums = nRedNums
			end
		--end
	end


	return nRedNums
end

--移除登录红点
function Player:removeFirstRedNums(_tData)

	if not _tData then
		return
	end

	if _tData.nLoginState and _tData.nLoginRedNums then
		if _tData.nLoginState ==1 then
			_tData.nLoginState = 2
			_tData.nLoginRedNums = 0
			saveLocalInfo(_tData.nId..Player:getPlayerInfo().pid,"0")
			Player:getActRedNums()--更新红点
		end
	end

end


--增加运营活动
function Player:addActData(_tData)
	if not _tData then
       return
	end


	Player:addActDataByServer(_tData)
	--获取活动红点
	Player:getActRedNums()
	sendMsg(gud_refresh_activity) --通知刷新界面
	sendMsg(gud_refresh_actlist) --移除活动模板a中的活动
end

--活动关闭操作
function Player:closeAct(_tData)
	if not _tData then
       return
	end

	Player:pushRefreshActData(_tData)

end


--活动移除操作
function Player:removeActById(_nId)
	if not _nId then
       return
	end

	local tActData = Player:getActivitys()
	if tActData and table.nums(tActData)>0 then
		local nActLong = table.nums(tActData)
		for i=nActLong,1,-1 do
			if tActData[i] and tActData[i].nId then
				if tActData[i].nId == _nId then
					table.remove(tActData, i)
				end
			end
		end
	end
	Player:getActRedNums()
	sendMsg(gud_refresh_activity) --通知刷新界面
	sendMsg(gud_refresh_actlist) --移除活动模板a中的活动


	-- dump(tActData,"tActData")

end

--活动零点推送
function Player:pushZeroActData(_tData)
	if not _tData then
       return
	end

	Player:refreshActData(_tData)

end

--根据推送,刷新本地数据
function Player:pushRefreshActData(_tData,_bIsZero)
	if not _tData then
       return
	end
	local bIsZero = _bIsZero or false
	-- dump(_tData,"pudhAct")
	local tActData = Player:getActivitys()
	if table.nums(tActData) > 0 then
		for k,v in pairs(tActData) do
			if _tData.id and (_tData.id == v.nId) then
				v:refreshDatasByServer(_tData)
				Player:getActRedNums()
				sendMsg(gud_refresh_activity) --通知刷新界面

				if _tData.ob and _tData.id == e_id_activity.developgift then
					showGetAllItems(_tData.ob)
				end
			end
		end
	end

	--零点推送
	if bIsZero then
		sendMsg(ghd_zero_act_push) --通知刷新界面
	end

end


--根据活动id获取活动数据
function Player:getActById(_nId)
	local tAct = nil
	if _nId then
		local tActList = Player:getActivitys()
		if tActList and table.nums(tActList)>0 then
			for k,v in pairs(tActList) do
				if v.nId == _nId then
					tAct = v
				end
			end
		end
	end
	return tAct
end

--获得活动模板a的活动 _nType 1 为模板a,2为模板b
function Player:getActModleList(_nType)
	local tList = {}
	if not _nType then
		return tList
	end
	-- local tNoShowDict = {
	-- 	[e_id_activity.specialsale] = true,
	-- 	[e_id_activity.newfirstrecharge] = true,
	-- 	[e_id_activity.tlboss] = true,
	-- 	[e_id_activity.exam] = true,
	-- 	[e_id_activity.mingjie] = true,
	-- }

	local tActData = Player:getActivitys()
	for k,v in pairs(tActData) do
		local nTyId = math.floor(tonumber(v.nId)/1000)
		if nTyId == _nType and tNoShowDict[v.nId] == nil then
			table.insert(tList, v)
		end
	end
	

	--排序
	if tList and #tList> 0 then
		table.sort( tList, function (a,b)
			return a.nOrder < b.nOrder
		end )
	end

	return tList
end



--获取所有活动数据
function Player:getActivitys()
	if Player.activity then
		return Player.activity
	else
		return {}
	end
end

--删除所有活动数据
function Player:clearAllActivitys(  )
	Player.activity = {}
end

--获取王权征收数据 特殊处理 王权征收的新旧版本同时应用在不同的服
function Player:getRoyaltyCollectData()
	-- body
	local pActData = Player:getActById(e_id_activity.royaltycollect)
	if not pActData then
		pActData = Player:getActById(e_id_activity.newroyaltycollect)
	end
	return pActData
end

-- --添加更改的新的标识信息
-- function Player:addActivityNew( sKey, sValue)
-- 	if Player.tActivityNew then
-- 		Player.tActivityNew[sKey] = sValue
-- 	end
-- end

-- --将新的标识注入
-- function Player:flushActivityNew( )
-- 	if Player.tActivityNew then
-- 		--注入
-- 		saveLocalInfoList(Player.tActivityNew)
-- 		Player.tActivityNew = {}
-- 	end
-- end

-- 初始化活动数据数据
function Player:initActivityInfo()
	Player.activity = {}
	Player.tActivityNew = {}
	return "Player.activitys"
end

-- 获取当前活动武王讨伐难度，默认为1
function Player:getWuWangDiff( )
	local tActData = Player:getActById(e_id_activity.wuwang)
	if tActData then
		return tActData.nDiff
	end
	return 1
end


--释放英雄基础数据
function Player:releaseActivityInfo(  )
	if Player.activity then
		Player.activity = nil
	end
	if Player.tActivityNew then
		Player.tActivityNew = nil
	end
	return "Player.activitys"
end
