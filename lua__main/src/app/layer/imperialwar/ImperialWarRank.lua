----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-03-16 18:10:00
-- Description: 皇城战 排行榜
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemImperialWarRank = require("app.layer.imperialwar.ItemImperialWarRank")
local RankListView = require("app.common.listview.RankListView")

local ImperialWarRank = class("ImperialWarRank", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

function ImperialWarRank:ctor(  )
	--解析文件
	parseView("layout_imperial_war_rank", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ImperialWarRank:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ImperialWarRank", handler(self, self.onImperialWarRankDestroy))
end

-- 析构方法
function ImperialWarRank:onImperialWarRankDestroy(  )
    self:onPause()
end

function ImperialWarRank:regMsgs(  )
	regMsg(self, gud_refresh_rankinfo, handler(self, self.updateMyRank))
	regMsg(self, gud_imperialwar_score_refresh, handler(self, self.updateScore))

end

function ImperialWarRank:unregMsgs(  )
	unregMsg(self, gud_refresh_rankinfo)
	unregMsg(self, gud_imperialwar_score_refresh)
end

function ImperialWarRank:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function ImperialWarRank:onPause(  )
	self:unregMsgs()
end

function ImperialWarRank:setupViews(  )
	self.pTxtMyRank = self:findViewByName("txt_my_rank")
	self.pTxtMyScore = self:findViewByName("txt_my_score")

	--分享按钮
	local pLayShare = self:findViewByName("lay_btn_share")
	self.pLayShare = pLayShare
	local pBtnShare = getCommonButtonOfContainer(pLayShare, TypeCommonBtn.M_BLUE, getConvertedStr(3, 10003))
	pBtnShare:onCommonBtnClicked(handler(self, self.onShareClicked))
	setMCommonBtnScale(pLayShare, pBtnShare, 0.8)

	local pTxtTitle1 = self:findViewByName("txt_rank_title1")
	pTxtTitle1:setString(getConvertedStr(3, 10483))
	local pTxtTitle2 = self:findViewByName("txt_rank_title2")
	pTxtTitle2:setString(getConvertedStr(3, 10720))
	local pTxtTitle3 = self:findViewByName("txt_rank_title3")
	pTxtTitle3:setString(getConvertedStr(3, 10484))
	local pTxtTitle4 = self:findViewByName("txt_rank_title4")
	pTxtTitle4:setString(getConvertedStr(3, 10485))

	self.pLayList = self:findViewByName("lay_listview")

	if b_close_imperialwar then
		local pLayTop = self:findViewByName("lay_top")
		pLayTop:setVisible(false)
		local pLayRankTitle = self:findViewByName("lay_rank_title")
		pLayRankTitle:setVisible(false)
		--没有数据提示
		local tLabel = {
		    str = getConvertedStr(3, 10220),
		}
		local pNullUi = getLayNullUiImgAndTxt(tLabel)
		pNullUi:setIgnoreOtherHeight(true)
		self:addView(pNullUi,9)
		centerInView(self, pNullUi)
	end
end

function ImperialWarRank:updateViews(  )
	self:updateScore()
end

function ImperialWarRank:getRankItem(  )
	return ItemImperialWarRank.new()
end

--更新我的排名
function ImperialWarRank:updateMyRank(  )
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

--更新我的积分
function ImperialWarRank:updateScore(  )
	self.nMyScore = Player:getImperWarData():getMyWarScore()
	local tStr = {
	    {color=_cc.pwhite,text=getConvertedStr(3, 10931)},
	    {color=_cc.white,text=tostring(self.nMyScore)}, 
	}
	self.pTxtMyScore:setString(tStr)
end


--切换界面时重新请求数据
function ImperialWarRank:reqNewData( )
	if b_close_imperialwar then
    else
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
end

--分享按钮
function ImperialWarRank:onShareClicked(  )
	local nMyRank = self.nMyHarmRank
	local sHarmRank = ""
	if nMyRank and nMyRank > 0 then
		sHarmRank = tostring(nMyRank)
	else
		sHarmRank = getConvertedStr(3, 10303)--未上榜
	end
	openShare(self.pLayShare, e_share_id.imperwar_rank, {sHarmRank})
end

return ImperialWarRank



