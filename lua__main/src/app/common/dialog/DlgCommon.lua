-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-03-31 14:30:15 星期五
-- Description:  通用对话框（自适配高度）（内容层宽度为560）标题栏高度60，底部按钮层100
--               addContentView(layer,bHadBottom)方法可控制是否有底部按钮层,默认没有底部按钮层
-----------------------------------------------------

local MDialog = require("app.common.dialog.MDialog")

local DlgCommon = class("DlgCommon", function ()
	return MDialog.new()
end)


local MAX_HEIGHT = 1500
local MIN_HEIGHT = 500

-- nType：类型
-- 内容层高度
-- 底部高度
function DlgCommon:ctor(nType, nContentH, nBottomH)
	-- body
	self:myInit()
	self._nContentH = nContentH
	self._nBottomH = nBottomH
    self.eDlgType = nType or e_dlg_index.common -- 对话框类型
	parseView("dlg_common", handler(self, self.onParseViewCallback))
	self:setName(UIAction.TAG_SMALL_DLG)
end

--初始化成员变量
function DlgCommon:myInit()
	self.bHadBottom 	   = false  --是否有底部按钮层
	self._nLeftHandler 	   = nil    --左边按钮回调事件
	self._nRightHandler    = nil 	--右边按钮回调事件
	self._nLeftDisHandler  = nil    --左边按钮无效回调事件
	self._nRightDisHandler = nil    --右边按钮无效回调事件
	self._nCloseHandler = nil 		--关闭按钮的回调函数
end

--解析布局回调事件
function DlgCommon:onParseViewCallback( pView )
	-- body
	self.pComDlgView = pView
	self:setContentView(self.pComDlgView)
	self:setupViews()
	self:updateViews()

	-- 注册关闭对话框的消息
	regMsg(self, ghd_msg_close_dlg_by_type, handler(self, self.onCloseDlg))
	 --注册析构方法
    self:setDestroyHandler("DlgCommon",handler(self, self.onDlgCommonDestroy))
end

  
--初始化控件
function DlgCommon:setupViews()
	-- body
	--获得全部层
	self.pLayBase 			= 	self:findViewByName("common")
	self.pLayView 			= 	self:findViewByName("view_com_fill")
    self.pLayTop 			= 	self:findViewByName("lay_com_t")    --顶部标题层
    self.pLayBottom	 		= 	self:findViewByName("lay_com_b")    --底部按钮层
    self.pLayContent	 	= 	self:findViewByName("lay_com_c")    --内容层

	--标题
	self.pLbTitle 			= 	self:findViewByName("lb_title")
	--关闭点击事件
	self.pLayCClose 		= 	self:findViewByName("lay_com_close")
	self.pLayCClose:setViewTouched(true)
	self.pLayCClose:setIsPressedNeedScale(false)
	self.pLayCClose:onMViewClicked(handler(self, self.onCloseClicked))

	self.pImgClose 			= 	self:findViewByName("img_com_close")

	self.pViewBg			= 	self:findViewByName("view_com")


	--左右两个按钮
	self.pLayLeft 			= 	self:findViewByName("lay_left")
	self.pLayRight 			= 	self:findViewByName("lay_right") 

	self.pBtnLeft = getCommonButtonOfContainer(self.pLayLeft,TypeCommonBtn.L_RED,getConvertedStr(1,10058))
	self.pBtnRight = getCommonButtonOfContainer(self.pLayRight,TypeCommonBtn.L_BLUE,getConvertedStr(1,10059))

	--左边按钮点击事件
	self.pBtnLeft:onCommonBtnClicked(handler(self, self.onLeftClicked))
    self.pBtnLeft:onCommonBtnDisabledClicked(handler(self, self.onLeftDisabledClicked))
    --右边按钮点击事件
	self.pBtnRight:onCommonBtnClicked(handler(self, self.onRightClicked))
    self.pBtnRight:onCommonBtnDisabledClicked(handler(self, self.onRightDisabledClicked))

    --指定底部大小
    if self._nBottomH then
    	self.pLayBottom:setLayoutSize(self.pLayBottom:getWidth(), self._nBottomH)
    	self.pLayBottom:setLocalZOrder(0)
    end
    --记录底部层高度
    self.nBottomLayHeight = self.pLayBottom:getHeight()
end

-- 修改控件内容或者是刷新控件数据
function DlgCommon:updateViews()
	-- body

end

--析构方法
function DlgCommon:onDlgCommonDestroy(  )
	-- body
	-- 销毁关闭对话框的消息
    unregMsg(self, ghd_msg_close_dlg_by_type)
end

--设置内容层高度，在调用addContentView方法前调用
function DlgCommon:setContentHeight(_height)
	-- body
	self._nContentH = _height
end

--设置底部高度，在调用addContentView方法前调用
function DlgCommon:setBottomHeight(_height)
	-- body
	self._nBottomH = _height
	self.pLayBottom:setLayoutSize(self.pLayBottom:getWidth(), self._nBottomH)
	self.pLayBottom:setLocalZOrder(0)
	self.nBottomLayHeight = self.pLayBottom:getHeight()
