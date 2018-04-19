-----------------------------------------------------
-- author: liangzhaowei
-- Date: 2017-06-21 11:51:21
-- Description: 活动模板a
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")

local DlgActivityModelA = class("DlgActivityModelA", function()
	-- body
	return DlgBase.new(e_dlg_index.actmodela)
end)

function DlgActivityModelA:ctor(nActID)
	-- body
	self:myInit(nActID)

	self:setTitle(getConvertedStr(5, 10195))--游戏活动
	parseView("dlg_activity_modle", handler(self, self.onParseViewCallback))


	self:refreshData()
	self:updateViews()
	self:onResume()
	
	--注册析构方法
	self:setDestroyHandler("DlgActivityModelA",handler(self, self.onDestroy))
end

--初始化成员变量
function DlgActivityModelA:myInit(nActID)
	self.tActListName = {}	--活动列表名称
	self.tActList     = {}  --活动列表
	self.nSelectTab = 1 --当前所选择的活动
	self.nActID = nActID    --默认进来选择的活动
end

--刷新数据
function DlgActivityModelA:refreshData()
	--获得活动列表
	self.tActListName = {}
	self.tActList = Player:getActModleList(1)	--活动列表
	--特惠礼包入口
	local tTGiftData = Player:getTriggerGiftData()
	if tTGiftData and tTGiftData:getIsHasTpackInCd2() then
		local tActData = {
			nId = e_id_activity.triggergift,
			sName = getConvertedStr(3, 10576),
			bIsEnter = true,
		}
		table.insert(self.tActList, tActData)
	end

	if self.tActList and table.nums(self.tActList)> 0 then
		for k,v in pairs(self.tActList) do
			if v.sName then
				table.insert(self.tActListName,v.sName)
			end
		end
	end
end

--根据活动ID获取对应的索引值
function DlgActivityModelA:getActIndexByID( nActId )
	-- body
	if not nActId then
		return 1
	end
	local nidx = 1	
	if self.tActList and #self.tActList > 0 then
		for k, v in pairs(self.tActList) do
			if v.nId == nActId then
				nidx = k
				break
			end
		end
	end
	return nidx
end

--解析布局回调事件
function DlgActivityModelA:onParseViewCallback( pView )
	-- body
	self.pView = pView
	self:addContentView(pView) --加入内容层
	self:setupViews()

end

--初始化控件
function DlgActivityModelA:setupViews( )

	self.pLayTab= self:findViewByName("ly_tab")
end

--创建listView
function DlgActivityModelA:createListView()
	-- listview tab
	-- self.pTabListView = createNewListView(self.pLyTabList)
	local pSize = self.pLyTabList:getContentSize()
	self.pTabListView = MUI.MListView.new {
			viewRect   = cc.rect(0, 0, pSize.width, pSize.height ),
			direction  = MUI.MScrollView.DIRECTION_VERTICAL,
			itemMargin = {left =  0,
	            right =  0,
	            top =  0, 
	            bottom =  0},
	    }
	self.pLyTabList:addView(self.pTabListView,11,9999)
	self.pTabListView:setBounceable(true) --是否回弹
	self.pTabListView:setItemCount(table.nums(self.tActListName))
	self.pTabListView:setItemCallback(handler(self, self.onTabEveryCallback))
	--上下箭头
	-- local pUpArrow, pDownArrow = getUpAndDownArrow("#v2_img_huodongshangxiafanjiantou.png")
	-- print("DlgActivityModelA 111",pDownArrow:getWidth())
	
	-- self.pTabListView:setUpAndDownArrow(pUpArrow, pDownArrow, true)
	-- local pSize = self.pLayTab:getContentSize()
	
	-- pUpArrow:setPosition(pSize.width/2, pSize.height -pUpArrow:getHeight()/2 )
	-- -- local pParent = self.pLyTabList:getParent()
	-- self.pLayTab:addView(pUpArrow, 999)
	-- pDownArrow:setPosition(pSize.width/2, pDownArrow:getHeight()/2 )
	-- self.pLayTab:addView(pDownArrow, 999)

	self.pTabListView:reload()
end

