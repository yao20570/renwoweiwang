----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-10-24 21:35:17
-- Description: 武王击杀排行 子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local IconGoods = require("app.common.iconview.IconGoods")

local ItemWuWangKillRank = class("ItemWuWangKillRank", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemWuWangKillRank:ctor(  )
	--解析文件
	parseView("item_wuwangkillrank", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemWuWangKillRank:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemWuWangKillRank", handler(self, self.onItemWuWangKillRankDestroy))
end

-- 析构方法
function ItemWuWangKillRank:onItemWuWangKillRankDestroy(  )
    self:onPause()
end

function ItemWuWangKillRank:regMsgs(  )
end

function ItemWuWangKillRank:unregMsgs(  )
end

function ItemWuWangKillRank:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function ItemWuWangKillRank:onPause(  )
	self:unregMsgs()
end

function ItemWuWangKillRank:setupViews(  )
	self.pTxtRank = self:findViewByName("txt_rank")
	self.pTxtName = self:findViewByName("txt_name")
	self.pTxtScore = self:findViewByName("txt_score")
	self.pLayGoodsView = self:findViewByName("lay_goods_view")
end

function ItemWuWangKillRank:updateViews(  )
	if not self.tData then
		return
	end

	--当前排名
	local nRank = self.tData.x
	self.pTxtRank:setString(nRank)

	-- 
	self.pTxtName:setString(self.tData.n)	


	self.pTxtScore:setString(self.tData.qa)	


	--奖励列表
	local tGoodList = nil
	-- local tRankAward = getAwakeInitData("rankAward")
	-- for i=1,#tRankAward do
	-- 	if tRankAward[i].nRank1 <= nRank and nRank <= tRankAward[i].nRank2 then
	-- 		tGoodList = tRankAward[i].tGoodsList
	-- 		break
	-- 	end
	-- end
	local tActData = Player:getActById(e_id_activity.wuwang)
	if tActData then
		local tRangeAwardVO = tActData:getRangeAwardVo(nRank)
		if tRangeAwardVO then
			tGoodList = {}
			for i=1,#tRangeAwardVO.tAward do
				local nGoodsId = tRangeAwardVO.tAward[i].k
				local nCt = tRangeAwardVO.tAward[i].v
				if nGoodsId and nCt then
					table.insert(tGoodList, {nGoodsId = nGoodsId, nCt = nCt})
				end
			end
		end
	end

	
	self.tGoodList = tGoodList
	if self.tGoodList then
		local nCurrCount = #self.tGoodList
		self.pLayGoodsView:setVisible(true)
		--容错
		if not self.pListView then
			
			local pLayGoods = self.pLayGoodsView
		    self.pListView = MUI.MListView.new {
		        viewRect   = cc.rect(0, 0, pLayGoods:getContentSize().width, pLayGoods:getContentSize().height),
		        direction  = MUI.MScrollView.DIRECTION_HORIZONTAL,
		        itemMargin = {left = 2,
		            right =  5,
		            top = 6,
		            bottom = 0},
		    }
		    pLayGoods:addView(self.pListView)
		    centerInView(pLayGoods, self.pListView )
			self.pListView:setItemCallback(handler(self, self.onGoodsListViewCallBack))
			self.pListView:setItemCount(nCurrCount)
			self.pListView:reload(true)
		else
			self.pListView:notifyDataSetChange(true, nCurrCount)
			local oldY = self.pListView.container:getPositionY()
			self.pListView:scrollTo(0, oldY, false)
		end
	else
		self.pLayGoodsView:setVisible(false)
	end
end

--列表项回调
function ItemWuWangKillRank:onGoodsListViewCallBack( _index, _pView )
	-- body
	local tTempData = self.tGoodList[_index]
	local nGoodsId = tTempData.nGoodsId
    local nCt = tTempData.nCt
    local tGoods = getGoodsByTidFromDB(nGoodsId)
    local pIcon = nil
    local pTempView = _pView
	if pTempView == nil then
		pTempView = MUI.MLayer.new()
		pTempView:setContentSize(108*0.6, 80)		
		pIcon = getIconGoodsByType(pTempView, TypeIconGoods.NORMAL, type_icongoods_show.item, tGoods)
		pIcon:setIconIsCanTouched(true)		
		pIcon:setPositionY(10)		
    else
    	pIcon = getIconGoodsByType(pTempView, TypeIconGoods.NORMAL, type_icongoods_show.item, tGoods)
    	pIcon:setCurData(tGoods) 
    end
	pIcon:setNumber(nCt)
	pIcon:setScale(0.6)
	return pTempView
end
--排行榜信息
function ItemWuWangKillRank:setData( tData )
	self.tData = tData
	self:updateViews()
end

return ItemWuWangKillRank


