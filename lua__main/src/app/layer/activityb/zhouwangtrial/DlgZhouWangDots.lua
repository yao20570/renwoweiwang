----------------------------------------------------- 
-- author: maheng
-- updatetime: 2018-04-09 20:45:00
-- Description: 纣王试炼点信息列表
-----------------------------------------------------

-- 乱军详情界面
local DlgCommon = require("app.common.dialog.DlgCommon")
local ItemZhouWangDotInfo =  require("app.layer.activityb.zhouwangtrial.ItemZhouWangDotInfo")			
local DlgZhouWangDots = class("DlgZhouWangDots", function()
	return DlgCommon.new(e_dlg_index.dlgzhouwangdots)
end)

function DlgZhouWangDots:ctor(  )
	parseView("layout_kingzhou_list", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgZhouWangDots:onParseViewCallback( pView )
	self.pView = pView
	self:addContentView(pView, true) --加入内容层

	self:setTitle(getConvertedStr(3, 10501))

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgZhouWangDots",handler(self, self.onDestroy))
end

-- 析构方法
function DlgZhouWangDots:onDestroy(  )
    self:onPause()
end

function DlgZhouWangDots:regMsgs(  )
end

function DlgZhouWangDots:unregMsgs(  )
end

function DlgZhouWangDots:onResume(  )
	self:regMsgs()	
end

function DlgZhouWangDots:onPause(  )
	self:unregMsgs()	
end

function DlgZhouWangDots:setupViews(  )
	--ui位置更新
	self.pLyRoot = self:findViewByName("lay_root")
	self.pLbTitle = self:findViewByName("lb_list_title")
	self.pLayList = self:findViewByName("lay_list")

	self:getOnlyConfirmButton(TypeCommonBtn.L_YELLOW, getConvertedStr(6, 10851))
	self:setRightHandler(handler(self, self.onCheckAct))
end

function DlgZhouWangDots:updateViews(  )
	local pData = Player:getWorldData()
	if not pData then
		return
	end
	local tDots = Player:getWorldData():getBlockKingZhou(Player:getWorldData():getMyCityBlockId())
	self.tDataList = {}
	for k, v in pairs(tDots) do
		table.insert(self.tDataList, v)
	end
	local nX, nY = Player:getWorldData():getMyCityDotPos()
	table.sort(self.tDataList, function ( a, b )
		-- body
		return WorldFunc.getArmyDistance(nX, nY, a.nX, a.nY) < WorldFunc.getArmyDistance(nX, nY, b.nX, b.nY)
	end)
	local nItemCnt = #self.tDataList
	local sStr = {
		{color=_cc.pwhite, text=getConvertedStr(6, 10849)},
		{color=_cc.blue,text=nItemCnt},
		{color=_cc.pwhite, text=getConvertedStr(1, 10370)},
	}
	self.pLbTitle:setString(sStr, false)
	if not self.pListView then
		self.pListView = MUI.MListView.new {
		    viewRect   = cc.rect(0, 0, self.pLayList:getContentSize().width, self.pLayList:getContentSize().height),
		    direction  = MUI.MScrollView.DIRECTION_VERTICAL,
		    itemMargin = {left =  0,
		        right =  0,
		        top =  5,
		        bottom =  5},
		}
		self.pLayList:addView(self.pListView)
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)			
		self.pListView:setItemCount(nItemCnt) 
		self.pListView:setItemCallback(handler(self, self.onListViewItemCallBack))
		self.pListView:reload(false)
	else
		self.pListView:notifyDataSetChange(false, nItemCnt)
	end
end

--列表回调
function DlgZhouWangDots:onListViewItemCallBack( _index, _pView)
	local pTempView = _pView
    if pTempView == nil then
        pTempView = ItemZhouWangDotInfo.new()                        
        pTempView:setViewTouched(false)
    end        
    if self.tDataList and self.tDataList[_index] then
    	pTempView:setCurData(self.tDataList[_index])
	end
    return pTempView
end

function DlgZhouWangDots:onCheckAct( )
	-- body	
	local tObject = {}
	tObject.nType = e_dlg_index.zhouwangtrial --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)
	closeDlgByType(e_dlg_index.dlgzhouwangdots, false)
end

return DlgZhouWangDots
