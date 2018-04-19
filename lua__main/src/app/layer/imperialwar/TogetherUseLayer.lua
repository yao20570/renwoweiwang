----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-03-17 14:42:00
-- Description: 战术买
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local TogetherUseLayer = class("TogetherUseLayer", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function TogetherUseLayer:ctor( tData )
	self.tData = tData
	self.nToCdSystemTime = getSystemTime()
	parseView("layout_use_together", handler(self, self.onParseViewCallback))
end

--解析界面回调
function TogetherUseLayer:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("TogetherUseLayer", handler(self, self.onTogetherUseLayerDestroy))
end

-- 析构方法
function TogetherUseLayer:onTogetherUseLayerDestroy(  )
    self:onPause()
end

function TogetherUseLayer:regMsgs(  )
	regUpdateControl(self, handler(self, self.updateCd))
end

function TogetherUseLayer:unregMsgs(  )
	unregUpdateControl(self)
end

function TogetherUseLayer:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function TogetherUseLayer:onPause(  )
	self:unregMsgs()
end

function TogetherUseLayer:setupViews(  )
	local pTxtDesc1 = self:findViewByName("txt_desc1")
	pTxtDesc1:setString(getConvertedStr(3, 10852))
	self.pTxtDesc2 = self:findViewByName("txt_desc2")
end

function TogetherUseLayer:updateViews(  )
	if not self.tData then
		return
	end

	local tStr = {
	    {color=_cc.white,text=getConvertedStr(3, 10853)},
	    {color=_cc.green,text=self.tData.nRamin},
	}
	self.pTxtDesc2:setString(tStr)
	
end

function TogetherUseLayer:setSubmitBtn( pBtn )
	self.pSubmitBth = pBtn
	local tConTable = {}
	local tLabel = {
	 {getConvertedStr(3, 10904) ,getC3B(_cc.white)},
	 {"2",getC3B(_cc.red)},
	}
	tConTable.tLabel = tLabel
	self.pSubmitBth:setBtnExText(tConTable)
	self:updateCd()
end

function TogetherUseLayer:updateCd(  )
	if not self.tData then
		return
	end
	if not self.pSubmitBth then
		return
	end

	local nCd = self:getToCd()
	if nCd > 0 then
		self.pSubmitBth:setExTextLbCnCr(2,getTimeLongStr(nCd,false,false))
		self.pSubmitBth:setExTextVisiable(true)
		self.pSubmitBth:setBtnEnable(false)
	else
		self.pSubmitBth:setExTextVisiable(false)
		self.pSubmitBth:setBtnEnable(true)
	end
end

--集结倒计时
function TogetherUseLayer:getToCd(  )
	if self.tData then
		if self.tData.nToCd and self.tData.nToCd > 0 then
	        local fCurTime = getSystemTime()
	        local fLeft = self.tData.nToCd - (fCurTime - self.nToCdSystemTime)
	        if(fLeft < 0) then
	            fLeft = 0
	        end
	        return fLeft
	    else
	        return 0
	    end
	end
	return 0
end

return TogetherUseLayer


