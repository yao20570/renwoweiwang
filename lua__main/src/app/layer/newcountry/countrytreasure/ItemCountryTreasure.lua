----------------------------------------------------- 
-- author: luwenjing
-- updatetime: 2018-03-29 17:06:20
-- Description: 国家宝藏列表子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local IconGoods = require("app.common.iconview.IconGoods")
local ActorVo = require("app.layer.playerinfo.ActorVo")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local ItemCountryTreasure = class("ItemCountryTreasure", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemCountryTreasure:ctor(  )
	--解析文件
	parseView("item_country_treasure", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemCountryTreasure:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	self:myInit()
	self:setupViews()

	--注册析构方法
	self:setDestroyHandler("ItemCountryTreasure", handler(self, self.onItemCountryTreasureDestroy))
end

function ItemCountryTreasure:myInit()
	self.tData=nil
	self.nType = 0

	self.tDropList ={}

	self.sName = nil
	self.nQuality = nil

end

-- 析构方法
function ItemCountryTreasure:onItemCountryTreasureDestroy(  )
end

function ItemCountryTreasure:setupViews(  )
	self.pTxtCd = self:findViewByName('txt_cd')
	self.pTxtHelper = self:findViewByName('txt_helper')
	self.pTxtHelper:setVisible(false)
	self.pLayBtn = self:findViewByName("lay_btn")
	self.pBtn = getCommonButtonOfContainer(self.pLayBtn,TypeCommonBtn.M_YELLOW,getConvertedStr(9,10197))
	self.pBtn:onCommonBtnClicked(handler(self, self.onBtnClicked))

	self.pTxtName = self:findViewByName("txt_name")
	self.pImgTreasure = self:findViewByName("img_treasure")
	self.pTxtCd = self:findViewByName("txt_cd")
	self.pLayPlayIcon = self:findViewByName("lay_player_icon")

	self.pLayList = self:findViewByName("lay_list")

	self.pListView = MUI.MListView.new {
	    viewRect   = cc.rect(0, 0, self.pLayList:getContentSize().width, self.pLayList:getContentSize().height),
	    direction  = MUI.MScrollView.DIRECTION_HORIZONTAL,
	    itemMargin = {left =  -15,
	        right =  0,
	        top =  18,
	        bottom =  0},
	}
	self.pLayList:addView(self.pListView)
	self.pListView:setItemCount(0) 
	self.pListView:setItemCallback(handler(self, self.onListViewItemCallBack))


end

function ItemCountryTreasure:updateViews(  )
	-- body
	-- self.pTxtTitle:setString()
	-- dump(self.tData,"ItemCountryTreasure----75")
	if not self.tData then
		return
	end
	self.pImgTreasure:setVisible(false)
	self.pLayPlayIcon:setVisible(false)
	self.pTxtHelper:setVisible(false)
	self.pTxtCd:setVisible(false)


	local tDbData = getCountryTreasureDataById(self.tData.tid)
	if tDbData  then
		local sIconImg = getCountryTreasureImgByQuality(tDbData.quality)
		self.sName = tDbData.name
		self.nQuality = tDbData.quality
		self.pTxtName:setString(tDbData.name)
		setTextCCColor(self.pTxtName,getColorByQuality(tDbData.quality))

		self.pImgTreasure:setCurrentImage(sIconImg)
		--掉落物品
		local tDropList = {}
		tDropList = getDropById(tDbData.dropid)
		if tDropList then
			self.tDropList = tDropList
		end
		local nPrevCount = #self.tDropList
		
		if #self.tDropList <= 0 then --经测试，self.pListView:notifyDataSetChange(true)，数据为0时会出错
	        self.pListView:removeAllItems()
	    else
	        self.pListView:notifyDataSetChange(true,table.nums(self.tDropList))
	        self.pListView:scrollToBegin()
	    end
	    --根据类型刷新不同内容
	    if self.nType == 1 then  --宝藏列表

	    	self:updateListView(tDbData)

	    elseif self.nType == 2 then  --我的宝藏列表
	    	self:updateMyListView(tDbData)
	    elseif self.nType == 3 then  --求助列表
	    	self:updateHelpListView(tDbData)
	    end
	end
end

--宝藏列表
function ItemCountryTreasure:updateListView( _tDbData )
	-- body
	self.pImgTreasure:setVisible(true)

	local tCountryTreasureData = Player:getCountryTreasureData()
	local nTime = _tDbData.opentime/3600
	self.pTxtCd:setString(string.format(getConvertedStr(9,10204),nTime))
	self.pTxtCd:setVisible(true)
	setTextCCColor(self.pTxtCd,_cc.white)
	if tCountryTreasureData.nD <= 0 then   --挖掘次数已用完
		self.pBtn:updateBtnText(getConvertedStr(9,10211))
		self.pBtn:setBtnEnable(false)
	else
		if tCountryTreasureData:isCanFreeDig() then   --免费挖掘
			self.pBtn:updateBtnText(getConvertedStr(9,10212))
			self.pBtn:updateBtnType(TypeCommonBtn.M_BLUE)
			self.pBtn:setBtnEnable(true)
		else  --黄金挖掘
			self.pBtn:updateBtnText(getConvertedStr(9,10211))
			self.pBtn:updateBtnType(TypeCommonBtn.M_YELLOW)
			self.pBtn:setBtnEnable(true)
		end
	end
end
--我的宝藏列表
function ItemCountryTreasure:updateMyListView( _tDbData )
	-- body
	self.pImgTreasure:setVisible(true)
	if self.tData.hn then 
		self.pTxtHelper:setVisible(true)
		self.pTxtHelper:setString(string.format(getConvertedStr(9,10230), self.tData.hn))
	else
		self.pTxtHelper:setVisible(false)

	end
	self:updateMyTreasureUi()

	regUpdateControl(self, handler(self, self.onUpdateTime))		--注册更新倒计时

end

--求助列表
function ItemCountryTreasure:updateHelpListView( _tDbData )
	-- body
	

	self.pLayPlayIcon:setVisible(true)
	local pActorVo = ActorVo.new()
	pActorVo:initData(self.tData.a,self.tData.b, nil)
	if not self.pIcon then
		self.pIcon = getIconGoodsByType(self.pLayPlayIcon, TypeIconGoods.HADMORE,type_icongoods_show.header, pActorVo, TypeIconHeroSize.L)
	else
        self.pIcon:setCurData(pActorVo)
	end
	self.pIcon:setMoreText(self.tData.n)
	self:updateHelpListUi()
	-- setTextCCColor(self.pTxtCd,_cc.white)


	regUpdateControl(self, handler(self, self.onUpdateTime))		--注册更新倒计时
end

function ItemCountryTreasure:onUpdateTime(  )
	-- body
	if self.nType == 2 then  --我的宝藏列表
		
		self:updateMyTreasureUi()
	elseif self.nType == 3 then    --求助列表
		
		self:updateHelpListUi()

	end
	
end

function ItemCountryTreasure:updateMyTreasureUi(  )
	-- body
	local tTreasureData = Player:getCountryTreasureData()
	local nLeftTime = tTreasureData:getTreasureDisappearTime(self.tData.tsid)
	-- self.pTxtCd:setVisible(true)
	if nLeftTime then
		if nLeftTime==0 then
			unregUpdateControl(self)--停止计时刷新
				
			if self.tData.hn then    --被协助时间到可领取三个列表都要刷新
				self.pTxtCd:setVisible(false)
				self.pBtn:updateBtnText(getConvertedStr(1,10178))
				self.pBtn:updateBtnType(TypeCommonBtn.M_YELLOW)
				self.pBtn:setBtnEnable(true)

			end
		else
			
			
			if self.tData.hn then    --被协助了
				setTextCCColor(self.pTxtCd,_cc.green)
				self.pBtn:setBtnEnable(false)
				self.pBtn:updateBtnText(getConvertedStr(1,10178))
				self.pTxtCd:setString(string.format(getConvertedStr(9,10219), formatTimeToHms(nLeftTime)),false)
				
					
			else   
				setTextCCColor(self.pTxtCd,_cc.red)
				self.pBtn:updateBtnText(getConvertedStr(9,10218))
				self.pBtn:updateBtnType(TypeCommonBtn.M_BLUE)
				self.pBtn:setBtnEnable(self.tData.fh == 1)

				self.pTxtCd:setString(string.format(getConvertedStr(9,10242), formatTimeToHms(nLeftTime)),false)
				
			end
			self.pTxtCd:setVisible(true)
		end
	end

end

function ItemCountryTreasure:updateHelpListUi(  )
	-- body
	local tTreasureData = Player:getCountryTreasureData()
	local nLeftTime = tTreasureData:getHelpTreasureDisappearTime(self.tData.tsid)
	self.pTxtCd:setVisible(true)
	if nLeftTime then
		if nLeftTime==0 then
			unregUpdateControl(self)--停止计时刷新
			if self.tData.tcd then    --被协助时间到可领取三个列表都要刷新
				self.pTxtCd:setVisible(false)
				self.pBtn:updateBtnText(getConvertedStr(1,10178))
				self.pBtn:updateBtnType(TypeCommonBtn.M_YELLOW)
				self.pBtn:setBtnEnable(true)
			else
				tTreasureData:updateTotalHelpList()
				sendMsg(ghd_refresh_country_treasure)
					
			end
		else
			if self.tData.tcd then    --被协助了
				setTextCCColor(self.pTxtCd,_cc.green)
				self.pBtn:updateBtnText(getConvertedStr(1,10099))
				self.pBtn:updateBtnType(TypeCommonBtn.M_YELLOW)
				self.pBtn:setBtnEnable(true)
				self.pTxtCd:setString(string.format(getConvertedStr(9,10219), formatTimeToHms(nLeftTime)),false)
				
			else   
				setTextCCColor(self.pTxtCd,_cc.white)
				self.pBtn:updateBtnText(getConvertedStr(1,10068))
				self.pBtn:updateBtnType(TypeCommonBtn.M_BLUE)
				if (tTreasureData.tHelp and #tTreasureData.tHelp > 0 ) or tTreasureData.nH <= 0 then
					self.pBtn:setBtnEnable(false)
				else
					self.pBtn:setBtnEnable(true)

				end
				local tDbData = getCountryTreasureDataById(self.tData.tid) 
				if tDbData then
					local nTime = tDbData.opentime/3600
					self.pTxtCd:setString(string.format(getConvertedStr(9,10204),nTime))
				end
			end
			self.pTxtCd:setVisible(true)
		end
	end
end

function ItemCountryTreasure:setData( _tData,_nType)
	-- body
	self.tData=_tData or self.tData
	self.nType = _nType or self.nType
	self:updateViews()

end

function ItemCountryTreasure:onListViewItemCallBack(_index, _pView )
	local tTempData = self.tDropList[_index]
    local pTempView = _pView
	-- body
	if pTempView == nil then
		pTempView = IconGoods.new(TypeIconGoods.NORAML)--HADMORE
		pTempView:setIconIsCanTouched(true)
	end
	    pTempView:setCurData(tTempData) 
		pTempView:setMoreTextColor(getColorByQuality(tTempData.nQuality))
		pTempView:setNumber(tTempData.nCt)
		pTempView:setScale(0.7)

    return pTempView
end

function ItemCountryTreasure:onBtnClicked( )
	-- body
	 --根据类型响应不同内容
	if self.nType == 1 then  --宝藏列表
	  	self:onDigClicked()

	elseif self.nType == 2 then  --我的宝藏列表
	   	self:onMyTreasureClicked()
	elseif self.nType == 3 then  --求助列表
	    self:onHelpClicked()
	end
end
function ItemCountryTreasure:onDigClicked(  )
	-- body
	local tCountryTreasureData = Player:getCountryTreasureData()
	if tCountryTreasureData.nD <= 0 then
		return 
	end
	local nCostType = 0
	if tCountryTreasureData:isCanFreeDig() then   --免费挖掘
		nCostType = 0
	else  --黄金挖掘
		nCostType = 1
	end
	if nCostType == 0 then
		SocketManager:sendMsg("reqDigCountryTreasure", {nCostType,self.tData.tsid}, handler(self, self.onGetFunc)) 
	else
		-- local tItemData = getGoodsByTidFromDB(100178)
		-- local tActData=Player:getActById(e_id_activity.luckystar)
		-- if not tActData then
		-- 	return
		-- end
		local nCostMoney = getCountryParam("goldDig") --需要消耗的黄金
		local strTips = {
		    {color=_cc.pwhite, text = getConvertedStr(9, 10213)},
		    {color=_cc.yellow, text = nCostMoney},
		    {color=_cc.pwhite, text = getConvertedStr(9, 10214)},
		}
		--展示购买对话框
		showBuyDlg(strTips, nCostMoney,function (  )
			SocketManager:sendMsg("reqDigCountryTreasure",{nCostType,self.tData.tsid},handler(self,self.onGetFunc))
		end, 1, true)

	end

end
function ItemCountryTreasure:onMyTreasureClicked( ... )

	-- body
	local tTreasureData = Player:getCountryTreasureData()
	local nLeftTime = tTreasureData:getTreasureDisappearTime(self.tData.tsid)
	if nLeftTime then
		if nLeftTime<=0 then
			if self.tData.hn then    --被协助时间到可领取三个列表都要刷新
				SocketManager:sendMsg("reqGetCountryTreasure", {self.tData.tsid}, handler(self, self.onGetFunc)) 
			end
		else
			if self.tData.fh == 1 then
				SocketManager:sendMsg("reqAskHelpCountryTreasure", {self.tData.tsid}, handler(self, self.onGetFunc)) 
			end
		end
	end
	
end
function ItemCountryTreasure:onHelpClicked( ... )
	-- body
	local tTreasureData = Player:getCountryTreasureData()
	local nLeftTime = tTreasureData:getHelpTreasureDisappearTime(self.tData.tsid)
	if nLeftTime <=0 then 

		if self.tData.tcd then    --被协助了
			SocketManager:sendMsg("reqGetCountryTreasure",{self.tData.tsid},handler(self,self.onGetFunc))

		end
	else
		if self.tData.tcd then    --被协助了
			local nCd = Player:getCountryTreasureData():getHelpTreasureDisappearTime(self.tData.tsid)
			local nCostMoney =math.ceil(nCd/ tonumber(getCountryParam("goldOpenTime"))) --需要消耗的黄金
			local strTips = {
			    {color=_cc.pwhite, text = getConvertedStr(9, 10213)},
			    {color=_cc.yellow, text = nCostMoney},
			    {color=_cc.pwhite, text = getConvertedStr(9, 10220)},
			}
			--展示购买对话框  加速
			showBuyDlg(strTips, nCostMoney,function (  )
				SocketManager:sendMsg("reqAccelerateCountryTreasure",{self.tData.tsid},handler(self,self.onGetFunc))
			end, 1, true)

			-- SocketManager:sendMsg("reqAccelerateCountryTreasure",{self.tData.tsid},handler(self,self.onGetFunc))
		else   
			--帮助
			SocketManager:sendMsg("reqHelpCountryTreasure",{self.tData.tsid},handler(self,self.onGetFunc))

		end
	end

end

function ItemCountryTreasure:onGetFunc( __msg,_oldMsg )
	-- dump(__msg,"__msg--",100)
	-- dump(_oldMsg,"_oldMsg--")
	-- body
	if __msg.head.state == SocketErrorType.success then	
	    if __msg.body and __msg.body.o then
			--获取物品效果
			showGetAllItems(__msg.body.o)
		end	
		--挖掘
		if __msg.head.type == MsgType.reqDigCountryTreasure.id then
			
			Player:getCountryTreasureData():refreshDatasByService(__msg.body)
			TOAST(getConvertedStr(9,10227))
		
		elseif __msg.head.type == MsgType.loadMyCountryTreasure.id then
			
		elseif __msg.head.type == MsgType.reqAskHelpCountryTreasure.id then   --求助
			local tData={self.sName,"c^q_"..self.nQuality}
			autoShareToCountry(e_share_id.country_treasure_help,tData)

			Player:getCountryTreasureData():refreshDatasByService(__msg.body)
			-- TOAST(getConvertedStr(9,10231))

		elseif __msg.head.type == MsgType.reqGetCountryTreasure.id then   --领取

			Player:getCountryTreasureData():refreshDatasByService(__msg.body)
			if self.nType == 2 then
				Player:getCountryTreasureData():removeMyItem(self.tData.tsid)
			elseif self.nType == 3 then
				Player:getCountryTreasureData():removeHelpItem(self.tData.tsid)
			end

		elseif __msg.head.type == MsgType.reqAccelerateCountryTreasure.id then   --加速

			Player:getCountryTreasureData():refreshDatasByService(__msg.body)
			TOAST(getConvertedStr(9,10229))

		elseif __msg.head.type == MsgType.reqHelpCountryTreasure.id then   --帮助

			Player:getCountryTreasureData():refreshDatasByService(__msg.body)
			TOAST(getConvertedStr(9,10235))
			
		end
		sendMsg(ghd_refresh_country_treasure)
	else
		if __msg.head.type == MsgType.reqHelpCountryTreasure.id  then   --帮助

			if __msg.head.state == 794  or  __msg.head.state == 786 then
				SocketManager:sendMsg("loadCountryTreasureHelpList", {1, 5}, handler(self, self.onHelpListCallBack))
			end
			
		end	
		TOAST(SocketManager:getErrorStr(__msg.head.state))					
	end
end

function ItemCountryTreasure:onHelpListCallBack( __msg,_oldMsg )
	-- body
	-- body
	if __msg.head.state == SocketErrorType.success then	
		-- TOAST(getConvertedStr(9,10241))
	else
	end
end

return ItemCountryTreasure


