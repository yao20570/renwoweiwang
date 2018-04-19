-- Author: liangzhaowei
-- Date: 2017-05-15 16:04:05
-- 守城npc武将列表
local DlgArmyLayer = require("app.layer.fuben.DlgArmyLayer")
local MCommonView = require("app.common.MCommonView")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local ItemWallNpc = require("app.layer.wall.ItemWallNpc")

local ItemListWallNpc = class("ItemListWallNpc", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemListWallNpc:ctor()
	-- body
	self:myInit()


	parseView("item_list_wall_npc", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemListWallNpc",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemListWallNpc:myInit()
	self.tCurData  			= 	nil 						-- 当前数据
	self.tListItem          = {}                            -- item


end

--解析布局回调事件
function ItemListWallNpc:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	--ly         	
	self.pLyIcon = self:findViewByName("ly_main")

	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemListWallNpc:setupViews( )

end

-- 修改控件内容或者是刷新控件数据
function ItemListWallNpc:updateViews(  )
end

--析构方法
function ItemListWallNpc:onDestroy(  )
	-- body
end




--设置数据 _data
function ItemListWallNpc:setCurData(_tData)
	if not _tData then
		return
	end

	self.pData = _tData or {}
	if table.nums(self.pData)>0 then
		for k,v in pairs(self.pData) do
			if not self.tListItem[k] then
				self.tListItem[k] = ItemWallNpc.new()
				self.pLyIcon:addView(self.tListItem[k],k)
				self.tListItem[k]:setPositionX(150*(k-1))
			end
			self.tListItem[k]:setCurData(v)
		end
	end

end


return ItemListWallNpc