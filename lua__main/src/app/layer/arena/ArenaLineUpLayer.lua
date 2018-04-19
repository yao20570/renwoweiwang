-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-03-21 17:55:23 星期三
-- Description: 竞技场 阵容分页
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local DlgAlert = require("app.common.dialog.DlgAlert")
local HomeBuffsLayer = require("app.layer.home.HomeBuffsLayer")
local ArenaFunc = require("app.layer.arena.ArenaFunc")
local DragChangeListView = require("app.layer.world.DragChangeListView")
local ItemArenaLineupHero = require("app.layer.arena.ItemArenaLineupHero")
local ArenaLineUpLayer = class("ArenaLineUpLayer", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)


function ArenaLineUpLayer:ctor(_tSize)
	-- body
	self:setContentSize(_tSize)
	self:myInit()
	parseView("lay_arena_lineup", handler(self, self.onParseViewCallback))
end
--解析布局回调事件
function ArenaLineUpLayer:onParseViewCallback( pView )
	-- body
	
	self:addView(pView)
	self:setupViews()	
	self:onResume()
	 --注册析构方法
	self:setDestroyHandler("ArenaLineUpLayer",handler(self, self.onDestroy))
end

-- --初始化参数
function ArenaLineUpLayer:myInit()
	-- body
	self.tHeroListItem = {} --英雄队列item
	self.bChanged = false
end

--初始化控件
function ArenaLineUpLayer:setupViews( )
	-- body	
	self.pLayTop = self:findViewByName("lay_top_info")
	self.pLbDesc = self:findViewByName("lb_des")
	self.pImgFont = self:findViewByName("img_font")
	self.pLbZhanli  = self:findViewByName("lb_zhanli")
	self.pLayList 		= 		self:findViewByName("lay_list")
	self.pLayBtnBot 	= 		self:findViewByName("lay_btn")	
	self.pLayDrag = self:findViewByName("lay_drag")
	setTextCCColor(self.pLbZhanli, _cc.yellow)

	self.pBuffsLayer = HomeBuffsLayer.new()
	self.pBuffsLayer:setBgVisible(false)
	self.pBuffsLayer:setPosition(self.pLayTop:getWidth() - self.pBuffsLayer:getWidth() - 20, (self.pLayTop:getHeight() - self.pBuffsLayer:getHeight())/2)
	self.pLayTop:addView(self.pBuffsLayer, 10)

	self.pLbDesc:setString(getTipsByIndex(20139), false)
	--底部保存阵容按钮
	self.pBtnBot = getCommonButtonOfContainer(self.pLayBtnBot,TypeCommonBtn.L_BLUE,getConvertedStr(7,10384))    
	self.pBtnBot:onCommonBtnClicked(handler(self, self.onBotBtnClicked))		

	self.tConfigs = {
		{x = 0, w = 600,h = 140},
		{x = 0, w = 600,h = 140},
		{x = 0, w = 600,h = 140},
		{x = 0, w = 600,h = 140},
	}

	local pSize = self.pLayDrag:getContentSize()
	local pDragChangeListView = DragChangeListView.new(pSize, 2)
	pDragChangeListView:setPosition(0, 0)
	pDragChangeListView:setChangeSuccessHandler(handler(self, self.onItemChange))
	self.pDragChangeListView = pDragChangeListView
	self.pLayDrag:addView(pDragChangeListView)	

end

-- 修改控件内容或者是刷新控件数据
function ArenaLineUpLayer:updateViews(  )
	-- body
	local pData = Player:getArenaData()	
	if not pData then
		return
	end		
	self:refreshLineUpData()
	--当前竞技场战力
	self.pLbZhanli:setString(pData.nTsc, false)
	
	local tItems = self.pDragChangeListView:getAllItemList()
	local fY = self.pLayDrag:getHeight()
	for newIndex = 1, 4 do
		local pHero = self.tHeroListData[newIndex]
		local pItem = tItems[newIndex]
		if(not self.tHeroListItem[newIndex]) then			
			self.tHeroListItem[newIndex] =  ItemArenaLineupHero.new(pHero, newIndex)
			local tConf = self.tConfigs[newIndex]
			local fX = tConf.x
			fY = fY - tConf.h - 10						
			self.pDragChangeListView:addItem(self.tHeroListItem[newIndex],cc.p(fX, fY))			
		else
			pItem:setCurData(pHero, newIndex)	
		end					
		if type(pHero) == "table" then
			self.pDragChangeListView:includeItem(pItem)
		elseif pHero == TypeIconHero.LOCK or pHero == TypeIconHero.ADD then
			self.pDragChangeListView:excludeItem(pItem)
		end
    end		
