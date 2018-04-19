-----------------------------------------------------
-- author: dengshulan
-- updatetime:  2017-03-30 15:39:41 星期四
-- Description: 基础对话框(自适配高度) 宽度：400，顶部标题栏高度60，底部按钮层100，默认内容层高度210
-- 说明：1.支持简单的文本提示，直接调用setContent()方法
-- 		 2.支持布局加载，调用addContentView(pView,bHadBottom)方法
--       3.addContentView(layer,bHadBottom)方法可控制是否有底部按钮层,默认有底部按钮层
-----------------------------------------------------


local MDialog = require("app.common.dialog.MDialog")

local MAX_HEIGHT = 750
local MIN_HEIGHT = 400

local DlgAlertSmall = class("DlgAlertSmall", function ()
	return MDialog.new()
end)

-- nType：类型
function DlgAlertSmall:ctor(nType, nContentH, nBottomH)
	-- body
	self:myInit()
	self._nContentH = nContentH
	self._nBottomH = nBottomH
    self.eDlgType = nType or e_dlg_index.alert -- 对话框类型
	parseView("dlg_alert_small", handler(self, self.onParseViewCallback))
	self:setName(UIAction.TAG_SMALL_DLG)
end

--初始化成员变量
function DlgAlertSmall:myInit()
	self._nLeftHandler 	   = nil    --左边按钮回调事件
	self._nRightHandler    = nil 	--右边按钮回调事件
	self._nLeftDisHandler  = nil    --左边按钮无效回调事件
	self._nRightDisHandler = nil    --右边按钮无效回调事件
	self.bHadBottom 	   = true   --是否有底部按钮层
end
  
--解析布局回调事件
function DlgAlertSmall:onParseViewCallback( pView )
	-- body
	self.pAlertDlgView = pView
	self:setContentView(self.pAlertDlgView)
	self:setupViews()
	self:updateViews()
	 --注册析构方法
    self:setDestroyHandler("DlgAlertSmall",handler(self, self.onDlgAlertSmallDestroy))
    -- 注册关闭对话框的消息
    regMsg(self, ghd_msg_close_dlg_by_type, handler(self, self.onCloseDlg))
end

--初始化控件
function DlgAlertSmall:setupViews()
	-- body
	--获得全部层
	self.pLayBase 			= 	self:findViewByName("alert")
	self.pLayView 			= 	self:findViewByName("view_alert_fill")
    self.pLayTop 			= 	self:findViewByName("lay_alert_t")    --顶部标题层
    self.pLayBottom	 		= 	self:findViewByName("lay_alert_b")    --底部按钮层
    self.pLayContent	 	= 	self:findViewByName("lay_alert_c")    --内容层

	--标题
	self.pLbTitle 			= 	self:findViewByName("lb_title")
	--关闭点击事件
	self.pLayAClose 		= 	self:findViewByName("lay_alert_close")
	self.pLayAClose:setViewTouched(true)
	self.pLayAClose:setIsPressedNeedScale(false)
	self.pLayAClose:onMViewClicked(handler(self, self.onCloseClicked))
	--左右两个按钮
	self.pLayLeft 			= 	self.pAlertDlgView:findViewByName("lay_left")
	self.pLayRight 			= 	self.pAlertDlgView:findViewByName("lay_right") 

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
function DlgAlertSmall:updateViews()
	-- body

end

--析构方法
function DlgAlertSmall:onDlgAlertSmallDestroy()
	-- 销毁关闭对话框的消息
    unregMsg(self, ghd_msg_close_dlg_by_type)
end

--设置内容层(布局)
-- _pView ：布局
-- _bHadBottomBtn
function DlgAlertSmall:addContentView( _pView, _bHadBottomBtn )
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

		-- self.bHadBottom = _bHadBottomBtn 
		-- if self.bHadBottom == nil then
		-- 	self.bHadBottom = true
		-- end
		-- if not self.bHadBottom then
		-- 	-- 移除底部
		-- 	self:removeBottom()
		-- 	--计算新的高度 动态刷新
		-- 	nNewHeigth = _pView:getHeight() + self.pLayTop:getHeight() 
		-- else
		-- 	--计算新的高度 动态刷新
		-- 	nNewHeigth = _pView:getHeight() + self.pLayTop:getHeight() 
		-- 		+ self.pLayBottom:getHeight()
		-- end

		local isMax = false
		if nNewHeigth < MIN_HEIGHT then
			nNewHeigth = MIN_HEIGHT
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
			--居中显示
			local pDetailLayer = MUI.MLayer.new()
			self.pLayContent:addView(pDetailLayer)
			pDetailLayer:setLayoutSize(self.pLayContent:getWidth(),self.pLayContent:getHeight())
    		centerInView(self.pLayContent,pDetailLayer)
			pDetailLayer:addView(pContent)
        	centerInView(pDetailLayer,pContent)
   			-- self.pLayContent:addView(pContent)
        	-- centerInView(self.pLayContent,pContent)

		end

		if _bHadBottomBtn == nil then
			self.bHadBottom = true	
		else
			self.bHadBottom = _bHadBottomBtn
		end
		self:setBottomBtnVisible(self.bHadBottom)

		self:refreshContentView()
	end
