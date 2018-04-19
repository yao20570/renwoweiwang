-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-03-27 10:20:05 星期一
-- Description: 浮动框，直接在原有的界面上扩充功能，并且自适应位置
-----------------------------------------------------

local MDialog = require("app.common.dialog.MDialog")

local DlgFlow = class("DlgFlow" , function (  )
	-- body
	return MDialog.new()
end)

function DlgFlow:ctor( eDtype )
	self:myInit()
	self.eDlgType = eDtype or e_dlg_index.flow

	self:setupViews()

	--注册析构方法
    self:setDestroyHandler("DlgFlow",handler(self, self.onDlgFlowDestroy))
	--注册关闭悬浮框消息
	regMsg(self, ghd_close_flow_dlg_msg, handler(self, self.onCloseFlowDlg))

end

function DlgFlow:myInit(  )
	self.__nCloseFlowDlgHandler 			= 		nil 		--关闭悬浮框回调事件
end

function DlgFlow:setupViews( )

	self.pConLayer = MUI.MLayer.new()
	self.pConLayer:setContentSize(cc.size(display.width, display.height))
	self:setContentView(self.pConLayer)
	self.pConLayer:setViewTouched(false)
	--设置穿透事件
	self:setIsTouchBeforeClick(true)
	self:onTouchBeforeClicked(handler(self, self.onLayoutClicked))
end

--销毁回收
function DlgFlow:onDlgFlowDestroy()
	--回收
	unregMsg(self, ghd_close_flow_dlg_msg)
end

--关闭
function DlgFlow:onCloseFlowDlg( )
	-- body
	self:closeDlg(false)
end

-- 设置点击控件,
-- pParentView: 要响应的控件
-- pChildView：要展示的浮动框
function DlgFlow:showChildView( pParentView, pChildView )
	self.pParentView = pParentView
	self.pChildView = pChildView
	self:updateViews()
end

-- 关闭对话框
function DlgFlow:onLayoutClicked(pView)
	if self.__nCloseFlowDlgHandler then
		self.__nCloseFlowDlgHandler()
	else
		self:onCloseFlowDlg()
	end
end

--什么关闭悬浮框回调事件
function DlgFlow:onCloseFlowDlgHandler( _handler )
	-- body
	self.__nCloseFlowDlgHandler = _handler
end