end

--设置内容层(布局)
-- _pView ：布局
-- _bHadBottomBtn：是否需要底部按钮层
--_MIN_HEIGHT:可以传个窗口总高度过来
function DlgCommon:addContentView( _pView, _bHadBottomBtn, _MIN_HEIGHT)
	-- body
	if _pView then
		local nNewHeigth = 0
		local pContent = _pView
		if self._nContentH then
			--顶部对齐
			pContent = MUI.MLayer.new()
			pContent:setLayoutSize(_pView:getWidth(), self._nContentH)
			pContent:addView(_pView)
			_pView:setPosition(0, self._nContentH - _pView:getHeight())
		end
		nNewHeigth = pContent:getHeight() + self.pLayTop:getHeight() 
				+ self.pLayBottom:getHeight()
		
	
		-- if not _bHadBottomBtn then
		-- 	self.bHadBottom = false	
		-- else
		-- 	self.bHadBottom = _bHadBottomBtn
		-- end
		-- self:setBottomBtnVisible(self.bHadBottom)
		local _MIN_HEIGHT = _MIN_HEIGHT or MIN_HEIGHT
		
		local isMax = false
		if nNewHeigth < _MIN_HEIGHT then
			nNewHeigth = _MIN_HEIGHT
		end
		if nNewHeigth > MAX_HEIGHT then
			nNewHeigth = MAX_HEIGHT
			isMax = true
		end
		self.pLayBase:setContentSize(cc.size(self.pLayBase:getWidth(), nNewHeigth))
		self.pLayView:setContentSize(cc.size(self.pLayView:getWidth(), nNewHeigth))
		self.pLayView:requestLayout()

		--记录窗口本身高度
		self.nLayBaseHeight = self.pLayBase:getHeight()

		if isMax == true then --如果超过最大高度，多嵌套一层ScrollView
			--scrollLayer的高
			local nSvH = 0
			if self.bHadBottom then
				nSvH = nNewHeigth - self.pLayTop:getHeight() - self.pLayBottom:getHeight()
			else
				nSvH = nNewHeigth - self.pLayTop:getHeight() 
			end
			local pSv = MUI.MScrollLayer.new({viewRect=cc.rect(0, 0, self.pLayContent:getWidth(), nSvH),
			    touchOnContent = false,
			    direction=MUI.MScrollLayer.DIRECTION_VERTICAL})
			self.pLayContent:addView(pSv)
			pSv:setBounceable(true)
			pSv:addView(pContent)
		else
			self.pLayContent:addView(pContent)
        	centerInView(self.pLayContent,pContent)
		end

		if not _bHadBottomBtn then
			self.bHadBottom = false	
		else
			self.bHadBottom = _bHadBottomBtn
		end
		self:setBottomBtnVisible(self.bHadBottom)

		self:refreshContentView()
	end
end

-- 设置标题
function DlgCommon:setTitle(_title)
    if not _title then
    	return
    end
     self.pLbTitle:setString(_title)
end

-- 关闭点击
function DlgCommon:onCloseClicked(pView)
	if self._nCloseHandler then
		self._nCloseHandler()
		return
	end
    self:closeCommonDlg()
end

-- 关闭对话框
function DlgCommon:onCloseDlg( sMsgName, pMsgObj )
	if (pMsgObj and pMsgObj.eDlgType == self.eDlgType) then
		self:closeCommonDlg()
	end
end

-- 关闭对话框
function DlgCommon:closeCommonDlg()
	self:closeDlg(false)
end

-- 设置左边handler
function DlgCommon:setLeftHandler(_handler)
    self._nLeftHandler = _handler
end

-- 设置右边handler
function DlgCommon:setRightHandler(_handler)
    self._nRightHandler = _handler
end

-- 设置关闭回调handler
function DlgCommon:setCloseHandler(_handler)
    self._nCloseHandler = _handler
end

-- 取消左边按钮事件
function DlgCommon:onLeftClicked(pView)
    if self._nLeftHandler then
        self._nLeftHandler()
    else
    	self:closeCommonDlg()
    end
    
end

-- 确定右边按钮事件
function DlgCommon:onRightClicked(pView)
    if self._nRightHandler then
        self._nRightHandler()
    else
    	self:closeCommonDlg()
    end
end

--设置左边无效回调
function DlgCommon:setLeftDisabledHandler(_handler )
	-- body
	self._nLeftDisHandler = _handler
end

--设置左边无效回调
function DlgCommon:setRightDisabledHandler(_handler )
	-- body
	self._nRightDisHandler = _handler
end

-- 取消左边无效按钮事件
function DlgCommon:onLeftDisabledClicked(pView)
    if self._nLeftDisHandler then
        self._nLeftDisHandler()
    end
end

-- 确定右边无效按钮事件
function DlgCommon:onRightDisabledClicked(pView)
    if self._nRightDisHandler then
        self._nRightDisHandler()
    end
end

