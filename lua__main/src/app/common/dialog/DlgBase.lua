-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-03-29 14:05:12 星期三

-- Description: 全屏对话框（640*1138）内容层高度（1066）宽度（640）
-----------------------------------------------------


local MDialog = require("app.common.dialog.MDialog")
local DlgBase = class("DlgBase", function ()
	return MDialog.new()
end)

-- nType：类型
function DlgBase:ctor(nType)
	self:myInit()
	self.eDlgType = nType or e_dlg_index.base -- 对话框类型
	parseView("dlg_base", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgBase:myInit()
	self.pBaseDlgView   		= nil 		--dlgbase布局
	self._nCloseHandler 		= nil 		--关闭回调事件
end

--解析布局回调事件
function DlgBase:onParseViewCallback( pView )
	-- body
	self.pBaseDlgView = pView
	self.pBaseDlgView:setContentSize(cc.size(display.width,display.height))
	self.pBaseDlgView:setName(UIAction.TAG_BIG_DLG)
	self:setContentView(self.pBaseDlgView)
	self.pBaseDlgView:requestLayout()
	self:setupViews()
	self:updateViews()

	 --注册析构方法
    self:setDestroyHandler("DlgBase",handler(self, self.onDlgBaseDestroy))
    
    -- 注册关闭对话框的消息
    regMsg(self, ghd_msg_close_dlg_by_type, handler(self, self.onCloseDlg))
end

--初始化控件
function DlgBase:setupViews( )
	--title
	self.pLbTitle 			= 		self.pBaseDlgView:findViewByName("lb_title_base")
	-- --标题栏左边图片
	-- self.pImgLeft 			= 		self.pBaseDlgView:findViewByName("img_left")
	-- if self.pImgLeft then
	-- 	self.pImgLeft:setFlippedX(true)
	-- end

	--背景层
	self.pLayBaseBg 		= 		self.pBaseDlgView:findViewByName("viewgroup_base")
	self.pLayTopBase 		= 		self.pBaseDlgView:findViewByName("lay_top_base")



	--帮助点击事件
	self.pLayBHelp 			= 		self.pBaseDlgView:findViewByName("lay_left_base")
	self.pLayBHelp:setViewTouched(true)
	self.pLayBHelp:setIsPressedNeedScale(false)
	self.pLayBHelp:onMViewClicked(handler(self, self.onHelpClicked))
	self.pLayBHelp:setVisible(false)
			
	--关闭点击事件
	self.pLayBClose 		= 		self.pBaseDlgView:findViewByName("lay_right_base")
	self.pLayBClose:setViewTouched(true)
	self.pLayBClose:setIsPressedNeedScale(false)
	self.pLayBClose:onMViewClicked(handler(self, self.onCloseClicked))

	--内容层
	self.pLayConBase        =      self.pBaseDlgView:findViewByName("lay_con_base")

	self.tHelpData = getHelpInterfaceIdTable()
end

-- 修改控件内容或者是刷新控件数据
function DlgBase:updateViews(  )
	-- body
	-- 需要帮助按钮的窗口
	for _, interfaceId in ipairs(self.tHelpData) do
		if self.eDlgType == interfaceId then
			self.pLayBHelp:setVisible(true)
			return
		end
	end
end

--设置背景图片
function DlgBase:setBgImg(_img)
	-- body
	self.pLayConBase:setBackgroundImage(_img)
end

--添加空层
function DlgBase:addContentTopSpace( nSpaceH )
	if self.pLaySpace then
		self.pLaySpace:removeFromParent(true)
		self.pLaySpace = nil
	end
	local nSpaceH = nSpaceH or 6
	local pLaySpace = MUI.MLayer.new()
	pLaySpace:setLayoutSize(self:getContentSize().width, nSpaceH)
    pLaySpace:setPositionY(10000)
	self.pLayConBase:addView(pLaySpace)
	self.pLaySpace = pLaySpace

end

function DlgBase:addContentView( pView, bScale)
	-- body
	-- 根据设备分辨率调整设配情况
	addViewConsiderTarget(self.pLayConBase,pView,bScale)
end

--设置标题
function DlgBase:setTitle(_title)
	if not _title then
		self.pLbTitle:setVisible(false)
	else
		self.pLbTitle:setVisible(true)
		self.pLbTitle:setString(_title)
	end
end

--设置标题字号
function DlgBase:setTitleSize(_nSize)
	self.pLbTitle:setSystemFontSize(_nSize)
end

--设置标题颜色
function DlgBase:setTitleColor( sColor )
	setTextCCColor(self.pLbTitle, sColor)
end

-- 关闭对话框
function DlgBase:onCloseDlg( sMsgName, pMsgObj )
	if (pMsgObj and pMsgObj.eDlgType == self.eDlgType) then
		self:closeOrHideDlg()
	end
end

--析构方法
function DlgBase:onDlgBaseDestroy(  )
	-- body
	-- 销毁关闭对话框的消息
    unregMsg(self, ghd_msg_close_dlg_by_type)
end

--帮助按钮点击事件
function DlgBase:onHelpClicked( _pView )
	-- body
	local tObject = {}
	tObject.nType = e_dlg_index.dlghelpcenter --dlg类型
	tObject.nOpenDlgType = self.eDlgType
	tObject.nDlgSecType  = self.nDlgSecType
	sendMsg(ghd_show_dlg_by_type,tObject)
end

--雇佣类型(窗口的第二个参数)
function DlgBase:setDlgSecondType(_nType)
	self.nDlgSecType = _nType
end

-- 设置关闭handler
function DlgBase:setCloseHandler(_handler)
    self._nCloseHandler = _handler
end

-- 关闭帮助按钮入口  
function DlgBase:closeLayBHelp()
	self.pLayBHelp:setViewTouched(false)
	self.pLayBHelp:setVisible(false)
end


--关闭按钮点击事件
function DlgBase:onCloseClicked( _pView )
	-- body
	if self._nCloseHandler then
        self._nCloseHandler()
    else
    	self:closeOrHideDlg()
    end
end

--关闭或者是隐藏对话框
function DlgBase:closeOrHideDlg(  )
	-- body
	if tDlgParams[tostring(self.eDlgType)] and tDlgParams[tostring(self.eDlgType)].h and b_open_ui_cach then --隐藏对话框
		self:hideDlg(false)
	else
		self:closeDlg(false)
	end

end

--隐藏顶部标题栏
function DlgBase:hideTopTitle()
	-- body
	self.pLayBClose:setViewTouched(false)
	self.pLayTopBase:setVisible(false)
end

--设置背景框为透明
function DlgBase:setContentBgTransparent()
	-- body
	self.pLayBaseBg:setBackgroundImage("ui/daitu.png")
end

return DlgBase

