----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-02-08 10:39:21
-- Description: 限时Boss五连击界面 箭头标题
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local TLBossHitResultTitle = class("TLBossHitResultTitle", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function TLBossHitResultTitle:ctor( nNum, bIsDouble )
	self.nNum = nNum
	self.bIsDouble = bIsDouble
	--解析文件
	parseView("tlboss_hit_result_title", handler(self, self.onParseViewCallback))
end

--解析界面回调
function TLBossHitResultTitle:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("TLBossHitResultTitle", handler(self, self.onTLBossHitResultTitleDestroy))
end

-- 析构方法
function TLBossHitResultTitle:onTLBossHitResultTitleDestroy(  )
    self:onPause()
end

function TLBossHitResultTitle:regMsgs(  )
end

function TLBossHitResultTitle:unregMsgs(  )
end

function TLBossHitResultTitle:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function TLBossHitResultTitle:onPause(  )
	self:unregMsgs()
end

function TLBossHitResultTitle:setupViews(  )
	local pTxtTitle = self:findViewByName("txt_title")
	if self.nNum then
		if self.bIsDouble then
			local tStr = {
			    {color=_cc.white,text=string.format(getConvertedStr(3, 10813), self.nNum)},
			    {color=_cc.green,text=" "..getConvertedStr(3, 10814)},
			}
			pTxtTitle:setString(tStr)
		else
			pTxtTitle:setString(string.format(getConvertedStr(3, 10813), self.nNum))
		end
	end
end

function TLBossHitResultTitle:updateViews(  )
	
end


return TLBossHitResultTitle


