-----------------------------------------------------
-- author: luwenjing
-- updatetime:  2018-03-28 09:31:44 星期三
-- Description: 国家宝藏
-----------------------------------------------------
local DlgBase = require("app.common.dialog.DlgBase")
local MBtnExText = require("app.common.button.MBtnExText")
local RichTextEx = require("app.common.richview.RichTextEx")
local TCommonTabHost = require("app.common.tabhost.TCommonTabHost")
local DlgAlert = require("app.common.dialog.DlgAlert")
local ItemCountryTreasure = require("app.layer.newcountry.countrytreasure.ItemCountryTreasure")
local DlgCountryTreasure = class("DlgCountryTreasure", function()
	-- body
	return DlgBase.new(e_dlg_index.dlgcountrytreasure)
end)

function DlgCountryTreasure:ctor( _nIndex )
	-- body
	self.nDefaultIndex = _nIndex
	self:myInit()
	parseView("dlg_country_treasure", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgCountryTreasure:myInit(  )
	-- body

	self.tListData = {}

	self.nType = 1
	self.nTabIndex = 1 

	self.bIsChangeToHelp = true
	-- self.bIsChangeToHelp = true
end

--解析布局回调事件
function DlgCountryTreasure:onParseViewCallback( pView )
	-- body
	self:addContentView(pView) --加入内容层
	self:addContentTopSpace(3)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgCountryTreasure",handler(self, self.onDlgCountryTreasureDestroy))
end

--初始化控件
function DlgCountryTreasure:setupViews( )
	-- body
	--设置标题
	self:setTitle(getConvertedStr(9, 10193))
	self.pLayBtn = self:findViewByName("lay_btn")
	self.pBtn = getCommonButtonOfContainer(self.pLayBtn,TypeCommonBtn.L_YELLOW,getConvertedStr(9,10197))
	-- self.pBtnCenter = getCommonButtonOfContainer(self.pLayCenter,TypeCommonBtn.L_YELLOW,getConvertedStr(1,10197))
	-- self.pBtnRight = getCommonButtonOfContainer(self.pLayRight,TypeCommonBtn.L_BLUE,getConvertedStr(1,10196))
	self.pBtn:onCommonBtnClicked(handler(self, self.onBtnClicked))
 
 	self.pLayList=self:findViewByName("lay_list")

 	self.pTxtCd = self:findViewByName("txt_cd")

 	self.pLayTip1 = self:findViewByName("lay_tip1")
 	self.pLayTip2 = self:findViewByName("lay_tip2")
 	self.pLayTip3 = self:findViewByName("lay_tip3")

 	self.pTxtDig1 = self:findViewByName("txt_dig_tip1")
 	self.pTxtDig1:setString(getConvertedStr(9,10206))
 	setTextCCColor(self.pTxtDig1,_cc.white)

 	self.pTxtDig2 = self:findViewByName("txt_dig_tip2")
 	setTextCCColor(self.pTxtDig2,_cc.yellow)

 	self.pTxtDig3 = self:findViewByName("txt_dig_tip3")
 	setTextCCColor(self.pTxtDig3,_cc.white)

 	self.pTxtDig4 = self:findViewByName("txt_dig_tip4")
 	self.pTxtDig4:setString(getConvertedStr(9,10208))
 	setTextCCColor(self.pTxtDig4,_cc.pwhite)

 	self.pTxtHelp1 = self:findViewByName("txt_help_tip1")
 	self.pTxtHelp1:setString(getConvertedStr(9,10207))
 	setTextCCColor(self.pTxtHelp1,_cc.white)

 	self.pTxtHelp2 = self:findViewByName("txt_help_tip2")
 	setTextCCColor(self.pTxtHelp2,_cc.yellow)

 	self.pTxtHelp3 = self:findViewByName("txt_help_tip3")
 	self.pTxtHelp3:setString(getConvertedStr(9,10210))
 	setTextCCColor(self.pTxtHelp3,_cc.pwhite)

 	self.pRichText = RichTextEx.new({width = 600, autow = false,align = 1,color=_cc.pwhite,size = 18,lineoffset = 7})
    self.pRichText:setVisible(true)
    self.pLayTip2:addView(self.pRichText)
    self.pRichText:setPosition(20, 16)
    -- centerInView(self.pLayTip2,self.pRichText)
    self.pRichText:setString(getConvertedStr(9,10209))

	self.tTitles = {
		getConvertedStr(9, 10194),
		getConvertedStr(9, 10195),
		getConvertedStr(9, 10196)
	}

	self.pLayTabHost 			= 		self:findViewByName("lay_tab_btn")

	self.pTComTabHost = TCommonTabHost.new(self.pLayTabHost,1,1,self.tTitles,handler(self, self.onIndexSelected))
	self.pLayTabHost:addView(self.pTComTabHost)
	self.pTComTabHost:removeLayTmp1()
	self.pTComTabHost:setDefaultIndex(self.nDefaultIndex)

	--按钮集
	self.pTabItems =  self.pTComTabHost:getTabItems()
end

-- 修改控件内容或者是刷新控件数据
function DlgCountryTreasure:updateViews(  )

	local tData = Player:getCountryTreasureData()
	self.pTxtDig2:setString(tostring(tData.nD))   --剩余挖掘次数
	self.pTxtHelp2:setString(tostring(tData.nH))  --剩余帮助次数

	if tData.nFr > 0 then
		self.pBtn:updateBtnText(getConvertedStr(5,10262))
		self.pBtn:updateBtnType(TypeCommonBtn.M_BLUE)
		-- self.pBtn:setBtnEnable(true)
	else
		self.pBtn:updateBtnText(getConvertedStr(9,10197))
		self.pBtn:updateBtnType(TypeCommonBtn.M_YELLOW)
	end
	-- self:onUpdateRefreshTime()	
	showRedTips(self.pTabItems[1]:getRedNumLayer(), 0, tData:getTreasureListRedNum())
	showRedTips(self.pTabItems[2]:getRedNumLayer(), 0, tData:getMyTreasureRedNum())
	showRedTips(self.pTabItems[3]:getRedNumLayer(), 0, tData:getHelpTreasureRedNum())
end
function DlgCountryTreasure:onUpdateRefreshTime(  )
	-- body
	local nLeftTime1 = Player:getCountryTreasureData():getRefreshLeftTime()

	if nLeftTime1 then
		if nLeftTime1<=0 then
			SocketManager:sendMsg("reqRefreshCountryTreasure",{2},handler(self,self.onRefreshFunc))
			self.pTxtCd:setVisible(false)
		else
			self.pTxtCd:setString(string.format(getConvertedStr(9,10234) ,formatTimeToHms(nLeftTime1)),false)
		end
	end

	local nLeftTime2 = Player:getCountryTreasureData():getFreeDigLeftTime()
	if nLeftTime2 then
		if nLeftTime2==0 then

			self.pTxtDig3:setVisible(false)
		else
			self.pTxtDig3:setVisible(true)
			self.pTxtDig3:setString(string.format(getConvertedStr(9,10205),formatTimeToHms(nLeftTime2)) ,false)
		end
	end
end
-- 析构方法
function DlgCountryTreasure:onDlgCountryTreasureDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgCountryTreasure:regMsgs( )
	regMsg(self, ghd_refresh_country_treasure, handler(self, self.updateList))
end

-- 注销消息
function DlgCountryTreasure:unregMsgs(  )
	unregMsg(self, ghd_refresh_country_treasure)
	
end


--暂停方法
function DlgCountryTreasure:onPause( )
	-- body
	self:unregMsgs()
	unregUpdateControl(self)
end

--继续方法
function DlgCountryTreasure:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	regUpdateControl(self, handler(self, self.onUpdateRefreshTime))		--注册更新倒计时
end
function DlgCountryTreasure:updateList(  )
	-- body
	self:onIndexSelected(self.nTabIndex)
	self:updateViews()
end

--下标选择回调事件
function DlgCountryTreasure:onIndexSelected( _index )

	if _index == 1 then --宝藏列表

		self.tListData = Player:getCountryTreasureData().tList

		self:setBottomVisible(true)
		self:createListView(_index)
		
	elseif _index == 2 then --我的宝藏
		self.tListData = Player:getCountryTreasureData().tMine

		self:setBottomVisible(false)

		self:createListView(_index)
	elseif _index == 3 then --求助列表
		
		if self.nTabIndex ~= _index then
			self.nTabIndex = _index
			self:sendGetHelpDataRequest(1)
		else
			self.tListData = Player:getCountryTreasureData().tTotalHelpList

			self:createListView(_index)
		end
		self:setBottomVisible(false)

	end

	self.nTabIndex = _index
	self:refreshTopTip()
	
end
function DlgCountryTreasure:setBottomVisible( _bVisible )
	-- body
	local bVisible = _bVisible or false
	self.pTxtCd:setVisible(_bVisible)
	self.pLayBtn:setVisible(_bVisible)

end
function DlgCountryTreasure:refreshTopTip(  )
	-- body
	if self.nTabIndex == 1 then
		self.pLayTip1:setVisible(true)
		self.pLayTip2:setVisible(false)
		self.pLayTip3:setVisible(false)

	elseif self.nTabIndex == 2 then
		self.pLayTip1:setVisible(false)
		self.pLayTip2:setVisible(true)
		self.pLayTip3:setVisible(false)
	elseif self.nTabIndex == 3 then
		self.pLayTip1:setVisible(false)
		self.pLayTip2:setVisible(false)
		self.pLayTip3:setVisible(true)
	end
end

--创建listView
function DlgCountryTreasure:createListView(_nIndex)
	local nIndex = _nIndex or self.nTabIndex
	-- --更新列表数据
	if self.tListData and #self.tListData>0 then
		if self.pLayNull then
			self.pLayNull:setVisible(false)
		end
		if not self.pListView then
			--列表
			local pSize = self.pLayList:getContentSize()
			self.pListView = MUI.MListView.new {
				viewRect   = cc.rect(0, 0, pSize.width, pSize.height),
				direction  = MUI.MScrollView.DIRECTION_VERTICAL,
				itemMargin = {
					left   = 0,
		            right  = 0,
		            top    = 0, 
		            bottom = 10}
		    }
		    self.pLayList:addView(self.pListView)
			local nCount = table.nums(self.tListData)
			self.pListView:setItemCount(nCount)
			self.pListView:setItemCallback(function ( _index, _pView ) 
			    local pTempView = _pView
			    if pTempView == nil then
			    	pTempView = ItemCountryTreasure.new()
				end
				pTempView:setData(self.tListData[_index],self.nTabIndex)
			    return pTempView
			end)

			self.pListView:onScroll(function ( event )
	    	-- body
	    	if event.name == "scrollToFooter" and self.nTabIndex == 3 then--当求助列表滑动到底部的时候启动申请请求
	    		self:onLoadHelpList()
	    	end
	    end)
			local pUpArrow, pDownArrow = getUpAndDownArrow()
	    	self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)  

			self.pListView:reload(true)
		else

			-- self.pListView:scrollToBegin()
			self.pListView:notifyDataSetChange(true,table.nums(self.tListData))
		end
		self.pListView:setVisible(true)
	else
		if self.pListView then
			self.pListView:setVisible(false)
		end
		if not self.pTxtNullTip then	
			self.pLayNull = MUI.MLayer.new()
			self.pLayNull:setLayoutSize(self.pLayList:getWidth(), self.pLayList:getHeight())
			self.pTxtNullTip = MUI.MLabel.new({text = "", size = 25, color = getC3B(_cc.pwhite)})
			self.pTxtNullTip:setPosition(self.pLayList:getWidth()/2,self.pLayList:getHeight()/2)
			self.pLayList:addView(self.pLayNull)
			self.pLayNull:addView(self.pTxtNullTip)

		end
		self.pLayNull:setVisible(true)
		if nIndex == 1 then
			self.pTxtNullTip:setString(getConvertedStr(9,10238))
		elseif nIndex == 2 then
			self.pTxtNullTip:setString(getConvertedStr(9,10239))

		elseif nIndex == 3  then
			--todo
			self.pTxtNullTip:setString(getConvertedStr(9,10240))

		end
	end
