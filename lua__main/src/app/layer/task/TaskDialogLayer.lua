----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-07 10:04:30
-- Description: 新手引导层 提示界面
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local TaskDialogLayer = class("NewGuideTip", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

function TaskDialogLayer:ctor(  )
	--解析文件
	parseView("lay_newguide_tip", handler(self, self.onParseViewCallback))
end

--解析界面回调
function TaskDialogLayer:onParseViewCallback( pView )
	self.pView = pView
	-- self:setContentSize(display.width, display.height)
	-- -- self:setContentSize(pView:getContentSize())
	-- self:addView(pView)
	-- centerInView(self, pView)
	-- pView:setPositionY(pView:getPositionY() - 200)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("TaskDialogLayer", handler(self, self.onTipDestroy))
end

-- 析构方法
function TaskDialogLayer:onTipDestroy(  )
    self:onPause()
end

function TaskDialogLayer:regMsgs(  )
	
end

function TaskDialogLayer:unregMsgs(  )
	
end

function TaskDialogLayer:onResume(  )
	self:regMsgs()
end

function TaskDialogLayer:onPause(  )
	self:unregMsgs()
end

function TaskDialogLayer:setupViews(  )
	--颜色层（半透明层）
	self.pLayerColor = cc.LayerColor:create(GLOBAL_DIALOG_BG_COLOR_DEFAULT, display.width, display.height)
	self.pLayerColor:setPosition(cc.p(0, 0))
	-- self:setContentSize(self.pLayerColor:getContentSize())
	self:addView(self.pLayerColor)

	--设置颜色层不可点击
	self.pLayerColor:setTouchCaptureEnabled(false)
	self.pLayerColor:setTouchEnabled(false)

	--新增内容层
	self.pLayMContent = MUI.MLayer.new()
	self.pLayMContent:setLayoutSize(self:getLayoutSize())
	self:addView(self.pLayMContent, 10)
	--把引导层加到内容层
	self.pLayMContent:addView(self.pView)
	--设置位置
	self.pView:setPositionY(display.height/5)



	self:setViewTouched(true)
	self:setIsPressedNeedScale(false)
	self:setIsPressedNeedColor(false)
	self:onMViewClicked(function ( _pView )
	    self:onOutsideClicked()
	end)


	self.pTxtContent = self:findViewByName("txt_content")
	self.pTxtName = self:findViewByName("txt_name")
	setTextCCColor(self.pTxtName, _cc.yellow)
	self.pImgArrow = self:findViewByName("img_cursor")
end

--点击任意地方
function TaskDialogLayer:onOutsideClicked(  )
	self.tData = self:getNextStepData(self.nStepId)
	if not self.tData then
		if self.nHandler then
			self.nHandler()
			self.nHandler = nil
		end
		self.nPrevStepId = nil
		self:setVisible(false)
	else
		self.nStepId = self.nStepId + 1
		self:updateViews()
	end
end

--强制隐藏
function TaskDialogLayer:onHideMsg( )
	self:setVisible(false)
end

function TaskDialogLayer:updateViews(  )
	if not self.tData then
		return
	end

	--保证唯一显示
	if self.nPrevStepId == self.nStepId then
		return
	end
	self.nPrevStepId = self.nStepId
	if B_GUIDE_LOG then
		print("B_GUIDE_LOG NewGuideTip ===================", self.nStepId)
	end
	
	--数据
	local tGuideData = self.tData
	local tStr = getTextColorByConfigure(tGuideData.word)
	self.pTxtContent:setString(tStr)
	local tChatNpcData = getGuideChatNpcData(tGuideData.chatnpc)
	if tChatNpcData then
		local sIcon = tChatNpcData.sIcon
		local sName = tChatNpcData.name
		--读主公
		if tChatNpcData.id == 6 then
			local nCountry = Player:getPlayerInfo().nInfluence
			sIcon = tChatNpcData.tIcon[nCountry] or ""
			sName = tChatNpcData.tName[nCountry] or ""
		end

		--显示npc图片
		if not self.pImgNpc then
			self.pImgNpc = MUI.MImage.new(sIcon)
			self.pImgNpc:setAnchorPoint(cc.p(0,0))
			self.pView:addView(self.pImgNpc,1)
		else
			self.pImgNpc:setCurrentImage(sIcon)
		end

		--显示名字
		self.pTxtName:setString(sName)

		--npc图片在右边
		if tGuideData.chatbox == 3 then
			self.pImgNpc:setFlippedX(true)
			self.pImgNpc:setPositionX(self.pView:getContentSize().width - self.pImgNpc:getContentSize().width)
			self.pTxtName:setPositionX(20)
			self.pTxtContent:setPositionX(20)
			self.pImgArrow:setPositionX(30)
		else
			self.pImgNpc:setFlippedX(false)
			self.pImgNpc:setPositionX(0)
			self.pTxtName:setPositionX(302)
			self.pTxtContent:setPositionX(302)
			self.pImgArrow:setPositionX(603)
		end
	end

	self:setVisible(true)
	-- --延迟出现
	-- self.bIsCanClicked = true
	-- if self.tGuideData.windelayed then
	-- 	local tData = luaSplit(self.tGuideData.windelayed, ":")
	-- 	local nType = tonumber(tData[1])
	-- 	local nDelayTime = tonumber(tData[2])
	-- 	if nType == 2 and nDelayTime then
	-- 		--一段时间显示
	-- 		self.bIsCanClicked = false
	-- 		self.pView:setVisible(false)
	-- 		self.pView:stopAllActions()
	-- 		local function func(  )
	-- 			self.bIsCanClicked = true
	-- 			self.pView:setVisible(true)
	-- 			ActionIn(self.pView, "pop", 0.15)
	-- 		end
	-- 		doDelayForSomething(self.pView, func, nDelayTime/1000)
	-- 	end
	-- else
	-- 	self.pView:setVisible(true)
	-- end
end

--nStepId：步骤id
function TaskDialogLayer:setData( nStepId, datas, nHandler) 
	self.nStepId = nStepId
	self.tDialogs = datas
	self.tData = self:getCurStepData(nStepId)
	self.nHandler = nHandler
	self:updateViews()
end

function TaskDialogLayer:getNextStepData(nStepId)
	local nNextId = nStepId + 1
	for k ,v in pairs(self.tDialogs) do
		if v.order == nNextId then
			return v
		end
	end
	return nil
end

function TaskDialogLayer:getCurStepData(nStepId)
	for k ,v in pairs(self.tDialogs) do
		if v.order == nStepId then
			return v
		end
	end
	return nil
end
 
return TaskDialogLayer


