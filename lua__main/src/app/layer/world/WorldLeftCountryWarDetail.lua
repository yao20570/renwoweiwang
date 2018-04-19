----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-17 19:59:21
-- Description: 世界大地图左边 国战列表
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemWorldLeftCountryWar = require("app.layer.world.ItemWorldLeftCountryWar")


local WorldLeftCountryWarDetail = class("WorldLeftCountryWarDetail", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function WorldLeftCountryWarDetail:ctor( pSize )
	self:setContentSize(pSize)
	self:myInit()
end

--解析界面回调
function WorldLeftCountryWarDetail:myInit(  )
	self.tCountryWarMsgs = {}
	self.tTasks = {}
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("WorldLeftCountryWarDetail",handler(self, self.onWorldLeftCountryWarDetailDestroy))
end

-- 析构方法
function WorldLeftCountryWarDetail:onWorldLeftCountryWarDetailDestroy(  )
    self:onPause()
end

function WorldLeftCountryWarDetail:regMsgs(  )
	regMsg(self, gud_my_country_war_list_change, handler(self, self.updateMyListView))
end

function WorldLeftCountryWarDetail:unregMsgs(  )
	unregMsg(self, gud_my_country_war_list_change)
end

function WorldLeftCountryWarDetail:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function WorldLeftCountryWarDetail:onPause(  )
	self:unregMsgs()
end

function WorldLeftCountryWarDetail:setupViews(  )
end

--创建listView
function WorldLeftCountryWarDetail:createListView(_count)
	self.pListView = MUI.MListView.new {
		viewRect   = cc.rect(0, 0, self:getContentSize().width, self:getContentSize().height),
		direction  = MUI.MScrollView.DIRECTION_VERTICAL,
    }
    self:addView(self.pListView)
    centerInView(self, self.pListView )

    --列表数据
    self.pListView:setItemCount(_count)
    self.pListView:setItemCallback(function ( _index, _pView ) 
    	local pItemData = self.tCountryWarMsgs[_index]
        local pTempView = _pView
        if pTempView == nil then
        	pTempView   = ItemWorldLeftCountryWar.new()
    	end
    	pTempView:setData(pItemData)
        return pTempView
	end)
	self.pListView:reload()
end

function WorldLeftCountryWarDetail:updateViews(  )
	self:updateMyListView()
end

--更新视图表
function WorldLeftCountryWarDetail:updateMyListView(  )
	local tCountryWarMsgs = Player:getWorldData():getMyCountryWarsList()
	self.tCountryWarMsgs = tCountryWarMsgs
	if not self.pListView then
		self:createListView(#self.tCountryWarMsgs)
	else
		self.pListView:notifyDataSetChange(true, #self.tCountryWarMsgs)
	end
end


return WorldLeftCountryWarDetail


