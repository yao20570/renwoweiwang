-----------------------------------------------------
-- author: wangxs
-- updatetime: 2017-02-14 14:39:28 星期二
-- Description:  基础对话框
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local MDialog = class("MDialog", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

function MDialog:ctor( _eDlgType )
	-- body
	self:myInit()

	self.eDlgType = _eDlgType

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("MDialog",handler(self, self.onMDialogDestroy))
	
end

--初始化成员变量
function MDialog:myInit(  )
	-- body
	self.bIsNeedOutTouch 		= 		true 			--外部是否可点击取消对话框
	self.__nCloseMHandler 		= 		nil 			--关闭回调事件
	self.__nShowMHandler 		= 		nil 			--展示对话框回调事件
	self.__nOutSideMHandler 	= 		nil 			--外层点击回调事件
	self.pCurRootLayer 			= 		nil 			--当前的RootLayer
	self.eDlgType 				= 		nil 			--基础对话框类型
	self.bHadEnterAction 		= 		false 			--是否进场动画
	self.bHadExitAction 		= 		false 			--是否出场动画
	self.__pauseing = false -- 是否处于暂停存放在缓存队列中的状态
end


--初始化控件
function MDialog:setupViews( )
	-- body

	--颜色层（半透明层）
	self.pLayerColor = cc.LayerColor:create(GLOBAL_DIALOG_BG_COLOR_DEFAULT, display.width, display.height)
	self.pLayerColor:setPosition(cc.p(0, 0))
	self:setContentSize(self.pLayerColor:getContentSize())
	self:addView(self.pLayerColor)

	--设置颜色层不可点击
	self.pLayerColor:setTouchCaptureEnabled(false);
	self.pLayerColor:setTouchEnabled(false);

	--默认状态为外部可点击
	self:setViewTouched(true)
	self:setIsPressedNeedScale(false)
	self:setIsPressedNeedColor(false)
	self:setIsNeedOutside(true)
	--设置点击事件
	self:onMViewClicked(handler(self, self.onOutsideClicked))

	--新增内容层
	self.pLayMContent = MUI.MLayer.new()
	self.pLayMContent:setLayoutSize(self:getLayoutSize())
	self:addView(self.pLayMContent, 10)
	self.pLayMContent:setViewTouched(false)



end

-- 修改控件内容或者是刷新控件数据
function MDialog:updateViews(  )
	-- body
end

-- 析构方法
function MDialog:onMDialogDestroy(  )
	-- body
end

--设置对话框背景颜色
function MDialog:setDialogBgColor( color4B )
 	-- body
 	self.pLayerColor:setColor(cc.c3b(color4B.r, color4B.g, color4B.b))
 	self.pLayerColor:setOpacity(color4B.a)
end

-- 获得对话框背景颜色
function MDialog:getDialogBgColor(  )
	-- body
	local color3B = self.pLayerColor:getColor()
 	local opacity = self.pLayerColor:getOpacity()
 	return cc.c4b(color3B.r,color3B.g, color3B.b, opacity)
end

--设置外层是否可点击
function MDialog:setIsNeedOutside( _bIsNeed )
	-- body
	self.bIsNeedOutTouch = _bIsNeed
end

--获得外层是否可点击
function MDialog:getIsNeedOutside(  )
	-- body
	return self.bIsNeedOutTouch
end

--对话框外部点击事件回到
function MDialog:onOutsideClicked( pView )
	if (self.bIsNeedOutTouch) then
		if self.__nOutSideMHandler then
			self.__nOutSideMHandler(self)
		else
			closeDlgByType(self.eDlgType, false)
		end
	end
end

--关闭对话框
function MDialog:closeDialog(  )
	-- body
	if self.__nCloseMHandler then
		self.__nCloseMHandler()
	end
--	if(self.releaseToPool) then
--		self:releaseToPool()
--	end
    myprint(string.format("MDialog:closeDialog ==> %s", self.eDlgType))

	self:removeSelf()
end

--打开对话框
function MDialog:showDialog( pMRootLayer )
	-- body
	if not pMRootLayer then
		print("pMRootLayer is nil")
	end
	if self.pCurRootLayer ~= pMRootLayer then
		self.pCurRootLayer = pMRootLayer
		self.pCurRootLayer:addView(self)
	    addDlgToArray(self)
	end

    myprint(string.format("MDialog:showDialog ==> %s", self.eDlgType))

	self:visibleDialog()
	if self.bHadEnterAction == false then
		if self.__nShowMHandler then
			self.__nShowMHandler()
		end
	end
	
end

--隐藏对话框
function MDialog:hideDialog(  )
	-- body
	self:setVisible(false)

    myprint(string.format("MDialog:hideDialog ==> %s", self.eDlgType))
end

--展示对话框
function MDialog:visibleDialog(  )
	-- body
	self.__pauseing = false
	self:setVisible(true)
	self:setLocalZOrder(GLOBAL_DIALOG_ZORDER)
	GLOBAL_DIALOG_ZORDER = GLOBAL_DIALOG_ZORDER + 1
	if GLOBAL_DIALOG_ZORDER > 0x00ffffff then
		GLOBAL_DIALOG_ZORDER = 0x000FFFFF
	end
	if self.bHadEnterAction == false then
		if self.__nShowMHandler then
			self.__nShowMHandler()
		end
	end
end
-- 是否处于暂停状态
function MDialog:isPausing(  )
	return self.__pauseing
end

--当前对话框是否展示中
function MDialog:isShowing(  )
	-- body
	return self:isVisible()
end

--设置对话框内容层
function MDialog:setContentView( pContentView )
	-- body
	centerInView(self.pLayMContent, pContentView)
	self.pLayMContent:addView(pContentView)
	pContentView:setTag(125421)
	pContentView:setViewTouched(true)
	pContentView:setIsPressedNeedScale(false) --没有特效效果
	pContentView:setIsPressedNeedColor(false) --没有颜色效果
end

--刷新对话框内容位置
function MDialog:refreshContentView( )
	-- body
	local pContentView = self:findViewByTag(125421)
	if pContentView then
		centerInView(self.pLayMContent, pContentView)
	end
end

--设置关闭回调事件
function MDialog:setCloseDialogHandler( _nHandler )
	-- body
	self.__nCloseMHandler = _nHandler
end

--设置关闭回调事件
function MDialog:setShowDialogHandler( _nHandler )
	-- body
	self.__nShowMHandler = _nHandler
end

--设置内容外层点击时间
function MDialog:setOutSideHandler( _nHandler )
	-- body
	self.__nOutSideMHandler = _nHandler
end

--获得对话框当前的MRootLayer
function MDialog:getCurRootLayer(  )
	-- body
	return self.pCurRootLayer
end

--设置对话框类型
function MDialog:setDialogType( _eDialogType )
	-- body
	self.eDlgType = _eDialogType
end

--展示对话框
-- _rootlayer: 显示对话框所在的层上
-- _bIsNew(bool): 是否该对话框是新建的，false为已存在，true为新建
-- _isQue(bool): 当有上层对话框的时候 自身是否需要隐藏
-- _bIsNeedAction（bool）:是否需要播放动画 
-- 注意：有动画的界面需要设置 UIAction.TAG_SMALL_DLG 或者 UIAction.TAG_BIG_DLG
function MDialog:showDlg( _bIsNew, _rootlayer, _isQue, _bIsNeedAction )
	-- body
	_rootlayer = _rootlayer or RootLayerHelper:getCurRootLayer()
	UIAction.enterDialog(self,_rootlayer, _bIsNew, _isQue, _bIsNeedAction)
end

--关闭对话框
--_bIsNeedAction
function MDialog:closeDlg( _bIsNeedAction)
    if SHOWING_EDITBOX ~= nil then
        -- 打开了输入框状态
        return
    end
	-- body
	UIAction.exitDialog(self ,_bIsNeedAction)
end

--隐藏对话框
function MDialog:hideDlg( _bIsNeedAction )    
    if SHOWING_EDITBOX ~= nil then
        -- 打开了输入框状态
        return
    end
	-- body
	self.__pauseing = true
	UIAction.hideDialog(self ,_bIsNeedAction)
end

return MDialog