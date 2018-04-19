------------------------------------------------
-- Author: dengshulan
-- Date: 2018-01-31 14:41:40
-- 副本章节列表
------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local EquipDropLayer = require("app.layer.bag.EquipDropLayer")
local EquipDropListLayer = class("EquipDropListLayer", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数
function EquipDropListLayer:ctor()
	-- body
	self:myInit()

	parseView("equip_drop_list", handler(self, self.onParseViewCallback))


	--注册析构方法
	self:setDestroyHandler("EquipDropListLayer",handler(self, self.onDestroy))
	
end

--初始化参数
function EquipDropListLayer:myInit()
	self.pData = {} --数据
	self.tListItem = {} --item列表
end

--解析布局回调事件
function EquipDropListLayer:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
end

--初始化控件
function EquipDropListLayer:setupViews( )
	self.pLayList = self:findViewByName("equip_drop_list")
end

-- 修改控件内容或者是刷新控件数据
function EquipDropListLayer:updateViews(  )
	-- body
end

--析构方法
function EquipDropListLayer:onDestroy(  )
	-- body
end

--设置数据 _data
function EquipDropListLayer:setCurData(_tData)
	if not _tData then
		return
	end


	self.pData = _tData or {}


	for i=1, 3 do
		local pView = self.tListItem[i]
		if self.pData[i] then
			if not pView then
				pView = EquipDropLayer.new()
				self.pLayList:addView(pView,i)
				pView:setPositionX((i-1)*pView:getWidth())
				self.tListItem[i] = pView
			end
			pView:setVisible(true)
			pView:setCurData(self.pData[i])
		else
			if pView then
				pView:setVisible(false)
			end
		end
	end
	

end


return EquipDropListLayer