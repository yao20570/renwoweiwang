-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-12-15 15:00:23 星期一
-- Description: 竞技场 竞技场分页
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemBattleRecord = require("app.layer.arena.ItemBattleRecord")
local ItemFooterTip = require("app.layer.arena.ItemFooterTip")
local ArenaRecordListLayer = class("ArenaRecordListLayer", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

function ArenaRecordListLayer:ctor(_tSize, _nIndex)
	-- body
	self:setContentSize(_tSize)
	self:myInit()
	self.nIndex = _nIndex or self.nIndex
	self:setupViews()	
	self:onResume()
	 --注册析构方法
	self:setDestroyHandler("ArenaRecordListLayer",handler(self, self.onDestroy))		
end

-- --初始化参数
function ArenaRecordListLayer:myInit()
	-- body
	self.nIndex = 1
end

--初始化控件
function ArenaRecordListLayer:setupViews( )
	-- body	

end

-- 修改控件内容或者是刷新控件数据
function ArenaRecordListLayer:updateViews(  )
	-- body
	local pData = Player:getArenaData()	
	if not pData then
		return
	end		
	if self.nIndex == 1 then--自己的战斗记录
		self.tDataList = pData:getMyFightRecords()		
	elseif self.nIndex == 2 then--自己的大神的战斗记录
		self.tDataList = pData:getGodsFightRecords()		
	end
	local nItemCnt = #self.tDataList 
	local nListWidth = 600
	if not self.pListView then
	    self.pListView = MUI.MListView.new {
            bgColor = cc.c4b(255, 255, 255, 250),
            viewRect = cc.rect(0, 0, self:getWidth(), self:getHeight()),
            itemMargin = {left = 0,
            right = 0,
            top = 10 ,
            bottom = 10 },
            direction = MUI.MScrollView.DIRECTION_VERTICAL ,--listView方向
        }
        self.pListView:setBounceable(true) --是否回弹        
        -- self.pListView:setPosition((self:getWidth() - self.pListView:getWidth())/2, 0)
        self:addView(self.pListView, 10)
        --上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)
		-- self:refreshFooterItem()
		self.pListView:setItemCount(nItemCnt)
		self.pListView:setItemCallback(handler(self, self.onEveryCallback))		
		self.pListView:reload(false)	
	else		
		-- self:refreshFooterItem()
		self.pListView:notifyDataSetChange(false, nItemCnt)
	end

	local bShow = nItemCnt <= 0
	--没有数据提示
	local tLabel = {
	    str = getConvertedStr(6, 10466),
	}
	if not self.pNullUi then
		local pNullUi = getLayNullUiImgAndTxt(tLabel)
		pNullUi:setIgnoreOtherHeight(true)
		self:addView(pNullUi)
		centerInView(self, pNullUi)
		self.pNullUi = pNullUi
	end
	self.pNullUi:setVisible(bShow)		
end

function ArenaRecordListLayer:refreshFooterItem(  )
	-- body	
	if not self.pFooterView then
		self.pFooterView = ItemFooterTip.new()
		self.pListView:addFooterView(self.pFooterView)
		self.pFooterView:setData({color=_cc.pwhite, text=getConvertedStr(6, 10817)})
		self.pFooterView:setItemClickHandler(handler(self, self.onGetMore))
	end	
end

function ArenaRecordListLayer:removeFooterView(  )
	-- body
	self.pListView:removeFooterView()
	self.pFooterView = nil
end

-- function ArenaRecordListLayer:updateFightRecordRed(  )
-- 	-- body
-- 	local pData = Player:getArenaData()	
-- 	if not pData then
-- 		return
-- 	end				
-- 	showRedTips(self.pLayRecordBtnRed,0,pData:getMyFightRed())	
-- end

function ArenaRecordListLayer:updateListView(  )
	-- body

end

function ArenaRecordListLayer:onEveryCallback ( _index, _pView ) 
    local pView = _pView
	if not pView then
		pView = ItemBattleRecord.new()				
	end
	pView:setCurData(self.tDataList[_index], self.nIndex)	
	return pView
end
--点击获取更多
function ArenaRecordListLayer:onGetMore(  )
	-- body
	print("点击获取更多")
end

--析构方法
function ArenaRecordListLayer:onDestroy(  )
	self:onPause()
end

-- 注册消息
function ArenaRecordListLayer:regMsgs( )
	-- body
end

-- 注销消息
function ArenaRecordListLayer:unregMsgs(  )
	-- body
end
--暂停方法
function ArenaRecordListLayer:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function ArenaRecordListLayer:onResume( )
	-- body
	self:regMsgs()
	self:updateViews()
end

return ArenaRecordListLayer
