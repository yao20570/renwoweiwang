-- Author: liangzhaowei
-- Date: 2017-06-29 14:41:48
-- 活动1头顶标题说明图片框item

local MCommonView = require("app.common.MCommonView")
local ItemActPlugAccount = class("ItemActPlugAccount", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数
function ItemActPlugAccount:ctor()
	-- body
	self:myInit()

	parseView("item_act_account_a", handler(self, self.onParseViewCallback))


	--注册析构方法
	self:setDestroyHandler("ItemActPlugAccount",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemActPlugAccount:myInit()
	self.pData = {} --数据
end

--解析布局回调事件
function ItemActPlugAccount:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	--ly         	
	self.pLyAccount = self:findViewByName("ly_account")
		

	--img
	self.pImgAccount = self:findViewByName("img_account")
	

	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemActPlugAccount:setupViews( )

end

-- 修改控件内容或者是刷新控件数据
function ItemActPlugAccount:updateViews(  )
	-- body
end

--析构方法
function ItemActPlugAccount:onDestroy(  )
	-- body
end

--设置数据 _data
function ItemActPlugAccount:setCurData(_tData)
	if not _tData then
		return
	end

	self.pData = _tData or {}

	--self.pLbN:setString(self.pData.sName or "")
	

end

--设置图片内容图片
function ItemActPlugAccount:setAccountImg(_strImg)
	-- body
	if _strImg then
		self.pImgAccount:setCurrentImage(_strImg)
	end
end


return ItemActPlugAccount