--region 战争大厅
--Author : wenzongyao
--Date   : 2018/3/20
--此文件由[BabeLua]插件自动生成

local DlgBase = require("app.common.dialog.DlgBase")
local ItemWarHall = require("app.layer.warhall.ItemWarHall")



local DlgWarHall = class("DlgWarHall", function()
	return DlgBase.new(e_dlg_index.dlgwarhall)
end)

function DlgWarHall:ctor(  )
	-- body
	self:myInit()
	
	parseView("dlg_war_hall", handler(self, self.onParseViewCallback))

end

--初始化成员变量
function DlgWarHall:myInit()
	-- body
end

--解析布局回调事件
function DlgWarHall:onParseViewCallback( pView )
	-- body
	self:setTitle(getConvertedStr(10, 10201))
	self.pView = pView
	self:addContentView(pView) --加入内容层
	--注册析构方法
	self:setDestroyHandler("DlgWarHall",handler(self, self.onDestroy))

	self:onResume()

end

-- 析构方法
function DlgWarHall:onDestroy(  )
	-- body
	self:onPause()

	--更新本地进入信息
	-- Player:flushActivityNew()
end

--暂停方法
function DlgWarHall:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgWarHall:onResume( _bReshow )
	-- body
	if(_bReshow and self.pListView) then
		-- 如果是重新显示，定位到顶部
		self.pListView:scrollToBegin()
	end
    self:setupViews()
	self:updateViews()
	self:regMsgs()	
end

-- 注册消息
function DlgWarHall:regMsgs( )
	regMsg(self, gud_war_hall_refresh, handler(self, self.updateViews))
end

-- 注销消息
function DlgWarHall:unregMsgs()
	unregMsg(self, gud_war_hall_refresh)
end

function DlgWarHall:setupViews()
    local pLayTop = self.pView:findViewByName("lay_top")
    setMBannerImage(pLayTop, TypeBannerUsed.zzdt)	
end

-- 修改控件内容或者是刷新控件数据
function DlgWarHall:updateViews()
    local tWarHallData = Player:getWarHall()
    self.tSysActivitys = tWarHallData:newListByType(1)    
    table.sort(self.tSysActivitys, function(a, b) 
        local lockA = a:isLock()
        local lockB = b:isLock()
        if lockA == lockB then --解锁
            return a.nSequence < b.nSequence --配置排序
        end    
        return lockB        
    end)

	--复用层
	if(not self.pLyList) then
		self.pLyList = self.pView:findViewByName("ly_list")
		self.pListView = createNewListView(self.pLyList)
		--上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)			
		self.pListView:setItemCallback(handler(self, self.onEveryCallback))
		self.pListView:setItemCount(#self.tSysActivitys)
		self.pListView:reload(true)
	else
		self.pListView:setItemCount(#self.tSysActivitys)
		self.pListView:notifyDataSetChange(true)
	end
end

-- 每帧回调 _index 下标 _pView 视图
function DlgWarHall:onEveryCallback( _index, _pView )
	local pView = _pView
	if not pView then
		if self.tSysActivitys[_index] then
			pView = ItemWarHall.new()
		end
	end

	if _index and self.tSysActivitys[_index] then
		pView:setCurData(self.tSysActivitys[_index])	
	end

	return pView
end


return DlgWarHall

--endregion
