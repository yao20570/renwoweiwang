----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-02-06 17:41:00
-- Description: 限时Boss排行
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemTLBossRank = require("app.layer.tlboss.ItemTLBossRank")
local TLBossRank = class("TLBossRank", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

local e_type_tab = {
	harm = 1,
	hitNum = 2,
}

function TLBossRank:ctor( _tSize )
    self:setContentSize(_tSize)
	--解析文件
	parseView("layout_tboss_rank", handler(self, self.onParseViewCallback))
end

--解析界面回调
function TLBossRank:onParseViewCallback( pView )
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()
	self:selectTab(e_type_tab.harm)

	--注册析构方法
	self:setDestroyHandler("TLBossRank", handler(self, self.onTLBossRankDestroy))
end

-- 析构方法
function TLBossRank:onTLBossRankDestroy(  )
    self:onPause()
end

function TLBossRank:regMsgs(  )
	regMsg(self, gud_tlboss_data_refresh, handler(self, self.refreshSubView))
end

function TLBossRank:unregMsgs(  )
	unregMsg(self, gud_tlboss_data_refresh)
end

function TLBossRank:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function TLBossRank:onPause(  )
	self:unregMsgs()
end

function TLBossRank:setupViews(  )
	local pTxtTab1 = self:findViewByName("txt_tab1")
	pTxtTab1:setString(getConvertedStr(3, 10808))
	local pTxtTab2 = self:findViewByName("txt_tab2")
	pTxtTab2:setString(getConvertedStr(3, 10809))
	self.pLayTab1 = self:findViewByName("lay_tab1")
	self.pLayTab1:setViewTouched(true)
	self.pLayTab1:setIsPressedNeedScale(false)
	self.pLayTab1:setIsPressedNeedColor(false)
	self.pLayTab1:onMViewClicked(function ( _pView )
	    self:selectTab(e_type_tab.harm)
	end)
	self.pLayTab2 = self:findViewByName("lay_tab2")
	self.pLayTab2:setViewTouched(true)
	self.pLayTab2:setIsPressedNeedScale(false)
	self.pLayTab2:setIsPressedNeedColor(false)
	self.pLayTab2:onMViewClicked(function ( _pView )
	    self:selectTab(e_type_tab.hitNum)
	end)

	local pTxtTitle1 = self:findViewByName("txt_title1")
	pTxtTitle1:setString(getConvertedStr(3, 10483))
	local pTxtTitle2 = self:findViewByName("txt_title2")
	pTxtTitle2:setString(getConvertedStr(3, 10806))
	local pTxtTitle3 = self:findViewByName("txt_title3")
	pTxtTitle3:setString(getConvertedStr(3, 10484))
	self.pTxtTitle4 = self:findViewByName("txt_title4")

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

function TLBossRank:updateViews(  )
end

--选择tab
function TLBossRank:selectTab( nIndex )
	if self.nCurrTab ~= nIndex then
		self.nCurrTab = nIndex
		if self.nCurrTab == e_type_tab.harm then
			self.pTxtTitle4:setString(getConvertedStr(3, 10810))
			self.pLayTab1:setBackgroundImage("#v2_btn_selected_hkoyp.png",{scale9 = true,capInsets=cc.rect(65,26, 1, 1)})
			self.pLayTab2:setBackgroundImage("#v2_btn_biaoqian_hkoyp.png",{scale9 = true,capInsets=cc.rect(65,26, 1, 1)})
		else
			self.pTxtTitle4:setString(getConvertedStr(3, 10811))
			self.pLayTab1:setBackgroundImage("#v2_btn_biaoqian_hkoyp.png",{scale9 = true,capInsets=cc.rect(65,26, 1, 1)})
			self.pLayTab2:setBackgroundImage("#v2_btn_selected_hkoyp.png",{scale9 = true,capInsets=cc.rect(65,26, 1, 1)})
		end
		self:refreshSubView()
	end
end

--请求排行数据
function TLBossRank:reqRankData( )
	SocketManager:sendMsg("reqTLBossRank", {})
end

--更新列表
function TLBossRank:updateListView( )
	if self.nCurrTab == e_type_tab.harm then
		self.tListData = Player:getTLBossData():getHarmRankList()
	else
		self.tListData = Player:getTLBossData():getHitNumRankList()
	end	
	if not self.tListData then
		return
	end
	local nCnt = #self.tListData
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
		        pTempView = ItemTLBossRank.new()  
		        pTempView:setHandler(handler(self, self.onRankItemClick)) 
		    end
		    pTempView:setCurData(self.nCurrTab, self.tListData[_index], _index)
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

function TLBossRank:refreshSubView( )
	self:updateListView()
	self:updateMyRankInfo()
end

--自己的排行信息
function TLBossRank:updateMyRankInfo( )
	local nMyRank = nil
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
		self.nMyHarmRank = nMyRank
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
		self.nMyHitNumRank = nMyRank
	end

end


function TLBossRank:onShareClicked(  )
	local nMyRank = self.nMyHarmRank
	local sHarmRank = ""
	if nMyRank and nMyRank > 0 then
		sHarmRank = tostring(nMyRank)
	else
		sHarmRank = getConvertedStr(3, 10303)--未上榜
	end

	local nMyRank = self.nMyHitNumRank
	local sHitNumRank = ""
	if nMyRank and nMyRank > 0 then
		sHitNumRank = tostring(nMyRank)
	else
		sHitNumRank = getConvertedStr(3, 10303)--未上榜
	end
	openShare(self.pLayShare, e_share_id.tlboss_rank, {sHarmRank, sHitNumRank})
end

--_tData:BossRankVo
function TLBossRank:onRankItemClick( _tData )
	if not _tData then
		return
	end
	local pMsgObj = {}
	pMsgObj.nplayerId = _tData.nPlayerId
	pMsgObj.bToChat = false
	--发送获取其他玩家信息的消息
	sendMsg(ghd_get_playerinfo_msg, pMsgObj)
end



return TLBossRank



