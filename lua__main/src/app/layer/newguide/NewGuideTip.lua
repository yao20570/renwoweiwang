----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-07 10:04:30
-- Description: 新手引导层 提示界面
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local MRichLabel = require("app.common.richview.MRichLabel")
local NewGuideTip = class("NewGuideTip", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

function NewGuideTip:ctor(  )
	--解析文件
	parseView("lay_newguide_tip", handler(self, self.onParseViewCallback))
end

--解析界面回调
function NewGuideTip:onParseViewCallback( pView )
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
	self:setDestroyHandler("NewGuideTip", handler(self, self.onNewGuideTipDestroy))
end

-- 析构方法
function NewGuideTip:onNewGuideTipDestroy(  )
    self:onPause()
end

function NewGuideTip:regMsgs(  )
	regMsg(self, ghd_guide_drama_or_tip_hide, handler(self, self.onHideMsg))
end

function NewGuideTip:unregMsgs(  )
	unregMsg(self, ghd_guide_drama_or_tip_hide)
end

function NewGuideTip:onResume(  )
	self:regMsgs()
end

function NewGuideTip:onPause(  )
	self:unregMsgs()
end

function NewGuideTip:setupViews(  )
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
function NewGuideTip:onOutsideClicked(  )
	if B_GUIDE_LOG then
		myprint("B_GUIDE_LOG NewGuideTip:onOutsideClicked")
	end
	if self.bIsCanClicked then
		self:setVisible(false)
		if self.tGuideData then
			if B_GUIDE_LOG then
				myprint("B_GUIDE_LOG NewGuideTip:onOutsideClicked 设置下一条事件和跳转转个界面")
			end
			--设置下一条事件
			Player:getNewGuideMgr():setCurrStepId(self.tGuideData.nextstep)
			--触发完成点击跳转转个界面
			Player:getNewGuideMgr():jumpToDlg(self.tGuideData.step)
		end
		if B_GUIDE_LOG then
			myprint("B_GUIDE_LOG 释放半屏的控制权")
		end
		--显示下一个
		showNextSequenceFunc(e_show_seq.newguidehalf)
	end
end

--强制隐藏
function NewGuideTip:onHideMsg( )
	self:setVisible(false)
	--显示下一个
	showNextSequenceFunc(e_show_seq.newguidehalf)
end

function NewGuideTip:updateViews(  )
	if not self.tGuideData then
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
	local tGuideData = self.tGuideData
	local tStr = getTextColorByConfigure(tGuideData.desc)
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

	--延迟出现
	self.bIsCanClicked = true
	if self.tGuideData.windelayed then
		local tData = luaSplit(self.tGuideData.windelayed, ":")
		local nType = tonumber(tData[1])
		local nDelayTime = tonumber(tData[2])
		if nType == 2 and nDelayTime then
			--一段时间显示
			self.bIsCanClicked = false
			self.pView:setVisible(false)
			self.pView:stopAllActions()
			local function func(  )
				self.bIsCanClicked = true
				self.pView:setVisible(true)
				ActionIn(self.pView, "pop", 0.15)
			end
			doDelayForSomething(self.pView, func, nDelayTime/1000)
		end
	else
		self.pView:setVisible(true)
	end
end

--nStepId：步骤id
--nGuideType: 1:美女引导教你玩
function NewGuideTip:setData( nStepId, nGuideType ) 
	self.nStepId = nStepId
	if nGuideType == 1 then
		self.tGuideData = getTeachPlayStep(self.nStepId)
	else
		self.tGuideData = getGuideData(self.nStepId)
	end
	self:updateViews()
end

--手指ui刷新位置(无0，上1，下2)
function NewGuideTip:setPosByFingerUi( nUpState )
	local fHalfHeight = self:getContentSize().height/2
	if nUpState == 1 then
		local fY = (fHalfHeight - self.pView:getContentSize().height)/2
		self.pNewGuideTip:setPositionY(fY)
	elseif nUpState == 2 then
		local fY = fHalfHeight + (fHalfHeight - self.pView:getContentSize().height)/2
	else
		-- centerInView(self, self.pView)
	end
	self.nUpState = nUpState
end

return NewGuideTip


