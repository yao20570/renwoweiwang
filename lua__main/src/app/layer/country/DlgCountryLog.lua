-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-06-5 15:10:23 星期一
-- Description: 国家日志界面
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local ItemCountryLog = require("app.layer.country.ItemCountryLog")

local DlgCountryLog = class("DlgCountryLog", function()
	-- body
	return DlgBase.new(e_dlg_index.dlgcountrylog)
end)

function DlgCountryLog:ctor(  )
	-- body
	self:myInit()
	parseView("dlg_country_log", handler(self, self.onParseViewCallback))
end

function DlgCountryLog:myInit(  )
	-- body
	self.pDataList = nil
end

--解析布局回调事件
function DlgCountryLog:onParseViewCallback( pView )
	-- body
	--设置标题	
	self:setTitle(getConvertedStr(6,10323))	
	self:addContentView(pView) --加入内容层
	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgCountryLog",handler(self, self.onDlgCountryLogDestroy))
end

--初始化控件
function DlgCountryLog:setupViews(  )
	-- body	


	--

end

--控件刷新
function DlgCountryLog:updateViews(  )
	-- body	

	if not self.pLayTitle then
		self.pLayTitle = self:findViewByName("lay_title")
	end
	if not self.pLbTitle1 then
		self.pLbTitle1 = self:findViewByName("lb_title_1")
		self.pLbTitle1:setString(getConvertedStr(6, 10351))
	end
	if not self.pLbTitle2 then
		self.pLbTitle2 = self:findViewByName("lb_title_2")
		self.pLbTitle2:setString(getConvertedStr(6, 10352))
	end
	local nItemCnt = 0
	self.pDataList = Player:getCountryData():getCountryLog()
	if self.pDataList and #self.pDataList > 0 then
		nItemCnt = #self.pDataList
	end
	if not self.pListView then
		self.pLayList = self:findViewByName("lay_list")
		self.pListView = MUI.MListView.new {
	        bgColor = cc.c4b(255, 255, 255, 250),
	        viewRect = cc.rect(0, 0, self.pLayList:getWidth(), self.pLayList:getHeight()),
	        direction = MUI.MScrollView.DIRECTION_VERTICAL,
	        itemMargin = {left =  0,
	         right =  0,
	         top =  0,
	         bottom =  0}}
		self.pLayList:addView(self.pListView, 10)   
		self.pListView:setBounceable(true)
	    self.pListView:setItemCallback(handler(self, self.onListViewItemCallBack))
	    self.pListView:setItemCount(nItemCnt)      
    	self.pListView:reload(true)
    else
    	self.pListView:notifyDataSetChange(true, nItemCnt)		
	end	
end

--析构方法
function DlgCountryLog:onDlgCountryLogDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgCountryLog:regMsgs(  )
	-- body
	regMsg(self, gud_refresh_country_log_msg, handler(self, self.updateViews))
end
--注销消息
function DlgCountryLog:unregMsgs(  )
	-- body
	unregMsg(self, gud_refresh_country_log_msg)
end

--暂停方法
function DlgCountryLog:onPause( )
	-- body	
	self:unregMsgs()	
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgCountryLog:onResume( _bReshow )
	-- body
	if _bReshow and self.pListView then
		-- 如果是重新显示，定位到顶部
		self.pListView:scrollToBegin()	
	end
	self:updateViews()
	self:regMsgs()
end

function DlgCountryLog:onListViewItemCallBack( _index, _pView  )
	-- body
	local pTempView = _pView
    if pTempView == nil then
        pTempView = ItemCountryLog.new()                        
        pTempView:setViewTouched(false)        
    end
    if self.pDataList and self.pDataList[_index] then
		pTempView:setCurData(self.pDataList[_index])
    end        	
    return pTempView
end
return DlgCountryLog