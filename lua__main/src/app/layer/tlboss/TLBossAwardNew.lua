----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-02-06 17:41:00
-- Description: 限时Boss奖励
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemTLBossAwardNew = require("app.layer.tlboss.ItemTLBossAwardNew")
local TLBossAwardNew = class("TLBossAwardNew", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

local e_type_tab = {
	harm = 1,
	num = 2,
}

function TLBossAwardNew:ctor( _tSize, nTypeTab )
	self.nCurrTab = nTypeTab
	self.nRankTime = 2--tonumber(getBossInitData("rankTime"))/1000
    self:setContentSize(_tSize)
	--解析文件
	parseView("layout_tboss_award_new", handler(self, self.onParseViewCallback))
end

--解析界面回调
function TLBossAwardNew:onParseViewCallback( pView )
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("TLBossAwardNew", handler(self, self.onTLBossAwardNewDestroy))
end

-- 析构方法
function TLBossAwardNew:onTLBossAwardNewDestroy(  )
    self:onPause()
end

function TLBossAwardNew:regMsgs(  )
end

function TLBossAwardNew:unregMsgs(  )
end

function TLBossAwardNew:onResume(  )
	self:regMsgs()
	self:updateViews()
	regUpdateControl(self, handler(self, self.updateCd))
end

function TLBossAwardNew:onPause(  )
	self:unregMsgs()
	unregUpdateControl(self)

end

function TLBossAwardNew:setupViews(  )
	self.pTxtMyRank = self:findViewByName("txt_my_rank")
	self.pTxtMyHarm = self:findViewByName("txt_my_harm")

	self.pLayList = self:findViewByName("lay_listview")

	--分享按钮
	local pLayShare = self:findViewByName("lay_btn_share")
	local pBtnShare = getCommonButtonOfContainer(pLayShare, TypeCommonBtn.M_BLUE, getConvertedStr(3, 10003))
	pBtnShare:onCommonBtnClicked(handler(self, self.onShareClicked))
	setMCommonBtnScale(pLayShare, pBtnShare, 0.8)
	self.pLayShare = pLayShare
end

function TLBossAwardNew:updateViews(  )
	self:updateMyRankInfo()
	self:updateListView()
end

--更新列表
function TLBossAwardNew:updateListView(  )
	if not self.nCurrTab then
		return
	end
	--伤害排行榜
	if self.nCurrTab == e_type_tab.harm then
		self.tAwards = clone(getBossInitData("hurtRankAwards"))
		local sKillDrop = getBossInitData("killDrop") 
		local tData = luaSplit(sKillDrop, ":")
		if tData then
			local nDropId = tonumber(tData[2])
			if nDropId then
				local tKillDrop = getDropById(nDropId)
				if tKillDrop then
					table.insert(self.tAwards, 1, {tKillDrop = tKillDrop})
				end
			end
		end
	else
		--次数排行榜
		self.tAwards = getBossInitData("fightRankAwards")
	end	
	if not self.tAwards then
		return
	end
	local nCnt = #self.tAwards
	if not self.pListView then
		self.pListView = MUI.MListView.new {
            bgColor = cc.c4b(255, 255, 255, 250),
            viewRect = cc.rect(0, 0, self.pLayList:getWidth(), self.pLayList:getHeight()),
            itemMargin = {left =  0,
            right =  0,
            top = 0,
            bottom =  0},
            direction = MUI.MScrollView.DIRECTION_VERTICAL,
        }
        self.pLayList:addView(self.pListView)	
	    self.pListView:setItemCallback(function ( _index, _pView ) 	    	
		 	local pTempView = _pView
		    if pTempView == nil then
		        pTempView = ItemTLBossAwardNew.new()  
		    end

		    local bIsLastHit = false
		    local tBossRankVo = nil
		    if self.nCurrTab == e_type_tab.harm then
		    	if _index == 1 then
		    		bIsLastHit = true
		    	else
		    		tBossRankVo = self.tListData[_index - 1]
		    	end
		    else
		    	tBossRankVo = self.tListData[_index]
		    end


		    pTempView:setCurData(self.nCurrTab, self.tAwards[_index], tBossRankVo, bIsLastHit)
		    return pTempView
		end)
		--上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)			
		self.pListView:setItemCount(nCnt)
		self.pListView:reload(false)		
	else
		self.pListView:notifyDataSetChange(false, nCnt)		
	end
