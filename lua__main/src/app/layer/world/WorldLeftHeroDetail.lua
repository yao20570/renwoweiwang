----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-17 19:59:21
-- Description: 世界大地图左边 武将详细
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemWorldLeftHero = require("app.layer.world.ItemWorldLeftHero")

local WorldLeftHeroDetail = class("WorldLeftHeroDetail", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function WorldLeftHeroDetail:ctor( pSize )
	self:setContentSize(pSize)
	self:myInit()
end

--解析界面回调
function WorldLeftHeroDetail:myInit(  )
	self.tHeroState = {}
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("WorldLeftHeroDetail",handler(self, self.onWorldLeftHeroDetailDestroy))
end

-- 析构方法
function WorldLeftHeroDetail:onWorldLeftHeroDetailDestroy(  )
    self:onPause()
end

function WorldLeftHeroDetail:regMsgs(  )
	regMsg(self, gud_world_task_change_msg, handler(self, self.updateViews))
end

function WorldLeftHeroDetail:unregMsgs(  )
	unregMsg(self, gud_world_task_change_msg)
end

function WorldLeftHeroDetail:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function WorldLeftHeroDetail:onPause(  )
	self:unregMsgs()
end

function WorldLeftHeroDetail:setupViews(  )
    self.pHeroUis = {}
    local pSize = self:getContentSize()
    local nCurrHeight = pSize.height - 10
    for i=1,4 do
    	local pHeroUi = ItemWorldLeftHero.new(i)
    	table.insert(self.pHeroUis, pHeroUi)
    	nCurrHeight = nCurrHeight - pHeroUi:getContentSize().height
    	pHeroUi:setPositionY(nCurrHeight)
    	self:addView(pHeroUi)
    end
    self:setViewTouched(true)
    self:setIsPressedNeedScale(false)
    self:setIsPressedNeedColor(false)
end

function WorldLeftHeroDetail:updateViews(  )
	--列表数据
	local tHeroState = Player:getWorldData():getHeroStateList()
	for i=1,#self.pHeroUis do
		local pItemData = tHeroState[i]
		self.pHeroUis[i]:setData(pItemData)
	end
end

return WorldLeftHeroDetail


