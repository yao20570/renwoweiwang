----------------------------------------------------- 
-- author: luwenjing
-- updatetime: 2017-11-21 10:47:21
-- Description: 邮件获得奖励的信息条
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local ItemMailRewardBanner = class("ItemMailRewardBanner", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemMailRewardBanner:ctor( _sStr )
	--解析文件

	self.sStr=_sStr
	parseView("item_mail_reward_banner", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemMailRewardBanner:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemMailRewardBanner",handler(self, self.onMailDetailAtkDefBannerDestroy))
end

-- 析构方法
function ItemMailRewardBanner:onMailDetailAtkDefBannerDestroy(  )
    self:onPause()
end

function ItemMailRewardBanner:regMsgs(  )
end

function ItemMailRewardBanner:unregMsgs(  )
end

function ItemMailRewardBanner:onResume(  )
	self:regMsgs()
end

function ItemMailRewardBanner:onPause(  )
	self:unregMsgs()
end

function ItemMailRewardBanner:setupViews(  )
	self.pTxtInfo=self:findViewByName("txt_info")
	-- setTextCCColor(self.pTxtInfo, _cc.white)
	
end

function ItemMailRewardBanner:updateViews(  )
	--居中显示

	if self.sStr then
		if type(self.sStr) == "table" then
		else
			setTextCCColor(self.pTxtInfo, _cc.white)
		end
		self.pTxtInfo:setString(self.sStr)
	end
end

return ItemMailRewardBanner


