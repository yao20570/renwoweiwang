-- Author: liangzhaowei
-- Date: 2017-07-19 15:43:53
-- 英雄属性item

local MCommonView = require("app.common.MCommonView")
local ItemFemalHeroShop = require("app.layer.femalehero.ItemFemalHeroShop")
local ItemShopGroup = class("ItemShopGroup", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数
function ItemShopGroup:ctor()
	-- body
	self:setContentSize(cc.size(180, 230))
	self:myInit()
	self:setupViews()
	self:updateViews()
	--注册析构方法
	self:setDestroyHandler("ItemShopGroup",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemShopGroup:myInit()
	self.pData = {} --数据
	self.tListItem = {} --item列表
end

--初始化控件
function ItemShopGroup:setupViews( )

end

-- 修改控件内容或者是刷新控件数据
function ItemShopGroup:updateViews(  )
	-- body
end

--析构方法
function ItemShopGroup:onDestroy(  )
	-- body
end

--设置数据 _data
function ItemShopGroup:setCurData(_tData)
	if not _tData then
		return
	end
	self.pData = _tData or {}
	for i=1,3 do
		if self.pData[i] then
			if not self.tListItem[i] then
				self.tListItem[i] = ItemFemalHeroShop.new()
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


return ItemShopGroup