end

-- 设置内容
-- _content: 提示内容
-- _sColor: 内容字体颜色（默认ffffff）
-- _nFontSize：字体大小
-- _nConWidth: 文字内容显示的区域
-- _nConHeight: 文字内容显示的区域
--_anchorPoint: 锚点设置
function DlgAlertSmall:setContent(_content, _sColor, _nFontSize, _nConWidth, _nConHeight ,_anchorPoint)
	-- body
	if not _content then
	    return
	end
	--默认颜色
	if not _sColor then
		_sColor = _cc.pwhite
	end
	local pLbContent = self:findViewByName("__alert_lb_text")
	if not pLbContent then
		pLbContent = MUI.MLabel.new({
		    text = "",
		    size = _nFontSize or 20,
		    anchorpoint = _anchorPoint or cc.p(0.5, 0.5),
		    align = cc.ui.TEXT_ALIGN_CENTER,
			valign = cc.ui.TEXT_VALIGN_TOP,
		    color = getC3B(_sColor),
		    dimensions = cc.size(_nConWidth or 450, _nConHeight or 0),
		})
		pLbContent:setName("__alert_lb_text")
		self:addContentView(pLbContent)
	end
	pLbContent:setString(_content)	
end

-- 设置内容--邮件格式显示
-- _content: 提示内容
-- _sColor: 内容字体颜色（默认ffffff）
-- _nFontSize：字体大小
-- _nConWidth: 文字内容显示的区域
-- _nConHeight: 文字内容显示的区域
--_anchorPoint: 锚点设置
function DlgAlertSmall:setContentLetter(_content, _sColor, _nFontSize, _nConWidth, _nConHeight ,_anchorPoint)
	-- body
	if not _content then
	    return
	end
	--默认颜色
	if not _sColor then
		_sColor = _cc.pwhite
	end
	local tSize = cc.size(_nConWidth or 450, _nConHeight or 0)
	local pLbContent = self:findViewByName("__alert_letter_text")
	if not pLbContent then
		pLbContent = MUI.MLabel.new({
		    text = "",
		    size = _nFontSize or 20,
		    anchorpoint = _anchorPoint or cc.p(0.5, 0.5),
		 --    align = cc.ui.TEXT_ALIGN_CENTER,
			-- valign = cc.ui.TEXT_VALIGN_TOP,
		    color = getC3B(_sColor),
		    dimensions = tSize,
		})
		pLbContent:setName("__alert_letter_text")
		pLbContent:setString(_content)		
		--self:addContentView(pLbContent)
		local nNewHeigth = 0

		self.bHadBottom = true
		--计算新的高度 动态刷新
		if tSize.height == 0 then
			tSize.height = pLbContent:getHeight() + 50
		end
		nNewHeigth = tSize.height + self.pLayTop:getHeight() 
			+ self.pLayBottom:getHeight()

		local isMax = false
		if nNewHeigth < MIN_HEIGHT then
			nNewHeigth = MIN_HEIGHT
		end
		if nNewHeigth > MAX_HEIGHT then
			nNewHeigth = MAX_HEIGHT
			isMax = true
		end

		self.pLayBase:setContentSize(cc.size(self.pLayBase:getWidth(), nNewHeigth))
		self.pLayView:setContentSize(cc.size(self.pLayView:getWidth(), nNewHeigth))
		self.pLayView:requestLayout()

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
			pSv:addView(pLbContent)
		else
			--居中显示
			local pDetailLayer = MUI.MLayer.new()
			self.pLayContent:addView(pDetailLayer)
			pDetailLayer:setLayoutSize(self.pLayContent:getWidth(),self.pLayContent:getHeight())
    		centerInView(self.pLayContent,pDetailLayer)
			pDetailLayer:addView(pLbContent)
        	local anchorPoint = pLbContent:getAnchorPoint()
        	local pos = cc.p((self.pLayContent:getWidth() - tSize.width)/2 + tSize.width * anchorPoint.x, 
				(self.pLayContent:getHeight() - tSize.height)/2 + tSize.height * anchorPoint.y)      	
        	pLbContent:setPosition(pos)
		end
		self:refreshContentView()
	else		
		pLbContent:setString(_content)		
	end	
end

-- 设置标题
function DlgAlertSmall:setTitle(_title)
    if not _title then
    	return
    end
     self.pLbTitle:setString(_title)
end

-- 设置左边handler
function DlgAlertSmall:setLeftHandler(_handler)
    self._nLeftHandler = _handler
end

-- 设置右边handler
function DlgAlertSmall:setRightHandler(_handler)
    self._nRightHandler = _handler
end

