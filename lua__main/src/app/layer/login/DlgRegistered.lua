----------------------------------------------------- 
-- author: maihuahao
-- updatetime: 2017-03-28 15:51:36
-- Description: 注册登陆界面

-----------------------------------------------------
local MDialog = require("app.common.dialog.MDialog")
local ItemAccoutList = require("app.layer.login.ItemAccoutList")

local RegType = { --登陆界面状态
	RegTypeLogn     = 1,       --登陆状态
	RegTyRerRgister = 2, 	   --用户注册状态
	RegTyRerAuto    = 3,       --一键注册
}

local DlgRegistered = class("DlgRegistered", function ()
	return MDialog.new()
end)

-- nType：类型
function DlgRegistered:ctor()
	-- body
	self:myInit()
	parseView("dlg_login_registered", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgRegistered:myInit()
	self.bIsOpenAccoutShow      = false  --是否打开账号展示列表
	self.eDlgType 				= e_dlg_index.register --登录对话框

	self.nRegisterTppe          = RegType.RegTypeLogn --初始化注册状态
	self.sAccout 		        = ""
	self.sPassward 			    = ""
	self.sModifyPassward 		= ""
	self.tMoreAccounts 		    = {}
	self:initRecentlyAccount()
end

--解析布局回调事件
function DlgRegistered:onParseViewCallback( pView )
	-- body
	self:setContentView(pView)
	self:setIsNeedOutside(false)
	self:setupViews()
	self:updateViews()
	--注册析构方法
	self:setDestroyHandler("DlgRegistered",handler(self, self.onDlgRegisteredDestroy))
end

  
--初始化控件
function DlgRegistered:setupViews()
	-- body
	--获得全部层
	self.pLayoutBase 			   =  self:findViewByName("base")
    self.pLayoutTempTop 		   =  self:findViewByName("layout_temp_1") --顶部临时层
    self.pLayoutTop 			   =  self:findViewByName("layout_top")    --顶部标题层
    self.pLayoutBottom	 		   =  self:findViewByName("layout_bottom") --底部按钮层
    self.pLayoutContent	 		   =  self:findViewByName("layout_content")--内容层

    self.pAccoutListView    	   =  self:findViewByName("layout_listview_account")--账号显示层
    self.pAccoutBg          	   =  self:findViewByName("layout_zhanghao")--输入账号显示层
    self.pAccoutTip         	   =  self:findViewByName("layout_zhanghao_num")--一键注册 账号显示层

    --文字
    self.pTexAccoutInputTip        =  self:findViewByName("label_zhanghao") --账号输入框的提示文字
    self.pTexPasswardInputTip      =  self:findViewByName("label_mima") --密码输入框的提示文字
    self.pTexWarming               =  self:findViewByName("label_warming")  --警告提示文字

    --账号一键注册成功文字提示
    self.pTexTip1                  =  self:findViewByName("label_tip_zhanghao_success") --注册成功
	self.pTexTip2 			       =  self:findViewByName("label_tip_zhanghao_zh") --账号
	self.pTexTip3 			       =  self:findViewByName("label_tip_zhanghao_mm")  --密码

	--一键注册 成功账号 数据
	self.pTexTipAccout     		   =  self:findViewByName("label_shuru_zhanghao") --账号
	self.pTexTipPassward  		   =  self:findViewByName("label_shuru_mima") --密码

	--标题
	self.pLbTitle 				   =  self:findViewByName("lb_title")
	setTextCCColor(self.pLbTitle,_cc.pwhite)

	--密码提示
	self.pLbMima 				   = self:findViewByName("lb_mima")	
	setTextCCColor(self.pLbMima,_cc.pwhite)
	self.pLbMima:setString(getConvertedStr(4, 10007))
	--账号提示
	self.pLbZhanghao 			   = self:findViewByName("lb_zhanghao")	
	setTextCCColor(self.pLbZhanghao,_cc.pwhite)
	self.pLbZhanghao:setString(getConvertedStr(4, 10006))


	--获取基本控件
	self.pBtnClose   		 	   =  self:findViewByName("btn_close")	
	self.pBtnClose:setVisible(false)

	self.pBtnArrow  			   =  self:findViewByName("layout_select_account")	
	self.pBtnArrow:setViewTouched(true)
	self.pBtnArrow:setIsPressedNeedColor(false)

	self.pImgArrow    			   =  self:findViewByName("img_arrow")	--箭头图片
	self.pImgArrow:setRotation(180)

	self.pBtnReturn   			   =  self:findViewByName("btn_return")	
	self.pBtnReturn:setViewTouched(true)
	self.pBtnReturn:setIsPressedNeedColor(false)

	--左右两个按钮
	self.pLeftLayout 			   =  self:findViewByName("layout_btn_left")
	self.pRightLayout 			   =  self:findViewByName("layout_btn_right") 

	self.pBtnLeft = getCommonButtonOfContainer(self.pLeftLayout,TypeCommonBtn.M_BLUE, getConvertedStr(4, 10001))
	self.pBtnLeft:onCommonBtnClicked(handler(self, self.onLeftClicked))

	self.pBtnRight = getCommonButtonOfContainer(self.pRightLayout,TypeCommonBtn.M_BLUE, getConvertedStr(4, 10002))
	self.pBtnRight:onCommonBtnClicked(handler(self, self.onRightClicked))

	if N_PACK_MODE == 1000 then --测试服
	    self.pTexWarming:setViewTouched(true)
	    self.pTexWarming:onMViewClicked(function (  )
	        -- body
	        TOAST("开启战斗场景拖动")
	    end)
	else
	    self.pTexWarming:setViewTouched(false)
	end
end

-- 修改控件内容或者是刷新控件数据
function DlgRegistered:updateViews()
	--文字
	self:setTitle(getConvertedStr(4, 10003))		 	
	self.pTexWarming:setString(getConvertedStr(4, 10004))    --账号密码提示   
	self.pTexTip1:setString(getConvertedStr(4, 10005))       --注册成功     
	self.pTexTip2:setString(getConvertedStr(4, 10006))       --账号      
	self.pTexTip3:setString(getConvertedStr(4, 10007))       --密码    

	self:setInputAccoutPlaceHolder(getConvertedStr(4, 10012)) 	--账号输入提示
	self:setInputPasswardPlaceHolder(getConvertedStr(4, 10013))  --密码输入提示

    --返回用户登陆
	self.pBtnReturn:onMViewClicked(function ( )
   		self:onReturnClicked()
	 end)

	--下拉箭头点击
	self.pBtnArrow:onMViewClicked(function ( )
   		self:onArrowClicked()
	end)

	--输入框文字 设置输入事件
	self.pTexAccoutInputTip:registerScriptEditBoxHandler(handler(self, self.onContentAccout))
	self.pTexPasswardInputTip:registerScriptEditBoxHandler(handler(self, self.onContentPassward))
    self:userLogin() --初始状态为登陆界面 
end


--析构方法
function DlgRegistered:onDlgRegisteredDestroy(  )
	-- body
end

-- 设置标题
function DlgRegistered:setTitle(_title)
    if not _title then
    	return
    end
     self.pLbTitle:setString(_title)
end

-- 设置账号输入框文字
function DlgRegistered:setInputAccoutNum(_sNum)
	 self.pTexAccoutInputTip:setText(_sNum)
end

-- 设置账号输入框"占位"文字
function DlgRegistered:setInputAccoutPlaceHolder(_sNum)
	self.pTexAccoutInputTip:setPlaceHolder(_sNum)
end
	  
-- 设置密码输入框提示文字
function DlgRegistered:setInputPassward(_sNum)
	self.pTexPasswardInputTip:setText(_sNum)
end

-- 设置密码输入框提示"占位"文字
function DlgRegistered:setInputPasswardPlaceHolder(_sNum)
	self.pTexPasswardInputTip:setPlaceHolder(_sNum)
end

-- 左边按钮事件
function DlgRegistered:onLeftClicked(pView)
    --切换状态
    if self.nRegisterTppe == RegType.RegTypeLogn  then
    	self.nRegisterTppe = RegType.RegTyRerRgister
    	self:changeRegType(self.nRegisterTppe) --设置登录状态
    	self:setAccout("")
    	self:setPassward("")
    elseif self.nRegisterTppe == RegType.RegTyRerRgister then
   		self:doRegist() --注册游戏
    elseif self.nRegisterTppe == RegType.RegTyRerAuto then
    	local nGetRemainPwd = self:getPassward()
	    if (self:checkPassword(nGetRemainPwd) ~= true) then
			TOAST(getConvertedStr(4, 10019))
			return
	    end
    	self:doModifyPwd(self:getAccout(),self.sModifyPassward,self:getPassward()) --修改密码
    end
end

-- 下拉点击
function DlgRegistered:onArrowClicked(pView)
	if self.bIsOpenAccoutShow then
		self.pImgArrow:setRotation(180)
		self.bIsOpenAccoutShow = false
		self:showListAccout(false) --设置隐藏最近账号
	else
		self.bIsOpenAccoutShow = true
		self.pImgArrow:setRotation(0)
		self:showListAccout(true) --设置显示最近账号

	end
end

-- 返回点击
function DlgRegistered:onReturnClicked(pView)
    --切换状态
	if self.nRegisterTppe == RegType.RegTyRerRgister  then
		self.nRegisterTppe = RegType.RegTypeLogn
	elseif self.nRegisterTppe == RegType.RegTyRerAuto then
		self.nRegisterTppe = RegType.RegTyRerRgister
	end
	self:changeRegType(self.nRegisterTppe) --设置登录状态
end


-- 确定右边按钮事件
function DlgRegistered:onRightClicked(pView)
    --切换状态
    if self.nRegisterTppe == RegType.RegTyRerRgister  then
    	self.nRegisterTppe = RegType.RegTyRerAuto
    	self:doFastRegist()
    else 
    	self:onLoginGame()--请求登陆游戏
    end
	self:changeRegType(self.nRegisterTppe) --设置登录状态
end

--登陆游戏
function DlgRegistered:onLoginGame()

	local sAccount = self:getAccout()
	local sPwd 	   = self:getPassward()

	if #sAccount <= 0 then
		TOAST(getConvertedStr(4, 10017))
		return 
	end

	if #sPwd <= 0 then
		TOAST(getConvertedStr(4, 10018))
		return 
	end

    if (self:checkAccount(sAccount) ~= true) then
		TOAST(getConvertedStr(4, 10019))
		return
    end

    if (self:checkPassword(sPwd) ~= true) then
		TOAST(getConvertedStr(4, 10020))
		return
    end

 	--请求网络数据（回调接口）
	HttpManager:doLogin(sAccount, sPwd, handler(self, self.onLoginResponse))
end

--注册账号
function DlgRegistered:doRegist()
	local sAccount = self:getAccout()
	local sPwd 	   = self:getPassward()
	if #sAccount == 0 or #sPwd == 0 then
		TOAST(getConvertedStr(6, 10537))
		return
	end
	--请求网络数据（回调接口）
	HttpManager:doRegist(sAccount, sPwd, handler(self, self.onLoginResponse))

end

--一键注册
function DlgRegistered:doFastRegist()
	HttpManager:doRegistFast(handler(self, self.onFastRegResponse))
end

--一键注册回调
function DlgRegistered:onFastRegResponse(event)
	-- 在结束时才处理这个结果
	if(event.name == "completed") then
	    if (event.data.s == 0) then
	    	--获得一键注册后的内容
	    	self:setAccout(event.data.r.ac) --账号
	    	self:setPassward(event.data.r.pw) --密码
	    	self.sModifyPassward = event.data.r.pw
	    	--显示一键注册成功的账号和密码
			self.pTexTipAccout:setString(self:getAccout())
			self.pTexTipPassward:setString(self:getPassward())
	    else
	    	TOAST(HttpManager:getStatusMsg(event.data.s))
	    end
	elseif event.name == "failed" then
		TOAST(getConvertedStr(4, 10021))
	end
end

--一键注册修改密码
function DlgRegistered:doModifyPwd(account,oldPass, newPass1)
	-- body
	HttpManager:doChangePass(account, oldPass, newPass1, handler(self, self.onChangePassResponse))
end

--一键注册修改密码回调
function DlgRegistered:onChangePassResponse(event)
    -- 在结束时才处理这个结果
	if(event.name == "completed") then
	    if (event.data.s == 0) then
	        TOAST(getConvertedStr(4, 10022))
			self.pTexTipPassward:setString(self:getPassward())
	        local acc = self:getAccout()
	        local pwd = self:getPassward()
	        HttpManager:doLogin(acc, pwd, handler(self, self.onLoginResponse))
	    else
	        TOAST(HttpManager:getStatusMsg(event.data.s))
	    end
	elseif event.name == "failed" then
		TOAST(getConvertedStr(4, 10021))
	end
end

--由于注册成功 已经是执行了登录操作
function DlgRegistered:onLoginResponse(event)
	-- body
	-- 在结束时才处理这个结果
	if(event.name == "completed") then
		local bIs = AccountCenter.parseAccountInfo(event.data)
		if(bIs) then
			self:saveRecentData()
			self:closeDlg(false)
		else
			 TOAST(HttpManager:getStatusMsg(event.data.s))
		end
	elseif (event.name == "failed") then
		TOAST(getConvertedStr(4, 10021))
	end
end


--根据需求判断账号合法性
function DlgRegistered:checkAccount(_acc)
    if (#_acc < 4 or #_acc > 16) then
 		return false
    end
    local m = string.match(_acc, "^[%w]+$")
    if m == nil then
        return false
    end
    return true
end

--根据需求判断密码合法性
function DlgRegistered:checkPassword(_pwd)
    if (#_pwd < 6 or #_pwd > 16) then
	    return false
    end
    return true
end

--设置登录状态
function DlgRegistered:changeRegType(_nRegisterType)
    --切换状态
    if self.nRegisterTppe == RegType.RegTypeLogn  then
    	 self:userLogin()
    elseif self.nRegisterTppe == RegType.RegTyRerRgister then
    	 self:UserRegister()
    elseif self.nRegisterTppe == RegType.RegTyRerAuto then
    	 self:autoRegister()
    end
end

--用户登录
function DlgRegistered:userLogin()
	self:getLocalLoginData() --获取本地账号,密码
    self:setTitle(getConvertedStr(4,10003)) --用户登录
	--设置按钮颜色与文字
    self.pBtnLeft:updateBtnText(getConvertedStr(4,10001))  --注册
    self.pBtnRight:updateBtnText(getConvertedStr(4,10002)) --登陆
    --设置返回按钮
    self:InitReturnBtton(false)
	self:setInputAccoutPlaceHolder(getConvertedStr(4, 10012))    --账号输入提示
    self:setInputPasswardPlaceHolder(getConvertedStr(4, 10013))  --密码输入提示
    --下拉按钮
    self:InitArrowBtton(true)
    --账号显示模块
	self.pAccoutBg:setVisible(true)   
	self.pAccoutTip:setVisible(false) 
end

--用户注册状态
function DlgRegistered:UserRegister()

	--清空显示账号,密码数据
	self:setInputAccoutNum("")
	self:setInputPassward("")
	self:setTitle(getConvertedStr(4, 10010)) --一键注册

    self.pBtnLeft:updateBtnText(getConvertedStr(4,10001)) 
    self.pBtnRight:updateBtnText(getConvertedStr(4,10014)) 

    --设置返回按钮
    self:InitReturnBtton(true)
	self:setInputAccoutPlaceHolder(getConvertedStr(4,10008)) --账号输入提示
    self:setInputPasswardPlaceHolder(getConvertedStr(4,10009))  --密码输入提示

    --下拉按钮
    self:InitArrowBtton(false)

    --账号显示模块
	self.pAccoutBg:setVisible(true)   
	self.pAccoutTip:setVisible(false) 
end

--一键注册状态
function DlgRegistered:autoRegister()

	--清空显示账号,密码数据
	self:setInputAccoutNum("")
	self:setInputPassward("")

	self:setTitle(getConvertedStr(4, 10014)) --一键注册

	self.pBtnLeft:updateBtnText(getConvertedStr(4, 10015))

	self.pBtnRight:updateBtnText(getConvertedStr(4, 10016))

    --设置返回按钮
    self:InitReturnBtton(true)
	self:setInputAccoutPlaceHolder(getConvertedStr(4, 10008)) --账号输入提示
    self:setInputPasswardPlaceHolder(getConvertedStr(4, 10009))  --密码输入提示

    --下拉按钮
    self:InitArrowBtton(false)

    --账号显示模块
	self.pAccoutBg:setVisible(false)   
	self.pAccoutTip:setVisible(true)     
end

--初始化 返回按钮
--方法说明
--program1  _bIsVisible 是否启用返回按钮
function DlgRegistered:InitReturnBtton(_bIsVisible)
	self.pBtnReturn:setVisible(_bIsVisible)
	self.pBtnReturn:setIsPressedNeedColor(_bIsVisible)
end

--初始化 下拉按钮
--方法说明
--program1  _bIsVisible 是否启用下拉按钮
function DlgRegistered:InitArrowBtton(_bIsVisible)
	self.pBtnArrow:setVisible(_bIsVisible)
	self.pImgArrow:setVisible(_bIsVisible)	
	self.pBtnArrow:setIsPressedNeedColor(_bIsVisible)
end


-- 返回点击
function DlgRegistered:onReturnClicked(pView)
	    --切换状态
    if self.nRegisterTppe == RegType.RegTyRerRgister  then
    	self.nRegisterTppe = RegType.RegTypeLogn
    elseif self.nRegisterTppe == RegType.RegTyRerAuto then
    	self.nRegisterTppe = RegType.RegTyRerRgister
    end
	self:changeRegType(self.nRegisterTppe) --设置登录状态
end

--账号输入返回内容
--方法说明
--program1 eventType
function DlgRegistered:onContentAccout(eventType)
	local sInput = ""
	if eventType == "began" then
		-- sInput = self.pTexAccoutInputTip:getText()
    elseif eventType == "ended" then
		-- sInput = self.pTexAccoutInputTip:getText()
    elseif eventType == "changed" then
		-- sInput = self.pTexAccoutInputTip:getText()
    elseif eventType == "return" then
		sInput = self.pTexAccoutInputTip:getText()
		self:setAccout(sInput)
    end
end

--密码输入返回内容
--方法说明
--program1 eventType
function DlgRegistered:onContentPassward(eventType)
	local sInput = ""
	if eventType == "began" then
		-- sInput = self.pTexPasswardInputTip:getText()
    elseif eventType == "ended" then
		-- sInput = self.pTexPasswardInputTip:getText()
    elseif eventType == "changed" then
		-- sInput = self.pTexPasswardInputTip:getText()
    elseif eventType == "return" then
		sInput = self.pTexPasswardInputTip:getText()
		self:setPassward(sInput)
    end
end


--设置发送的账号
--方法说明
--program1 _sAccout 账号
function DlgRegistered:setAccout(_sAccout)
	self.sAccout = _sAccout
	AccountCenter.acc = _sAccout
end

--获得账号
function DlgRegistered:getAccout()
	return self.sAccout
end

--设置发送的密码
--方法说明
--program1 _sPassward 密码
function DlgRegistered:setPassward(_sPassward)
	self.sPassward = _sPassward
	AccountCenter.pass = sPwd
end

--获得密码
function DlgRegistered:getPassward()
	return self.sPassward
end

-- 只有确定选项
function DlgRegistered:setOnlyConfirm(_sText)
    -- 取消
    self.pBtnLeft:setVisible(false)
    if _sText then
    	self.pBtnRight:setCommonBtnText1(_sText)
    end

    -- 确定
    self.pRightLayout:setPositionX((self.pLayoutContent:getContentSize().width - 
    self.pRightLayout:getContentSize().width)/2 + self.pLayoutContent:getPositionX())
end

--设置 显示账号下拉菜单选项
-- 方法说明
--_sText 按钮内容
function DlgRegistered:showListAccout(_bIsVisible)

	if _bIsVisible then
		self.pAccoutListView:setVisible(true)
		self:updateMoreAcc() --初始化更多账号
	else
		self.pAccoutListView:setVisible(false)
		if self.pListView and self.pListView:getItemCount() > 0 then
			self.pListView:removeAllItems()
		end	
	end
end

--初始化最近登录用户账号
function DlgRegistered:initRecentlyAccount( )
	self.tMoreAccounts = getPlayerAccDatas()
end

--获取本地账号和密码
function DlgRegistered:getLocalLoginData()
	local sAcc = getLocalInfo("acc", "")
	local sPass = getLocalInfo("pass", "")

	if sAcc ~= "" then --必须保存的账号不为空
		if self:getAccout() =="" then --必须输入的账号不为空 才能去保存的地方拿账号
			self:setAccout(sAcc)
			self:setPassward(sPass)
			self:setInputAccoutNum(sAcc)
			self:setInputPassward(sPass)
		end
	end
end

--统一设置账号,密码 包含显示与
--更多账号
function DlgRegistered:updateMoreAcc( )

	if self.tMoreAccounts == nil or table.nums(self.tMoreAccounts) == 0 then
		return
	end

	-- init and add ListView --------------------
	self.pListView = MUI.MListView.new {
		bgColor    = cc.c4b(255, 255, 255, 250),
		viewRect   = cc.rect(0, 0, self.pAccoutListView:getContentSize().width, self.pAccoutListView:getContentSize().height),
		direction  = MUI.MScrollView.DIRECTION_VERTICAL,
		itemMargin = {
			left       =  0,
			right      =  0,
			top        =  2,
			bottom     =  0
		}
    }

    self.pAccoutListView:addView(self.pListView)
    centerInView(self.pAccoutListView,self.pListView )
    self.pListView:setItemCount(table.nums(self.tMoreAccounts))

    -- set data for item ------------------------
    self.pListView:setItemCallback(function ( _index, _pView ) 
    	local pItemData = self.tMoreAccounts[_index]
        local pTempView = _pView
        if pTempView == nil then
        	pTempView   = ItemAccoutList.new()
    	end

		pTempView:setHandler(handler(self, self.onMoreAccClicked)) --设置事件回调
		pTempView:setIdNum(_index) --创建时设置ID
		pTempView:setAccoutStr(pItemData.name) --设置显示账户
        return pTempView
	end)

	-- 载入所有展示的item
	self.pListView:reload()
end


--更多账号点击回调
--prigrom1 _num 对应点击编号
function DlgRegistered:onMoreAccClicked(_num)
	local sAcc  = self.tMoreAccounts[_num].name
	local sPass = self.tMoreAccounts[_num].pass

	self:setInputAccoutNum(sAcc)
	self:setInputPassward(sPass)

	self:setAccout(sAcc)
	self:setPassward(sPass)	

	local index = nil
	for i = 1, #self.tMoreAccounts, 1 do
		if self.tMoreAccounts[i].name == sAcc then
			index = i
		end
	end

	if index ~= nil then
		local temp = self.tMoreAccounts[index]
		table.remove(self.tMoreAccounts,index)
		table.insert(self.tMoreAccounts, 1,temp)
	end

	--隐藏账号操作
	self.pImgArrow:setRotation(180)
	self.bIsOpenAccoutShow = false
	self:showListAccout(false) --设置显示最近账号

	self:saveRecentData()
end


--保存最近登录账户列表
function DlgRegistered:saveRecentData()
	-- body
	--保存最近登录的用户信息
	saveLocalInfo("acc", self:getAccout() or "")
	saveLocalInfo("pass",self:getPassward() or "")
    
    --登录成功的用户
    local isHad = nil
    for i = 1, #self.tMoreAccounts, 1 do
    	if self.tMoreAccounts[i].name == AccountCenter.acc then
    		isHad = i
    	end
    end

    local aAcc = {}
    aAcc.name = self:getAccout()
	aAcc.pass = self:getPassward()

    if isHad == nil then
		table.insert(self.tMoreAccounts,1, aAcc)
	else --有的情况下
		table.remove(self.tMoreAccounts, isHad)
		table.insert(self.tMoreAccounts, 1, aAcc)
    end
    savePlayerAccDatas(self.tMoreAccounts)
end

return DlgRegistered