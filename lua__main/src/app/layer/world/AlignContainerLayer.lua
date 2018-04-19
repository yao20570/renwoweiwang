----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-08-31 17:53:14
-- Description: 对齐容器层
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local e_align_type = {
	left = 1, --左对齐 默认
	center = 2, --居中
}

local AlignContainerLayer = class("AlignContainerLayer", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function AlignContainerLayer:ctor( tParam )
	self:setContentSize(tParam.size)
	self:setAlignType(tParam.align)
	self:setMargin(tParam.margin)
	self:setLeftPos(tParam.leftpos)
	self.tUiInfoList = {}
end

function AlignContainerLayer:setAlignType( nAlignType )
	self.nAlignType = nAlignType
end

function AlignContainerLayer:setMargin( nMargin )
	self.nMargin = nMargin
end

function AlignContainerLayer:setLeftPos( pPos )
	self.pLeftPos = pPos
end

function AlignContainerLayer:getUiByIndex( nIndex )
	if self.tUiInfoList[nIndex] then
		return self.tUiInfoList[nIndex].pUi
	end
	return nil
end

function AlignContainerLayer:addUi( pUi, pOffsetPos )
	self:addView(pUi)
	if pUiSize == nil then
		pUiSize = pUi:getContentSize()
	end
	if pOffsetPos == nil then
		pOffsetPos = cc.p(0, 0)
	end
	table.insert(self.tUiInfoList, {pUi = pUi, pUiSize = pUiSize, pOffsetPos = pOffsetPos})
end

--刷新位置(外部主动调用)
function AlignContainerLayer:refreshUisPos( )
	local pSize = self:getContentSize()
	local tUiIndexList = {}
	for i=1,#self.tUiInfoList do
		local pUi = self.tUiInfoList[i].pUi
		if pUi:isVisible() then
			table.insert(tUiIndexList, i)
		end
	end

	local nWidth = 0
	local nHeight = 0
	for i=1,#tUiIndexList do
		local tUiInfo = self.tUiInfoList[tUiIndexList[i]]
		local pUi = tUiInfo.pUi
		local pUiSize = tUiInfo.pUiSize
		nWidth = nWidth + pUiSize.width
		nHeight = math.max(nHeight, pUiSize.height)
	end
	nWidth = nWidth + self.nMargin * (#tUiIndexList - 1)

	if self.nAlignType == e_align_type.left then
		local nBeginX, nBeginY = 0, 0
		if self.pLeftPos then
			nBeginX = self.pLeftPos.x 
			nBeginY = self.pLeftPos.y
		end
		for i=1,#tUiIndexList do
			local tUiInfo = self.tUiInfoList[tUiIndexList[i]]
			local pUi = tUiInfo.pUi
			local pOffsetPos = tUiInfo.pOffsetPos
			if pOffsetPos then
				pUi:setPosition(nBeginX + pOffsetPos.x, nBeginY + pOffsetPos.y)
			end
			nBeginX = nBeginX + pUiSize.width + self.nMargin
		end
	elseif self.nAlignType == e_align_type.center then
		local nBeginX, nBeginY = (pSize.width - nWidth)/2 , 0
		for i=1,#tUiIndexList do
			local tUiInfo = self.tUiInfoList[tUiIndexList[i]]
			local pUi = tUiInfo.pUi
			local pOffsetPos = tUiInfo.pOffsetPos
			pUi:setPosition(nBeginX + pOffsetPos.x, nBeginY + pOffsetPos.y)
			nBeginX = nBeginX + pUiSize.width + self.nMargin
		end
	end
end

return AlignContainerLayer
