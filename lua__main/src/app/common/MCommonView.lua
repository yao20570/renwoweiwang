-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-02-08 15:38:33 星期三
-- Description: 通用基础层（MFillLayer，MRootLayer，MLayer 都需要继承这个类）
-----------------------------------------------------


--layer的样式
TYPE_LAYER = {
	LAYER_MLAYER 		= 1,   	--MLayer
	LAYER_MFILLLAYER 	= 2, 	--MFillLayer
	LAYER_MROOTLAYER  	= 3, 	--MRootLayer
}

local MCommonView = class("MCommonView", function(layerType)
	-- body
	if layerType == TYPE_LAYER.LAYER_MLAYER then
		return MUI.MLayer.new()
	elseif layerType == TYPE_LAYER.LAYER_MFILLLAYER then
		return MUI.MFillLayer.new()
	elseif layerType == TYPE_LAYER.LAYER_MROOTLAYER then
		return MUI.MRootLayer.new()
	else
		return MUI.MLayer.new()
	end
end)

function MCommonView:ctor(  )
	-- body
	self.tCommonViewHandler = {}
	self.bCommonViewDestroy = false
end

--注册析构方法
function MCommonView:setDestroyHandler( pTView, nNHandler )
	local bFound = false
	local tTempData = nil

	for i, v in pairs(self.tCommonViewHandler) do
		if(v and v.pView and v.pView == (pTView)) then
			bFound = true
			tTempData = v
		end
	end
	if(bFound) then
		tTempData.nHander = nNHandler
	else
		table.insert(self.tCommonViewHandler, {pView=pTView, nHander=nNHandler})
	end
	if(not self.bCommonViewDestroy) then
		self.bCommonViewDestroy = true
		self:setDestroyCallback(handler(self, self.onCommonViewDestroy))
	end
end

--调用析构方法
function MCommonView:onCommonViewDestroy( )
	if self.tCommonViewHandler then
		for i, v in pairs(self.tCommonViewHandler) do
			if v.nHander then
				v.nHander()
			end
		end
		
		self.tCommonViewHandler = nil
	end
end

return MCommonView