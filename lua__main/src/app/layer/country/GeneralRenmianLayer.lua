----------------------------------------------------- 
-- author: maheng
-- updatetime: 2017-06-08 14:28:14
-- Description: 将军任免层
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local ItemVoteLayer = require("app.layer.country.ItemVoteLayer")

local GeneralRenmianLayer = class("GeneralRenmianLayer", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)


function GeneralRenmianLayer:ctor( _type )
	-- body
	self:myInit(_type)
	parseView("general_renmian_layer", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function GeneralRenmianLayer:myInit( _type )
	-- body
	self.tTitleGroup = nil
	self.nType = _type or 0
	self.pDataList = {}
	self.tItemGroup = {}
	self.nItemCnt = 0
	self.pListView = nil	
end

--解析布局回调事件
function GeneralRenmianLayer:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("GeneralRenmianLayer",handler(self, self.onGeneralRenmianLayerDestroy))
end

--初始化控件
function GeneralRenmianLayer:setupViews( )
	-- body
	self.pLayRoot = self:findViewByName("root")
	self.pLayTitle = self:findViewByName("lay_title")	
	self.tTitleGroup = {}
	local nwidth = self.pLayTitle:getWidth()/4
	local y = self.pLayTitle:getHeight()/2
	for i = 1, 4 do
		local label = self:findViewByName("lb_title_"..i)
		label:setPosition(nwidth/2 + (i - 1)*nwidth, y)
		setTextCCColor(label, _cc.pwhite)
		self.tTitleGroup[i] = label
	end

	self.nItemCnt = getOfficialNum(e_official_ids.general)--获得国家将军数量
	self.tTitleGroup[1]:setString(getConvertedStr(6, 10342))--默认罢免
	if self.nType == 1 then--任命
		self.tTitleGroup[1]:setString(getConvertedStr(6, 10346))
		local svalue = getCountryParam("scoreN")
		self.nItemCnt = tonumber(svalue)--将军预选名额
	end
	self.tTitleGroup[2]:setString(getConvertedStr(6, 10343))
	self.tTitleGroup[3]:setString(getConvertedStr(6, 10344))
	self.tTitleGroup[4]:setString(getConvertedStr(6, 10345))

	self.pLayContent = self:findViewByName("lay_content")

	self:resetView()
end

-- 修改控件内容或者是刷新控件数据
function GeneralRenmianLayer:updateViews( )
	-- body
	if self.nType == 0 then
		for i = 1, self.nItemCnt do	
			if self.pDataList[i] then
				self.tItemGroup[i]:showGeneralInfo(self.pDataList[i])
				self.tItemGroup[i]:setBtnVisible(true)
			else
				self.tItemGroup[i]:showEmpty(getConvertedStr(6, 10399))
			end			
		end
	elseif self.nType == 1 then	
		self.pListView:notifyDataSetChange(true, table.nums(self.pDataList))
	end
end

-- 析构方法
function GeneralRenmianLayer:onGeneralRenmianLayerDestroy(  )
	-- body
end

function GeneralRenmianLayer:setCurData( _tdatalist)
	-- body
	self.pDataList = _tdatalist or {}
	self:updateViews()
end
--重新设置布局
function GeneralRenmianLayer:resetView(  )
	-- body
	--清空原有数据
	self:clearAllItem()
	if self.pListView then
		self.pListView:removeSelf()
		self.pListView = nil
	end		
	local nItemHeight = 58
	if self.nType == 0 then --罢免
		self.pLayContent:setLayoutSize(self.pLayTitle:getWidth(), nItemHeight*self.nItemCnt)
		local y = self.pLayContent:getHeight() - nItemHeight
		for i = 1, self.nItemCnt do
			local itemlayer = ItemVoteLayer.new()
			itemlayer:setPosition(0, y)
			table.insert(self.tItemGroup, itemlayer) 
			itemlayer:setViewTouched(false)
			local btn = itemlayer:getBtn()
			itemlayer:setBtnVisible(true)  
			btn:updateBtnType(TypeCommonBtn.M_RED)
			btn:updateBtnText(getConvertedStr(6, 10349))
			itemlayer:setOperateHandler(handler(self, self.onReCallBtnClick))
			self.pLayContent:addView(itemlayer, 10)			
			y = y - nItemHeight			
		end		
	elseif self.nType == 1 then--任命
		self.pLayContent:setLayoutSize(self.pLayTitle:getWidth(), 365)
		self.pListView = MUI.MListView.new {
	        bgColor = cc.c4b(255, 255, 255, 250),
	        viewRect = cc.rect(0, 0, self.pLayContent:getWidth(), self.pLayContent:getHeight()),
	        direction = MUI.MScrollView.DIRECTION_VERTICAL,
	        itemMargin = {left =  0,
	         right =  0,
	         top =  0,
	         bottom =  0}}
		self.pLayContent:addView(self.pListView, 10)   
		self.pListView:setBounceable(true)    
	    self.pListView:setItemCallback(handler(self, self.onListViewItemCallBack))
	    self.pListView:setItemCount(0)  
	    self.pListView:reload(true)
	else
		return
	end
	self.pLayTitle:setPosition(0, self.pLayContent:getHeight())
	self.pLayRoot:setLayoutSize(self.pLayTitle:getWidth(), self.pLayTitle:getHeight() + self.pLayContent:getHeight())
	self:setLayoutSize(self.pLayRoot:getWidth(), self.pLayRoot:getHeight())
end
--
function GeneralRenmianLayer:clearAllItem(  )
	-- body
	if self.tItemGroup and #self.tItemGroup > 0 then
		for i, v in pairs(self.tItemGroup) do
			if v then
				v:removeSelf()				
			end
		end
	end
	self.tItemGroup = {}
end

function GeneralRenmianLayer:onListViewItemCallBack( _index, _pView )
	-- body
	local pTempView = _pView
    if pTempView == nil then
        pTempView = ItemVoteLayer.new()                        
        pTempView:setViewTouched(false)
        pTempView:setBtnVisible(true)
        local btn = pTempView:getBtn()
		btn:updateBtnType(TypeCommonBtn.M_BLUE)
		btn:updateBtnText(getConvertedStr(6, 10350))
        pTempView:setOperateHandler(handler(self, self.onAppointBtnClick))
    end            
	pTempView:showGeneralInfo(self.pDataList[_index])	
    return pTempView	
end
--雇用按钮回调
function GeneralRenmianLayer:onAppointBtnClick( _data )
	-- body
	local pData = Player:getCountryData():getCountryDataVo()
	if pData and pData:isKing() then		
		local DlgAlert = require("app.common.dialog.DlgAlert")
		local MRichLabel = require("app.common.richview.MRichLabel")
		local pDlg, bNew = getDlgByType(e_dlg_index.alert)
	    if(not pDlg) then
	        pDlg = DlgAlert.new(e_dlg_index.alert)
	    end
	    pDlg:setTitle(getConvertedStr(3, 10091))

	    local tStr = {
	    	{color=_cc.white,text=getConvertedStr(6, 10400)},
		    {color=_cc.blue,text=_data.sName},
		    {color=_cc.white,text=getConvertedStr(6, 10401)},
		}
		local pRichLabel = MRichLabel.new({str = tStr, fontSize = 20, rowWidth = 380})
	    pDlg:addContentView(pRichLabel)
	    pDlg:setRightHandler(function (  )
	        SocketManager:sendMsg("appoinrGeneral", {_data.nID})
	        pDlg:closeDlg(false)
	    end)
	    pDlg:showDlg(bNew)
	else		
		TOAST(getConvertedStr(1, 10432))
	end
end

--罢免按钮回调
function GeneralRenmianLayer:onReCallBtnClick( _data )
	-- body
	local pData = Player:getCountryData():getCountryDataVo()
	if pData and pData:isKing() then		
		local trecalcost = luaSplit(getCountryParam("removeOfficial"), ":")	
		local resid = tonumber(trecalcost[1])
		local ncost = tonumber(trecalcost[2])
		if resid == e_resdata_ids.ybao then
		    local strTips = {
		    	{color=_cc.pwhite,text=getConvertedStr(6, 10349)},--罢免
		    	{color=_cc.blue,text=_data.sName},--名字
		    	{color=_cc.pwhite,text=getConvertedStr(6, 10402)},--任命
		    }
		    --展示购买对话框
			showBuyDlg(strTips,ncost,function (  )
				-- body
				--请求协议
				SocketManager:sendMsg("recallGeneral", {_data.nID})
			end, 0, true)
		else
			SocketManager:sendMsg("recallGeneral", {_data.nID})		
		end
	else		
		TOAST(getConvertedStr(1, 10432))
	end
end
return GeneralRenmianLayer


