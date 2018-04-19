----------------------------------------------------- 
-- author: xiesite
-- updatetime: 2018-03-22 18:00:31
-- Description: 国家宝藏获得提示
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
					
local ItemTreasureGet = class("ItemTreasureGet", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemTreasureGet:ctor( )
	-- body
	self:myInit()
	parseView("item_treasure_get", handler(self, self.onParseViewCallback))
end

--解析布局回调事件
function ItemTreasureGet:onParseViewCallback( pView )
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	--注册析构方法
	self:setDestroyHandler("ItemTreasureGet",handler(self, self.onDestroy))
end
--初始化成员变量
function ItemTreasureGet:myInit(  )

end

 


function ItemTreasureGet:regMsgs(  )
end

function ItemTreasureGet:unregMsgs(  )
end

function ItemTreasureGet:onResume(  )
	self:regMsgs()
end

function ItemTreasureGet:onPause(  )
	self:unregMsgs()
end

function ItemTreasureGet:setupViews(  )
	self.pLb1 = self:findViewByName("lb_1")
	self.pLb2 = self:findViewByName("lb_2")
end

--析构方法
function ItemTreasureGet:onDestroy( )
	-- body
	self:onPause()
end

function ItemTreasureGet:updateViews(  )
	if not self.tData then
		return
	end
	
	for i=1, 2 do
		if self.tData[i] then
			local id = self.tData[i].i
			local sName = self.tData[i].n 
			if id then
				local tItemInfo = getBaseItemDataByID(id)
				if tItemInfo then
					self["pLb"..i]:setString(string.format(getConvertedStr(1,10402),sName,tItemInfo.sName))
				end				
			end

		else
			self["pLb"..i]:setString("")
		end
	end
end
 

--_state 0-未完成，1-完成未领取，2-完成已领取
function ItemTreasureGet:setCurData( _tData )
	self.tData = _tData
	self:updateViews()
end


return ItemTreasureGet


