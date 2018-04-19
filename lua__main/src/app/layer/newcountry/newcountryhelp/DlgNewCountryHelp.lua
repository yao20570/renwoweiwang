-----------------------------------------------------
-- author: xiesite
-- updatetime:  2018-3-29 14:22:21
-- Description: 新国家互助
-----------------------------------------------------
local DlgBase = require("app.common.dialog.DlgBase")
local DlgAlert = require("app.common.dialog.DlgAlert")

local ItemCountryHelp = require("app.layer.newcountry.newcountryhelp.ItemCountryHelp")

local DlgNewCountryHelp = class("DlgNewCountryHelp", function()
	-- body
	return DlgBase.new(e_dlg_index.newcountryhelp)
end)

function DlgNewCountryHelp:ctor(  )
	-- body
	self:myInit()
	parseView("dlg_new_country_help", handler(self, self.onParseViewCallback))
end

function DlgNewCountryHelp:myInit(  )
 
end

--解析布局回调事件
function DlgNewCountryHelp:onParseViewCallback( pView )
	-- body
	self:addContentView(pView) --加入内容层
	--设置标题
	self:setTitle(getConvertedStr(1, 10413))
	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgNewCountryHelp",handler(self, self.onDestroy))
end

--初始化控件
function DlgNewCountryHelp:setupViews()
 	--lay_list
 	self.pLyList = self:findViewByName("lay_list")   --items
 	self.pLayBtn  = self:findViewByName("lay_btn")    --按钮层
 	self.pBtn = getCommonButtonOfContainer(self.pLayBtn ,TypeCommonBtn.l_BLUE,getConvertedStr(1,10410))
	self.pBtn:onCommonBtnClicked(handler(self, self.onClickHelpAll))


	--没有数据提示
	local tLabel = {
	    str = getConvertedStr(3, 10220),
	}
	local pNullUi = getLayNullUiImgAndTxt(tLabel)
	pNullUi:setIgnoreOtherHeight(true)
	self.pLyList:addView(pNullUi)
	centerInView(self.pLyList, pNullUi)
	self.pNullUi = pNullUi
	self.pNullUi:setVisible(false)
end

--控件刷新
function DlgNewCountryHelp:updateViews( )
	local tList = Player:getCountryHelpData():getHelps()
 	self:setItemListViewData(tList)
end

function DlgNewCountryHelp:onClickHelpAll( )
	local _tData = Player:getCountryHelpData()
	if not _tData then
		return
	end
	if _tData:haveHelps() then
		SocketManager:sendMsg("countryhelp", {2})
	else
		TOAST(getConvertedStr(1,10427))
	end
end

--列表项回调
function DlgNewCountryHelp:onItemListViewCallBack( _index, _pView )
	-- body
	local tTempData = self.tDropList[_index]
    local pTempView = _pView
	if pTempView == nil then
		pTempView = ItemCountryHelp.new()
	end
 	
	pTempView:setCurData(tTempData) 
    return pTempView
end

--设置数据
-- tDropList:List<Pair<Integer,Long>>
function DlgNewCountryHelp:setItemListViewData( tDropList )
	if not tDropList then
		return
	end
	self.tDropList = tDropList
	local nCurrCount = #self.tDropList
	--容错
	if not self.pListView then
		local pLayGoods = self.pLyList
		self.pListView = MUI.MListView.new {
		     	viewRect   = cc.rect(0, 0, pLayGoods:getContentSize().width, pLayGoods:getContentSize().height),
		        direction  = MUI.MScrollView.DIRECTION_VERTICAL,
		        itemMargin = {left = 0,
		            right = 0,
		            top = 0,
		            bottom = 12},
		}
		pLayGoods:addView(self.pListView)
		centerInView(pLayGoods, self.pListView)
		self.pListView:setItemCallback(handler(self, self.onItemListViewCallBack))
		self.pListView:setItemCount(nCurrCount)
		self.pListView:reload(true)
	else
		self.pListView:notifyDataSetChange(true, nCurrCount)
	end
	self.pNullUi:setVisible(nCurrCount == 0)
end

--析构方法
function DlgNewCountryHelp:onDestroy()
	-- body
	self:onPause()
end

--注册消息
function DlgNewCountryHelp:regMsgs(  )
	regMsg(self, gud_refresh_countryhelp, handler(self, self.updateViews))
end
--注销消息
function DlgNewCountryHelp:unregMsgs( )
	unregMsg(self, gud_refresh_countryhelp)
end

--暂停方法
function DlgNewCountryHelp:onPause( )
	-- body		
	self:unregMsgs()	

end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgNewCountryHelp:onResume( _bReshow )
	-- body		
	self:regMsgs()	
	self:updateViews()
end

return DlgNewCountryHelp