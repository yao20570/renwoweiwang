-----------------------------------------------------
-- author: luwenjing
-- updatetime:  2017-12-15 15:00:23 星期五
-- Description: 上阵武将界面的列表布局
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemOnlineHero = require("app.layer.hero.ItemOnlineHero")
local DragChangeListView = require("app.layer.world.DragChangeListView")

local HeroLineUpList = class("HeroLineUpList", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)


function HeroLineUpList:ctor(_listType)
	-- body
	self:myInit(_listType)
	parseView("layout_hero_line_up_list", handler(self, self.onParseViewCallback))

	
	
end
--解析布局回调事件
function HeroLineUpList:onParseViewCallback( pView )
	-- body
	self:addView(pView)
	self:setupViews()
	self:updateViews()
	self:onResume()
	 --注册析构方法
	self:setDestroyHandler("HeroLineUpList",handler(self, self.onDestroy))
end

-- --初始化参数
function HeroLineUpList:myInit(_listType)
	-- body
	self.tHeroListData = {} --英雄队列数据
	self.tHeroListItem = {} --英雄队列item
	self.nListType=_listType or 1
end

--初始化控件
function HeroLineUpList:setupViews( )
	-- body	
	self.pLyList = self:findViewByName("ly_list")
	self.pLbBuNums = self:findViewByName("lb_bu_nums")
	self.pLbGongNums = self:findViewByName("lb_gong_nums")
	self.pLbQiNums = self:findViewByName("lb_qi_nums")

	-- end
	local pSize = self.pLyList:getContentSize()
	local pDragChangeListView = DragChangeListView.new(pSize, 2)
	pDragChangeListView:setPosition(0, 0)
	pDragChangeListView:setChangeSuccessHandler(handler(self, self.onItemChange))
	self.pDragChangeListView = pDragChangeListView
	self.pLyList:addView(pDragChangeListView)
end

-- 修改控件内容或者是刷新控件数据
function HeroLineUpList:updateViews(  )
	-- body
	self:refreshLineUpData()
	local tItems = self.pDragChangeListView:getAllItemList()
	for newIndex = 1, 4 do
		local pData = self.tHeroListData[newIndex]
		local pItem = tItems[newIndex]
		if(not self.tHeroListItem[newIndex]) then
			self.tHeroListItem[newIndex] =  ItemOnlineHero.new(pData,newIndex, self.nListType)
			local nY = self.pLyList:getHeight()-(self.tHeroListItem[newIndex]:getHeight() +10)*newIndex		
			self.pDragChangeListView:addItem(self.tHeroListItem[newIndex],cc.p(0, nY))			
		else
			pItem:setCurData(pData, newIndex)	
		end					
		if type(pData) == "table" then
			self.pDragChangeListView:includeItem(pItem)
		elseif pData == TypeIconHero.LOCK or pData == TypeIconHero.ADD then
			self.pDragChangeListView:excludeItem(pItem)
		end
    end

	if self.nIdx then
		local pIconLayer = tItems[self.nIdx]:getIconLayer()
		if pIconLayer then
			showTaskFinger(pIconLayer, 0.8)
		end
		self.nIdx = nil
	end			

	local function guide()
		sendMsg(ghd_guide_finger_show_or_hide, true)
	end
	--延迟显示新手引导
	self:runAction(cc.Sequence:create({
		cc.DelayTime:create(0.2),
    	cc.CallFunc:create(guide)
	}))
end

function HeroLineUpList:onItemChange( ... )
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
	SocketManager:sendMsg("editOnLineHeros", {sHeros},function (msg)
	end)	
end

--析构方法
function HeroLineUpList:onDestroy(  )
	self:onPause()
end

--更新上阵数据
function HeroLineUpList:refreshLineUpData()

		--武将队列
	self.tHeroListData = {} --英雄队列数据
	local tHeroOnlineList = Player:getHeroInfo():getOnlineHeroList() --上阵队列
	self.tHeroOnlineList = tHeroOnlineList

	for i=1,4 do

		if tHeroOnlineList[i] then
			self.tHeroListData[i] = tHeroOnlineList[i]
		else
			--锁住类型待添加
			if i> Player:getHeroInfo().nOnlineNums then
				self.tHeroListData[i] = TypeIconHero.LOCK
			else
				self.tHeroListData[i] = TypeIconHero.ADD
			end
		end
	end
end

-- 注册消息
function HeroLineUpList:regMsgs( )
	-- body

end

-- 注销消息
function HeroLineUpList:unregMsgs(  )
	-- body
end
--暂停方法
function HeroLineUpList:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function HeroLineUpList:onResume( )
	-- body
	self:regMsgs()
end

return HeroLineUpList
