-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-06-10 15:37:24 星期liu
-- Description: 爵位升级
-----------------------------------------------------
local DlgCommon = require("app.common.dialog.DlgCommon")
local ItemNobilityPromote = require("app.layer.country.ItemNobilityPromote")

local DlgNobilityPromote = class("DlgNobilityPromote", function()
	-- body
	return DlgCommon.new(e_dlg_index.dlgnobilitypromote)
end)
local nContHeight = 550
function DlgNobilityPromote:ctor(  )
	-- body
	self:myInit()
	parseView("dlg_nobility_promote", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgNobilityPromote:myInit(  )
	-- body
	self.tResGroup = {}
end

--解析布局回调事件
function DlgNobilityPromote:onParseViewCallback( pView )
	-- body
	self.pView = pView
	self:addContentView(pView, true) --加入内容层
	
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgNobilityPromote",handler(self, self.onDlgNobilityPromoteDestroy))
end

--初始化控件
function DlgNobilityPromote:setupViews( )
	-- body
	self:setTitle(getConvertedStr(6, 10374))
	self.pLayTop = self:findViewByName("lay_top")
	self.pLayIcon = self:findViewByName("lay_icon")

	local data = Player:getPlayerInfo():getActorVo()
	-- data.nGtype = e_type_goods.type_head --头像
	-- data.sIcon = Player:getPlayerInfo().sTx
	-- data.nQuality = 100
	local pIconHero = getIconGoodsByType(self.pLayIcon, TypeIconHero.NORMAL,type_icongoods_show.header, data, TypeIconHeroSize.L)
	pIconHero:setIconIsCanTouched(false)

	self.pLbNobility = self:findViewByName("lb_nobility")
	setTextCCColor(self.pLbNobility, _cc.yellow)	
	self.pLbNextNobility = self:findViewByName("lb_next_nobility")
	setTextCCColor(self.pLbNextNobility, _cc.red)
	self.pLbArrow1 = self:findViewByName("lb_arrow_1")
	setTextCCColor(self.pLbArrow1, _cc.pwhite)
	self.pLbArrow1:setString(getConvertedStr(6, 10387), false)
	self.pLbArrow2 = self:findViewByName("lb_arrow_2")
	setTextCCColor(self.pLbArrow2, _cc.pwhite)
	self.pLbArrow2:setString(getConvertedStr(6, 10387), false)

	self.pLbTip = self:findViewByName("lv_tip_1")
	setTextCCColor(self.pLbTip, _cc.pwhite)
	self.pLbTip:setString(getConvertedStr(6, 10386), false)

	self.pLbAddDes = self:findViewByName("lb_adddes")
	setTextCCColor(self.pLbAddDes, _cc.pwhite)
	self.pLbCurValue = self:findViewByName("lb_cur_value")
	setTextCCColor(self.pLbCurValue, _cc.blue)
	self.pLbNextAdd = self:findViewByName("lb_add_value")
	setTextCCColor(self.pLbNextAdd, _cc.green)

	self.pLayList = self:findViewByName("lay_center")
	self.pLayTitle = self:findViewByName("lay_title")	
	self.pLbTitle = self:findViewByName("lb_title")
	self.pLbTitle:setString(getConvertedStr(6, 10385), false)

	local rightbtn = self:getRightButton()
	rightbtn:updateBtnText(getConvertedStr(6, 10388))
	self:setRightHandler(handler(self, self.onRightBtnClicked))
	
end

-- 修改控件内容或者是刷新控件数据
function DlgNobilityPromote:updateViews(  )
	-- body
	local tCountryDatavo = Player:getCountryData():getCountryDataVo()
	local tbanneret = getCountryBanneret()
	if tbanneret and tbanneret[tCountryDatavo.nNobility] then		
		local nNobility	= tCountryDatavo.nNobility	
		local data = tbanneret[nNobility]	
		local nextdata = tbanneret[nNobility + 1]
		self.pLbNobility:setString(data.name, false)	
		self.pLbNextNobility:setString(nextdata.name, false)	
		local attr = luaSplit(data.attr, ":")
		local tattr = getBaseAttData(tonumber(attr[1]))
		local nvalue = attr[2]
		self.pLbAddDes:setString(tattr.sName, false)
		self.pLbCurValue:setString(nvalue, false)
		attr = luaSplit(nextdata.attr, ":")
		tattr = getBaseAttData(tonumber(attr[1]))
		nvalue = attr[2]
		self.pLbNextAdd:setString(nvalue, false)
		self.pLbAddDes:setPositionX(self.pLbTip:getPositionX() + self.pLbTip:getWidth())
		self.pLbArrow1:setPositionX(self.pLbNobility:getPositionX() + self.pLbNobility:getWidth() + 10)
		self.pLbNextNobility:setPositionX(self.pLbArrow1:getPositionX() + self.pLbArrow1:getWidth() + 10)
		self.pLbCurValue:setPositionX(self.pLbAddDes:getPositionX() + self.pLbAddDes:getWidth())
		self.pLbArrow2:setPositionX(self.pLbCurValue:getPositionX() + self.pLbCurValue:getWidth() + 10)
		self.pLbNextAdd:setPositionX(self.pLbArrow2:getPositionX() + self.pLbArrow2:getWidth() + 10)

		local tcost = luaSplit(data.cost, ";")
		self:refreshResList(tcost)
	end
end

--刷新资源显示列表
function DlgNobilityPromote:refreshResList( _tListData )
	-- body
	local tcost = _tListData or {}
	self.tListData = _tListData or {}
	--dump(tcost, "tcost", 100)
	local nCnt = table.nums(tcost)
	if not self.pListView then
	    self.pListView = MUI.MListView.new {
            bgColor = cc.c4b(255, 255, 255, 250),
            viewRect = cc.rect(0, 0, self.pLayList:getWidth(), self.pLayList:getHeight()),
            itemMargin = {left = 0,
            right = 0,
            top = 0,
            bottom = 0}
        }
        
        self.pListView:setItemCallback(handler(self, self.onItemCallBack))
        --上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)	
        self.pListView:setBounceable(true) --是否回弹
        self.pLayList:addView(self.pListView)
        self.pListView:setItemCount(nCnt)
        self.pListView:reload(false)
	else
		self.pListView:notifyDataSetChange(false, nCnt)
	end
	self.pListView:setIsCanScroll(nCnt > 5)
