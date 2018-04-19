-- Author: liangzhaowei
-- Date: 2017-07-19 15:43:53
-- 英雄属性item

local MCommonView = require("app.common.MCommonView")
local ItemShogunSigleHero = require("app.layer.shogun.ItemShogunSigleHero")
local ItemShogunList = class("ItemShogunList", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数
function ItemShogunList:ctor()
	-- body
	self:myInit()

	parseView("item_shogun_list", handler(self, self.onParseViewCallback))


	--注册析构方法
	self:setDestroyHandler("ItemShogunList",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemShogunList:myInit()
	self.pData = {} --数据
	self.tListItem = {} --item列表
end

--解析布局回调事件
function ItemShogunList:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	--ly         	

	--lb
	--self.pLbN = self:findViewByName("lb_n")
	

	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemShogunList:setupViews( )

end

-- 修改控件内容或者是刷新控件数据
function ItemShogunList:updateViews(  )
	-- body
end

--析构方法
function ItemShogunList:onDestroy(  )
	-- body
end

--设置数据 _data
function ItemShogunList:setCurData(_tData)
	if not _tData then
		return
	end


	self.pData = _tData or {}


	for i=1,3 do
		if self.pData[i] then
			if not self.tListItem[i] then
				self.tListItem[i] = ItemShogunSigleHero.new()
				self:addView(self.tListItem[i],i)
				self.tListItem[i]:setPositionX(10+200*(i-1))
			end
			self.tListItem[i]:setVisible(true)
			self.tListItem[i]:setCurData(self.pData[i])
		else
			if self.tListItem[i] then
				self.tListItem[i]:setVisible(false)
			end
		end
	end
	

end


return ItemShogunList