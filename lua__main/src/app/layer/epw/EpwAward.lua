----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-03-27 10:22:00
-- Description: 皇城战奖励
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local EpwAwardRank = require("app.layer.epw.EpwAwardRank")
local EpwAwardStage = require("app.layer.epw.EpwAwardStage")
local EpwAward = class("EpwAward", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

local e_type_tab = {
	rank = 1, --排名奖励
	stage = 2,--阶段奖励
}

function EpwAward:ctor( _tSize )
    self:setContentSize(_tSize)
	--解析文件
	parseView("layout_epw_award", handler(self, self.onParseViewCallback))
end

--解析界面回调
function EpwAward:onParseViewCallback( pView )
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()
	self:selectTab(e_type_tab.rank)

	--注册析构方法
	self:setDestroyHandler("EpwAward", handler(self, self.onEpwAwardDestroy))
end

-- 析构方法
function EpwAward:onEpwAwardDestroy(  )
    self:onPause()
end

function EpwAward:regMsgs(  )
	regMsg(self, ghd_refresh_epw_award_state, handler(self, self.refershAwardState))
end

function EpwAward:unregMsgs(  )
	unregMsg(self, ghd_refresh_epw_award_state)
end

function EpwAward:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function EpwAward:onPause(  )
	self:unregMsgs()

end

function EpwAward:setupViews(  )
	local pTxtTab1 = self:findViewByName("txt_tab1")
	pTxtTab1:setString(getConvertedStr(3, 10962))
	local pTxtTab2 = self:findViewByName("txt_tab2")
	pTxtTab2:setString(getConvertedStr(3, 10963))
	self.pLayTab1 = self:findViewByName("lay_tab1")
	self.pLayTab2 = self:findViewByName("lay_tab2")
	
	self.pLayTab1:setViewTouched(true)
	self.pLayTab1:setIsPressedNeedScale(false)
	self.pLayTab1:setIsPressedNeedColor(false)
	self.pLayTab1:onMViewClicked(function ( _pView )
	    self:selectTab(e_type_tab.rank)
	end)
	self.pLayTab2 = self:findViewByName("lay_tab2")
	self.pLayTab2:setViewTouched(true)
	self.pLayTab2:setIsPressedNeedScale(false)
	self.pLayTab2:setIsPressedNeedColor(false)
	self.pLayTab2:onMViewClicked(function ( _pView )
	    self:selectTab(e_type_tab.stage)
	end)

	self.pLayList = self:findViewByName("lay_listview")

	self.pLayBtnAwardRank = self:findViewByName("lay_btn1")
	self.pBtnAwardRank = getCommonButtonOfContainer(self.pLayBtnAwardRank, TypeCommonBtn.L_YELLOW, getConvertedStr(3, 10213))
	self.pBtnAwardRank:onCommonBtnClicked(handler(self, self.onGetAwardRankClicked))

	self.pLayBtnAwardStage = self:findViewByName("lay_btn2")
	self.pBtnAwardStage = getCommonButtonOfContainer(self.pLayBtnAwardStage, TypeCommonBtn.L_YELLOW, getConvertedStr(3, 10213))
	self.pBtnAwardStage:onCommonBtnClicked(handler(self, self.onGetAwardStageClicked))
end

function EpwAward:updateViews(  )
end

--选择tab
function EpwAward:selectTab( nIndex )
	if self.nCurrTab ~= nIndex then
		self.nCurrTab = nIndex
		if self.nCurrTab == e_type_tab.rank then
			self.pLayTab1:setBackgroundImage("#v2_btn_selected_hkoyp.png",{scale9 = true,capInsets=cc.rect(65,26, 1, 1)})
			self.pLayTab2:setBackgroundImage("#v2_btn_biaoqian_hkoyp.png",{scale9 = true,capInsets=cc.rect(65,26, 1, 1)})
		else
			self.pLayTab1:setBackgroundImage("#v2_btn_biaoqian_hkoyp.png",{scale9 = true,capInsets=cc.rect(65,26, 1, 1)})
			self.pLayTab2:setBackgroundImage("#v2_btn_selected_hkoyp.png",{scale9 = true,capInsets=cc.rect(65,26, 1, 1)})
		end
		if self.nCurrTab == e_type_tab.rank then
			if self.pEpwAwardStage then
				self.pEpwAwardStage:setVisible(false)
			end
			if self.pEpwAwardRank then
				self.pEpwAwardRank:setVisible(true)
			else
				local tSize = self.pLayList:getContentSize()
				self.pEpwAwardRank = EpwAwardRank.new(tSize)
				self.pLayList:addView(self.pEpwAwardRank)
				centerInView(self.pLayList, self.pEpwAwardRank)
			end
		else
			if self.pEpwAwardRank then
				self.pEpwAwardRank:setVisible(false)
			end
			if self.pEpwAwardStage then
				self.pEpwAwardStage:setVisible(true)
			else
				local tSize = self.pLayList:getContentSize()
				self.pEpwAwardStage = EpwAwardStage.new(tSize)
				self.pLayList:addView(self.pEpwAwardStage)
				centerInView(self.pLayList, self.pEpwAwardStage)
			end
		end
		self:refershAwardState()
	end
end

--切换界面时重新请求数据
function EpwAward:reqNewData( )
	--请求我的积分数据
	SocketManager:sendMsg("reqImperWarMyScore", {}, nil)
	SocketManager:sendMsg("getRankData", {e_rank_type.imperialwar, 1, 15}, nil)
end

--获取排行榜奖励
function EpwAward:onGetAwardRankClicked(  )
	self:sendGetAward(1)
end

--获取阶段奖励
function EpwAward:onGetAwardStageClicked(  )
	self:sendGetAward(2)
end

--获取奖励
--1.领取排行奖励 2领取阶段奖励
function EpwAward:sendGetAward( nId )
	SocketManager:sendMsg("reqGetEpwAward", {nId}, function(__msg, __oldMsg)
        if __msg.head.state == SocketErrorType.success then 
            if __msg.head.type == MsgType.reqGetEpwAward.id then
            	if nId == 1 then
                	Player:getImperWarData():setRankAward(e_epwaward_state.got)
                elseif nId == 2 then
                	Player:getImperWarData():setStageAward(e_epwaward_state.got)
                end
                showGetAllItems(__msg.body.ob)
                TOAST(getConvertedStr(3, 10968))
            end
        else
            TOAST(SocketManager:getErrorStr(__msg.head.state))
        end
    end)

end

--更新按钮
function EpwAward:updateBtnAwardRank(  )
	if Player:getImperWarData():getIsRankAward() then
		self.pLayBtnAwardRank:setVisible(true)
	else
		self.pLayBtnAwardRank:setVisible(false)
	end
end

--更新按钮
function EpwAward:updateBtnAwardStage(  )
	if Player:getImperWarData():getIsStageAward() then
		self.pLayBtnAwardStage:setVisible(true)
	else
		self.pLayBtnAwardStage:setVisible(false)
	end
end

--更新红点信息和按钮信息
function EpwAward:refershAwardState(  )
	--红点
	if Player:getImperWarData():getIsRankAward() then
		showRedTips(self.pLayTab1, 0, 1, 2)
	else
		showRedTips(self.pLayTab1, 0, 0, 2)
	end

	if Player:getImperWarData():getIsStageAward() then
		showRedTips(self.pLayTab2, 0, 1, 2)
	else
		showRedTips(self.pLayTab2, 0, 0, 2)
	end

	--按钮
	if self.nCurrTab == e_type_tab.rank then
		self.pLayBtnAwardStage:setVisible(false)
		self:updateBtnAwardRank()
	else
		self.pLayBtnAwardRank:setVisible(false)
		self:updateBtnAwardStage()
	end
end


return EpwAward



