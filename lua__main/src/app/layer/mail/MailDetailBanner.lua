----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-17 19:59:21
-- Description: 邮件详细横条
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local MailDetailBanner = class("MailDetailBanner", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--横条文本
function MailDetailBanner:ctor( sStr,tStrs )
	self.sStr=sStr		--左边固定文本
	self.tStrs = tStrs			--右边动态添加的文本  文本按从左到右的顺序放进table
	--解析文件
	parseView("lay_mail_banner", handler(self, self.onParseViewCallback))
end

--解析界面回调
function MailDetailBanner:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("MailDetailBanner",handler(self, self.onMailDetailBannerDestroy))
end

-- 析构方法
function MailDetailBanner:onMailDetailBannerDestroy(  )
    self:onPause()
end

function MailDetailBanner:regMsgs(  )
end

function MailDetailBanner:unregMsgs(  )
end

function MailDetailBanner:onResume(  )
	self:regMsgs()
end

function MailDetailBanner:onPause(  )
	self:unregMsgs()
end

function MailDetailBanner:setupViews(  )
	local pTxtTip = self:findViewByName("txt_tip")
	local pBg=self:findViewByName("default")
	pTxtTip:setString(self.sStr)
	setTextCCColor(pTxtTip,_cc.pwhite)
	local nPosX=pBg:getWidth()-20
	local nHeight=pBg:getHeight()
	if self.tStrs then
		for i, v in pairs(self.tStrs) do
			local pTxt=MUI.MLabel.new({text = v.sStr or "", size = v.nFontSize})
			pTxt:setColor(getC3B(v.sColor) or getC3B(_cc.white))
			-- pTxt:updateTexture()
			pTxt:setAnchorPoint(1,0)
			local nPosY=(nHeight-pTxt:getHeight())/2
			pTxt:setPosition(nPosX,nPosY)
			nPosX=nPosX-pTxt:getWidth()-10
			self:addView(pTxt,10)
			-- if v then
			-- 	pTxt:setString(v.sStr)
			-- 	setTextCCColor(pTxt, v.sColor)
			-- 	pTxt:setVisible(true)
			-- end
		end
	
	end
end

function MailDetailBanner:updateViews(  )
end

return MailDetailBanner