-- 没帧回调 _index 下标 _pView 视图
function DlgActivityModelA:onTabEveryCallback( _index, _pView )
	local pView = _pView
	if not pView then
		if self.tActListName[_index] then
			local ItemServerTab = require("app.layer.serverlist.ItemServerTab")
			pView = ItemServerTab.new()
			pView:setHandler(handler(self, self.clickTabItem))
		end
	end

	if _index and self.tActListName[_index] then
		pView:setCurData(self.tActListName[_index],_index,self.nSelectTab)	
		if self.tActList[_index].bIsEnter then
			--只是入口不处理
		else
			pView:setRedNums(self.tActList[_index])
		end
	end

	return pView
end


--点击引导item回调
function DlgActivityModelA:clickTabItem(_pData)
	if _pData then
		if self.nSelectTab ~= _pData then
			self.nSelectTab = _pData
	    	--重新获取服务器列表数据
	    	self.pTabListView:notifyDataSetChange(false)
	    	if self.tActList[self.nSelectTab] then
	    		self:createActLayer(self.tActList[self.nSelectTab])
	    	else
	    		if  self.tActList[1] then
	    			self:createActLayer(self.tActList[1])
	    		end
	    	end
		end
	end
end

function DlgActivityModelA:createActLayer(_pData)

	if not _pData then
		return
	end

	local pLayer = self.pLyContent:findViewByTag(83223)
	if pLayer then
		pLayer:removeFromParent(true)
		pLayer = nil
	end	

	if not pLayer then
		if _pData.nId  then
			local pActLayer = nil
			if _pData.nId == e_id_activity.expeditefuben then --副本掉落
				local ItemExpediteFuben = require("app.layer.activitya.expeditefuben.ItemExpediteFuben")
				pActLayer = ItemExpediteFuben.new(_pData.nId)
			elseif _pData.nId == e_id_activity.countryfight then--国战排行活动
				local ItemCountryFight = require("app.layer.activitya.countryfight.ItemCountryFight")
				pActLayer = ItemCountryFight.new(_pData.nId)
			elseif _pData.nId == e_id_activity.enemydrawing then --乱军图纸
				local ItemEnemyDrawing = require("app.layer.activitya.enemydrawing.ItemEnemyDrawing")
				pActLayer = ItemEnemyDrawing.new(_pData.nId)
			elseif _pData.nId == e_id_activity.expediteworkshop then --工坊加速
				local ItemExpediteWorkshop = require("app.layer.activitya.expediteworkshop.ItemExpediteWorkshop")
				pActLayer = ItemExpediteWorkshop.new(_pData.nId)
			elseif _pData.nId == e_id_activity.enemyresource then --乱军资源
				local ItemEnemyResource = require("app.layer.activitya.enemyresource.ItemEnemyResource")
				pActLayer = ItemEnemyResource.new(_pData.nId)
			elseif _pData.nId == e_id_activity.expeditenemy then --乱军加速
				local IremExpeditEnemy = require("app.layer.activitya.expeditenemy.IremExpeditEnemy")
				pActLayer = IremExpeditEnemy.new(_pData.nId)
			elseif _pData.nId == e_id_activity.doublecollect then --采集翻倍
				local ItemDoubleCollect = require("app.layer.activitya.doublecollect.ItemDoubleCollect")
				pActLayer = ItemDoubleCollect.new(_pData.nId)
			elseif _pData.nId == e_id_activity.giftrecharge then   --礼包兑换
				local ItemGiftRecharge = require("app.layer.activitya.giftrecharge.ItemGiftRecharge")
				pActLayer = ItemGiftRecharge.new(_pData.nId)
			elseif _pData.nId == e_id_activity.doubleexp then   --翻倍经验
				local ItemDoubleExp = require("app.layer.activitya.doubleexp.ItemDoubleExp")
				pActLayer = ItemDoubleExp.new(_pData.nId)
			elseif _pData.nId == e_id_activity.enemyremoval then   --乱军迁城
				local ItemEnemyRemoval = require("app.layer.activitya.enemyremoval.ItemEnemyRemoval")
				pActLayer = ItemEnemyRemoval.new(_pData.nId)
			elseif _pData.nId == e_id_activity.expediteproducts then   --物产加速
				local ItemExpediteProducts = require("app.layer.activitya.expediteproducts.ItemExpediteProducts")
				pActLayer = ItemExpediteProducts.new(_pData.nId)
			elseif _pData.nId == e_id_activity.nanbeiwar then --南征北战
				local ItemNanBeiWar = require("app.layer.activitya.nanbeiwar.ItemNanBeiWar")
				pActLayer = ItemNanBeiWar.new(_pData.nId)
			elseif _pData.nId == e_id_activity.forgerank then--锻造排行活动
				local ItemForgeRank = require("app.layer.activitya.forgerank.ItemForgeRank")
				pActLayer = ItemForgeRank.new(_pData.nId)
			elseif _pData.nId == e_id_activity.armyrank then--兵力排行活动
				local ItemArmyRank = require("app.layer.activitya.armyrank.ItemArmyRank")
				pActLayer = ItemArmyRank.new(_pData.nId)
			elseif _pData.nId == e_id_activity.sevendaylog then --七天登录
				local ItemSevenDayLog = require("app.layer.activitya.sevendaylog.ItemSevenDayLog")
				pActLayer = ItemSevenDayLog.new(_pData.nId)
			elseif _pData.nId == e_id_activity.succinctrank then--洗练排行活动
				local ItemSuccinct = require("app.layer.activitya.succinctrank.ItemSuccinct")
				pActLayer = ItemSuccinct.new(_pData.nId)	
			elseif _pData.nId == e_id_activity.foodstore then--洗练排行活动
				local ItemFoodStore = require("app.layer.activitya.foodstore.ItemFoodStore")
				pActLayer = ItemFoodStore.new(_pData.nId)
			elseif _pData.nId == e_id_activity.ironstore then
				local ItemIronStore = require("app.layer.activitya.ironstore.ItemIronStore")
				pActLayer = ItemIronStore.new(_pData.nId)	
			elseif 	_pData.nId == e_id_activity.cityfight then		
				local ItemCityFight = require("app.layer.activitya.cityfight.ItemCityFight")	
				pActLayer = ItemCityFight.new(_pData.nId)	
			elseif _pData.nId == e_id_activity.consumegift then --消费好礼
				local ItemConsumeGift = require("app.layer.activitya.consumegift.ItemConsumeGift")
				pActLayer = ItemConsumeGift.new(_pData.nId)
			elseif _pData.nId == e_id_activity.totalrecharge then --累积充值
				local ItemTotalRecharge = require("app.layer.activitya.totalrecharge.ItemTotalRecharge")
				pActLayer = ItemTotalRecharge.new(_pData.nId)
			elseif _pData.nId == e_id_activity.dayrebate then --每日返利
				local ItemDayRebate = require("app.layer.activitya.dayrebate.ItemDayRebate")
				pActLayer = ItemDayRebate.new(_pData.nId)
			elseif _pData.nId == e_id_activity.eatchicken then --每日吃鸡
				local ItemEatChicken = require("app.layer.activitya.eatchicken.ItemEatChicken")
				pActLayer = ItemEatChicken.new(_pData.nId)
			elseif _pData.nId == e_id_activity.sevenking then --七日为王
				local ItemSevenKing = require("app.layer.activitya.sevenking.ItemSevenKing")
				pActLayer = ItemSevenKing.new(_pData.nId)
			elseif _pData.nId == e_id_activity.redpacket then --红包馈赠
				local ItemRedPacket = require("app.layer.activitya.redpacket.ItemRedPacket")
				pActLayer = ItemRedPacket.new(_pData.nId)
			elseif _pData.nId == e_id_activity.phonebind then --手机绑定
				local ItemPhoneBind = require("app.layer.activitya.phonebind.ItemPhoneBind")
				pActLayer = ItemPhoneBind.new(_pData.nId)	
			elseif _pData.nId == e_id_activity.realnamecheck then --实名认证
				local ItemRealNameCheck = require("app.layer.activitya.realnamecheck.ItemRealNameCheck")
				pActLayer = ItemRealNameCheck.new(_pData.nId)	
			elseif _pData.nId == e_id_activity.freecall then --免费召唤
				local ItemFreeCall = require("app.layer.activitya.freecall.ItemFreeCall")
				pActLayer = ItemFreeCall.new(_pData.nId)	
			elseif _pData.nId == e_id_activity.magiccrit then --免费召唤
				local ItemMagicCrit = require("app.layer.activitya.magiccrit.ItemMagicCrit")
				pActLayer = ItemMagicCrit.new(_pData.nId)	
			elseif _pData.nId == e_id_activity.palacecollect then --免费召唤
				local ItemPalaceCollect = require("app.layer.activitya.palacecollect.ItemPalaceCollect")
				pActLayer = ItemPalaceCollect.new(_pData.nId)
			elseif _pData.nId == e_id_activity.doubleegg then --双旦活动
				local ItemDoubleEgg = require("app.layer.activitya.doubleegg.ItemDoubleEgg")
				pActLayer = ItemDoubleEgg.new(_pData.nId)
			elseif	_pData.nId == e_id_activity.energydiscount then --体力折扣
				local ItemEnergyDiscount = require("app.layer.activitya.energydiscount.ItemEnergyDiscount")
				pActLayer = ItemEnergyDiscount.new(_pData.nId)
			elseif	_pData.nId == e_id_activity.onlinewelfare then --在线福利
				local ItemOnlineWelfare = require("app.layer.activitya.onlinewelfare.ItemOnlineWelfare")
				pActLayer = ItemOnlineWelfare.new(_pData.nId)							
			elseif	_pData.nId == e_id_activity.rechargesign then --充值签到
				local ItemRechargeSign = require("app.layer.activitya.rechargesign.ItemRechargeSign")
				pActLayer = ItemRechargeSign.new(_pData.nId)										
			elseif  _pData.nId == e_id_activity.triggergift then --特惠礼包
				local ItemTriggerGiftAct = require("app.layer.activitya.triggergift.ItemTriggerGiftAct")
				pActLayer = ItemTriggerGiftAct.new(_pData.nId)
			elseif  _pData.nId == e_id_activity.packetgift then  --特惠礼包(送审用)
				local ItemPacketGiftAct = require("app.layer.activitya.packetgift.ItemPacketGiftAct")
				pActLayer = ItemPacketGiftAct.new(_pData.nId)
			elseif 	_pData.nId == e_id_activity.equipmake then   --装备打造
				local ItemEquipMake = require("app.layer.activitya.equipmake.ItemEquipMake")
				pActLayer = ItemEquipMake.new(_pData.nId)
			elseif 	_pData.nId == e_id_activity.fubenpass then   --副本推进
				local ItemFubenPass = require("app.layer.activitya.fubenpass.ItemFubenPass")
				pActLayer = ItemFubenPass.new(_pData.nId)
			elseif 	_pData.nId == e_id_activity.playerlvup then   --主公升级
				local ItemPlayerLvUp = require("app.layer.activitya.playerlvup.ItemPlayerLvUp")
				pActLayer = ItemPlayerLvUp.new(_pData.nId)
			elseif 	_pData.nId == e_id_activity.equiprefine then   --装备洗炼
				local ItemEquipRefine = require("app.layer.activitya.equiprefine.ItemEquipRefine")
				pActLayer = ItemEquipRefine.new(_pData.nId)
			elseif 	_pData.nId == e_id_activity.artifactmake then   --神器升级
				local ItemArtifactMake = require("app.layer.activitya.artifactmake.ItemArtifactMake")
				pActLayer = ItemArtifactMake.new(_pData.nId)				
			elseif  _pData.nId == e_id_activity.blueequipmake then --蓝装打造
				local ItemBlueEquipMake = require("app.layer.activitya.blueequipmake.ItemBlueEquipMake")
				pActLayer = ItemBlueEquipMake.new(_pData.nId)
			elseif  _pData.nId == e_id_activity.attackvillage then  --攻城拔寨
				local ItemAttackVillage = require("app.layer.activitya.attackvillage.ItemAttackVillage")
				pActLayer = ItemAttackVillage.new(_pData.nId)
			elseif  _pData.nId == e_id_activity.herocollect then  --武将收集
				local ItemHeroCollect = require("app.layer.activitya.herocollect.ItemHeroCollect")
				pActLayer = ItemHeroCollect.new(_pData.nId)
			elseif  _pData.nId == e_id_activity.nationpillars then  --国家栋梁
				local ItemNationPillars = require("app.layer.activitya.nationpillars.ItemNationPillars")
				pActLayer = ItemNationPillars.new(_pData.nId)
			elseif  _pData.nId == e_id_activity.regress then  --回归有礼
				local ItemRegress = require("app.layer.activitya.regress.ItemRegress")
				pActLayer = ItemRegress.new(_pData.nId)
			end
			if pActLayer then
				self.pLyContent:addView(pActLayer, 1,83223)
				pActLayer:setData(_pData)
				if _pData.bIsEnter then
					--只是入口不处理
				else
				 	Player:removeFirstRedNums(_pData)--移除第一次登录红点
				 	_pData:setNewLocal() --移除新的标识
				end
			    --刷新列表中的红点
			    if  self.pTabListView then
			    	self.pTabListView:notifyDataSetChange(true)
			    end
			end
		end
	end


	-- local pLayer = self.pLyContent:findViewByTag(83223)
	-- if pLayer then
	-- 	local nType = pLayer:getType()
	-- 	dump(nType,"nType")
	-- 	if _pData.nUIType and (nType == _pData.nUIType) and (nType==1)  then
	-- 		pLayer:setCurData(_pData)
	-- 	else
	-- 		pLayer:removeFromParent(true)
	-- 		pLayer = nil
	-- 	end
	-- end

	-- if not pLayer then
	-- 	if _pData.nId  then
	-- 		local pActLayer = nil
	-- 		if _pData.nId == e_id_activity.expeditefuben then --副本掉落
	-- 			pActLayer = ItemExpediteFuben.new(_pData.nId)
	-- 		end

	-- 		if pActLayer then
	-- 			pActLayer:setData(_pData)
	-- 			self.pLyContent:addView( pActLayer, 1, 83223 )
	-- 		end
	-- 	end
	-- end

