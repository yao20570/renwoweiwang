----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-03-27 13:48:00
-- Description: 皇城战排行
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemEpwAwardRank = require("app.layer.epw.ItemEpwAwardRank")
local EpwAwardRank = class("EpwAwardRank", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function EpwAwardRank:ctor( _tSize )
	--解析文件
	self:setContentSize(_tSize)
	parseView("layout_epw_award_rank", handler(self, self.onParseViewCallback))
end

--解析界面回调
function EpwAwardRank:onParseViewCallback( pView )
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("EpwAwardRank", handler(self, self.onEpwAwardRankDestroy))
end

-- 析构方法
function EpwAwardRank:onEpwAwardRankDestroy(  )
    self:onPause()
end

function EpwAwardRank:regMsgs(  )
	regMsg(self, gud_refresh_rankinfo, handler(self, self.updateMyRank))
	regMsg(self, gud_imperialwar_score_refresh, handler(self, self.updateScore))
end

function EpwAwardRank:unregMsgs(  )
	unregMsg(self, gud_refresh_rankinfo)
	unregMsg(self, gud_imperialwar_score_refresh)
end

function EpwAwardRank:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function EpwAwardRank:onPause(  )
	self:unregMsgs()
end

function EpwAwardRank:setupViews(  )
	self.pTxtMyRank = self:findViewByName("txt_my_rank")
	self.pTxtMyScore = self:findViewByName("txt_my_score")
	self.pLayList = self:findViewByName("lay_listview")

	--分享按钮
	local pLayShare = self:findViewByName("lay_btn_share")
	local pBtnShare = getCommonButtonOfContainer(pLayShare, TypeCommonBtn.M_BLUE, getConvertedStr(3, 10003))
	pBtnShare:onCommonBtnClicked(handler(self, self.onShareClicked))
	setMCommonBtnScale(pLayShare, pBtnShare, 0.8)
	self.pLayShare = pLayShare
end

function EpwAwardRank:updateViews(  )
	self.tListData = getEpangWarInitData("perAward")
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
		        pTempView = ItemEpwAwardRank.new()  
		    end
		    pTempView:setData(self.tListData[_index])
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

	self:updateScore()
	self:updateMyRank()
end

--分享按钮
function EpwAwardRank:onShareClicked(  )
	local nMyRank = self.nMyHarmRank
	local sHarmRank = ""
	if nMyRank and nMyRank > 0 then
		sHarmRank = tostring(nMyRank)
	else
		sHarmRank = getConvertedStr(3, 10303)--未上榜
	end
	openShare(self.pLayShare, e_share_id.imperwar_rank, {sHarmRank})
end

--更新积分
function EpwAwardRank:updateScore(  )
	--更新我的积分
	self.nMyScore =  Player:getImperWarData():getMyWarScore()
	local tStr = {
	    {color=_cc.pwhite,text=getConvertedStr(3, 10931)},
	    {color=_cc.green,text=getResourcesStr(self.nMyScore)}, 
	}
	self.pTxtMyScore:setString(tStr)
end

--更新我的排名
function EpwAwardRank:updateMyRank(  )
	local nMyRank = nil
	local tRankInfo = Player:getRankInfo()
	if tRankInfo then
		nMyRank = tRankInfo.nMyRank
	end
	self.nMyHarmRank = nMyRank
	local sScore = ""
	if nMyRank and nMyRank > 0 then
		sScore = tostring(nMyRank)
	else
		sScore = getConvertedStr(3, 10303)--未上榜
	end
	local tStr = {
	    {color=_cc.pwhite,text=getConvertedStr(3, 10495)},
	    {color=_cc.white,text=sScore}, 
	}
	self.pTxtMyRank:setString(tStr)
end


return EpwAwardRank


