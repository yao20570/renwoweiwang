----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-03-27 09:45:00
-- Description: 决战阿房宫排行
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemEpwRank = require("app.layer.epw.ItemEpwRank")
local RankListView = require("app.common.listview.RankListView")
local EpwRank = class("EpwRank", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

function EpwRank:ctor( _tSize )
    self:setContentSize(_tSize)
	--解析文件
	parseView("layout_epw_rank", handler(self, self.onParseViewCallback))
end

--解析界面回调
function EpwRank:onParseViewCallback( pView )
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("EpwRank", handler(self, self.onEpwRankDestroy))
end

-- 析构方法
function EpwRank:onEpwRankDestroy(  )
    self:onPause()
end

function EpwRank:regMsgs(  )
	regMsg(self, gud_refresh_rankinfo, handler(self, self.updateMyRank))
	regMsg(self, gud_imperialwar_score_refresh, handler(self, self.updateScore))
end

function EpwRank:unregMsgs(  )
	unregMsg(self, gud_refresh_rankinfo)
	unregMsg(self, gud_imperialwar_score_refresh)
end

function EpwRank:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function EpwRank:onPause(  )
	self:unregMsgs()
end

function EpwRank:setupViews(  )
	local pTxtTitle1 = self:findViewByName("txt_title1")
	pTxtTitle1:setString(getConvertedStr(3, 10483))
	local pTxtTitle2 = self:findViewByName("txt_title2")
	pTxtTitle2:setString(getConvertedStr(3, 10806))
	local pTxtTitle3 = self:findViewByName("txt_title3")
	pTxtTitle3:setString(getConvertedStr(3, 10484))
	local pTxtTitle4 = self:findViewByName("txt_title4")
	pTxtTitle4:setString(getConvertedStr(3, 10485))

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

function EpwRank:updateViews(  )
	self:updateScore()
	self:updateMyRank()
end

--切换界面时重新请求数据
function EpwRank:reqNewData( )
	--请求我的积分数据
	SocketManager:sendMsg("reqImperWarMyScore", {}, nil)
	--请求排行榜数据
	if self.pRankList then
		self.pRankList:reqMoreListData(1)
	else
		local pLayList = self.pLayList
		local tSize = pLayList:getContentSize()
		self.pRankList = RankListView.new(tSize)
		self.pRankList:setData(e_rank_type.imperialwar, handler(self, self.getRankItem))
		self.pRankList:reqMoreListData(1)
		pLayList:addView(self.pRankList)
	end
end

function EpwRank:getRankItem(  )
	return ItemEpwRank.new()
end

--更新我的排名
function EpwRank:updateMyRank(  )
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

--更新积分
function EpwRank:updateScore(  )
	--更新我的积分
	self.nMyScore =  Player:getImperWarData():getMyWarScore()
	local tStr = {
	    {color=_cc.pwhite,text=getConvertedStr(3, 10931)},
	    {color=_cc.green,text=getResourcesStr(self.nMyScore)}, 
	}
	self.pTxtMyScore:setString(tStr)
end


--分享按钮
function EpwRank:onShareClicked(  )
	local nMyRank = self.nMyHarmRank
	local sHarmRank = ""
	if nMyRank and nMyRank > 0 then
		sHarmRank = tostring(nMyRank)
	else
		sHarmRank = getConvertedStr(3, 10303)--未上榜
	end
	openShare(self.pLayShare, e_share_id.imperwar_rank, {sHarmRank})
end


return EpwRank



