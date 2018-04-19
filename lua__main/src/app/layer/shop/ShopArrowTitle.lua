----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-14 17:09:09
-- Description: 商城箭头
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local ShopArrowTitle = class("ShopArrowTitle", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--sStr :文本
function ShopArrowTitle:ctor( sStr , ntype)
	self.sStr = sStr
	--解析文件
	self.nType = ntype or 1
	if self.nType == 1 then --长标题 文字居中显示
		parseView("lay_shop_arrow_title_l", handler(self, self.onParseViewCallback))
	else	--短标题
		parseView("lay_shop_arrow_title_s", handler(self, self.onParseViewCallback))
	end
	
end

--解析界面回调
function ShopArrowTitle:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ShopArrowTitle",handler(self, self.onShopArrowTitleDestroy))
end

-- 析构方法
function ShopArrowTitle:onShopArrowTitleDestroy(  )
    self:onPause()
end

function ShopArrowTitle:regMsgs(  )
end

function ShopArrowTitle:unregMsgs(  )
end

function ShopArrowTitle:onResume(  )
	self:regMsgs()
end

function ShopArrowTitle:onPause(  )
	self:unregMsgs()
end

function ShopArrowTitle:setupViews(  )
	self.pTxtTitle = self:findViewByName("txt_title")
end

function ShopArrowTitle:updateViews(  )
	if not self.sStr then
		return
	end

	self.pTxtTitle:setString(self.sStr)
end

--sStr :文本
function ShopArrowTitle:setData( sStr )
	self.sStr = sStr
	self:updateViews()
end

return ShopArrowTitle


