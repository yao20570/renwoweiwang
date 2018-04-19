-- Author: liangzhaowei
-- Date: 2017-05-31 16:06:29
-- 双个服务器列表

local MCommonView = require("app.common.MCommonView")
local ItemServerView = require("app.layer.serverlist.ItemServerView")

local ItemDoubleServer = class("ItemDoubleServer", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数
function ItemDoubleServer:ctor()
	-- body
	self:myInit()

	parseView("item_server_rect_m", handler(self, self.onParseViewCallback))


	--注册析构方法
	self:setDestroyHandler("ItemDoubleServer",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemDoubleServer:myInit()
	self.pData = {} --数据
	self.pListItem = {} --服务器列表
end

--解析布局回调事件
function ItemDoubleServer:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	--ly         	
	self.pLyMain = self:findViewByName("item_server_rect_m")

	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemDoubleServer:setupViews( )

end

-- 修改控件内容或者是刷新控件数据
function ItemDoubleServer:updateViews(  )
	-- body
end

--析构方法
function ItemDoubleServer:onDestroy(  )
	-- body
end

--设置数据 _data
function ItemDoubleServer:setCurData(_tData)
	if not _tData then
		return
	end

	self.pData = _tData or {}

	for i=1,2 do
		if not self.pListItem[i] then
			self.pListItem[i] = ItemServerView.new()
			self.pListItem[i]:setPositionX(self.pListItem[i]:getWidth()*(i-1))
			self:addView(self.pListItem[i])
		end

		if self.pData[i] then
			self.pListItem[i]:setVisible(true)
			self.pListItem[i]:setCurData(self.pData[i])
		else
			self.pListItem[i]:setVisible(false)
		end

	end



	--self.pLbN:setString(self.pData.sName or "")
	

end


return ItemDoubleServer