----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-02-08 10:39:21
-- Description: 限时Boss五连击界面 奖励物品
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local IconGoods = require("app.common.iconview.IconGoods")
local nCol = 4
local nSubHeight = 130
local TLBossHitResultGoods = class("TLBossHitResultGoods", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function TLBossHitResultGoods:ctor( tGoodsList )
	self.bIsCanUpdateView = false
	local nGoodsNum = #tGoodsList
	local nHeight = math.ceil(nGoodsNum/nCol) * nSubHeight
	self:setContentSize(560, nHeight)
	self.tGoodsList = tGoodsList
	self.nHeight = nHeight
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("TLBossHitResultGoods", handler(self, self.onTLBossHitResultGoodsDestroy))
end

-- 析构方法
function TLBossHitResultGoods:onTLBossHitResultGoodsDestroy(  )
    self:onPause()
end

function TLBossHitResultGoods:regMsgs(  )
end

function TLBossHitResultGoods:unregMsgs(  )
end

function TLBossHitResultGoods:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function TLBossHitResultGoods:onPause(  )
	self:unregMsgs()
end

function TLBossHitResultGoods:setupViews(  )
end

function TLBossHitResultGoods:updateViews(  )
	if not self.bIsCanUpdateView then
		return
	end

	local nBeginX, nBeginY = 40, self.nHeight - nSubHeight
	local nOffsetX, nOffsetY = 130, nSubHeight
	local nX, nY = nBeginX, nBeginY
	for i=1,#self.tGoodsList do
		local pIconGoods = self:getChildByTag(i)
		if not pIconGoods then
			pIconGoods = IconGoods.new(TypeIconGoods.HADMORE, type_icongoods_show.itemnum)   
			pIconGoods:setScale(0.8)
			self:addView(pIconGoods, 1, i)
		end
		if pIconGoods then
			local tGoods = self.tGoodsList[i]
			if tGoods then
		        pIconGoods:setCurData(tGoods)
			end
			pIconGoods:setPosition(nX, nY)
		end	
		--位置
		if i % nCol == 0 then
			nX = nBeginX
			nY = nY - nOffsetY
		else
			nX = nX + nOffsetX
		end
	end
end

--刷新界面
function TLBossHitResultGoods:setData( )
	self.bIsCanUpdateView = true
	self:updateViews()
end

return TLBossHitResultGoods


