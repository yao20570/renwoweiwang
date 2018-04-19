----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-10-24 16:12:57
-- Description: 纣王试炼
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local ZhouWangShiLian = class("ZhouWangShiLian", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

function ZhouWangShiLian:ctor( _tSize )
    self:setContentSize(_tSize)
	--解析文件
	parseView("lay_zhouwangshilian", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ZhouWangShiLian:onParseViewCallback( pView )
	--self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ZhouWangShiLian", handler(self, self.onZhouWangShiLianDestroy))

	--请求排行榜信息
	SocketManager:sendMsg("getRankData", {e_rank_type.wuwang_kill, 1})
end

-- 析构方法
function ZhouWangShiLian:onZhouWangShiLianDestroy(  )
    self:onPause()
end

function ZhouWangShiLian:regMsgs(  )
	regMsg(self, gud_refresh_rankinfo, handler(self, self.updateRankListView))
end

function ZhouWangShiLian:unregMsgs(  )
	unregMsg(self, gud_refresh_rankinfo)
end

function ZhouWangShiLian:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function ZhouWangShiLian:onPause(  )
	self:unregMsgs()
end

function ZhouWangShiLian:setupViews(  )
	-- local pLayBtn = self:findViewByName("kill_btn")
	-- local pRankBtn = getCommonButtonOfContainer(pLayBtn ,TypeCommonBtn.L_BLUE, getConvertedStr(3, 10480))
	-- pRankBtn:onCommonBtnClicked(handler(self, self.onRankClicked))

	self.pTxtMyRank = self:findViewByName("txt_my_rank")

	local pLayCallBtn = self:findViewByName("lay_call_btn")
	local pCallBtn = getCommonButtonOfContainer(pLayCallBtn ,TypeCommonBtn.L_YELLOW, getConvertedStr(3, 10481))
	pCallBtn:onCommonBtnClicked(handler(self, self.onCallClicked))
	
	local tGoods = getGoodsByTidFromDB(100155)
	local pLayGoods = self:findViewByName("lay_goods")
	getIconGoodsByType(pLayGoods, TypeIconGoods.NORMAL, type_icongoods_show.item, tGoods)

	local pTxtGoodsName = self:findViewByName("txt_goods_name")
	pTxtGoodsName:setString(getConvertedStr(3, 10481))

	self.pTxtCost = self:findViewByName("txt_goods_cost")

	self.pLayContent =self:findViewByName("lay_content")

	-- local pHeroImg=creatHeroView("i200641_")
	-- self.pLayContent:addView(pHeroImg)
 --    centerInView(self.pLayContent,pHeroImg)
end

function ZhouWangShiLian:updateViews(  )
	--消耗
	local nCostNum = 1
	local nCurrNum = getMyGoodsCnt(100154) + getMyGoodsCnt(100155) + getMyGoodsCnt(100172)
	local sColor = _cc.green
	if nCurrNum < nCostNum then
		sColor = _cc.red
	end
	local tStr = {
	    {color=_cc.white,text= getConvertedStr(3, 10442) },
	    {color=sColor,text=nCostNum},
	    {color=_cc.white,text="/"..tostring(nCurrNum)}, 
	}
	self.pTxtCost:setString(tStr)
end

function ZhouWangShiLian:onRankClicked( )
	local tObject = {
	    nType = e_dlg_index.wuwangkillrank,
	}
	sendMsg(ghd_show_dlg_by_type, tObject)
end

function ZhouWangShiLian:onCallClicked( )
	sendMsg(ghd_world_dot_near_my_city, {nDotType = e_type_builddot.null, bIsClicked = true,nJumpType=e_jumpto_world_type.activity})
   	closeDlgByType(e_dlg_index.wuwang, false)
   	closeDlgByType(e_dlg_index.actmodelb, false)
end

--更新列表
function ZhouWangShiLian:updateRankListView( )
	local tRank = Player:getRankInfo():getRankDataList()
	if not tRank then
		return 
	end
	self.tRank = tRank
	--
	--我的排名
	local nMyRank = nil
	for i=1,#self.tRank do
		if self.tRank[i].i == Player:getPlayerInfo().pid then
			nMyRank = self.tRank[i].x
			break
		end
	end
	if nMyRank then
		local tStr = {
		    {color=_cc.pwhite,text= getConvertedStr(3, 10495) },
		    {color=_cc.white,text=tostring(nMyRank)},
		}
		self.pTxtMyRank:setString(tStr)
	else
		local tStr = {
		    {color=_cc.pwhite,text= getConvertedStr(3, 10495) },
		    {color=_cc.red,text=getConvertedStr(3, 10303)},
		}
		self.pTxtMyRank:setString(tStr)
	end
end

return ZhouWangShiLian



