----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-03-17 14:42:00
-- Description: 战术买
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local TacticsBuyLayer = class("TacticsBuyLayer", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function TacticsBuyLayer:ctor( nTechId, tImperialWarVo)
	self.nTechId = nTechId
	self.tImperialWarVo = tImperialWarVo
	parseView("layout_tactics_buy", handler(self, self.onParseViewCallback))
end

--解析界面回调
function TacticsBuyLayer:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("TacticsBuyLayer", handler(self, self.onTacticsBuyLayerDestroy))
end

-- 析构方法
function TacticsBuyLayer:onTacticsBuyLayerDestroy(  )
    self:onPause()
end

function TacticsBuyLayer:regMsgs(  )
end

function TacticsBuyLayer:unregMsgs(  )
end

function TacticsBuyLayer:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function TacticsBuyLayer:onPause(  )
	self:unregMsgs()
end

function TacticsBuyLayer:setupViews(  )
	self.pLayIcon = self:findViewByName("lay_icon")
	self.pTxtName = self:findViewByName("txt_name")
	self.pTxtDesc = self:findViewByName("txt_desc")
	self.pTxtRemain = self:findViewByName("txt_remain")
	self.pTxtRemain:setVisible(false)
end

function TacticsBuyLayer:updateViews(  )
	if not self.nTechId or not self.tImperialWarVo then
		return
	end
	local tTechData = getTechDataById(self.nTechId)
	if not tTechData then
		return
	end
	self.pTechIcon = getIconGoodsByType(self.pLayIcon, TypeIconGoods.NORMAL, type_icongoods_show.tech, tTechData)
	self.pTechIcon:setMoreTextSize(24)
	self.pTxtName:setString(tTechData.sName)
	setTextCCColor(self.pTxtName, getColorByQuality(tTechData.nQuality)) 
	self.pTxtDesc:setString(tTechData.sDesc)
	
	-- --有限购次数
	-- local nLimit = tTechData.nLimit
	-- if nLimit then
	-- 	local nId = tTechData.sTid
	-- 	local nUsed = self.tImperialWarVo:getTechBuyed(nId)
	-- 	self.nCanUse = math.max(nLimit - nUsed, 0)
	-- 	self.pTechIcon:setTechUsedStr(string.format("%s/%s", self.nCanUse, nLimit))

	-- 	self.pTxtRemain:setVisible(true)
	-- 	self.pTxtRemain:setString(getConvertedStr(3, 10932) .. self.nCanUse)
	-- else
	-- 	self.nCanUse = nil
	-- 	self.pTxtRemain:setVisible(false)
	-- end
end


return TacticsBuyLayer