end


--获取当前选择活动数据
function DlgActivityModelA:getSelectActData()
	local pData = {}
	if self.tActList[self.nSelectTab] then
		pData = self.tActList[self.nSelectTab] 
	end

	return pData
end


-- 修改控件内容或者是刷新控件数据
function DlgActivityModelA:updateViews(  )


	gRefreshViewsAsync(self, 6, function ( _bEnd, _index )
		if(_index == 1) then

			--ly
			if not self.pLyTabList then
				self.pLyTabList     			= 		self.pView:findViewByName("ly_tab_list")
				self.pLyContent 			    = 		self.pView:findViewByName("ly_content")

				self:createListView()

				self.nSelectTab = self:getActIndexByID(self.nActID)
				if self.tActList and self.tActList[self.nSelectTab] then
					self:createActLayer(self.tActList[self.nSelectTab])
					if table.nums(self.tActList)>11 and self.pTabListView then
						self.pTabListView:scrollToPosition(self.nSelectTab, false)
					end
				end	
			end

			self:refreshData()


			-- self:clickTabItem(self.nSelectTab)

			local nCount = table.nums(self.tActListName) or 0
			if self.pTabListView and self.tActListName then
				self.pTabListView:setItemCount(nCount)
				self.pTabListView:notifyDataSetChange(true)
			end
		-- elseif _index == 3 then
		end
	end)