end

function DlgCountryTreasure:onLoadHelpList(  )
	local tData = Player:getCountryTreasureData()
	if tData.nCp < tData.nAp then
		-- body
		local nNextPage = Player:getCountryTreasureData().nCp + 1

	    self:sendGetHelpDataRequest(nNextPage)	
	end
end

function DlgCountryTreasure:sendGetHelpDataRequest( _nPage )
	-- body
	local nPage = _nPage or 1

	if self.bIsAskingData == true then--判断是否正在请求数据
		return
	end
	self.bIsAskingData = true
	SocketManager:sendMsg("loadCountryTreasureHelpList", {nPage, 10}, handler(self, self.onHelpListCallBack))
end


function DlgCountryTreasure:onBtnClicked(  )
	-- body
	local tData =  Player:getCountryTreasureData()
	local nLeftTime = tData:getRefreshLeftTime()
	if nLeftTime <= 30 then
		TOAST(getConvertedStr(9,10215))
		return
	end
	if tData.nFr > 0 then
		local nCostType = 0 --免费刷新
		SocketManager:sendMsg("reqRefreshCountryTreasure", {nCostType}, handler(self, self.onRefreshFunc)) 
	else
		local nCostType = 1 --黄金刷新
		local nCostMoney = getCountryParam("goldReNum") --需要消耗的黄金
		nCostMoney = nCostMoney * (tData.nCr +1)
		local strTips = {
		    {color=_cc.pwhite, text = getConvertedStr(9, 10213)},
		    {color=_cc.yellow, text = nCostMoney},
		    {color=_cc.pwhite, text = getConvertedStr(9, 10216)},
		}
		--展示购买对话框
		showBuyDlg(strTips, nCostMoney,function (  )
			SocketManager:sendMsg("reqRefreshCountryTreasure",{nCostType},handler(self,self.onRefreshFunc))
		end, 1, true)
	end
end

function DlgCountryTreasure:onRefreshFunc( __msg,_oldMsg )
	-- body
	if __msg.head.state == SocketErrorType.success then		
		if __msg.head.type == MsgType.reqRefreshCountryTreasure.id then
			-- dump(__msg,"__msg")
			Player:getCountryTreasureData():refreshDatasByService(__msg.body)
			if __msg.body and __msg.body.o then
				--获取物品效果
				showGetAllItems(__msg.body.o)
			end
			self:updateViews()
			self:onIndexSelected(self.nTabIndex)
			TOAST(getConvertedStr(9,10228))
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))						
	end
end

--网络请求回到
function DlgCountryTreasure:onHelpListCallBack(__msg)
	-- body
	--dump(__msg.body, "__msg.body",10)
	self.bIsAskingData = false--请求返回，结束正在请求的状态
	if __msg.head.state == SocketErrorType.success	then				
		--请求成功
		self.tListData = Player:getCountryTreasureData().tTotalHelpList
		self:updateViews()
		self:refreshTopTip()

		self:createListView(_index)
	else		
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end
end


return DlgCountryTreasure