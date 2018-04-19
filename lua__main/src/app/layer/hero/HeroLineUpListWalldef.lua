----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-12-25 11:01:01
-- Description: 上阵武将界面的采集列表布局
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemOnlineHeroWalldef = require("app.layer.hero.ItemOnlineHeroWalldef")
local DragChangeListView = require("app.layer.world.DragChangeListView")

local HeroLineUpListWalldef = class("HeroLineUpListWalldef", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)


function HeroLineUpListWalldef:ctor(_listType)
	-- body
	self:myInit(_listType)
	parseView("layout_hero_line_up_list", handler(self, self.onParseViewCallback))
end

--解析布局回调事件
function HeroLineUpListWalldef:onParseViewCallback( pView )
	-- body
	self:addView(pView)
	self:setupViews()
	
	self:onResume()
	 --注册析构方法
	self:setDestroyHandler("HeroLineUpListWalldef",handler(self, self.onDestroy))
end

-- --初始化参数
function HeroLineUpListWalldef:myInit(_listType)
	-- body
	self.tHeroListData = {} --英雄队列数据

	self.tHeroListItem = {} --英雄队列item

	self.nListType=_listType or 1
end

--初始化控件
function HeroLineUpListWalldef:setupViews( )
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
function HeroLineUpListWalldef:updateViews(  )
	--刷新武将数据
	self:refreshDefenseData()
	local tItems = self.pDragChangeListView:getAllItemList()	
	--武将item
	for newIndex = 1, 4 do
		local pData = self.tHeroListData[newIndex]
		local pItem = tItems[newIndex]
		if(not self.tHeroListItem[newIndex]) then
			self.tHeroListItem[newIndex] =  ItemOnlineHeroWalldef.new(pData,newIndex, self.nListType)
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
    --
    self:checkFillNaili()
end

function HeroLineUpListWalldef:onItemChange( ... )
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
	SocketManager:sendMsg("editDefHeros", {sHeros},function (msg)
	end)	
	
end

--析构方法
function HeroLineUpListWalldef:onDestroy(  )
	self:onPause()
end

--更新城防数据
function HeroLineUpListWalldef:refreshDefenseData()

		--武将队列
	self.tHeroListData = {} --英雄队列数据
	local tHeroOnlineList = Player:getHeroInfo():getDefenseHeroList() --城防队列
	self.tHeroOnlineList = tHeroOnlineList

	--上锁下标
	local nUnLockIndex = Player:getHeroInfo():getDefenseQueueNums()
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
function HeroLineUpListWalldef:regMsgs( )
	regMsg(self, gud_tcf_hero_pos_unlock_push, handler(self, self.updateViews))
	-- 注册粮草更新
	regMsg(self, gud_refresh_playerinfo, handler(self, self.checkFillNaili))
	-- 统帅府自动补充耐力
	regMsg(self, gud_tcf_auto_add_naili, handler(self, self.checkFillNaili))
	--
	regMsg(self, gud_refresh_hero, handler(self, self.updateViews))
end

-- 注销消息
function HeroLineUpListWalldef:unregMsgs(  )
	unregMsg(self, gud_tcf_hero_pos_unlock_push)
	-- 注册粮草更新
	unregMsg(self, gud_refresh_playerinfo)
	-- 统帅府自动补充耐力
	unregMsg(self, gud_tcf_auto_add_naili)

	unregMsg(self, gud_refresh_hero)
end
--暂停方法
function HeroLineUpListWalldef:onPause( )
	-- body
	self:unregMsgs()
	unregUpdateControl(self)
end

--继续方法
function HeroLineUpListWalldef:onResume( )
	self:updateViews()
	self:regMsgs()
end

--更新cd时间
function HeroLineUpListWalldef:updateCd( )
	local nBestIndex = nil
	local nBestNaili = nil
	for i=1,#self.tHeroListItem do
		if self.tHeroListItem[i]:getIsNeedFillNaili() then
			local nCurr = self.tHeroListItem[i]:getWalldefStamina()
			if nBestIndex then
				if nCurr > nBestNaili then
					nBestIndex = i
					nBestNaili = nCurr
				end
			else
				nBestIndex = i
				nBestNaili = nCurr
			end
		end
	end

	for i=1,#self.tHeroListItem do
		if nBestIndex == i then
			self.tHeroListItem[i]:updateCd(true, true)
		else
			self.tHeroListItem[i]:updateCd(false, true)
		end
	end
end

--统帅府自动耐力
function HeroLineUpListWalldef:checkFillNaili(  )
	local bIsAuto = getIsOpenNailiFill()
	if bIsAuto then
		self:updateCd()
		regUpdateControl(self, handler(self, self.updateCd))
	else
		unregUpdateControl(self)
		--停止所有更新
		for i,v in ipairs(self.tHeroListItem) do
			v:updateCd(false, false)
		end
	end
end

return HeroLineUpListWalldef
