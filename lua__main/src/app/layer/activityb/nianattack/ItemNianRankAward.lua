-----------------------------------------------------
-- author: zhangnianfeng
-- updatetime:  2017-05-17 15:05:40 星期三
-- Description: 排名奖励
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local IconGoods = require("app.common.iconview.IconGoods")
local ItemNianRankAward = class("ItemNianRankAward", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemNianRankAward:ctor( )
	-- body	
	self:myInit()	
	parseView("item_nian_award", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemNianRankAward:myInit()
end

--解析布局回调事件
function ItemNianRankAward:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemNianRankAward",handler(self, self.onItemNianRankAwardDestroy))
end

--初始化控件
function ItemNianRankAward:setupViews( )
	self.pTxtTitle = self:findViewByName("txt_title")
	local pLayItems = self:findViewByName("lay_goods")
	self.tGoodsList = {}
	local nX, nY, nOffsetX = 10, 0, 100
	for i=1,4 do
		local pIconView = IconGoods.new(TypeIconGoods.NORMAL)--HADMORE
		pIconView:setIconIsCanTouched(true)
		pIconView:setScale(0.8)
		pLayItems:addView(pIconView)
		pIconView:setPosition(nX, nY)
		nX = nX + nOffsetX
		table.insert(self.tGoodsList, pIconView)
	end
	local pTxtRewardTime = self:findViewByName("txt_reward_time") 
	pTxtRewardTime:setString(getConvertedStr(3, 10725))
	setTextCCColor(pTxtRewardTime, _cc.green)
end

-- 修改控件内容或者是刷新控件数据
function ItemNianRankAward:updateViews( )
	if not self.tCurData then
		return
	end

	--等级
	local tLv = self.tCurData.tLv
	if tLv then
		local sTilte = ""
		if #tLv == 2 then
			local nLv1 = tLv[1]
			local nLv2 = tLv[2]
			if nLv1 == nLv2 then
				sTitle = string.format(getConvertedStr(3, 10723), nLv1)
			else
				sTitle = string.format(getConvertedStr(3, 10724), nLv1, nLv2)
			end
		else
			local nLvl = tLv[1]
			sTitle = string.format(getConvertedStr(3, 10723), nLv1)
		end
		self.pTxtTitle:setString(sTitle)
	end

	--图标
	for i=1,#self.tGoodsList do
		self.tGoodsList[i]:setVisible(false)
	end
	local tAward = self.tCurData.tAward
	for i=1,#tAward do
		local pIconView = self.tGoodsList[i]
		if pIconView then
			local tAwardData = tAward[i]
			local nGoodsId = tAwardData.k
			local nCt = tAwardData.v
			local tGoods = getGoodsByTidFromDB(nGoodsId)
			if tGoods then
			    pIconView:setCurData(tGoods) 
			end
			pIconView:setNumber(nCt)
			pIconView:setVisible(true)
		end
	end
end

-- 析构方法
function ItemNianRankAward:onItemNianRankAwardDestroy( )
end

--_data:RankAwardRes
function ItemNianRankAward:setCurData( _data )
	self.tCurData = _data
	self:updateViews()
end

function ItemNianRankAward:setHandler( _nhandler )
	-- body
	self.nHandler = _nhandler
end

function ItemNianRankAward:onClick(  )
	-- body
	if self.nHandler then
		self.nHandler(self.tCurData)
	end
end

return ItemNianRankAward