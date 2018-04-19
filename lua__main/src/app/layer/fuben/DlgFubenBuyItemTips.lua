-- Author: liangzhaowei
-- Date: 2017-05-17 19:47:24
-- 副本资源补给关卡提示框


local DlgAlert = require("app.common.dialog.DlgAlert")
local MRichLabel = require("app.common.richview.MRichLabel")
local MBtnExText = require("app.common.button.MBtnExText")

local DlgFubenBuyItemTips = class("DlgFubenBuyItemTips", function ()
	return DlgAlert.new(e_dlg_index.fubenbutyitemtips)
end)

--构造
function DlgFubenBuyItemTips:ctor()
	-- body
	self:myInit()
	parseView("dlg_fuben_buyitem_tip", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgFubenBuyItemTips:myInit()
	-- body
	self.nNeedCost = 0   --需求金币
	self.prichText = nil --富文本提示内容
end
  
--解析布局回调事件
function DlgFubenBuyItemTips:onParseViewCallback( pView )
	-- body
	self:addContentView(pView, true)

	self:setOnlyConfirm(getConvertedStr(5, 10088))
	self:setupViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgFubenBuyItemTips",handler(self, self.onDestroy))
end

--初始化控件
function DlgFubenBuyItemTips:setupViews()
	-- body
	--设置右边按钮样式
	self:setOnlyConfirmBtn(TypeCommonBtn.L_YELLOW)
	self:setOnlyConfirmBtnHeight(8)
	--设置标题
	self:setTitle(getConvertedStr(5,10087))

	--提示内容层
	-- self.pLayTip = self:findViewByName("ly_icon")

	self.pLyIcon = self:findViewByName("ly_icon")
	self.pLyMain = self:findViewByName("ly_main")


	--lb
	self.pLbName = self:findViewByName("lb_name")
	self.pLbName:setZOrder(10)
	self.pLbDesc = self:findViewByName("lb_desc")
	self.pLbDesc:setZOrder(11)

	--按钮上的金币提示
	local tBtnTable = {}
	tBtnTable.parent = self.pBtnRight
	tBtnTable.img = "#v1_img_qianbi.png"
	--文本
	tBtnTable.tLabel = {
		{"0",getC3B(_cc.blue)},
		{"/",getC3B(_cc.white)},
		{"0",getC3B(_cc.white)},
		
	}
	self.pBtnExText = MBtnExText.new(tBtnTable)

	--设置右键按钮点击事件
	self:setRightHandler(handler(self, self.onCostClicked))
	--默认背景隐藏
	self:setContentBgTransparent()
end

-- 修改控件内容或者是刷新控件数据
function DlgFubenBuyItemTips:updateViews()
	-- body

end

--析构方法
function DlgFubenBuyItemTips:onDestroy()

end

-- 注册消息
function DlgFubenBuyItemTips:regMsgs( )
	-- body
end

-- 注销消息
function DlgFubenBuyItemTips:unregMsgs(  )
	-- body
end


--暂停方法
function DlgFubenBuyItemTips:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgFubenBuyItemTips:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

--设置数据 _pData 数据
function DlgFubenBuyItemTips:setCurData(_pData)
	if not _pData then
		--todo
		return
	end



	self.pData = _pData

	if self.pData.nType == 3 then --补给关
		self:setRightBtnText(getConvertedStr(5, 10088))
		if self.pData.nRb then

			--购买价格
			local tCost = self.pData:getFeedBuyCost()
			if table.nums(tCost) > 0 then
				local nIndex = self.pData.nRb +1
				if nIndex > table.nums(tCost) then
					nIndex = table.nums(tCost)
				end
				self:setNeedCost(tCost[nIndex])     
			end
		end

		self.pLbName:setVisible(true)
		self.pLbName:setZOrder(10)
		setTextCCColor(self.pLbName, _cc.blue)
		self.pLbName:setString(self.pData.sName)

		local strText1 = getTextColorByConfigure(getTipsByIndex(10010))

		local sIconStr = luaSplit(self.pData.sTempIcon, "i")
		if sIconStr then
			local nResId = tonumber(sIconStr[2])
			if nResId == e_resdata_ids.lc then 	   --粮草
				strText1 = getTextColorByConfigure(getTipsByIndex(10010))
			elseif nResId == e_resdata_ids.yb then --银币
				strText1 = getTextColorByConfigure(getTipsByIndex(20064))
			elseif nResId == e_resdata_ids.mc then --木材
				strText1 = getTextColorByConfigure(getTipsByIndex(20065))
			elseif nResId == e_resdata_ids.bt then --镔铁
				strText1 = getTextColorByConfigure(getTipsByIndex(20066))
			end
		end

		local tDrop = getDropById(self.pData.nNormaldrop)[1]

		local nGetNums =  0
		if tDrop  and tDrop.nCt then
			nGetNums = tDrop.nCt*self.pData.nFeedTime
		end



		--直接替换掉内容
		if strText1[2].text then
			strText1[2].text =  nGetNums
		end
		if not self.pRichViewTips1 then
			self.pRichViewTips1 = MRichLabel.new({str=strText1,fontSize=20, rowWidth=270})
		    self.pRichViewTips1:setPosition(182,167)
		    self.pRichViewTips1:setAnchorPoint(cc.p(0,1))
		    self.pLyMain:addView(self.pRichViewTips1,10)
		end

		--icon
		if tDrop and (not self.pIcon) then
			self.pIcon = getIconGoodsByType(self.pLyIcon, TypeIconGoods.NORMAL, type_icongoods_show.item, tDrop,TypeIconGoodsSize.L)
		end

		
		local nMaxCost = table.nums(self.pData:getFeedBuyCost())
	    if not self.pRichViewTips2 then
			local strTips2 = nil
		    strTips2 = {
		    	{color=_cc.white,text=getConvertedStr(5, 10090)},
		    	{color=_cc.white,text=self.pData.nRb},
		    	{color=_cc.blue,text="/"},
		    	{color=_cc.blue,text=nMaxCost},
		    }
	 		self.pRichViewTips2 = MRichLabel.new({str=strTips2, fontSize=20, rowWidth=200})
		    self.pRichViewTips2:setPosition(250,30)
		    self.pRichViewTips2:setAnchorPoint(cc.p(0.5,0.5))
		    self.pLyMain:addView(self.pRichViewTips2,10)
		end
	elseif self.pData.nType == 4 then --装备关
		self:setRightBtnText(getConvertedStr(5, 10115))
		local nTnums = tonumber(self.pData.sTarget)

		if self.pData.sTarget and (self.pData.sTarget~= "") then
			local pEq = getGoodsByTidFromDB(self.pData.sTarget) 
			if pEq then
				self.pIcon = getIconGoodsByType(self.pLyIcon, TypeIconGoods.NORMAL, type_icongoods_show.item, pEq,TypeIconGoodsSize.L)
				self.pLbName:setString(pEq.sName or "")
				setTextCCColor(self.pLbName, _cc.blue)
				self.pLbDesc:setString(pEq.sDes or "")
				setTextCCColor(self.pLbDesc, _cc.blue)
				self:setNeedCost(self.pData.nWeaponPaperCost)     
			end
		end
	end




end

--设置当前需求值
function DlgFubenBuyItemTips:setNeedCost(_nCost)
	-- body
	--设置拥有量
	self.pBtnExText:setLabelCnCr(1,Player:getPlayerInfo().nMoney)
	self.nNeedCost = _nCost or self.nNeedCost	
	--设置当前需求值
	self.pBtnExText:setLabelCnCr(3,self.nNeedCost)	
end



--消费按钮点击事件回调
function DlgFubenBuyItemTips:onCostClicked( pView )
	-- body

	if self.pData.nType == 3 then --补给关
		if Player:getPlayerInfo().nMoney >= self.nNeedCost  then
			SocketManager:sendMsg("buyFubenSupplyRes", {self.pData.nId},
			function ()
				sendMsg(gud_refresh_fuben) --通知刷新界面
				self:closeAlertDlg()
			end)
		else
			TOAST(getConvertedStr(1, 10160))--黄金不足
			-- print("跳到充值界面")
			local tObject = {}
		    tObject.nType = e_dlg_index.dlgrechargetip --dlg类型
		    sendMsg(ghd_show_dlg_by_type,tObject)   
		    self:closeAlertDlg()
		end
	elseif self.pData.nType == 4  then --装备关
		if self.pData and self.pData.nWeaponPaperCost  then
			if Player:getPlayerInfo().nMoney >= self.pData.nWeaponPaperCost  then
				SocketManager:sendMsg("buyFubenEquip", {self.pData.nId},
				function (__msg)
				    if  __msg.head.state == SocketErrorType.success then 
				        if __msg.head.type == MsgType.buyFubenEquip.id then
							sendMsg(gud_refresh_fuben) --通知刷新界面
							self:closeAlertDlg()
							if __msg.body.o then
								showGetAllItems(__msg.body.o)
							end
				        end
				    else
				        --弹出错误提示语
				        TOAST(SocketManager:getErrorStr(__msg.head.state))
				    end
				end)
			else
				TOAST(getConvertedStr(1, 10160))--黄金不足
				-- print("跳到充值界面")
				local tObject = {}
			    tObject.nType = e_dlg_index.dlgrechargetip --dlg类型
			    sendMsg(ghd_show_dlg_by_type,tObject)   
			    self:closeAlertDlg()
			end
		end
	end
		--todo

end
return DlgFubenBuyItemTips