end

function DlgNobilityPromote:onItemCallBack( _index, _pView )
	-- body
 	local pTempView = _pView
    if pTempView == nil then
        pTempView = ItemNobilityPromote.new()  
    end   
    if self.tListData then
		local ttmp = luaSplit(self.tListData[_index], ":")
		local resid = tonumber(ttmp[1])
		local num = tonumber(ttmp[2])
    	pTempView:setCurData(resid, num)
    end
    return pTempView	
end

-- 析构方法
function DlgNobilityPromote:onDlgNobilityPromoteDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgNobilityPromote:regMsgs( )
	-- body
	regMsg(self, gud_refresh_country_msg, handler(self, self.updateViews))
	--注册玩家数据刷新消息
	regMsg(self, gud_refresh_playerinfo, handler(self, self.updateViews))
	--注册玩家背包数据刷新消息
	regMsg(self, gud_refresh_baginfo, handler(self, self.updateViews))
end

-- 注销消息
function DlgNobilityPromote:unregMsgs(  )
	-- body
	unregMsg(self, gud_refresh_country_msg)
	--注销玩家数据刷新消息
	unregMsg(self, gud_refresh_playerinfo)
	--注销玩家背包数据刷新消息
	unregMsg(self, gud_refresh_baginfo)	
end


--暂停方法
function DlgNobilityPromote:onPause( )
	removeTextureFromCache("tx/other/sg_tx_jmtx_smjsj")
	self:unregMsgs()
end

--继续方法
function DlgNobilityPromote:onResume( )
	addTextureToCache("tx/other/sg_tx_jmtx_smjsj")
	self:updateViews()
	self:regMsgs()
end
function DlgNobilityPromote:isResEnough(  )
	-- body
	for i = 1, 5 do
		if self.tResGroup[i]:isVisible() == true and self.tResGroup[i]:isResEnough() == false then
			return false
		end
	end
	return true
end
--升级按钮
function DlgNobilityPromote:onRightBtnClicked( pview )
	-- body
	SocketManager:sendMsg("upNobility", {},handler(self, self.onUpNobility))	
	-- if self:isResEnough() == true  then
	-- 	SocketManager:sendMsg("upNobility", {},handler(self, self.onUpNobility))			
	-- else
	-- 	TOAST(getConvertedStr(6, 10441))--"资源不足"		
	-- end
end
function DlgNobilityPromote:onUpNobility( __msg )
	-- body	
	if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.upNobility.id then
        	if self.pIcon then
        		playUpDefenseArm(self.pIcon)--显示升级特效
        	end
        end
    else
        --弹出错误提示语
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end		
end
return DlgNobilityPromote