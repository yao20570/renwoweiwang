--
-- Author: maheng
-- Date: 2017-10-31 11:30:29
-- 活动排行前三名显示层

local MCommonView = require("app.common.MCommonView")
local ItemActCard = require("app.layer.activitya.ItemActCard")

local ActivityRankTops = class("ActivityRankTops", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数
function ActivityRankTops:ctor()
	-- body
	self:myInit()

	parseView("lay_rank_tops", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ActivityRankTops",handler(self, self.onDestroy))
	
end

--初始化参数
function ActivityRankTops:myInit()
	self.tListData = {}
	self.tMyData = nil
	self.tCards = {}
	self.nHandlerGetPrize = nil
end

--解析布局回调事件
function ActivityRankTops:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	self:setupViews()
	self:updateViews()
end

--初始化控件
function ActivityRankTops:setupViews( )
	--ly 
	self.pLayRoot = self:findViewByName("lay_rank_tops")
	self.pLayTitle = self:findViewByName("lay_my_rank")
	self.pImgTitle = self:findViewByName("img_title")
	self.pImgTip = self:findViewByName("img_tip")

	self.pTxtDesc = MUI.MLabel.new({
		    text = "",
		    size = 20,
		    anchorpoint = cc.p(0, 1),
		    align = cc.ui.TEXT_ALIGN_LEFT,
			valign = cc.ui.TEXT_VALIGN_TOP,
		    color = cc.c3b(255, 255, 255),
		    dimensions = cc.size(492, 0),
		})
	self.pTxtDesc:setPosition(15, self.pLayRoot:getHeight() - 5)
	self.pLayRoot:addView(self.pTxtDesc, 10)
	setTextCCColor(self.pTxtDesc, _cc.pwhite)

	self.pLayBannerBg = self:findViewByName("lay_rank_tops")
	setMBannerImage(self.pLayBannerBg,TypeBannerUsed.phb3)	

	self.pLbMyRank = MUI.MLabelAtlas.new({text="0", 
        png="ui/atlas/v2_img_zjm_vipshuzi.png", pngw=15, pngh=28, scm=48})	
	self.pLbMyRank:setAnchorPoint(0, 0.5)
	self.pLbMyRank:setPosition(self.pImgTitle:getPositionX() + 10, self.pImgTitle:getPositionY())
    self.pLayTitle:addView(self.pLbMyRank, 10)

	self.pLayBtnRank = self:findViewByName("lay_btn_rank")
	self.pLayBtnPrize = self:findViewByName("lay_btn_prize")

	self.pBtnL = getCommonButtonOfContainer(self.pLayBtnRank, TypeCommonBtn.L_BLUE, getConvertedStr(6, 10448), false)
	self.pBtnL:onCommonBtnClicked(handler(self, self.checkRank))
	self.pBtnR = getCommonButtonOfContainer(self.pLayBtnPrize, TypeCommonBtn.L_YELLOW, getConvertedStr(6, 10447), false)
	self.pBtnR:onCommonBtnClicked(handler(self, self.checkPrize))

	local pLayRed = MUI.MLayer.new()
	pLayRed:setLayoutSize(20, 20)
	local x = self.pLayBtnPrize:getPositionX() + self.pLayBtnPrize:getWidth() - 15
	local y = self.pLayBtnPrize:getPositionY() + self.pLayBtnPrize:getHeight() - 15
	pLayRed:setPosition(x, y)
	self.pLayRoot:addView(pLayRed, 11)
	self.pLayBtnRed = pLayRed	
end

-- 修改控件内容或者是刷新控件数据
function ActivityRankTops:updateViews(  )
	-- body
	if self.tListData then
		for i = 1, 3 do
			if not self.tCards[i] then
				local pCard = ItemActCard.new(i)
				if i == 1 then
					pCard:setPosition(186, 230)
				elseif i == 2 then
					pCard:setPosition(36, 210)
				elseif i == 3 then
					pCard:setPosition(336, 210)
				end
				self.pLayRoot:addView(pCard, 10)
				self.tCards[i] = pCard
			end
			if self.tListData[i] then
				self.tCards[i]:setCurData(self.tListData[i])
			else
				self.tCards[i]:setCurData(nil)
			end
		end
	end	
	if self.tMyData and self.tMyData.x ~= 0  then
		self.pLbMyRank:setString(self.tMyData.x, false)		
		self.pImgTip:setVisible(false)
	else
		self.pLbMyRank:setString("", false)
		self.pImgTip:setVisible(true)
	end
	local pActivityData = Player:getActById(e_id_activity.sevenking)
	if not pActivityData then
		return
	end
	local sStr = pActivityData:getRankActTipsByRankType(self.nRankType)
	if sStr then
		self.pTxtDesc:setString(sStr, false)	
	else
		self.pTxtDesc:setString("", false)	
	end
	local Index = pActivityData:getActDataByRankType(self.nRankType)
	showRedTips(self.pLayBtnRed, 0, pActivityData:getRedNumsByIndex(Index))
end

--析构方法
function ActivityRankTops:onDestroy(  )
	-- body

end

--设置数据 _data
function ActivityRankTops:setCurData(_tData)
	self.tListData = {}
	self.tMyData = nil	
	self.nRankType = nil
	if _tData then
		if _tData.tListData then
			self.tListData = _tData.tListData
		end
		if _tData.tMyData then
			self.tMyData = _tData.tMyData
		end
		self.nRankType = _tData.nRankType or nil
	end	
	self:updateViews()
end

function ActivityRankTops:onGetPrizeBtnClick( pView )
	-- body	
	if self.nHandlerGetPrize then
		self.nHandlerGetPrize(self.pData)
	end
end

function ActivityRankTops:setGetPrizeHandler( _handler )
	-- body
	self.nHandlerGetPrize = _handler
end
--查看排行
function ActivityRankTops:checkRank(  )
	-- body
	--print("查看排行")
	if not self.nRankType then
		return
	end
	local tObject = {}	
	tObject.nType = e_dlg_index.dlgsevenkingrank
	tObject.nRankType = self.nRankType
	tObject.bSHowRank = 1
	sendMsg(ghd_show_dlg_by_type,tObject)		
end
--查看奖励
function ActivityRankTops:checkPrize(  )
	-- body
	--print("查看奖励")
	if not self.nRankType then
		return
	end
	local tObject = {}	
	tObject.nType = e_dlg_index.dlgsevenkingrank
	tObject.nRankType = self.nRankType
	tObject.bSHowRank = 0
	sendMsg(ghd_show_dlg_by_type,tObject)		
end

return ActivityRankTops