-- 取消左边按钮事件
function DlgAlertSmall:onLeftClicked(pView)
    if self._nLeftHandler then
        self._nLeftHandler()
    else
    	self:closeAlertDlg()
    end
end

-- 设置左右按钮层的高度
function DlgAlertSmall:setBtnLayHeight(_height)
	-- body
	self.pLayRight:setPositionY(_height)
	self.pLayLeft:setPositionY(_height)
end

-- 确定右边按钮事件
function DlgAlertSmall:onRightClicked(pView)
    if self._nRightHandler then
        self._nRightHandler()
    else
       	self:closeAlertDlg()
    end
end

--设置左边无效回调
function DlgAlertSmall:setLeftDisabledHandler(_handler )
	-- body
	self._nLeftDisHandler = _handler
end

--设置左边无效回调
function DlgAlertSmall:setRightDisabledHandler(_handler )
	-- body
	self._nRightDisHandler = _handler
end

-- 取消左边无效按钮事件
function DlgAlertSmall:onLeftDisabledClicked(pView)
    if self._nLeftDisHandler then
        self._nLeftDisHandler()
    end
end

-- 确定右边无效按钮事件
function DlgAlertSmall:onRightDisabledClicked(pView)
    if self._nRightDisHandler then
        self._nRightDisHandler()
    end
end

-- 关闭点击
function DlgAlertSmall:onCloseClicked(pView)
    self:closeAlertDlg()
end

-- 关闭对话框
function DlgAlertSmall:closeAlertDlg()
	self:closeDlg(false)
end

-- 关闭对话框
function DlgAlertSmall:onCloseDlg( sMsgName, pMsgObj )
	if (pMsgObj and pMsgObj.eDlgType == self.eDlgType) then
		self:closeAlertDlg()
	end
end

--获得左边按钮
function DlgAlertSmall:getLeftButton( )
	-- body
	return self.pBtnLeft
end

--获得右边按钮
function DlgAlertSmall:getRightButton( )
	-- body
	return self.pBtnRight
end

-- 只有确定选项
function DlgAlertSmall:setOnlyConfirm(_sText)
    self.pLayLeft:setVisible(false)
    if _sText then
    	self:setRightBtnText(_sText)
    end
    self.pLayRight:setPositionX((self.pLayBottom:getContentSize().width - 
        self.pLayRight:getContentSize().width) / 2)
	self.bOnlyOneBtn = true
end

function DlgAlertSmall:getOnlyConfirmButton(_nType,_sText)
	self:setOnlyConfirm(_sText)
	self:setOnlyConfirmBtn(_nType)
	return self.pBtnRight
end

--设置确定按钮高度
function DlgAlertSmall:setOnlyConfirmBtnHeight(_height)
	-- body
	self.pLayRight:setPositionY(_height)
end

--设置按钮样式
function DlgAlertSmall:setOnlyConfirmBtn( _nType )
	-- body
	self:setRightBtnType(_nType)
	self.bOnlyOneBtn = true
end

--设置左边按钮 文字内容
--_sText 按钮内容
function DlgAlertSmall:setLeftBtnText(_sText)
	local sText = _sText
	if sText == nil then
		return
	end
	self.pBtnLeft:updateBtnText(sText)
end

--设置右边按钮 文字内容
--_sText 按钮内容
function DlgAlertSmall:setRightBtnText(_sText)
	local sText = _sText
	if sText == nil then
		return
	end
	self.pBtnRight:updateBtnText(sText)
end

--设置左边样式
function DlgAlertSmall:setLeftBtnType( _nType )
	-- body
	self.pBtnLeft:updateBtnType(_nType)
end

--设置右边样式
function DlgAlertSmall:setRightBtnType( _nType )
	-- body
	self.pBtnRight:updateBtnType(_nType)
end

--设置左边按钮是否有效
function DlgAlertSmall:setLeftBtnEnabled(_bEnabled)
	self.pBtnLeft:setBtnEnable(_bEnabled)
end

--设置右边按钮是否有效
function DlgAlertSmall:setRightBtnEnabled(_bEnabled)
	self.pBtnRight:setBtnEnable(_bEnabled)
end

--设置背景框为透明
function DlgAlertSmall:setContentBgTransparent()
	-- body
	self.pLayContent:setBackgroundImage("ui/daitu.png")
end

--移除底部
function DlgAlertSmall:setBottomBtnVisible(_bVisiable)
	-- 移除底部
	-- self.pLayBottom:removeSelf()
    self.pLayRight:setVisible(_bVisiable)
    if self.bOnlyOneBtn then
    	self.pLayLeft:setVisible(false)
    	_bVisiable = true
    else
    	self.pLayLeft:setVisible(_bVisiable)
    end

    --设置了底部高度就不处理
	if self._nBottomH then
	else
		--没按钮时调整底部的高度
		if not _bVisiable then
			local nSubHeight=self.pLayBottom:getHeight()/2

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
end

return DlgAlertSmall