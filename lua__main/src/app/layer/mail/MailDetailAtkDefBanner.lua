----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-17 19:59:21
-- Description: 邮件详细横条
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local MailDetailAtkDefBanner = class("MailDetailAtkDefBanner", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function MailDetailAtkDefBanner:ctor(  )
	--解析文件
	parseView("lay_mail_atk_def_banner", handler(self, self.onParseViewCallback))
end

--解析界面回调
function MailDetailAtkDefBanner:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("MailDetailAtkDefBanner",handler(self, self.onMailDetailAtkDefBannerDestroy))
end

-- 析构方法
function MailDetailAtkDefBanner:onMailDetailAtkDefBannerDestroy(  )
    self:onPause()
end

function MailDetailAtkDefBanner:regMsgs(  )
end

function MailDetailAtkDefBanner:unregMsgs(  )
end

function MailDetailAtkDefBanner:onResume(  )
	self:regMsgs()
end

function MailDetailAtkDefBanner:onPause(  )
	self:unregMsgs()
end

function MailDetailAtkDefBanner:setupViews(  )
	local pTxtAtkTitle = self:findViewByName("txt_atk_title")
	pTxtAtkTitle:setString(getConvertedStr(3, 10249))
	local pTxtDefTitle = self:findViewByName("txt_def_title")
	pTxtDefTitle:setString(getConvertedStr(3, 10250))
end

function MailDetailAtkDefBanner:updateViews(  )
end

return MailDetailAtkDefBanner