end


-- 析构方法
function DlgActivityModelA:onDestroy(  )
	-- body
	self:onPause()

	--更新本地进入信息
	-- Player:flushActivityNew()

end

-- 注册消息
function DlgActivityModelA:regMsgs( )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
	regMsg(self, gud_refresh_actlist, handler(self, self.refreshlist))
	regMsg(self, gud_trigger_gift_list_refresh, handler(self, self.refreshTriggerGift))

end

-- 注销消息
function DlgActivityModelA:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
	unregMsg(self, gud_refresh_actlist)
	unregMsg(self, gud_trigger_gift_list_refresh)
end


--暂停方法
function DlgActivityModelA:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgActivityModelA:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	
end

--刷新活动界面
function DlgActivityModelA:refreshlist()
	self:clickTabItem(1)
end

--刷新特惠礼包入口
function DlgActivityModelA:refreshTriggerGift(  )
	self:updateViews()
	if self.tActList[self.nSelectTab] then
		if self.tActList[self.nSelectTab].nId == e_id_activity.triggergift then
			local tTriGiftList = Player:getTriggerGiftData():getTpackListInCd2()
			if #tTriGiftList == 0 then
				self:clickTabItem(1)
			end
		end
	end
end

function DlgActivityModelA:jumpToLayerByActId(_nId )
	-- body

	local nSelectTab= self:getActIndexByID(_nId)
	print("secttab",nSelectTab)
	self:clickTabItem(nSelectTab)

end

return DlgActivityModelA