--获得左边按钮
function DlgCommon:getLeftButton( )
	-- body
	return self.pBtnLeft
end

--获得右边按钮
function DlgCommon:getRightButton( )
	-- body
	return self.pBtnRight
end

-- 只有确定选项
function DlgCommon:setOnlyConfirm(_sText)
    self.pLayLeft:setVisible(false)
    if _sText then
    	self:setRightBtnText(_sText)
    end
    self.pLayRight:setPositionX((self.pLayBottom:getContentSize().width - 
        self.pLayRight:getContentSize().width) / 2)
end

function DlgCommon:getOnlyConfirmButton(_nType,_sText)
	self:setOnlyConfirm(_sText)
	self:setOnlyConfirmBtn(_nType)
	return self.pBtnRight
end

--设置按钮样式
function DlgCommon:setOnlyConfirmBtn( _nType )
	-- body
	self:setRightBtnType(_nType)
end

--隐藏按钮层
function DlgCommon:visibleDownBottom(_bVisiable)
	if self.pLayBottom then
		self.pLayBottom:setVisible(_bVisiable)
	end
end

function DlgCommon:setBottomBtnVisible( _bVisiable )
	self.pLayLeft:setVisible(_bVisiable)
	self.pLayRight:setVisible(_bVisiable)

	--设置了底部高度就不处理
	if self._nBottomH then
	else
		--没按钮时调整底部的高度
		if not _bVisiable then
			local nSubHeight=self.pLayBottom:getHeight()-60

			self.pLayBase:setContentSize(cc.size(self.pLayBase:getWidth(), self.pLayBase:getHeight()-nSubHeight))
			self.pLayBottom:setLayoutSize(self.pLayBottom:getWidth(),self.pLayBottom:getHeight()-nSubHeight)
			self.pLayView:setContentSize(cc.size(self.pLayView:getWidth(),self.pLayView:getHeight()-nSubHeight))
			self.pLayView:requestLayout()
		else
			self.pLayBase:setContentSize(cc.size(self.pLayBase:getWidth(), self.nLayBaseHeight))
			self.pLayBottom:setLayoutSize(self.pLayBottom:getWidth(), self.nBottomLayHeight)
			self.pLayView:setContentSize(cc.size(self.pLayView:getWidth(), self.nLayBaseHeight))
			self.pLayView:requestLayout()
		end

	end


	-- self.pLayView:setContentSize(cc.size(self.pLayView:getWidth(), 60))

	-- self.pLayBase:setContentSize(cc.size(self.pLayBase:getWidth(), nHeight))
end

function DlgCommon:setNeedBottomBg( _bNeed )

	if not  _bNeed then
		if self.pLayBottom and self.pLayBottom:isVisible() then
			local nHeight = self.pLayBase:getHeight() - self.pLayBottom:getHeight()
			self.pLayBottom:removeSelf()
			self.pLayBase:setContentSize(cc.size(self.pLayBase:getWidth(), nHeight))
			self.pLayView:setContentSize(cc.size(self.pLayView:getWidth(), nHeight))
			self.pLayView:requestLayout()
		end
	end
end

--设置左边按钮 文字内容
--_sText 按钮内容
function DlgCommon:setLeftBtnText(_sText)
	local sText = _sText
	if sText == nil then
		return
	end
	self.pBtnLeft:updateBtnText(sText)
end

--设置右边按钮 文字内容
--_sText 按钮内容
function DlgCommon:setRightBtnText(_sText)
	local sText = _sText
	if sText == nil then
		return
	end
	self.pBtnRight:updateBtnText(sText)
end

--设置左边样式
function DlgCommon:setLeftBtnType( _nType )
	-- body
	self.pBtnLeft:updateBtnType(_nType)
end

--设置右边样式
function DlgCommon:setRightBtnType( _nType )
	-- body
	self.pBtnRight:updateBtnType(_nType)
end

--设置右边按钮上扩展文字
function DlgCommon:setRightBtnExText(_tbale)
	if _tbale then
		return self.pBtnRight:setBtnExText(_tbale)
	end
end

--设置左边按钮是否有效
function DlgCommon:setLeftBtnEnabled(_bEnabled)
	self.pBtnLeft:setBtnEnable(_bEnabled)
end

--设置右边按钮是否有效
function DlgCommon:setRightBtnEnabled(_bEnabled)
	self.pBtnRight:setBtnEnable(_bEnabled)
end

--由于每日登录继承自该类，然而每日收贡
--和通用的背景图素和按钮图素不一样，所以
--在需要该显示方式的时候调用即可
function DlgCommon:changeToOtherType()
	self.pImgClose:setCurrentImage("#v1_btn_closebig2.png")
	self.pImgClose:setPosition(cc.p(self.pImgClose:getPositionX() + 13,self.pImgClose:getPositionY() + 5))
	self.pViewBg:setBackgroundImage("#v1_img_yindaotankuang.png",{scale9 = true,capInsets=cc.rect(572/2,242/2, 1, 1)})
end



return DlgCommon