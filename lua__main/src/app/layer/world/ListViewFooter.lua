----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-17 19:59:21
-- Description: 城池详细界面 侦查子界面
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local ListViewFooter = class("ListViewFooter", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ListViewFooter:ctor(  )
	--解析文件
	parseView("item_city_owner_candidate_next", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ListViewFooter:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ListViewFooter",handler(self, self.onListViewFooterDestroy))
end

-- 析构方法
function ListViewFooter:onListViewFooterDestroy(  )
    self:onPause()
end

function ListViewFooter:regMsgs(  )
end

function ListViewFooter:unregMsgs(  )
end

function ListViewFooter:onResume(  )
	self:regMsgs()
end

function ListViewFooter:onPause(  )
	self:unregMsgs()
end

function ListViewFooter:setupViews(  )
	self.pTxtNext = self:findViewByName("txt_next")
	self.pTxtNext:setString(getConvertedStr(3, 10177))
end

function ListViewFooter:updateViews(  )
	
end

return ListViewFooter


