-----------------------------------------------------
-- author: luwenjing
-- updatetime:  2018-01-11 20:47:40 星期四
-- Description: 拉霸活动的单个拉霸
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local MBtnExText = require("app.common.button.MBtnExText")
local IconGoods = require("app.common.iconview.IconGoods")


local nSpeed1 = 0.1 		--加速阶段滚动一个格子距离的时间
local nSpeed2 = 0.1 		--匀速阶段滚动一个格子距离的时间
local nSpeed3 = 0.2        --减速阶段滚动一个格子距离的时间

local nSlotWidth = 110  --滚动的一个格子的宽
local nSlotHeight = 112 --滚动的一个格子的长

local nSpeedUpTotalNum = 8  --加速阶段滚动的个数

local nNorSpeedNum1 = 3 --左匀速阶段滚动的个数
local nNorSpeedNum2 = 10 --中匀速阶段滚动的个数
local nNorSpeedNum3 = 21 --右匀速阶段滚动的个数

local nTotalNum1 = 18  --左边滚动的总数
local nTotalNum2 = 25 --中间滚动的总数
local nTotalNum3 =  35 --右边滚动的总数



local SingleLaba = class("SingleLaba", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--_nType：TypeSingalLabaSize（大小类型）
function SingleLaba:ctor( _nWidth,_nHeight ,_nIndex)
	-- body
	self:myInit()
	self:setLayoutSize(_nWidth,_nHeight)
	self.pContent = MUI.MScrollLayer.new({viewRect=cc.rect(0, 0,_nWidth, _nHeight),
			    touchOnContent = false,
			    direction=MUI.MScrollLayer.DIRECTION_VERTICAL})
	-- body
	self.pScrollView=MUI.MLayer.new()
	self.pScrollView:setLayoutSize(_nWidth,_nHeight)
     self.pScrollView:setPosition(0,0)

	self.pContent:addView(self.pScrollView)
	self.pContent:setIsCanScroll(false)
	
	self:addView(self.pContent)

	self.nIndex = _nIndex or 0

	self:onResume()

	-- self:setupViews()
end
function SingleLaba:setupViews()
	self.pMask = MUI.MImage.new("#v2_img_labazhegai.png")
	self.pContent:addView(self.pMask)
end

--初始化成员变量
function SingleLaba:myInit(  )
	self.nIndex = 0 --这是哪一个滚动条
	self.nBtttom = 0 --滚动条的下面的图片的序号
	self.nCenter = 0 --中间
	self.nTop = 0 -- 上面
	self.nTarget = 0 --目标序号

	self.nLastIconIndex = 0 --当前添加的最后一个图标的序号
	self.nCurNum = 0  --当前添加的物品数
	self.nCurDeleteNum = 0  --当前需要删除的物品
	-- self.nTotalHeight = 0
	self.nTotalNum = 0  --一共需要滚动的物品数

	self.nScrollNum = 0
	self.tIcon={}

	self.nSpeedUpNum = 0 --加速阶段已经滚动的数量
	self.nSpeedNorNum = 0 --匀速阶段已经滚动的数量
	self.nSpeedSlowNum = 0 --减速阶段已经滚动的数量
	self.bIsRolling = false --是否转动中
	self.bIsBest = false --是否最佳
	--获得滚动的图标
	local  tActData = Player:getActById(e_id_activity.laba)
	if tActData then
		local tT = luaSplit(tActData.sRule, "#")
		
		if tT and #tT >0 then
			for k,v in pairs(tT) do
				local tT2 = luaSplit(v, ";")
				if tT2 then
					if not self.tIcon[tT2[1]] then
						self.tIcon[tonumber(tT2[1])] ="#"..tT2[3]..".png"
					end
				end
			end

		end
	end

	self.tActions ={}

	self.time=0

end
--初始化拉霸滚动框

function SingleLaba:initLaba( _nBottom,_nCenter,_nTop)
	-- body
	self.nLastIconIndex = 0 --当前添加的最后一个图标的序号
	self.nCurNum = 0  --当前添加的物品数

	-- self.nCurDeleteNum = 0  --当前需要删除的物品
	self.nScrollNum = 0
	self.nSpeedUpNum = 0 --加速阶段已经滚动的数量
	self.nSpeedNorNum = 0 --匀速阶段已经滚动的数量
	self.nSpeedSlowNum = 0 --减速阶段已经滚动的数量
	-- self.bIsRolling = false --是否转动中
	self.bIsBest = false --是否最佳
	self.pScrollView:setPosition(0,0)


	self.nBottom = _nBottom or self.nBottom
	self.nCenter = _nCenter or self.nCenter
	self.nTop = _nTop or self.nTop
	self.nLastIconIndex = self.nTop
	
	self:setLabaLayerHeight()
	for i = 1 ,7 do
		self:addItem()
	end

	if self.nCurDeleteNum ~= 0  then
		for i=self.nCurDeleteNum,self.nTotalNum do
			self:removeItem()
		end
		self.nCurDeleteNum = 0
	end

end

function SingleLaba:setTarget( _nTarget )
	-- body
	self.bIsRolling=true

	self.nTarget=_nTarget
	self.nLastIconIndex = (self.nBottom + 1) % 4
	if self.nLastIconIndex == 0 then
		self.nLastIconIndex = 4
	end
	self:initLaba()
	self:playLaba(1)

end
--根据目标序号 设置需要的滚动层有多长
function SingleLaba:setLabaLayerHeight(  )
	-- body

	--基础高度
	--停下的顺序从左到右 所以长度不一样
	if self.nIndex == 1 then 
		self.nTotalNum = nTotalNum1 		
	elseif self.nIndex == 2 then
		self.nTotalNum = nTotalNum2
	elseif self.nIndex == 3 then
		self.nTotalNum = nTotalNum3
	end


	self.pScrollView:setLayoutSize(nSlotWidth, nSlotHeight * self.nTotalNum)

end
function SingleLaba:stepCallback(  )
	-- body


	local nSpeedType=1
	self.nScrollNum = self.nScrollNum + 1
	if self.nScrollNum < self.nTotalNum -3 then

		if self.nCurNum < self.nTotalNum then
			
			self:addItem()
		end
		if self.nSpeedUpNum < nSpeedUpTotalNum then
			nSpeedType=1
			self.nSpeedUpNum = self.nSpeedUpNum + 1
		else
			if (self.nIndex ==1 and self.nSpeedNorNum < nNorSpeedNum1) 
			or (self.nIndex ==2 and self.nSpeedNorNum < nNorSpeedNum2)
			or (self.nIndex ==3 and self.nSpeedNorNum < nNorSpeedNum3) then
				nSpeedType=2
				self.nSpeedNorNum = self.nSpeedNorNum + 1
					
			elseif  (self.nIndex ==1 and self.nSpeedSlowNum < self.nTotalNum- nSpeedUpTotalNum - nNorSpeedNum1 -3) 
			or (self.nIndex ==2 and self.nSpeedSlowNum < self.nTotalNum- nSpeedUpTotalNum - nNorSpeedNum2 - 3)
			or (self.nIndex ==3 and self.nSpeedSlowNum < self.nTotalNum- nSpeedUpTotalNum - nNorSpeedNum3 - 3) then
				nSpeedType = 3
				self.nSpeedSlowNum = self.nSpeedSlowNum + 1

			end
		end
		self:playLaba(nSpeedType)
		

		self:removeItem()
	else
		self:showFinish()
	end
end

function SingleLaba:showFinish(  )
	-- body
	
	--展示动画
	-- print("time",self.time)
	self.nTop = self.nLastIconIndex
	self.nCenter = self.nTarget
	self.nBottom = (self.nLastIconIndex + 2) % 4
	if self.nBottom == 0 then
		self.nBottom = 4
	end

	local pTargetIcon = self.pScrollView:findViewByName("slot"..tostring(self.nTotalNum-1))

	if pTargetIcon then
		--pTargetIcon:setOpacity(0)
		local pTemp1=pTargetIcon:findViewByName("img1")
		local pTemp2=pTargetIcon:findViewByName("img2")
		if pTemp1 then
			pTemp1:removeSelf()
			pTemp1 = nil
		end
		if pTemp2 then
			pTemp2:removeSelf()
			pTemp2 = nil
		end
		local pImg1 = MUI.MImage.new(self.tIcon[self.nTarget])

		local pImg2 = MUI.MImage.new(self.tIcon[self.nTarget])

		-- pImg1:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		pImg2:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		-- pImg1:setScale(0.8)
		-- pImg2:setScale(0.8)
		-- pImg1:setName("img1")
		pImg2:setName("img2")
		-- pImg2:setOpacity(0)

		pTargetIcon:addChild(pImg1,10)
		pTargetIcon:addChild(pImg2,15)
		centerInView(pTargetIcon,pImg1)
		centerInView(pTargetIcon,pImg2)



		-- pImg1:setVisible(false)
		-- self.pImgBxTx:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		-- self.pImgBxTx:setOpacity(255*0.3)
		-- self.pImgBxTx:setScale(self.tCurData.nIconScale)
		local action1_1=cc.ScaleTo:create(0, 1)
		local action1_2=cc.ScaleTo:create(0.7, 1.1)
		local action1_3=cc.ScaleTo:create(0.7, 1)

		local action2_1=cc.ScaleTo:create(0, 1.12)
		local action2_2 = cc.FadeTo:create(0, 0)
		local action2_3 = cc.Spawn:create(action2_1, action2_2)

		local action2_4=cc.ScaleTo:create(0.17, 1.15)
		local action2_5 = cc.FadeTo:create(0.17,255*0.5)
		local action2_6 = cc.Spawn:create(action2_4, action2_5)

		local action2_7=cc.ScaleTo:create(0.33, 1.25)
		local action2_8 = cc.FadeTo:create(0.33, 0)
		local action2_9 = cc.Spawn:create(action2_7, action2_8)

		function callback ()
			if self.nIndex == 3 and self.bIsRolling == true then   --bisRolling =false 的时候 是强制停止的
				sendMsg(ghd_laba_stop)

			end
			self.bIsRolling = false
		end
		

		local action1=cc.Sequence:create(action1_1, action1_2,action1_3)
		local action2=cc.Sequence:create(action2_3, action2_6,action2_9)
		local action3 =cc.CallFunc:create(callback)

		local delay =cc.DelayTime:create(0.3)
		pImg1:runAction(cc.RepeatForever:create(action1))
		pImg2:runAction(cc.Sequence:create(action2,delay,action3))
		-- print("SingleLaba 293")
		-- pImg2:runAction(action2_5)

		table.insert(self.tActions,pImg1)
		table.insert(self.tActions,pImg2)
	end

	-- self:initLaba(nBottom,nCenter,nTop)
	
end

function SingleLaba:addBaseLaba(  )
	-- body
end

function SingleLaba:addItem( )
	-- body
	local nIconIndex = (self.nLastIconIndex - 1) % 4
	if nIconIndex == 0 then
		nIconIndex = 4
	end
	if self.nCurNum == self.nTotalNum - 2 then
		
		nIconIndex = self.nTarget
		
	end
	local pNewIcon =  MUI.MImage.new(self.tIcon[nIconIndex])
	pNewIcon:setScale(0.8)
	pNewIcon:setAnchorPoint(0,0)
	pNewIcon:setPosition(20,self.nCurNum * nSlotHeight + 10)
   	self.pScrollView:addView(pNewIcon)
   	self.nLastIconIndex = nIconIndex
   	self.nCurNum = self.nCurNum + 1
	pNewIcon:setName("slot"..self.nCurNum)
end

function SingleLaba:removeItem(  )
	-- body
	local  nTemp=self.nCurDeleteNum +1
	local pItem = self.pScrollView:findViewByName("slot" .. nTemp)
	if pItem then
		pItem:removeSelf()
		pItem= nil
	end
	self.nCurDeleteNum = self.nCurDeleteNum + 1
end
--nSpeedType 当前的速度阶段
function SingleLaba:playLaba( _nSpeedType )
	-- body
	local nSpeed = nSpeed1
	if _nSpeedType == 1 then
		nSpeed = nSpeed1
	elseif _nSpeedType == 2 then
		nSpeed = nSpeed2
	elseif _nSpeedType == 3 then
		nSpeed = nSpeed3
	end
	-- self.time =self.time+ nSpeed

	local moveVec=cc.p(0, -nSlotHeight)
	local moveBy = cc.MoveBy:create(nSpeed, moveVec)
	local callback = cc.CallFunc:create(handler(self,self.stepCallback))
	self.pScrollView:runAction(cc.Sequence:create(moveBy,callback)) 
end
function SingleLaba:setRollingState(_bState)
	self.bIsRolling = _bState or self.bIsRolling
end

function SingleLaba:getIsRolling()
	return self.bIsRolling 
end

-- 修改控件内容或者是刷新控件数据
function SingleLaba:updateViews( )
	
end

function SingleLaba:removeScaleAction()
	for i=1, #self.tActions do
		if self.tActions[i] then
			self.tActions[i]:removeSelf()
			self.tActions[i]= nil
		end
	end
	self.tActions ={}
end

function SingleLaba:stopForce(  )
	-- body
	if self.bIsRolling then
		self.bIsRolling = false
		if self.nCurNum < self.nTotalNum - 2 then
			self.nTotalNum = self.nCurNum + 2
		end
	end
end

function SingleLaba:regMsgs(  )
	
	regMsg(self, ghd_laba_stop_force, handler(self, self.stopForce))

end

function SingleLaba:unregMsgs(  )
	unregMsg(self, ghd_laba_stop_force)
end

function SingleLaba:onResume(  )
	self:regMsgs()
end

function SingleLaba:onPause(  )
	self:unregMsgs()
end


-- 析构方法
function SingleLaba:onSingalLabaDestroy(  )
	-- body

	self:onPause()
end


return SingleLaba