-- 刷新位置显示
function DlgFlow:updateViews()
    if self.pChildView then
        self.pConLayer:addView(self.pChildView)
    end

    if self.eDlgType == e_dlg_index.taskguidetip then
        if self.pParentView == nil then
		    self.pChildView:setPosition(50, 330)
            return
        --主要是针对教你玩提示(这段代码治好了小朋友的强迫症, 因为他不想显示在下面, 只能在这改了)
        elseif (self.pParentView and self.pChildView) then
            self.curSize = self.pParentView:getContentSize()        -- 点击控件的尺寸
            self.curSize = cc.size(self.curSize.width * self.pParentView:getScale(),
            self.curSize.height * self.pParentView:getScale())
            -- 坐标转换
            local tParentPos = RootLayerHelper:getCurRootLayer():convertToNodeSpace(self.pParentView:convertToWorldSpace(cc.p(0, 0)))
            local tLayerPos = RootLayerHelper:getCurRootLayer():convertToNodeSpace(self:convertToWorldSpace(cc.p(0, 0)))
            -- 计算位置
            self.pos = cc.p((tParentPos.x - tLayerPos.x),(tParentPos.y - tLayerPos.y))
            -- 记录锚点
            local anchorPoint = self.pParentView:getAnchorPoint()
            -- 根据锚点重置位置
            self.pos = cc.p(self.pos.x + self.curSize.width / 2, self.pos.y + self.curSize.height / 2)
            local nAnchorX = 0.5
            local nAnchorY = 0
            local nMaxHeight = 700
            local nSpaceHeight = 62
            if self.pos.y > nMaxHeight then
                self.pos.y = nMaxHeight
            else
                self.pos.y = self.pos.y + nSpaceHeight
            end
            if self.curSize.width > display.width then
                self.pos.x = self.pos.x - self.curSize.width / 5
            end
            self.pChildView:setAnchorPoint(nAnchorX, nAnchorY)

            self.pChildView:setPosition(self.pos.x, self.pos.y)

            return
        end
    end

    if (self.pParentView and self.pChildView) then
        self.curSize = self.pParentView:getContentSize()        -- 点击控件的尺寸
        self.curSize = cc.size(self.curSize.width * self.pParentView:getScale(),
        self.curSize.height * self.pParentView:getScale())
        -- 坐标转换
        local tParentPos = RootLayerHelper:getCurRootLayer():convertToNodeSpace(self.pParentView:convertToWorldSpace(cc.p(0, 0)))
        local tLayerPos = RootLayerHelper:getCurRootLayer():convertToNodeSpace(self:convertToWorldSpace(cc.p(0, 0)))
        -- 计算位置
        self.pos = cc.p((tParentPos.x - tLayerPos.x),(tParentPos.y - tLayerPos.y))
        -- 记录锚点
        local anchorPoint = self.pParentView:getAnchorPoint()
        -- 根据锚点重置位置
        self.pos = cc.p(self.pos.x + self.curSize.width / 2, self.pos.y + self.curSize.height / 2)
        -- dump(self.pos, "self.pos",100)
        -- self.pConLayer:addView(self.pChildView)
        local bDown = true
        local nAnchorX = 0.5
        local nAnchorY = 0
        -- 如果是icon描述
        if self.eDlgType == e_dlg_index.showicontips then
            if (display.height -(self.pos.y + self.pChildView:getHeight() + self.curSize.height / 2) < 50) then
                self.pos.y = self.pos.y - self.pChildView:getHeight() - self.curSize.height / 2
                bDown = true
            else
                self.pos.y = self.pos.y + self.curSize.height / 2
                bDown = false
            end

        elseif self.eDlgType == e_dlg_index.dlgtaskfinger then
            self.pos = cc.p(self.pos.x - self.pChildView:getWidth() / 2,
            self.pos.y - self.pChildView:getHeight() / 2)
            nAnchorY = 0.5
            -- dump(tParentPos, "tParentPos", 100)
            -- self.pos = cc.p(self.curSize.width/2, self.curSize.height/2)
            -- self.pChildView:setPosition(self.pos)

        else
            if (self.pos.y - self.pChildView:getHeight() < 50) then
                self.pos.y = self.pos.y + self.curSize.height / 2
                bDown = false
            else
                self.pos.y = self.pos.y - self.pChildView:getHeight() - self.curSize.height / 2
                bDown = true
            end
        end


        local nSpaceX = 10
        self.pChildView:setAnchorPoint(nAnchorX, nAnchorY)
        if self.pos.x <(self.pChildView:getWidth() / 2 + nSpaceX) then
            self.pos.x = self.pChildView:getWidth() / 2 + nSpaceX
        elseif self.pos.x + self.pChildView:getWidth() / 2 + nSpaceX > display.width then
            self.pos.x = display.width - self.pChildView:getWidth() / 2 - nSpaceX
        end

        self.pChildView:setPosition(self.pos.x, self.pos.y)
        -- 如果是分享按钮
        if self.eDlgType == e_dlg_index.dlgshare then

            self.pChildView:setDownArrow(not bDown)
            -- 设置穿透事件
            self:setIsTouchBeforeClick(false)
            return
        end
        -- self.pChildView:setScaleY(0)
        -- local pS = cc.ScaleTo:create(0.1, 1.0)
        -- self.pChildView:runAction(cc.Sequence:create(
        -- 	pS, cc.CallFunc:create(function (  )
        -- 		self.pChildView:setAnchorPoint(cc.p(0, 0))
        -- 	end)))
    end
end

-- 把对话框设置到屏幕中间
function DlgFlow:setToCenter()
	self.pChildView:setPosition(display.width / 2 - self.pChildView:getWidth() / 2, display.height / 2 - self.pChildView:getHeight() / 2)
end


return DlgFlow