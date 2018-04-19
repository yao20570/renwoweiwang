----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-17 19:59:21
-- Description: 城池详细界面 侦查子界面
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local LoadMoreMail = class("LoadMoreMail", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function LoadMoreMail:ctor(  )
	--解析文件
	parseView("lay_load_more_mail", handler(self, self.onParseViewCallback))
end

--解析界面回调
function LoadMoreMail:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("LoadMoreMail", handler(self, self.onLoadMoreMailDestroy))

	--请求数据 znftodo
end

-- 析构方法
function LoadMoreMail:onLoadMoreMailDestroy(  )
    self:onPause()
end

function LoadMoreMail:regMsgs(  )
end

function LoadMoreMail:unregMsgs(  )
end

function LoadMoreMail:onResume(  )
	self:regMsgs()
end

function LoadMoreMail:onPause(  )
	self:unregMsgs()
end

function LoadMoreMail:setupViews(  )
	local pTxtTip = self:findViewByName("txt_tip")
	pTxtTip:setString(getConvertedStr(3, 10239))
end

function LoadMoreMail:updateViews(  )
	
end

return LoadMoreMail