end

--更新上阵数据
function ArenaLineUpLayer:refreshLineUpData()

		--武将队列
	self.tHeroListData = {} --英雄队列数据
	local tHeroOnlineList = Player:getArenaData():getArenaLineUp() --上阵阵容
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

function ArenaLineUpLayer:adjustLineUp( sMsgName, pMsgObj )
	-- body
	-- dump(pMsgObj, "pMsgObj", 100)
	if not pMsgObj then
		return
	end
	local nIdx = pMsgObj.nIdx
	local pHero = pMsgObj.pHeroData
	if not pHero then
		return
	end
	local tHeroList = self.pDragChangeListView:getItemList()
	if nIdx >= 1 and (nIdx <= table.nums(self.tHeroOnlineList)) then
		tHeroList[nIdx]:setCurData(pHero)
		self:onItemChange()
	elseif nIdx == table.nums(self.tHeroOnlineList) + 1 then
		self.tHeroOnlineList[nIdx] = pHero		
		ArenaFunc.adjustArenaLineUp(false, self.tHeroOnlineList)
	end
end

function ArenaLineUpLayer:onItemChange(  )
	-- body
	local tItem = self.pDragChangeListView:getItemList()
	local tData = {}
	for k, v in pairs(tItem) do
		table.insert(tData, v:getData())
	end	
	ArenaFunc.adjustArenaLineUp(false, tData)
end

-- 最大战力
function ArenaLineUpLayer:onBotBtnClicked(  )
	--保存阵容
	local pData = Player:getArenaData()
	if not pData then
		return
	end	
	ArenaFunc.adjustArenaLineUp(false, pData:getArenaBestHeros())
end

function ArenaLineUpLayer:showArenaLineUpTip( )
	-- body
	if self.bChanged then
		local pDlg, bNew = getDlgByType(e_dlg_index.alert)
	    if(not pDlg) then
	        pDlg = DlgAlert.new(e_dlg_index.alert)
	    end
	    pDlg:setTitle(getConvertedStr(3, 10091))
	    pDlg:setContent(getConvertedStr(6, 10826))
	    pDlg:getRightButton():updateBtnText(getConvertedStr(6, 10811))
	    pDlg:setRightHandler(function (  )            
	 		ArenaFunc.adjustArenaLineUp(false, self.tHeroOnlineList)
	        closeDlgByType(e_dlg_index.alert, false)  
	    end)
	    pDlg:showDlg(bNew)   
	    return pDlg			
	end
end

--析构方法
function ArenaLineUpLayer:onDestroy(  )
	self:onPause()
end

-- 注册消息
function ArenaLineUpLayer:regMsgs( )
	-- body	
	--竞技场玩家配置数据刷新	
	regMsg(self, gud_refresh_arena_msg, handler(self, self.updateViews))
    -- 注册玩家战力变化
    regMsg(self, gud_refresh_playerinfo, handler(self, self.updateViews))
 	-- 注册玩家调整整容消息
 	regMsg(self, ghd_adjust_arena_hero_msg, handler(self, self.adjustLineUp))
end

-- 注销消息
function ArenaLineUpLayer:unregMsgs(  )
	-- body	
	unregMsg(self, gud_refresh_arena_msg)	
	unregMsg(self, gud_refresh_playerinfo)
	unregMsg(self, ghd_adjust_arena_hero_msg)		
end
--暂停方法
function ArenaLineUpLayer:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function ArenaLineUpLayer:onResume( )
	-- body
	self:regMsgs()
	self:updateViews()
end

return ArenaLineUpLayer
