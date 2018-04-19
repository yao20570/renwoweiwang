----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-12-25 11:01:01
-- Description: 上阵武将界面的采集列表布局
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemOnlineHeroCollect = require("app.layer.hero.ItemOnlineHeroCollect")
local DragChangeListView = require("app.layer.world.DragChangeListView")

local HeroLineUpListCollect = class("HeroLineUpListCollect", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)


function HeroLineUpListCollect:ctor(_listType)
	-- body
	self:myInit(_listType)
	parseView("layout_hero_line_up_list", handler(self, self.onParseViewCallback))
end

--解析布局回调事件
function HeroLineUpListCollect:onParseViewCallback( pView )
	-- body
	
	self:addView(pView)
	self:setupViews()
	
	self:onResume()
	 --注册析构方法
	self:setDestroyHandler("HeroLineUpListCollect",handler(self, self.onDestroy))
end

-- --初始化参数
function HeroLineUpListCollect:myInit(_listType)
	-- body
	self.tHeroListData = {} --英雄队列数据

	self.tHeroListItem = {} --英雄队列item

	self.nListType=_listType or 1
end

--初始化控件
function HeroLineUpListCollect:setupViews( )
	-- body	
	self.pLyList = self:findViewByName("ly_list")

	local pSize = self.pLyList:getContentSize()
	local pDragChangeListView = DragChangeListView.new(pSize, 2)
	pDragChangeListView:setPosition(0, 0)
	pDragChangeListView:setChangeSuccessHandler(handler(self, self.onItemChange))
	self.pDragChangeListView = pDragChangeListView
	self.pLyList:addView(pDragChangeListView)	
end

-- 修改控件内容或者是刷新控件数据
function HeroLineUpListCollect:updateViews(  )
	--刷新武将数据
	self:refreshCollectData()
	local tItems = self.pDragChangeListView:getAllItemList()
	--武将item
	for newIndex = 1, 4 do
		local pData = self.tHeroListData[newIndex]
		local pItem = tItems[newIndex]
		if(not self.tHeroListItem[newIndex]) then
			self.tHeroListItem[newIndex] =  ItemOnlineHeroCollect.new(pData,newIndex, self.nListType)
			local nY = self.pLyList:getHeight()-(self.tHeroListItem[newIndex]:getHeight() +10)*newIndex			
			self.pDragChangeListView:addItem(self.tHeroListItem[newIndex],cc.p(0, nY))
			if not pItem then
				pItem = self.tHeroListItem[newIndex]
			end
		else
			pItem:setCurData(pData, newIndex)
		end
		if type(pData) == "table" then
			self.pDragChangeListView:includeItem(pItem)
		elseif pData == TypeIconHero.LOCK or pData == TypeIconHero.ADD then
			self.pDragChangeListView:excludeItem(pItem)
		end		
    end
end

function HeroLineUpListCollect:onItemChange( )
	-- body
	local tItems = self.pDragChangeListView:getItemList()
	local tEdit = {}
	local tDef = {}	
	for k, v in pairs(tItems) do
		local pData = v:getData()
		table.insert(tEdit, pData.nId)
	end	
	for k, v in pairs(self.tHeroOnlineList) do
		table.insert(tDef, v.nId)	
	end
	local bEdit = true
	if #tDef == #tEdit then
		for i = 1, #tEdit do
			if tDef[i] ~= tEdit[i] then
				bEdit = false
				break
			end			
		end
	end
	if bEdit then
		return
	end
	local sHeros = table.concat(tEdit, ";")
	SocketManager:sendMsg("editCollectHeros", {sHeros},function (msg)
	end)		
end

--析构方法
function HeroLineUpListCollect:onDestroy(  )
	-- body	
end

--更新采集数据
function HeroLineUpListCollect:refreshCollectData()

	--武将队列
	self.tHeroListData = {} --英雄队列数据
	local tHeroOnlineList = Player:getHeroInfo():getCollectHeroList() --采集队列
	self.tHeroOnlineList = tHeroOnlineList
	--上锁下标
	local nUnLockIndex = Player:getHeroInfo():getCollectQueueNums()

	for i=1,4 do
		if tHeroOnlineList[i] then
			self.tHeroListData[i] = tHeroOnlineList[i]
		else
			--锁住类型待添加
			if i> nUnLockIndex then
				self.tHeroListData[i] = TypeIconHero.LOCK
			else
				self.tHeroListData[i] = TypeIconHero.ADD
			end
		end
	end
end

-- 注册消息
function HeroLineUpListCollect:regMsgs( )
	regMsg(self, gud_tcf_hero_pos_unlock_push, handler(self, self.updateViews))
end

-- 注销消息
function HeroLineUpListCollect:unregMsgs(  )
	unregMsg(self, gud_tcf_hero_pos_unlock_push)
end
--暂停方法
function HeroLineUpListCollect:onPause( )
	-- body
	self:unregMsgs()
end

--继续方法
function HeroLineUpListCollect:onResume( )
	self:updateViews()
	self:regMsgs()
end

return HeroLineUpListCollect