end

--自己的排行信息
function TLBossAwardNew:updateMyRankInfo( )
	local nMyRank = nil
	if self.nCurrTab == e_type_tab.harm then
		self.tListData = Player:getTLBossData():getHarmRankList()
	else
		self.tListData = Player:getTLBossData():getHitNumRankList()
	end	
	if self.tListData then
		for i=1,#self.tListData do
			if self.tListData[i]:getPlayerId() == Player:getPlayerInfo().pid then
				nMyRank = i
				break
			end
		end
	end
	if self.nCurrTab == e_type_tab.harm then --伤害排行
		local sScore = ""
		if nMyRank and nMyRank > 0 then
			sScore = tostring(nMyRank)
		else
			sScore = getConvertedStr(3, 10303)--未上榜
		end
		self.pTxtMyRank:setString(getConvertedStr(3, 10495)..sScore)

		local nMyHarm = Player:getTLBossData():getMyHarm()
		local tStr = {
		    {color=_cc.pwhite,text=getConvertedStr(3, 10718)},
		    {color=_cc.green,text=getResourcesStr(nMyHarm)}, 
		}
		self.pTxtMyHarm:setString(tStr)
	else
		local sScore = ""
		if nMyRank and nMyRank > 0 then
			sScore = tostring(nMyRank)
		else
			sScore = getConvertedStr(3, 10303)--未上榜
		end
		self.pTxtMyRank:setString(getConvertedStr(3, 10495)..sScore)

		local nMyHitNum = Player:getTLBossData():getMyHitNum()
		local tStr = {
		    {color=_cc.pwhite,text=getConvertedStr(3, 10819)},
		    {color=_cc.green,text=nMyHitNum}, 
		}
		self.pTxtMyHarm:setString(tStr)
	end
end

function TLBossAwardNew:onShareClicked(  )
	local nMyHarmRank = nil
	local tListData = Player:getTLBossData():getHarmRankList()
	for i=1,#tListData do
		if tListData[i]:getPlayerId() == Player:getPlayerInfo().pid then
			nMyHarmRank = i
			break
		end
	end
	local sHarmRank = ""
	if nMyHarmRank and nMyHarmRank > 0 then
		sHarmRank = tostring(nMyHarmRank)
	else
		sHarmRank = getConvertedStr(3, 10303)--未上榜
	end

	local nMyHitNumRank = nil
	local tListData = Player:getTLBossData():getHitNumRankList()
	for i=1,#tListData do
		if tListData[i]:getPlayerId() == Player:getPlayerInfo().pid then
			nMyHitNumRank = i
			break
		end
	end
	local sHitNumRank = ""
	if nMyHitNumRank and nMyHitNumRank > 0 then
		sHitNumRank = tostring(nMyHitNumRank)
	else
		sHitNumRank = getConvertedStr(3, 10303)--未上榜
	end
		
	openShare(self.pLayShare, e_share_id.tlboss_rank, {sHarmRank, sHitNumRank})
end

--每2秒更新一次排行榜
function TLBossAwardNew:updateCd(  )
	if self.bIsReqing then
		return
	end
	--两秒请求一次排名
	local bIsReq = false
	if self.nReqTLBossRankTime then
		local nTime = getSystemTime()
		if nTime - self.nReqTLBossRankTime >= self.nRankTime then
			bIsReq = true
		end
	else
		bIsReq = true
	end
	if bIsReq then
		self.bIsReqing = true
		SocketManager:sendMsg("reqTLBossRank", {}, function()
			self.bIsReqing = false
			self.nReqTLBossRankTime = getSystemTime()
		end)
	end
end

return TLBossAwardNew



