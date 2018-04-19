-----------------------------------------------------
-- author: zhangnianfeng
-- updatetime:  2018-02-06 20:32:0 星期二
-- Description: 伤害排名
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local e_type_tab = {
	harm = 1,
	num = 2,
}

local ItemTLBossAward = class("ItemTLBossAward", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemTLBossAward:ctor( )
	-- body	
	self:myInit()	
	parseView("item_tboss_award_new", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemTLBossAward:myInit()
end

--解析布局回调事件
function ItemTLBossAward:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemTLBossAward",handler(self, self.onItemTLBossAwardDestroy))
end

--初始化控件
function ItemTLBossAward:setupViews( )
	self.pTxtTitle = self:findViewByName("txt_title")
	self.pListView = self:findViewByName("lay_listview")
	self.pTxtOwner = self:findViewByName("txt_owner")
	self.pLayBtnGet = self:findViewByName("lay_btn_get")
	local pBtnGet = getCommonButtonOfContainer(self.pLayBtnGet, TypeCommonBtn.L_YELLOW, getConvertedStr(3, 10213))
	pBtnGet:onCommonBtnClicked(handler(self, self.onGetBtnClicked))
end

-- 修改控件内容或者是刷新控件数据
function ItemTLBossAward:updateViews( )
	if not self.tData then
		return
	end
	if self.tData.tKillDrop then
		self.pTxtTitle:setString(getConvertedStr(3, 10836))
	elseif self.tData.nRank then
		self.pTxtTitle:setString(string.format(getConvertedStr(3, 10818), self.tData.nRank))
	end
	gRefreshHorizontalList(self.pListView, self.tGoodsList, 10, 35)


	--tab标签，物品数据
	local nCountry = nil
	local sName = nil
	local sValue = nil
	if self.nTab == e_type_tab.harm then
		if self.bIsLastHit then
			nCountry = Player:getTLBossData():getLastCountry()
			sName = Player:getTLBossData():getLastName()
		else
			if self.tBossRankVo then
				nCountry = self.tBossRankVo:getCountry()
				sName = self.tBossRankVo:getName()
				sValue = getResourcesStr(self.tBossRankVo:getHarm())
			end
		end
	else
		if self.tBossRankVo then
			nCountry = self.tBossRankVo:getCountry()
			sName = self.tBossRankVo:getName()
			sValue = self.tBossRankVo:getHitNum()
		end
	end

	if nCountry and sName then
		if sValue then
			local tStr = {
			    {color=getColorByCountry(nCountry) ,text=getCountryShortName(nCountry)},
			    {color=_cc.white,text=getSpaceStr(1)..sName},
			    {color=_cc.green,text=getSpaceStr(1)..sValue},
			}
			self.pTxtOwner:setString(tStr)
		else
			local tStr = {
			    {color=getColorByCountry(nCountry) ,text=getCountryShortName(nCountry)},
			    {color=_cc.white,text=getSpaceStr(1)..sName},
			}
			self.pTxtOwner:setString(tStr)
		end
		self.pTxtOwner:setVisible(true)
	else
		self.pTxtOwner:setVisible(false)
	end

	if self.bIsLastHit then
		--Integer	领取伤害排行奖励 0不可领取 1可以领取 2已经领取
		local nState = Player:getTLBossData():getTk()
		if nState == e_tlboss_award.get then
			self.pLayBtnGet:setVisible(true)
		else
			self.pLayBtnGet:setVisible(false)
		end
	else
		if self.tBossRankVo and self.tBossRankVo:getPlayerId() == Player:getPlayerInfo().pid then
			if self.nTab == e_type_tab.harm then
			     --Integer	领取次数排行奖励 0不可领取 1可以领取 2已经领取
				local nState = Player:getTLBossData():getTh()
				if nState == e_tlboss_award.get then
					self.pLayBtnGet:setVisible(true)
				else
					self.pLayBtnGet:setVisible(false)
				end
			else
				--	Integer	领取最终击杀奖励 0不可领取 1可以领取 2已经领取
				local nState = Player:getTLBossData():getTf() 
				if nState == e_tlboss_award.get then
					self.pLayBtnGet:setVisible(true)
				else
					self.pLayBtnGet:setVisible(false)
				end
			end
		else
			self.pLayBtnGet:setVisible(false)
		end
	end
end

-- 析构方法
function ItemTLBossAward:onItemTLBossAwardDestroy( )
end

function ItemTLBossAward:setCurData( nTab, tData, tBossRankVo, bIsLastHit)
	self.nTab = nTab
	self.bIsLastHit = bIsLastHit
	self.tData = tData
	self.tBossRankVo = tBossRankVo
	self.tGoodsList = {}
	if self.tData then
		if self.tData.tKillDrop then
			self.tGoodsList = self.tData.tKillDrop
		elseif self.tData.tGoods then
			for i=1,#self.tData.tGoods do
				local k = self.tData.tGoods[i].k
				local v = self.tData.tGoods[i].v
				local tGoods = getGoodsByTidFromDB(k)
				if tGoods then
					tGoods.nCt = v
					table.insert(self.tGoodsList, tGoods)
				end
			end
		end
	end
	self:updateViews()
end

function ItemTLBossAward:onGetBtnClicked( )
	if self.bIsLastHit then
		SocketManager:sendMsg("reqGetFinalKillAward",{})
	elseif self.nTab == e_type_tab.harm then
		SocketManager:sendMsg("reqGetHarmRankAward",{})
	elseif self.nTab == e_type_tab.num then
		SocketManager:sendMsg("reqGetHitNumRankAward",{})
	end
end

return ItemTLBossAward