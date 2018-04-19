-- Author: maheng
-- Date: 2017-04-12 20:03:24
-- 玩家重命名对话框


local DlgAlert = require("app.common.dialog.DlgAlert")


local DlgRename = class("DlgRename", function ()
	return DlgAlert.new(e_dlg_index.rename)
end)

--构造
--tData : {nCityId = xxx, sCityName = "城市名字"} 都城/名城改名（默认为nil,以后有类似的实现都传一个tData进来入自己做判断）
function DlgRename:ctor( tData )
	self.tData = tData or nil
	self:myInit()
	parseView("dlg_rename", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgRename:myInit()
	-- body
	self._sNewName = ""
	if self.tData then
		self._nClass = 1 --
	else

	end
	self._ntype = 1 -- 1.正常使用 2.购买并使用
	self._nameMin = 2--名字最小长度
	self._nameMax = 6--名字最大长度
end
  
--解析布局回调事件
function DlgRename:onParseViewCallback( pView )
	-- body
	
	self:addContentView(pView, true)
	self:setupViews()

	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgRename",handler(self, self.onDlgRenameDestroy))
end

--初始化控件
function DlgRename:setupViews()
	-- body
	--设置标题
	local tRenameCard = Player:getBagInfo():getItemDataById(e_item_ids.gmt)
	if not tRenameCard then
		tRenameCard = getBaseItemDataByID(e_item_ids.gmt)
	end
	self:setTitle(tRenameCard.sName)
	--物品名称
	self.pLbStuffName			=			self:findViewByName("lb_stuff_name")
	self.pLbStuffName:setString(tRenameCard.sName, false)
	--物品图片
	self.pLayStuffImg 			=			self:findViewByName("lay_img")	
	--名称标注
	self.pLbNewname				= 			self:findViewByName("lb_newname")
	self.pLbNewname:setString(getConvertedStr(6, 10077))	
	--名字
	self.pLayName				=			self:findViewByName("lay_name")
	self.pTexNameInputTip 		= 			self:findViewByName("lt_name")	
	--提示内容
	self.pLbTip					= 			self:findViewByName("lb_tip")
	self.pLbTip:setString(getConvertedStr(6, 10072))
	--随机按钮
	self.pBtnSuiji				= 			self:findViewByName("btn_suiji")
	--右侧改名按钮文字设置-改名
	self:setRightBtnType(TypeCommonBtn.L_YELLOW)
	self:setRightBtnText(getConvertedStr(6,10071))


	getIconGoodsByType(self.pLayStuffImg, TypeIconGoods.NORMAL, type_icongoods_show.itemnum, tRenameCard,TypeIconGoodsSize.L)
	setLbTextColorByQuality(self.pLbStuffName, tRenameCard.nQuality)
	
	local _tabele = {}
	if tRenameCard.nCt > 0 then
		_tabele.tLabel = {{getConvertedStr(6, 10319),getC3B(_cc.green)}}	
	else
		_tabele.img = "#v1_img_qianbi.png"
		_tabele.tLabel = {{tRenameCard.nPrice,getC3B(_cc.yellow)}}		
	end
	self:getRightButton():setBtnExText(_tabele)
	--名字输入监听
	self.pTexNameInputTip:registerScriptEditBoxHandler(handler(self, self.onContentPlayerName))

	--随机按钮点击事件
	self.pBtnSuiji:onMViewClicked(handler(self, self.onBtnSuijiClicked))

	--设置右边改名按钮的按钮事件
	self:setRightHandler(handler(self, self.onBtnRightClicked))	

	--名字最小长度的配表数据
	self._nameMin = tonumber(getGlobleParam("nameMin"))
	self._nameMax = tonumber(getGlobleParam("nameMax"))

	--别的数据时处理
	if self.tData then
		--城池改名
		if self.tData.nCityId then
			self.pLbTip:setString(getConvertedStr(3, 10349))
			self.pTexNameInputTip:setPlaceHolder(self.tData.sCityName)
			--self._sNewName = self.tData.sCityName			
		end
	else
		--self._sNewName = Player:getPlayerInfo().sName
		self.pTexNameInputTip:setPlaceHolder(getConvertedStr(6, 10511))
	end	
end

-- 修改控件内容或者是刷新控件数据
function DlgRename:updateViews()
	-- body
end

--析构方法
function DlgRename:onDlgRenameDestroy()
	self:onPause()	
end

-- 注册消息
function DlgRename:regMsgs( )
	-- body
end

-- 注销消息
function DlgRename:unregMsgs(  )
	-- body
end


--暂停方法
function DlgRename:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgRename:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

--随机按钮点击回调
function DlgRename:onBtnSuijiClicked( pView )
	--body
	local randomname = getRandomName()	
	if randomname then
		self.pTexNameInputTip:setText(randomname)
		self._sNewName = randomname	
	end
end

--右侧改名按钮回调
function DlgRename:onBtnRightClicked( pView )
	-- body	
	if self._sNewName ~= "" then		
		local tRenameCard = Player:getBagInfo():getItemDataById(e_item_ids.gmt)--获取改名帖道具数据
		if	tRenameCard and tRenameCard.nCt and tRenameCard.nCt > 0 then --背包中有改名卡道具
			self._ntype = 1
			self:sendChangeNameOrGenderRequest()
		else--没有改名卡
			tRenameCard = getBaseItemDataByID(e_item_ids.gmt)--从配表读取改名帖的基本数据
			self._ntype = 2
			local nCost = tRenameCard.nPrice
		    local strTips = {
		    	{color=_cc.pwhite,text=getConvertedStr(6, 10078)}--道具不足，购买并使用
		    }
		    --展示购买对话框
			showBuyDlg(strTips,nCost,handler(self, self.sendChangeNameOrGenderRequest),1)
		end
	else
		TOAST(getConvertedStr(6, 10076))
	end
end

function DlgRename:onContentPlayerName( eventType )
	-- body
	local sInput = ""
	if eventType == "began" then
		self.pTexNameInputTip:setText(self._sNewName)
    elseif eventType == "ended" then
		-- sInput = self.pTexPasswardInputTip:getText()
    elseif eventType == "changed" then
		-- sInput = self.pTexPasswardInputTip:getText()
    elseif eventType == "return" then
		sInput = self.pTexNameInputTip:getText()		
		self:checkNewName(sInput)
    end
end

function DlgRename:checkNewName( _newName )
	-- body
	local nLength, nCntEn, nCntCn = getUtf8StringCount(_newName)
	if nLength == 0 then
		self.pLbTip:setString(getConvertedStr(6, 10076)) --名字为空提示
		islegal = false
	elseif (nCntEn + nCntCn  <= self._nameMin) or (nCntEn + nCntCn  >= self._nameMax) then
		-- print("mingzichangdu:"..#_newName)
		self.pLbTip:setString(getConvertedStr(6, 10072)) --名字长度		
		islegal = false
	end	
	self._sNewName = _newName		
end
--发送改名请求
function DlgRename:sendChangeNameOrGenderRequest( )
	-- body
	-- if self._sNewName ~= "" then	
		--别的数据时处理
		if self.tData then
			--城池改名
			if self.tData.nCityId then
				local nIfBuy = 0
				if self._ntype == 2 then
					nIfBuy = 1
				end
				SocketManager:sendMsg("reqWorldCityRename", {self.tData.nCityId, self._sNewName, nIfBuy}, handler(self, self.changenameOrGenderCallBack))
			end
		else
			local nLength, nCntEn, nCntCn = getUtf8StringCount(self._sNewName)
			if (nCntEn + nCntCn  < self._nameMin) or (nCntEn + nCntCn  > self._nameMax) then
				TOAST(getConvertedStr(7, 10124))
				return
			end
			--角色改名
			local sname = self._sNewName
			local ntype = self._ntype
			SocketManager:sendMsg("useRenameCard", {sname, ntype}, handler(self, self.changenameOrGenderCallBack))
		end
	-- else
	-- 	TOAST(getConvertedStr(6, 10076))
	-- end
end
--改名申请回调
function DlgRename:changenameOrGenderCallBack( __msg, __oldMsg )
	-- body
	-- dump(__msg, "mingzi", 100)	
	if __msg.head.state == SocketErrorType.success	then
		--别的数据时处理
		if self.tData then
			--城池改名不处理
			local nCityId = __oldMsg[1]
			local sName = __oldMsg[2]
			Player:getWorldData():setCtiyName(nCityId, sName)
		else
			--刷新玩家信息
			Player:getPlayerInfo():refreshDatasByService(__msg.body)--刷新玩家的名字性别信息		
			--发送玩家信息刷新消息
			sendMsg(gud_refresh_playerinfo)
			--改名
			sendMsg(ghd_rename_success_msg)
		end
		--改名成功	
		TOAST(getConvertedStr(6, 10528))			
		self:closeAlertDlg()--关闭对话框
	elseif 	__msg.head.state == 206 then	--名字重复，等不合法情况
		self.pLbTip:setString(getConvertedStr(6, 10073))		
	elseif __msg.head.state == 216 then    --存在特殊字符
		self.pLbTip:setString(getConvertedStr(6, 10074))
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end
end

return DlgRename
