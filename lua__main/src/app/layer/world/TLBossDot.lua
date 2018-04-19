----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-2-6 9:44:00
-- Description: 地图上的限时Boss
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local nFloorEffectZorder = 0 --地表特效层次
local nSoldierZorder = 1 -- 士兵层次
local nTLBossZorder = 2 --TLBoss层次
local nHurtZorder = 3 --受击层次
local nAtkEffectZorder = 4 --刀光特效
local nHpZorder = 10 --血条层次
local nBlastZorder = 15 --爆破层次
local nEnterZorder = 16 --进入特效层次
local nLastNameZorder = 18 --最后名字层次
local nHurtTextZoder = 19 --破坏文字层次
local nNameZorder = 20 --名字层次
local nFingerZorder = 21 --手指

--临时Boss血量测试
-- local nLifeTime = 6
-- local nBrokeTime = 4
-- local nCheckCd = 10
-- local nBeginCd = 5
-- local nCheckStage = 3
local nCaremaMask = 10 --1010 摄像机掩码（在最后才渲染最高层。照道理用1000就可以了，不过存在问题，不能随着屏幕移动，所以用10） 

local tSoldierPos =
{
	{x =-172 + 30, y=-100 + 120},--1
	{x =-77  + 30, y=-144 + 120},--2
	{x = 11  + 30, y=-180 + 120},--3
	{x =-253 + 30, y=-140 + 120},--4
	{x =-158 + 30, y=-183 + 120},--5
	{x =-69  + 30, y=-220 + 120},--6
	{x =-334 + 30, y=-179 + 120},--7
	{x =-239 + 30, y=-223 + 120},--8
	{x =-150 + 30, y=-259 + 120},--9
}


--步兵
local e_bbing_arm = {
	pb = "1_1_2_1", --跑步2
	dj = "1_1_1_1", --待机2
	pg = "1_1_3_1", --普攻2
	ts = "1_1_5_1", --死亡2
}
--骑兵
local e_qbing_arm = {
	pb = "1_2_2_1", --跑步2
	dj = "1_2_1_1", --待机2
	pg = "1_2_3_1", --普攻2
	ts = "1_2_5_1", --死亡2
}
--弓兵
local e_gbing_arm = {
	pb = "1_3_2_1", --跑步2
	dj = "1_3_1_1", --待机2
	pg = "1_3_3_1", --普攻2
	ts = "1_3_5_1", --死亡2
}

--Boss模型动画
local e_tlboss_arm =
{
	dj = "2_5_1_1",
	pg = "2_5_3_1",
	qg = "2_5_4_1",
	ts = "2_5_5_1",
}

local TLBossDot = class("TLBossDot",function ( )
	local pView = MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
	pView:setAnchorPoint(0.5,0.5)
    return pView
end)

--pWorldLayer：世界层
function TLBossDot:ctor( pWorldLayer )
	--设置相机类型
	WorldFunc.setCameraMaskForView(self)

	self.pWorldLayer= pWorldLayer
	self.bIsFirstArm = true --是否是第一次动
	self:onParseViewCallback()
end

--解析界面回调
function TLBossDot:onParseViewCallback( pView )
	self:setContentSize(UNIT_WIDTH, UNIT_HEIGHT)

	self:setupViews()
	self:onResume()

	--注册析构方法
    self:setDestroyHandler("TLBossDot",handler(self, self.onTLBossDotDestroy))
end

function TLBossDot:onTLBossDotDestroy(  )
	self:onPause()
	if self.nImgJdtScheduler then
		MUI.scheduler.unscheduleGlobal(self.nImgJdtScheduler)
		self.nImgJdtScheduler = nil
	end
	unregUpdateControl(self)
end

function TLBossDot:onResume(  )
	self:regMsgs()
end

function TLBossDot:onPause(  )
	self:unregMsgs()
end

function TLBossDot:regMsgs( )
end

function TLBossDot:unregMsgs( )
end

function TLBossDot:setupViews(  )
end

--设置服务器数据
--tData:BossLocatVo
function TLBossDot:setData( tData )
	self.tData = tData
	self:updateViews()
end

--获取数据
function TLBossDot:getData(  )
	return self.tData
end

--获取区域id
function TLBossDot:getBlockId()
	if self.tData then
		return self.tData:getBlockId()
	end
	return nil
end

--设置显示视图
function TLBossDot:setViewRect( pRect )
	self.pViewRect = pRect
end

--获取显示视图
function TLBossDot:getViewRect(  )
	return self.pViewRect
end

--更新
function TLBossDot:updateViews(  )	
	--防止重复刷新
	if self.nX ~= self.tData.nX or self.nY ~= self.tData.nY then
		self.nX = self.tData.nX
		self.nY = self.tData.nY
		--更新坐标
		local fX, fY = self.pWorldLayer:getMapPosByDotPos(self.tData.nX,self.tData.nY)
		self:setPosition(fX, fY)
	end
end

--隐藏
function TLBossDot:setVisibleEx( bIsShow )
	if bIsShow then
	else
		--清空数据
		self:delViewDotMsg()
	end
	self:setVisible(bIsShow)
end

function TLBossDot:delViewDotMsg( )
end

--由于摄像机的特殊处理，要初始化完摄像机2才进行初始化
function TLBossDot:initTLBoss(  )
	if not self.bIsInited then
		self.bIsInited = true

		local nBossX, nBossY = UNIT_WIDTH/2 + 20 + 20, UNIT_HEIGHT/2 + 120 - 10
		self.nBossX = nBossX
		self.nBossY = nBossY

		--主要层
		local pLayTLBossHp = MUI.MLayer.new()
		pLayTLBossHp:setContentSize(161,20)
		self:addChild(pLayTLBossHp, nHpZorder)
		self.pLayTLBossHp = pLayTLBossHp
		pLayTLBossHp:setCameraMask(nCaremaMask ,true)

		--层位置
		local fX, fY = self.nBossX - 70, self.nBossY + 120
		pLayTLBossHp:setPosition(fX, fY)

		local pImgTLBossBg = display.newSprite("ui/bar/v2_bar_bboss.png")
		pImgTLBossBg:setPosition(161/2, 20/2)
		pImgTLBossBg:setOpacity(0.5*255)
		pLayTLBossHp:addChild(pImgTLBossBg)
		pImgTLBossBg:setCameraMask(nCaremaMask ,true)

		--步骤一：进度条序列帧动画
		--血条进度条
		local pImgJdt = display.newSprite("ui/bar/tlboos_jdt/rwww_boss_jdt_01.png")
		self.pImgJdt = pImgJdt
	    local pProJdt = cc.ProgressTimer:create(pImgJdt)
	    pProJdt:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	    pProJdt:setBarChangeRate(cc.p(1, 0))
	    pProJdt:setMidpoint(cc.p(0, 0.5))
	    pProJdt:setPosition(161/2, 20/2)
	    pLayTLBossHp:addChild(pProJdt, 1)
	    self.pProJdt = pProJdt
	    self.pProJdt:setCameraMask(nCaremaMask,true)

	    --血条尾端光，默认是隐藏
		self.pImgHpEndLight = display.newSprite("#rwww_boss_yq1_003.png")
		self.pImgHpEndLight:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		self.pImgHpEndLight:setCameraMask(nCaremaMask,true)
		self.pImgHpEndLight:setPosition(0, 20/2)
		pLayTLBossHp:addChild(self.pImgHpEndLight,10)
		self.pImgHpEndLight:setVisible(false)

		--阶段背景
		self.pBbStageBg = display.newSprite("#v2_img_clock_bossa.png")
		self.pBbStageBg:setPosition(-20, 20/2)
		pLayTLBossHp:addChild(self.pBbStageBg, 2)
		self.pBbStageBg:setCameraMask(nCaremaMask,true)
		
		--圆圈图片
	    local pImgStageBg = display.newSprite("#v2_img_clock_bossb.png")
	    local pProStageBg = cc.ProgressTimer:create(pImgStageBg)  
	    pProStageBg:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
	    pProStageBg:setReverseDirection(true) --反向
	    pProStageBg:setPosition(-20, 20/2)
	    pLayTLBossHp:addChild(pProStageBg, 3)  
	    self.pProStageBg = pProStageBg
	    self.pProStageBg:setCameraMask(nCaremaMask,true)

	    --圆圈粒子
	    self.pRedParitcle =  createParitcle("tx/other/lizi_sjboss_qzhd_0001.plist")
	    self.pLayParitcle = display.newNode()    
	    self.pLayParitcle:setScale(2)
	    self.pLayParitcle:addChild(self.pRedParitcle)
	    pLayTLBossHp:addChild(self.pLayParitcle, 3)
	    self.pRedParitcle:setPosition(0, 0)
	    self.pLayParitcle:setCameraMask(nCaremaMask,true)
	    self.pLayParitcle:setVisible(false)

	    --阶段数字
		self.pTxtStageNum = MUI.MLabelAtlas.new({text="0", png="ui/atlas/v2_img_shanghaishuzihh.png", pngw=16, pngh=27, scm=48})
		pLayTLBossHp:addChild(self.pTxtStageNum, 4)
		self.pTxtStageNum:setPosition(-20, 20/2)
		self.pTxtStageNum:setCameraMask(nCaremaMask,true)

		--行士兵集
		local nPos1X, nPos1Y = nBossX + tSoldierPos[1].x, nBossY + tSoldierPos[1].y
		local nPos2X, nPos2Y = nBossX + tSoldierPos[2].x, nBossY + tSoldierPos[2].y
		local nPos3X, nPos3Y = nBossX + tSoldierPos[3].x, nBossY + tSoldierPos[3].y
		--相对于中间的位置
		self.tRelativetPos = {
			{nPos1X - nPos2X, nPos1Y - nPos2Y},
			{0, 0},
			{nPos3X - nPos2X, nPos3Y - nPos2Y},
		}
		self.tIdleSoldierRow = {}
		self.tAllSoldierRow = {}
		self.pRowTwoLayer = nil --第二排士兵层

		--名字和背景
		local pLayName = display.newNode()
		pLayName:setPosition(nBossX + 20, nBossY - UNIT_HEIGHT/2 - 40)
		self:addChild(pLayName, nNameZorder)
		local pImgName = display.newSprite("#v1_img_namebg3.png")
		pImgName:setOpacity(0.5*255) --因为渲染了两次，所以这里减少一半透明度
		pLayName:addChild(pImgName)
		local pTxtName = MUI.MLabel.new({
	            text = getConvertedStr(3, 10800),
	            size = 20,})
		pLayName:addChild(pTxtName, 2)
		local pImgIcon = display.newSprite("#v2_img_dengjidi02.png")
		pLayName:addChild(pImgIcon, 1)
		pImgIcon:setPositionX(-pImgName:getContentSize().width/2)
		pLayName:setCameraMask(nCaremaMask,true)

		--准备结束倒计时
		local pLayReadyCd = display.newNode()
		self.pLayReadyCd = pLayReadyCd
		pLayReadyCd:setPosition(0, nBossY - UNIT_HEIGHT/2 - 90)
		self:addChild(pLayReadyCd, nNameZorder)
		local pTxtReadyCdT = MUI.MLabel.new({
	            text = getConvertedStr(3, 10834),
	            size = 22,})
		pTxtReadyCdT:setAnchorPoint(cc.p(0,0.5))
		setTextCCColor(pTxtReadyCdT, _cc.white)
		-- pTxtReadyCdT:enableOutline(cc.c4b(0, 0, 0, 255),2)
		pLayReadyCd:addChild(pTxtReadyCdT, 2)
		self.nReadyCdTWidth = pTxtReadyCdT:getContentSize().width

		local pTxtReadyCd = MUI.MLabel.new({
	            text = "0",
	            size = 22,})
		self.pTxtReadyCd = pTxtReadyCd
		pTxtReadyCd:setAnchorPoint(cc.p(0,0.5))
		pTxtReadyCd:setPositionX(self.nReadyCdTWidth)
		setTextCCColor(pTxtReadyCd, _cc.red)
		-- pTxtReadyCd:enableOutline(cc.c4b(0, 0, 0, 255),2)
		pLayReadyCd:addChild(pTxtReadyCd, 2)
		pLayReadyCd:setCameraMask(nCaremaMask,true)
		--默认隐藏倒计时
		self:hideReadyCd()
	end

	--更新限时Boss数据
	self:updateTLBoss()
end

--重置血条
function TLBossDot:resetHpUi()
	self.bIsRecording = false
	self.pProJdt:stopAllActions()
	self.pProStageBg:stopAllActions()
	self.pTxtStageNum:stopAllActions()
	self.pTxtStageNum:setOpacity(255)
	self.pTxtStageNum:setVisible(true)
	self.pTxtStageNum:setScale(1)
	self.bHpEndLight = false
	self.pImgHpEndLight:setVisible(false)
	self.pLayParitcle:setVisible(false)
	self.pLayTLBossHp:stopAllActions()
	self.pLayTLBossHp:setOpacity(255)
	self.pLayTLBossHp:setVisible(true)
end

--显示限时时间
function TLBossDot:showReadyCd(  )
	if self.pLayReadyCd then
		self.pLayReadyCd:setVisible(true)
		regUpdateControl(self, handler(self, self.updateReadyCd))
		self:updateReadyCd()
	end
end

--隐藏限时时间
function TLBossDot:hideReadyCd(  )
	if self.pLayReadyCd then
		self.pLayReadyCd:setVisible(false)
	end
	unregUpdateControl(self)
end

--更新限时时间
function TLBossDot:updateReadyCd(  )
	local nTLBossTime = Player:getTLBossData():getCdState()
	if nTLBossTime == e_tlboss_time.ready then
		local nCd = Player:getTLBossData():getCd()
		if nCd >= 0 then
			self.pTxtReadyCd:setString(getTimeLongStr(nCd,false,false))
			local nTxtReadyCdWidth = self.pTxtReadyCd:getContentSize().width
			local nMiddleX =  self.nBossX - (self.nReadyCdTWidth + nTxtReadyCdWidth)/2 + 20
			self.pLayReadyCd:setPositionX(nMiddleX)
		else
			unregUpdateControl(self)
		end
	else
		unregUpdateControl(self)
	end
end

--TLBoss进场动画
function TLBossDot:showTLBossEnter(  )
	--如果之前有值就进行强制重置
	if self.nTLBossTime then
		self.nTLBossTime = nil
		--重置死亡
		self.bIsDeath = false
		--重置血条
		self:resetHpUi()
		--重置士兵
		self:resetSoilders()
	end
	--音效
	--BOSS出现
	self:playSoundEffect(Sounds.Effect.jianglin)

	--播放进场动画
	self:playEnterEffect()
end

--TLBoss状态发生变化
function TLBossDot:updateTLBoss(  )
	--活动当前状态
	local nTLBossTime = Player:getTLBossData():getCdState()
	--活动状态发生改变（注意网络数据时差）
	if self.nTLBossTime ~= nTLBossTime then
		self.nTLBossTime = nTLBossTime
		--显示是否有打开过Ui面板
		self:updateFinger() --更新显示手指
		if self.nTLBossTime == e_tlboss_time.ready then --准备状态
			--标记为没有死
			self.bIsDeath = false
			--播放血条（满血)
			self:playTLBossHpFull()
			--播放准备动画
			self:playReadyArms()
			--隐藏最后的名字
			self:hideLastName()
			--显示倒计时
			self:showReadyCd()
		elseif self.nTLBossTime == e_tlboss_time.begin then --开始状态
			--记录当前Boss状态，用于当在开始阶段，阶段数不同时，进行爆破显示下一段
			local tStageVo = Player:getTLBossData():getBossStageVo()
			if tStageVo then
				self.nStage = tStageVo:getStage()
			end
			--标记为没有死
			self.bIsDeath = false
			--播放血条
			self:playTLBossHpCd()
			--播放开始动画直到死Boss死亡退场
			self:playBeginArms()						
			--隐藏最后的名字
			self:hideLastName()
			--隐藏倒计时
			self:hideReadyCd()
		else
			--标记为死
			self.bIsDeath = true
			--播放血条消息
			self:playTLBossHpDiappear()
			--播放结束动画
    		self:playOverArms()
    		--播放最后名字
    		self:showLastName()
    		--隐藏倒计时
			self:hideReadyCd()
		end
		self.bIsFirstArm = false
	else
		if self.nTLBossTime == e_tlboss_time.begin then
			local tStageVo = Player:getTLBossData():getBossStageVo()
			if tStageVo then
				local nStage = tStageVo:getStage()
				--记录当前Boss状态，用于当在开始阶段，阶段数不同时，进行爆破显示下一段
				if self.nStage ~= nStage then
					self:resetHpUi()
					self:playStageNumExplosion()
				end
				self.nStage = nStage
			end
		end
	end
end

function TLBossDot:updateTLBossHp(  )
	if self.nTLBossTime == e_tlboss_time.begin then
		self:playTLBossHpCd()
	end
end

--血条渐变动行
function TLBossDot:runJdtScheduler( )
	--血条进度度渐变处理
	if not self.nImgJdtScheduler then
	    self.pImgJdtIndex = 1
	    self.nImgJdtOffset = 1/15 * 1000
	    self.nImgJdtSysTime = getSystemTime(false)

	    self.nImgJdtScheduler = MUI.scheduler.scheduleGlobal(function (dt)
	    	if MArmatureUtils:getSceneType() == Scene_arm_type.world then
	    		--一定间隔切换序列帧
		    	local nCurrSysTime = getSystemTime(false)
		    	if nCurrSysTime - self.nImgJdtSysTime >= self.nImgJdtOffset then
		    		self.nImgJdtSysTime = nCurrSysTime

		    		local sImg = nil
					if self.pImgJdtIndex < 10 then
						sImg =  string.format("ui/bar/tlboos_jdt/rwww_boss_jdt_0%s.png",self.pImgJdtIndex)
					else
						sImg =  string.format("ui/bar/tlboos_jdt/rwww_boss_jdt_%s.png",self.pImgJdtIndex)
					end
					self.pImgJdt:setTexture(sImg)
					self.pImgJdtIndex = self.pImgJdtIndex + 1
			    	if self.pImgJdtIndex > 14 then
			    		self.pImgJdtIndex = 1
			    	end
		    	end
		    	--光效尾巴更新位置
		    	if self.bHpEndLight then
			  		local nPer = self.pProJdt:getPercentage()
			  		local nX = nPer/100 * 161
					self.pImgHpEndLight:setPositionX(nX)
				end
				--圆圈粒子更新位置
		    	if self.bRedParitcle then
					local nX, nY = self:getRedParitclePos()
					self.pLayParitcle:setPosition(nX, nY)
		    	end
		    end
		end,0.05)
	end
end

--满血状态
function TLBossDot:playTLBossHpFull(  )
	--渐变条动作
	self:runJdtScheduler()

	self:resetHpUi()

	local tStageVo = Player:getTLBossData():getBossStageVo()
	if tStageVo then
		self.pTxtStageNum:setString(tStageVo:getStage())
	end
	self.pProJdt:setPercentage(100)
	self.pProStageBg:setPercentage(100)
end

--nCd 倒计时
function TLBossDot:playTLBossHpCd(  )
	--渐变条动作
	self:runJdtScheduler()
	self:resetHpUi()

	--设置阶段数
	local nStage = 0
	local tStageVo = Player:getTLBossData():getBossStageVo()
	if tStageVo then
		nStage = tStageVo:getStage()
	end
	self.pTxtStageNum:setString(nStage)
	--更新进度条
	self:updateHpUi()
end


--更新cd进度条，更加精准
function TLBossDot:updateHpUi( )
	--播放恢复时间就不执行
	if self.bIsRecording then
		return
	end

	local tStageVo = Player:getTLBossData():getBossStageVo()
	if not tStageVo then
		return
	end
	local nBrokeTime = tStageVo:getBrokeTime()
	local nCd = tStageVo:getLifeCd()
	local nBarTime = tStageVo:getBarTime()
	local nLifeTime = tStageVo:getLifeTime()
	if nCd > nBrokeTime then
		--Bar长度
		self.pProJdt:stopAllActions()
		self.pProJdt:setPercentage((nCd - nBrokeTime)/nBarTime * 100)
		local progressTo = cc.ProgressTo:create((nCd - nBrokeTime),0)  
	    local clear = cc.CallFunc:create(function (  )  
	    	self:playTLBossBrokeCd()
	    end) 
	    local pAct = cc.Sequence:create(progressTo,clear)
	    self.pProJdt:runAction(pAct)

	    --圆圈
	    self.bRedParitcle = false
		self.pLayParitcle:setVisible(false)
		self.pProStageBg:stopAllActions()
		self.pProStageBg:setPercentage(100)
	else
		self.pProJdt:stopAllActions()
		self.pProJdt:setPercentage(0)
		self:playTLBossBrokeCd()
	end
end

--获取红色粒子位置
function TLBossDot:getRedParitclePos(  )
	local nPer = self.pProStageBg:getPercentage()
	local nRadian = ((1 - nPer/100) * 360 - 90) * math.pi / 180
	local nStartX, nStartY = -20, 20/2
	local nRadius = 14.5
	local nX, nY = nStartX + nRadius * math.cos(nRadian), nStartY - nRadius * math.sin(nRadian)
	return nX, nY
end

--步骤二：倒计时圈圈，使用“v2_img_clock_bossb”做如预览效果的动画。 
--nCd 倒计时
function TLBossDot:playTLBossBrokeCd( )
	local tStageVo = Player:getTLBossData():getBossStageVo()
	if not tStageVo then
		return
	end

    local nBrokeTime = tStageVo:getBrokeTime()
    local nCd = tStageVo:getLifeCd()
    self.pProStageBg:stopAllActions()
	self.pProStageBg:setPercentage(nCd/nBrokeTime*100)
	if nCd <= 0 then
		self.bRedParitcle = false
		self.pLayParitcle:setVisible(false)
	else
		--圆圈粒子更新位置
		self.bRedParitcle = true
		self.pLayParitcle:setVisible(true)
		local nX, nY = self:getRedParitclePos()
		self.pLayParitcle:setPosition(nX, nY)
	    local progressTo = cc.ProgressTo:create(nCd,0)  
	    local clear = cc.CallFunc:create(function (  )  
	    	self.bRedParitcle = false
	    	self.pLayParitcle:setVisible(false)
	    	--改变检测状态发生改变时调用（根据服务器的数据进行爆炸）
	    	-- self:playStageNumExplosion()
	    end)
	    local pAct = cc.Sequence:create(progressTo,clear)
	    self.pProStageBg:runAction(pAct)
	end
end

--步骤三：圆圈爆炸动画。 等到圆圈完全消失的时候， 播放圆圈爆炸动画，圆圈内的数字同时消失。
function TLBossDot:playStageNumExplosion(  )
	self.pTxtStageNum:setVisible(false)
	local tArmData1  = 
	{
--        sPlist = "tx/other/rwww_boss_jdt",
--        nImgType = 1,
		nFrame = 18, -- 总帧数
		pos = {-12, 18}, -- 特效的x,y轴位置（相对中心锚点的偏移）
		fScale = 1.4,-- 初始的缩放值
		nBlend = 1, -- 需要加亮
	   	nPerFrameTime = 1/20, -- 每帧播放时间（20帧每秒）
		tActions = {
			 {
				nType = 1, -- 序列帧播放
				sImgName = "rwww_boss_jdt_bp_",
				nSFrame = 1, -- 开始帧下标
				nEFrame = 18, -- 结束帧下标
				tValues = nil, -- 参数列表
			},
		},
	}
	local pArm = MArmatureUtils:createMArmature(
        tArmData1, 
        self.pLayTLBossHp, 
        5, 
        cc.p(-20, 20/2),
        function ( _pArm )
        	_pArm:removeSelf()
        end, Scene_arm_type.world)
    if pArm then
    	pArm:setCameraMask(nCaremaMask,true)
    	pArm:setFrameEventCallFunc(function ( _nCur )
    		if _nCur == 9 then
    			self:playStageNumAppear()
			end
		end)
        pArm:play(1)
    end
end

--步骤四：出现新的数字同时进度条刷出。
function TLBossDot:playStageNumAppear(  )
	local nStage = 0
	local tStageVo = Player:getTLBossData():getBossStageVo()
	if tStageVo then
		nStage = tStageVo:getStage()
	end
	self.pTxtStageNum:setString(nStage)
	self.pTxtStageNum:setVisible(true)
	-- 时间    透明度    缩放值   
	-- 0秒      40%        300%
	-- 0.21秒   100%       100%
	self.pTxtStageNum:setOpacity(0.4*255)
	self.pTxtStageNum:setScale(3)
	local pAct = cc.Sequence:create({
	 	cc.Spawn:create({
						cc.FadeTo:create(0.21, 255),
		    			cc.ScaleTo:create(0.21, 1),
		    		}),
	 	cc.CallFunc:create(function (  )  
	 		--显示光芒动画
	 		self:playLightArm()
	 		--显示进度底底图发光
	 		self:pLayTLBossHpBgLight()
	 		--恢复进度条
	    	self:recoverTLBossHp()
	    end),
	 	})
	self.pTxtStageNum:runAction(pAct)  
end

--当数字缩放动画播放到 0.21秒时，圆圈的边框出现“v2_img_clock_bossb”
--同时（0.21秒）出现光芒动画。
--播放光芒动画
function TLBossDot:playLightArm(  )
	self.pProStageBg:setPercentage(100)
	local nX, nY = -20, 20/2
	local tArmData1  = 
	{
--        sPlist = "tx/other/rwww_boss_jdt",
--        nImgType = 1,
		nFrame = 8, -- 总帧数
		pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
		fScale = 1,-- 初始的缩放值
		nBlend = 1, -- 需要加亮
	  	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
		tActions = {
			{
				nType = 5, -- 缩放 + 透明度
				sImgName = "rwww_boss_yq1_001",
				nSFrame = 1,
				nEFrame = 8,
				tValues = {-- 参数列表
					{1, 1.5}, -- 开始, 结束缩放值
					{255, 0}, -- 开始, 结束透明度值
				},
			},
		},
	}
	local pArm = MArmatureUtils:createMArmature(
        tArmData1, 
        self.pLayTLBossHp, 
        6, 
        cc.p(nX, nY),
        function ( _pArm )
        	_pArm:removeSelf()
        end, Scene_arm_type.world)
    if pArm then
    	pArm:setCameraMask(nCaremaMask,true)
        pArm:play(1)
    end

	local tArmData2  = 
	{
--        sPlist = "tx/other/rwww_boss_jdt",
--        nImgType = 1,
		nFrame = 11, -- 总帧数
		pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
		fScale = 1,-- 初始的缩放值
		nBlend = 1, -- 需要加亮
	  	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
		tActions = {
			{
				nType = 5, -- 缩放 + 透明度
				sImgName = "rwww_boss_yq1_002",
				nSFrame = 1,
				nEFrame = 3,
				tValues = {-- 参数列表
					{1, 1}, -- 开始, 结束缩放值
					{255, 125}, -- 开始, 结束透明度值
				},
			},
			{
				nType = 5, -- 缩放 + 透明度
				sImgName = "rwww_boss_yq1_002",
				nSFrame = 4,
				nEFrame = 11,
				tValues = {-- 参数列表
					{1, 1}, -- 开始, 结束缩放值
					{115, 0}, -- 开始, 结束透明度值
				},
			},
		},
	}
	local pArm = MArmatureUtils:createMArmature(
        tArmData2, 
        self.pLayTLBossHp, 
        6, 
        cc.p(nX, nY),
        function ( _pArm )
        	_pArm:removeSelf()
        end, Scene_arm_type.world)
    if pArm then
    	pArm:setCameraMask(nCaremaMask,true)
        pArm:play(1)
    end

	local tArmData3  = 
	{
		nFrame = 6, -- 总帧数
		pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
		fScale = 1,-- 初始的缩放值
		nBlend = 1, -- 需要加亮
	  	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
		tActions = {
			{
				nType = 5, -- 缩放 + 透明度
				sImgName = "v2_img_clock_bossa",
				nSFrame = 1,
				nEFrame = 6,
				tValues = {-- 参数列表
					{1, 1}, -- 开始, 结束缩放值
					{255, 0}, -- 开始, 结束透明度值
				},
			},
		},
	}
	local pArm = MArmatureUtils:createMArmature(
        tArmData3, 
        self.pLayTLBossHp, 
        6, 
        cc.p(nX, nY),
        function ( _pArm )
        	_pArm:removeSelf()
        end, Scene_arm_type.world)
    if pArm then
    	pArm:setCameraMask(nCaremaMask,true)
        pArm:play(1)
    end

	local tArmData4  = 
	{
		nFrame = 11, -- 总帧数
		pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
		fScale = 1,-- 初始的缩放值
		nBlend = 1, -- 需要加亮
	  	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
		tActions = {
			{
				nType = 5, -- 缩放 + 透明度
				sImgName = "v2_img_clock_bossa",
				nSFrame = 1,
				nEFrame = 11,
				tValues = {-- 参数列表
					{1.1, 1.4}, -- 开始, 结束缩放值
					{255, 0}, -- 开始, 结束透明度值
				},
			},
		},
	}
	local pArm = MArmatureUtils:createMArmature(
        tArmData4, 
        self.pLayTLBossHp, 
        6, 
        cc.p(nX, nY),
        function ( _pArm )
        	_pArm:removeSelf()
        end, Scene_arm_type.world)
    if pArm then
    	pArm:setCameraMask(nCaremaMask,true)
        pArm:play(1)
    end
end

--同时（0.21秒）播放UI“v2_bar_bboss”加亮动画（位置原底框"v2_bar_bboss"的位置上，且在其他UI的下层）
--播放UI“v2_bar_bboss”加亮动画
function TLBossDot:pLayTLBossHpBgLight(  )
	local tArmData1  = 
	{
		nFrame = 11, -- 总帧数
		pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
		fScale = 1,-- 初始的缩放值
		nBlend = 1, -- 需要加亮
	  	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
		tActions = {
			{
				nType = 5, -- 缩放 + 透明度
				sImgName = "ui/bar/v2_bar_bboss.png",
				nSFrame = 1,
				nEFrame = 4,
				tValues = {-- 参数列表
					{1, 1}, -- 开始, 结束缩放值
					{125, 255}, -- 开始, 结束透明度值
				},
			},
			{
				nType = 5, -- 缩放 + 透明度
				sImgName = "ui/bar/v2_bar_bboss.png",
				nSFrame = 5,
				nEFrame = 10,
				tValues = {-- 参数列表
					{1, 1}, -- 开始, 结束缩放值
					{220, 0}, -- 开始, 结束透明度值
				},
			},
		},
	}
	local pArm = MArmatureUtils:createMArmature(
        tArmData1, 
        self.pLayTLBossHp, 
        0, 
        cc.p(161/2,20/2),
        function ( _pArm )
        	_pArm:removeSelf()
        end, Scene_arm_type.world)
    if pArm then
    	pArm:setCameraMask(nCaremaMask,true)
        pArm:play(1)
    end
end

-- 同时（0.21秒）以0.25秒的速度  刷出新的进度条，在进度条刷出来的末端需要加一张“rwww_boss_yq1_003”加亮，一起移动刷出。   
function TLBossDot:recoverTLBossHp( )
	self.bIsRecording = true
	self.bHpEndLight = true
	self.pImgHpEndLight:setVisible(true)
	self.pImgHpEndLight:setPositionX(0)
	local progressTo = cc.ProgressTo:create(0.25,100)  
    local clear = cc.CallFunc:create(function (  )  
    	self.bIsRecording = false
    	self.bHpEndLight = false
    	self.pImgHpEndLight:setVisible(false)
    	self:pLayTLBossHpBgLightScale()

    	self:playTLBossHpCd()
    end)  
    local pAct = cc.Sequence:create(progressTo,clear)
	self.pProJdt:runAction(pAct)
end

-- 在完全刷出来的时候播放：“v2_bar_bboss”缩放动画
function TLBossDot:pLayTLBossHpBgLightScale(  )
	local tArmData1  = 
	{
		nFrame = 10, -- 总帧数
		pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
		fScale = 1,-- 初始的缩放值
		nBlend = 1, -- 需要加亮
	  	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
		tActions = {
			{
				nType = 5, -- 缩放 + 透明度
				sImgName = "ui/bar/v2_bar_bboss.png",
				nSFrame = 1,
				nEFrame = 10,
				tValues = {-- 参数列表
					{1.06, 1.13}, -- 开始, 结束缩放值
					{255, 0}, -- 开始, 结束透明度值
				},
			},
		},
	}

	local pArm = MArmatureUtils:createMArmature(
        tArmData1, 
        self.pLayTLBossHp, 
        0, 
        cc.p(161/2,20/2),
        function ( _pArm )
        	_pArm:removeSelf()
        end, Scene_arm_type.world)
    if pArm then
    	pArm:setCameraMask(nCaremaMask,true)
        pArm:play(1)
    end
end

--当进度条是最后一次的时候， 只需要播放“步骤3” ，在播放到“rwww_boss_jdt_bp_09”帧的时，进度条UI 透明度消失。
function TLBossDot:playTLBossHpDiappear()
	-- 时间     透明度   
	-- 0秒       100%
	-- 0.2秒     0%
	if self.nImgJdtScheduler then
		MUI.scheduler.unscheduleGlobal(self.nImgJdtScheduler)
		self.nImgJdtScheduler = nil
	end
	self:resetHpUi()
	self.pProStageBg:setPercentage(0)
	self.pProJdt:setPercentage(0)
	-- if self.bIsFirstArm then
	-- 	self.pLayTLBossHp:setOpacity(0)
	-- else
 --    	self.pLayTLBossHp:runAction(cc.FadeOut:create(0.2))
 --    end
 	self.pLayTLBossHp:setVisible(false)
end
-------------------------------------------------------血条动画


-------------------------------------------------------破坏文字飘出
--sName 名字
--bIsBroke 是否破坏时间
function TLBossDot:showAtkTLBossName( sName, bIsBroke )
	local nX, nY = self.nBossX, self.nBossY - UNIT_HEIGHT/2 --距形中心点
	local nRandomX = math.random(-100, 100)
	local nRandomY = math.random(-20, 20)
	nX = nX + nRandomX
	nY = nY + nRandomY

	local pNode = display.newNode()
	pNode:setCascadeOpacityEnabled(true)
	pNode:setPosition(nX, nY)
	self:addChild(pNode, nHurtTextZoder)

	local sImg = "#v2_fonts_zuiqiangyiji.png"
	if bIsBroke then
		sImg = "#v2_buweipohuai.png"
	end
	local pImgFont = display.newSprite(sImg)
	pImgFont:setOpacity(0.5*255) --因为渲染了两次，所以这里减少一半透明度
	pNode:addChild(pImgFont, 1)
	pImgFont:setPosition(0, 33/2)

	local pImgName = display.newSprite("#v1_img_namebg3.png")
	pImgName:setOpacity(0.5*255) --因为渲染了两次，所以这里减少一半透明度
	pNode:addChild(pImgName, 2)
	pImgName:setPosition(0, - 28/2 - 2)

	local pTxtName = MUI.MLabel.new({
            text = sName,
            size = 20,})
	pTxtName:setOpacity(0.5*255) --因为渲染了两次，所以这里减少一半透明度
	pNode:addChild(pTxtName, 3)
	pTxtName:setPosition(0, - 28/2 - 2 - 1)

	pNode:setCameraMask(nCaremaMask,true)

	-- 弹出动画：
	-- 时间    缩放值    位置（Y）    透明度
	-- 0秒       0%           0        100%
	-- 0.20秒    115%         0        100%
	-- 0.30秒    100%         0        100%
	-- 0.90秒    100%         18       100%
	-- 1.55秒    100%         36       0%
	pNode:setScale(0)
	local pAct = cc.Sequence:create({
		cc.ScaleTo:create(0.20, 1.15),
		cc.ScaleTo:create(0.30 - 0.20, 1),
		cc.MoveTo:create(0.90 - 0.30, cc.p(nX, nY + 18)),
	 	cc.Spawn:create({
						cc.MoveTo:create(1.55 - 0.90, cc.p(nX, nY + 36)),
		    			cc.FadeOut:create(1.55 - 0.90),
		    		}),
	 	cc.CallFunc:create(function (  )
	 		pNode:removeFromParent()
	 	end),
	 	})
	pNode:runAction(pAct)
end

-------------------------------------------------------破坏文字飘出

-------------------------------------------------------飘血数字
--nNum 伤害数字
--bIsBest 是否最强一击
function TLBossDot:showAtkTLBossHurt( nNum, bIsBest)
	local nX, nY = self.nBossX + 15, self.nBossY - UNIT_HEIGHT/2 + 30 --距形中心点
	local nRandomX = math.random(-100, 100)
	local nRandomY = math.random(-20, 20)
	nX = nX + nRandomX
	nY = nY + nRandomY

	--伤害数字
	local sImg = "ui/atlas/v2_img_shanghaishuzih.png"
	if bIsBest then
		sImg = "ui/atlas/v2_img_shanghaishuzihh.png"
	end
	local pTxtNum = MUI.MLabelAtlas.new({text=":"..tostring(nNum), png=sImg, pngw=16, pngh=27, scm=48})
	self:addChild(pTxtNum, nHurtTextZoder)
	pTxtNum:setPosition(nX, nY)
	pTxtNum:setCameraMask(nCaremaMask,true)

	-- 弹出动画：
	-- 时间    缩放值    位置（Y）    透明度
	-- 0秒       0%           0        100%
	-- 0.20秒    115%         0        100%
	-- 0.30秒    100%         0        100%
	-- 0.90秒    100%         18       100%
	-- 1.55秒    100%         36       0%
	pTxtNum:setScale(0)
	local pAct = cc.Sequence:create({
		cc.ScaleTo:create(0.20, 1.15),
		cc.ScaleTo:create(0.30 - 0.20, 1),
		cc.MoveTo:create(0.90 - 0.30, cc.p(nX, nY + 18)),
	 	cc.Spawn:create({
						cc.MoveTo:create(1.55 - 0.90, cc.p(nX, nY + 36)),
		    			cc.FadeOut:create(1.55 - 0.90),
		    		}),
	 	cc.CallFunc:create(function (  )
	 		pTxtNum:removeFromParent()
	 	end),
	 	})
	pTxtNum:runAction(pAct)
end

-------------------------------------------------------飘血数字

-------------------------------------------------------Boss及小兵动画

--BOSS动作刀光
--1是普攻，2是重攻
function TLBossDot:playTLBossKnifeArm( nType )
	if not self.pLayTLBossArm then
		return
	end
	local tArmData1 = nil
	if nType == 1 then
		tArmData1  = 
		{
            sPlist = "tx/other/rwww_sjbs_xdg_bk",
            nImgType = 1,
			nFrame = 8, -- 总帧数
			pos = {-2, -59}, -- 特效的x,y轴位置（相对中心锚点的偏移）
			fScale = 3,-- 初始的缩放值
			nBlend = 1, -- 需要加亮
		   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
			tActions = {
				 {
					nType = 1, -- 序列帧播放
					sImgName = "rwww_sjbs_xdg_bk_",
					nSFrame = 1, -- 开始帧下标
					nEFrame = 8, -- 结束帧下标
					tValues = nil, -- 参数列表
				},
			},
		}
	elseif nType == 2 then
		tArmData1  = 
		{
            sPlist = "tx/other/rwww_sjbs_ddg_bk",
            nImgType = 1,
			nFrame = 8, -- 总帧数
			pos = {-8, 21}, -- 特效的x,y轴位置（相对中心锚点的偏移）
			fScale = 3,-- 初始的缩放值
			nBlend = 1, -- 需要加亮
		   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
			tActions = {
				 {
					nType = 1, -- 序列帧播放
					sImgName = "rwww_sjbs_ddg_bk_",
					nSFrame = 1, -- 开始帧下标
					nEFrame = 8, -- 结束帧下标
					tValues = nil, -- 参数列表
				},
			},
		}
	end
	if not tArmData1 then
		return
	end
	--特效层(透明度*0.5，主要用于摄像机2的层)
	local pLayEffectArm = MUI.MLayer.new()
	pLayEffectArm:setCameraMask(nCaremaMask,true)
	pLayEffectArm:setOpacity(255*0.5)
	self:addChild(pLayEffectArm, nAtkEffectZorder)
	pLayEffectArm:setPosition(self.nBossX,self.nBossY)

	local pArm = MArmatureUtils:createMArmature(
        tArmData1, 
        pLayEffectArm, 
        0, 
        cc.p(0,0),
        function ( _pArm )
        	_pArm:removeSelf()
        	pLayEffectArm:removeFromParent()
        end, Scene_arm_type.world)
    if pArm then
    	pArm:play(1)
    	pArm:setCameraMask(nCaremaMask,true)
    end
end

--BOSS受击特效
--nSoliderType 士兵类型 1是步，2是弓，3是骑
function TLBossDot:playTLBossHurtArm( nSoliderType )
	if not self.pLayTLBossArm then
		return
	end
	local tArmData1 = nil
	if nSoliderType == 1 then
		tArmData1  = 
		{
            sPlist = "tx/fight/p2_fight_hurt",
            nImgType = 2,
			nFrame = 6, -- 总帧数
			pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
			fScale = 2.5,-- 初始的缩放值
			nBlend = 1, -- 需要加亮
		   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
			tActions = {
				 {
					nType = 1, -- 序列帧播放
					sImgName = "sg_zdtx_bbsjgx_",
					nSFrame = 1, -- 开始帧下标
					nEFrame = 6, -- 结束帧下标
					tValues = nil, -- 参数列表
				},
			},
		}
	elseif nSoliderType == 2 then
		tArmData1  = 
		{
            sPlist = "tx/fight/p2_fight_hurt",
            nImgType = 2,
			nFrame = 6, -- 总帧数
			pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
			fScale = 2.5,-- 初始的缩放值
			nBlend = 1, -- 需要加亮
		   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
			tActions = {
				 {
					nType = 1, -- 序列帧播放
					sImgName = "sg_zdtx_gbsjgx_",
					nSFrame = 1, -- 开始帧下标
					nEFrame = 6, -- 结束帧下标
					tValues = nil, -- 参数列表
				},
			},
		}
	elseif nSoliderType == 3 then
		tArmData1  = 
		{
            sPlist = "tx/fight/p2_fight_hurt",
            nImgType = 2,
			nFrame = 6, -- 总帧数
			pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
			fScale = 2.5,-- 初始的缩放值
			nBlend = 1, -- 需要加亮
		   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
			tActions = {
				 {
					nType = 1, -- 序列帧播放
					sImgName = "sg_zdtx_qbsjgx_",
					nSFrame = 1, -- 开始帧下标
					nEFrame = 6, -- 结束帧下标
					tValues = nil, -- 参数列表
				},
			},
		}
	end
	if not tArmData1 then
		return
	end

	--特效层(透明度*0.5，主要用于摄像机2的层)
	local pLayEffectArm = MUI.MLayer.new()
	pLayEffectArm:setCameraMask(nCaremaMask,true)
	pLayEffectArm:setOpacity(255*0.5)
	self:addChild(pLayEffectArm, nHurtZorder)
	pLayEffectArm:setPosition(self.nBossX,self.nBossY)

	local pArm = MArmatureUtils:createMArmature(
        tArmData1, 
        pLayEffectArm, 
        nHurtZorder, 
        cc.p(0,0),
        function ( _pArm )
        	_pArm:removeSelf()
        end, Scene_arm_type.world)
    if pArm then
    	pArm:setCameraMask(nCaremaMask,true)
    	pArm:play(1)
    end
end

--Boss播放动方法
--sArmKey: 动画key
--nLoop:循环次数
--nEndFunc:结束回调事件
--nFrameFunc:帧回调事件
function TLBossDot:playTLBossArm( sArmKey, nLoop, nEndFunc, nFrameFunc)
	local tArmData1 = tFightSecArmDatas[sArmKey]
	if not tArmData1 then
		return
	end

	--音效
	if sArmKey == e_tlboss_arm.pg then--普攻
		self:playSoundEffect(Sounds.Effect.huiji)
	elseif sArmKey == e_tlboss_arm.qg then--BOSS重攻击
		self:playSoundEffect(Sounds.Effect.zhendi)
	elseif sArmKey == e_tlboss_arm.ts then--BOSS死亡
		self:playSoundEffect(Sounds.Effect.siwang)
	end

	if self.pTLBossArm then
		self.pTLBossArm:setData(tArmData1)
	else
		local pLayTLBossArm = MUI.MLayer.new()
		pLayTLBossArm:setCameraMask(nCaremaMask,true)
		self:addChild(pLayTLBossArm, nTLBossZorder)
		pLayTLBossArm:setPosition(self.nBossX, self.nBossY)
		self.pLayTLBossArm = pLayTLBossArm

		local pArm = MArmatureUtils:createMArmature(
	        tArmData1, 
	        pLayTLBossArm, 
	        0, 
	        cc.p(0,0),
	        function ( _pArm )
	        end, Scene_arm_type.world)
	    if pArm then
	    	pArm:setCameraMask(nCaremaMask,true)
	    end
	    self.pTLBossArm = pArm
	end
	if self.pTLBossArm then
		--帧函数监听
		self.pTLBossArm:setFrameEventCallFunc(nFrameFunc)
		--结束函数监听
		self.pTLBossArm:setMovementEventCallFunc(nEndFunc)
	    self.pTLBossArm:play(nLoop)
	end
end

--播放准备动画
function TLBossDot:playReadyArms( )
	--重置士兵
	self:resetSoilders()
	--播放Boss待机
	self:playTLBossArm(e_tlboss_arm.dj, -1)
	--一段时间后播放切换至开始状态
	local nBeginCd = Player:getTLBossData():getCd()
	local pAct = cc.Sequence:create({
		cc.DelayTime:create(nBeginCd),
		cc.CallFunc:create(function ( )
	 		self:updateTLBoss(e_tlboss_time.begin)
	 	end),
 	})
	self:runAction(pAct)
end

--获取闲置兵一排
function TLBossDot:getIdleSoliders( )
	local nSoldierType = self.nSoldierType
	--精灵
	local pLayer = nil
	local nCount = #self.tIdleSoldierRow
	if nCount > 0 then
		pLayer = self.tIdleSoldierRow[nCount]
		pLayer.nSoldierType = nSoldierType
		pLayer:setVisible(true)
		table.remove(self.tIdleSoldierRow, nCount)
	end
	
	--主要动作层
	if not pLayer then
		pLayer = MUI.MLayer.new()
		pLayer:setCascadeOpacityEnabled(true)
		pLayer.nSoldierType = nSoldierType
		self:addChild(pLayer, nSoldierZorder)

		local tPosList = self.tRelativetPos
		--默认动画
		local tArmData1 = tFightSecArmDatas[e_bbing_arm.dj]
		pLayer.tSoldierArms = {}
		for i=1,#tPosList do
			local nX ,nY = tPosList[i][1], tPosList[i][2]
			local pArm = MArmatureUtils:createMArmature(
		        tArmData1, 
		        pLayer, 
		        0, 
		        cc.p(nX ,nY),
		        function ( _pArm )
		        	-- _pArm:removeSelf()
		        end, Scene_arm_type.world)
			table.insert(pLayer.tSoldierArms, pArm)
		end
		WorldFunc.setCameraMaskForView(pLayer)
		table.insert(self.tAllSoldierRow, pLayer)
	end

	self.nSoldierType = self.nSoldierType + 1
	if self.nSoldierType > 3 then
		self.nSoldierType = 1
	end

	return pLayer
end

--加入闲置兵
function TLBossDot:pushIdleSoliders( pLayer )
	if not pLayer then
		return
	end
	if pLayer.tSoldierArms then
		for i=1,#pLayer.tSoldierArms do
			local pArm = pLayer.tSoldierArms[i]
			if pArm then
				pArm:stop()
			end
		end
	end
	pLayer:stopAllActions()
	pLayer:setVisible(false)
	table.insert(self.tIdleSoldierRow, pLayer)
end

--士兵播放受击特效
--1是普攻，2是重攻
function TLBossDot:playSoldierHurtArm( pLayer, nType )
	if not pLayer then
		return
	end
	local tArmData1 = nil
	if nType == 1 then
		tArmData1  = 
		{
			nFrame = 6, -- 总帧数
			pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
			fScale = 1.5,-- 初始的缩放值
			nBlend = 1, -- 需要加亮
		   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
			tActions = {
				 {
					nType = 1, -- 序列帧播放
					sImgName = "sg_zdtx_gbsjgx_",
					nSFrame = 1, -- 开始帧下标
					nEFrame = 6, -- 结束帧下标
					tValues = nil, -- 参数列表
				},
			},
		}

	elseif nType == 2 then
		tArmData1  = 
		{
			nFrame = 6, -- 总帧数
			pos = {-8, 21}, -- 特效的x,y轴位置（相对中心锚点的偏移）
			fScale = 1.5,-- 初始的缩放值
			nBlend = 1, -- 需要加亮
		   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
			tActions = {
				 {
					nType = 1, -- 序列帧播放
					sImgName = "sg_zdtx_qbsjgx_",
					nSFrame = 1, -- 开始帧下标
					nEFrame = 6, -- 结束帧下标
					tValues = nil, -- 参数列表
				},
			},
		}
	end
	if not tArmData1 then
		return
	end
	local tPosList = self.tRelativetPos
	for i=1,#tPosList do
		local nX ,nY = tPosList[i][1], tPosList[i][2]
		local pArm = MArmatureUtils:createMArmature(
	        tArmData1, 
	        pLayer, 
	        nHurtZorder, 
	        cc.p(nX ,nY),
	        function ( _pArm )
	        	_pArm:removeSelf()
	        end, Scene_arm_type.world)
		if pArm then
			pArm:play(1)
			WorldFunc.setCameraMaskForView(pArm)
		end
	end
end

--士兵播放统一动作
function TLBossDot:playSoldierArm( pLayer, sArmKey, nLoop, nEndFunc, nFrameFunc)
	if not pLayer then
		print("NoTLayer")
		return
	end
	local nSoldierType = pLayer.nSoldierType
	local tArmData = nil
	if nSoldierType == 1 then
		tArmData = tFightSecArmDatas[e_bbing_arm[sArmKey]]
	elseif nSoldierType == 2 then
		tArmData = tFightSecArmDatas[e_qbing_arm[sArmKey]]
	elseif nSoldierType == 3 then
		tArmData = tFightSecArmDatas[e_gbing_arm[sArmKey]]
	end
	if not tArmData then
		print("NoTArmData")
		return
	end
	if pLayer.tSoldierArms then
		for i=1,#pLayer.tSoldierArms do
			local pChild = pLayer.tSoldierArms[i]
			if pChild then
				pChild:setData(tArmData)
			
				if i == 1 then --只需要一个加回调就好了
					--帧函数监听
					pChild:setFrameEventCallFunc(nFrameFunc)
					--结束函数监听
					pChild:setMovementEventCallFunc(nEndFunc)
				end
				pChild:play(nLoop)
			end
		end
	end
end

--获取相对于Boss的位置
function TLBossDot:getSoldersMidPos( sKey )
	local nBossX, nBossY = UNIT_WIDTH/2, UNIT_HEIGHT/2
	if sKey == "123" then
		return nBossX + tSoldierPos[2].x, nBossY + tSoldierPos[2].y
	elseif sKey == "456" then
		return nBossX + tSoldierPos[5].x, nBossY + tSoldierPos[5].y
	elseif sKey == "789" then
		return nBossX + tSoldierPos[8].x, nBossY + tSoldierPos[8].y
	end
end

--播放第一排士兵动画
function TLBossDot:playRowOneSoldierArm( pLayer, bIsFirst )
	if not pLayer then
		return
	end
	pLayer:stopAllActions()
	--第一个是渐现加移动
	if bIsFirst then
		self:playSoldierArm(pLayer, "dj", -1)
		pLayer:setOpacity(0)
		pLayer:runAction(cc.FadeIn:create(0.5))
	end
	--456->123
	self:playSoldierArm(pLayer, "pb", -1)
	local nX, nY = self:getSoldersMidPos("123")
	local pAct = cc.Sequence:create({
		cc.MoveTo:create(0.6, cc.p(nX, nY)),
		cc.CallFunc:create(function ( )
			--兵种普攻
	 		self:playSoldierArm(pLayer, "pg", -1, nil, function( nFrameIndex)
	 			--在第 6 帧播放受击特效。 
				if nFrameIndex == 6 then
					self:playTLBossHurtArm(pLayer.nSoldierType)
				end
	 		end)
	 		--死就不往下执行
	 		if self.bIsDeath then
	 			return
	 		end
	 		--Boss普攻
	 		self:playTLBossArm(e_tlboss_arm.pg, 1, 
	 			--普攻结束回调
 				function( ) 
		 			--播放Boss强攻
		 			self:playTLBossArm(e_tlboss_arm.qg, 1, 
		 				function ( nFrameIndex )
		 					self:playTLBossArm(e_tlboss_arm.dj, -1)
		 				end
		 				,
		 				function( nFrameIndex) --强攻帧回调
			 				--BOSS强攻动作刀光 当boss强攻序列帧播放至  “sj_boss_s_qg_05”帧时，在BOSS的位置上播放：
							if nFrameIndex == 5 then
								self:playTLBossKnifeArm(2)
							elseif nFrameIndex == 6 then
								--第6帧士兵受击
								self:playSoldierHurtArm(pLayer, 2) 
								--第6帧播放士兵死亡
					 			self:playSoldierArm(pLayer, "ts", 1, 
					 				--士兵死亡结束回调
					 				function( )
					 					self:pushIdleSoliders(pLayer)
					 				end,
					 				--士兵死亡帧回调
						 			function( nFrameIndex2 )
						 				--第8帧播放补位
						 				if nFrameIndex2 == 8 then
								 			self:playRowOneSoldierArm(self.pRowTwoLayer)
								 			self.pRowTwoLayer = nil
								 		end
						 			end)
					 			--破地	
					 			self:playBlastArms(nX + 5 , nY - 40)
					 		end
				 		end)
		 		end,
		 		--普功帧回调
		 		function( nFrameIndex ) 
					--BOSS普攻动作刀光 当boss普攻序列帧播放至  “sj_boss_s_pg_04”帧时，在BOSS的位置上播放：
					if  nFrameIndex == 4 then
						self:playTLBossKnifeArm(1)
					elseif nFrameIndex == 6 then --第6帧士兵受击
						self:playSoldierHurtArm(pLayer, 1)
					end
		 		end)
		 	end),
		})
	pLayer:runAction(pAct)
	local pAct = cc.Sequence:create({
		cc.DelayTime:create(0.25),
		cc.CallFunc:create(function ( )
	 		self:playRowTwoSoldierArm()
	 	end),
	 	})
	pLayer:runAction(pAct)
end

--播放第二排士兵动画
function TLBossDot:playRowTwoSoldierArm( )
	local pLayer = self:getIdleSoliders()
	self.pRowTwoLayer = pLayer
	self:playSoldierArm(pLayer, "pb", -1)
	pLayer:setOpacity(0)
	pLayer:runAction(cc.FadeIn:create(0.5))
	local nX, nY = self:getSoldersMidPos("789")
	pLayer:setPosition(nX, nY)
	local nX2, nY2 = self:getSoldersMidPos("456")
	local pAct = cc.Sequence:create({
		cc.MoveTo:create(0.6, cc.p(nX2, nY2)),
		cc.CallFunc:create(function ( )
	 		self:playSoldierArm(pLayer, "dj", -1)
	 	end),
		})
	pLayer:runAction(pAct)
end

--重置士兵
function TLBossDot:resetSoilders(  )
	self.tIdleSoldierRow = {}
	for i=1,#self.tAllSoldierRow do
		local pLayer = self.tAllSoldierRow[i]
		for j=1,#pLayer.tSoldierArms do
			local pArm = pLayer.tSoldierArms[j]
			pArm:stop()
		end
		pLayer:stopAllActions()
		pLayer:setVisible(false)
		table.insert(self.tIdleSoldierRow, pLayer)
	end
end

--播放战斗动画(-个循环)
function TLBossDot:playBeginArms( )
	--播放Boss待机
	self:playTLBossArm(e_tlboss_arm.dj, -1)
	-- 第一排兵(闲置兵)渐变出现 456->123，同时（普通攻击， TLBoss普通攻击），TLBoss重击，重击时后第8帧执行回调（士兵死亡动画，同时
	-- 执行第二排士兵执行第一排士兵的代码，第一排兵标记为闲置兵。TLBoss重击完后自动切换成待机

	-- 第一排的渐变出现的0.25秒执行以下
	-- 第二排兵(闲置兵)渐变出现 789->456，待机动作，执行充当第一排士兵的代码

	--重置士兵
	self:resetSoilders()

	self.nSoldierType = 1
	local pLayer = self:getIdleSoliders()
	local nX, nY = self:getSoldersMidPos("456")
	pLayer:setPosition(nX, nY)
	-- 第一排兵的动作
	self:playRowOneSoldierArm(pLayer, true)
end


--播放结束动画
function TLBossDot:playOverArms( )
	if self.bIsFirstArm then
		self:playTLBossArm(e_tlboss_arm.ts, 1)
		if self.pTLBossArm then
			self.pTLBossArm:stopForImg("sj_boss_s_ts_20")
		end
	else
		--原地爆炸
		self:playBlastArms(UNIT_WIDTH/2 + 15, 30)
		--播放Boss死亡(保留最后一帧)
		self:playTLBossArm(e_tlboss_arm.ts, 1, function()
			--兵种渐隐
			self.tIdleSoldierRow = {}
			for i=1,#self.tAllSoldierRow do
				local pLayer = self.tAllSoldierRow[i]
				for j=1,#pLayer.tSoldierArms do
					local pArm = pLayer.tSoldierArms[j]
					pArm:stop()
				end
				pLayer:stopAllActions()
				pLayer:runAction(cc.FadeOut:create(0.5))
				--全部加入闲置列表
				table.insert(self.tIdleSoldierRow, pLayer)
			end
		end)
	end
end
-------------------------------------------------------Boss及小兵动画

-------------------------------------------------------进场动画
function TLBossDot:setTLBossVisible( bIsShow )
	if self.pLayTLBossArm then
		self.pLayTLBossArm:setVisible(bIsShow)
	end
	if self.pLayTLBossHp then
		self.pLayTLBossHp:setVisible(bIsShow)
	end
end

--进入的光效
function TLBossDot:playEnterEffect( )
	--隐藏之前的
	self:setTLBossVisible(false)
	--
	local nZoder = nEnterZorder
	local nX, nY = self.nBossX + 20, self.nBossY - UNIT_HEIGHT/2 - 50
	--1、地面光效
	-- 第一层：
	-- “rwww_sjbs_dlxg_dl_003”
	-- （缩放值x=364%,y=175%）
	-- 时间    透明度    是否加亮
	-- 0秒       0%        加亮
	-- 0.38秒   100%       加亮
	-- 0.40秒    0%        加亮
	local pImgFloor1 = display.newSprite("#rwww_sjbs_dlxg_dl_003.png")
	pImgFloor1:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	pImgFloor1:setPosition(nX, nY)
	self:addChild(pImgFloor1, nZoder)
	WorldFunc.setCameraMaskForView(pImgFloor1)
	pImgFloor1:setScale(3.64, 1.75)
	pImgFloor1:setOpacity(0)
	local pAct = cc.Sequence:create({
		cc.FadeIn:create(0.38),
		cc.FadeOut:create(0.40 - 0.38),
		cc.CallFunc:create(function ( )
	 		pImgFloor1:removeSelf()
	 	end),
		})
	pImgFloor1:runAction(pAct)

	-- 第二层：
	-- “rwww_sjbs_dlxg_dl_003”
	-- （缩放值x=176%,y=85%）

	-- 时间    透明度    是否加亮
	-- 0秒       0%        加亮
	-- 0.38秒   100%       加亮
	-- 0.60秒    0%        加亮
	local pImgFloor2 = display.newSprite("#rwww_sjbs_dlxg_dl_003.png")
	pImgFloor2:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	pImgFloor2:setPosition(nX, nY)
	self:addChild(pImgFloor2, nZoder)
	WorldFunc.setCameraMaskForView(pImgFloor2)
	pImgFloor2:setScale(1.76, 0.85)
	pImgFloor2:setOpacity(0)
	local pAct = cc.Sequence:create({
		cc.FadeIn:create(0.38),
		cc.FadeOut:create(0.60 - 0.38),
		cc.CallFunc:create(function ( )
	 		pImgFloor2:removeSelf()
	 	end),
		})
	pImgFloor2:runAction(pAct)

	-- 第三层：
	-- “rwww_sjbs_dlxg_dl_003”
	-- （缩放值x=95%,y=45%）

	-- 时间    透明度    是否加亮
	-- 0秒       0%        加亮
	-- 0.38秒   100%       加亮
	-- 0.40秒    0%        加亮
	local pImgFloor3 = display.newSprite("#rwww_sjbs_dlxg_dl_003.png")
	pImgFloor3:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	pImgFloor3:setPosition(nX, nY)
	self:addChild(pImgFloor3, nZoder)
	WorldFunc.setCameraMaskForView(pImgFloor3)
	pImgFloor3:setScale(0.95, 0.45)
	pImgFloor3:setOpacity(0)
	local pAct = cc.Sequence:create({
		cc.FadeIn:create(0.38),
		cc.FadeOut:create(0.40 - 0.38),
		cc.CallFunc:create(function ( )
	 		pImgFloor3:removeSelf()
	 	end),
		})
	pImgFloor3:runAction(pAct)

	-- 2、从上往下掉的光效。
	-- “rwww_sjbs_dlxg_dl_008”
	-- （缩放值x=200%,y=200%）
	-- 时间    透明度        坐标         是否加亮
	-- 0秒      30%     (x=-5，y=1000)      加亮
	-- 0.38秒   100%    (x=-5，y=150)       加亮
	-- 0.45秒   0%      (x=-5，y=150)       加亮
	local pImgFloor4 = display.newSprite("#rwww_sjbs_dlxg_dl_008.png")
	pImgFloor4:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	pImgFloor4:setPosition(nX -5, nY + 1000)
	self:addChild(pImgFloor4, nZoder)
	WorldFunc.setCameraMaskForView(pImgFloor4)
	pImgFloor4:setScale(2)
	pImgFloor4:setOpacity(0.3*255)
	local pAct = cc.Sequence:create({
		cc.Spawn:create({
			cc.FadeIn:create(0.38),
			cc.MoveTo:create(0.38, cc.p(nX -5, nY + 150)),
		}),
		cc.CallFunc:create(function ( )
			--(当“2、从上往下掉的光效。”播放至0.38秒，播放该效果)
			--原地爆炸
	 		self:playBlastArms(nX, nY)
	 		--显示之前隐藏的
			self:setTLBossVisible(true)
	 	end),
		cc.FadeOut:create(0.45 - 0.38),
		cc.CallFunc:create(function ( )
	 		pImgFloor4:removeSelf()
	 	end),
		})
	pImgFloor4:runAction(pAct)
end

--爆破的光效
-- 1、BOSS的上层（层级比BOSS大）光效。
-- 2、BOSS的下层（层级比BOSS小）光效。
function TLBossDot:playBlastArms( nX, nY )
	--1、BOSS的上层光效。
	local nZoder = nBlastZorder

	--特效层(透明度*0.5，主要用于摄像机2的层)
	if not self.pLayBlast then
		self.pLayBlast = MUI.MLayer.new()
		self.pLayBlast:setCameraMask(nCaremaMask,true)
		self.pLayBlast:setOpacity(255*0.5)
		self:addChild(self.pLayBlast, nBlastZorder)
	end

	local tArmData1  =  {
		nFrame = 15, -- 总帧数
		pos = {2, 94}, -- 特效的x,y轴位置（相对中心锚点的偏移）
		fScale = 2.4,-- 初始的缩放值
		nBlend = 1, -- 需要加亮
	  	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
		tActions = {
			{
				nType = 2, -- 透明度
				sImgName = "rwww_sjbs_dlxg_dl_007",
				nSFrame = 1,
				nEFrame = 3,
				tValues = {-- 参数列表
					{255, 150}, -- 开始, 结束透明度值
				}, 
			},
			{
				nType = 2, -- 透明度
				sImgName = "rwww_sjbs_dlxg_dl_007",
				nSFrame = 4,
				nEFrame = 15,
				tValues = {-- 参数列表
					{150, 0}, -- 开始, 结束透明度值
				}, 
			},
		},
	}
	local pArm = MArmatureUtils:createMArmature(
        tArmData1, 
        self.pLayBlast, 
        nZoder, 
        cc.p(nX,nY),
        function ( _pArm )
        	_pArm:removeSelf()
        end, Scene_arm_type.world)
    if pArm then
    	pArm:setCameraMask(nCaremaMask,true)
    	pArm:play(1)
    end

    local tArmData2  = 
	{
		nFrame = 12, -- 总帧数
		pos = {-11, 161}, -- 特效的x,y轴位置（相对中心锚点的偏移）
		fScale = 2,-- 初始的缩放值
		nBlend = 1, -- 需要加亮
	   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
		tActions = {
			 {
				nType = 1, -- 序列帧播放
				sImgName = "rwww_sjbs_lgxg_bk_",
				nSFrame = 1, -- 开始帧下标
				nEFrame = 12, -- 结束帧下标
				tValues = nil, -- 参数列表
			},
		},
	}
	local pArm = MArmatureUtils:createMArmature(
        tArmData2, 
        self.pLayBlast, 
        nZoder, 
        cc.p(nX,nY),
        function ( _pArm )
        	_pArm:removeSelf()
        end, Scene_arm_type.world)
    if pArm then
    	pArm:setCameraMask(nCaremaMask,true)
    	pArm:play(1)
    end

    local nZoder = nFloorEffectZorder
    --2、BOSS的下层光效。
    local tArmData1  =  {
		nFrame = 20, -- 总帧数
		pos = {1, 20}, -- 特效的x,y轴位置（相对中心锚点的偏移）
		fScale = 1.5,-- 初始的缩放值
		nBlend = 0, -- 需要加亮
	  	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
		tActions = {
			{
				nType = 2, -- 透明度
				sImgName = "rwww_sjbs_dlxg_dl_001",
				nSFrame = 1,
				nEFrame = 6,
				tValues = {-- 参数列表
					{100, 255}, -- 开始, 结束透明度值
				}, 
			},
			{
				nType = 2, -- 透明度
				sImgName = "rwww_sjbs_dlxg_dl_001",
				nSFrame = 7,
				nEFrame = 21,
				tValues = {-- 参数列表
					{255, 0}, -- 开始, 结束透明度值
				}, 
			},
		},
	}
	local pArm = MArmatureUtils:createMArmature(
        tArmData1, 
        self, 
        nZoder, 
        cc.p(nX,nY),
        function ( _pArm )
        	_pArm:removeSelf()
        end, Scene_arm_type.world)
    if pArm then
    	WorldFunc.setCameraMaskForView(pArm)
    	pArm:play(1)
    end
    
    local tArmData2  = 
	{
		nFrame = 12, -- 总帧数
		pos = {5, 60}, -- 特效的x,y轴位置（相对中心锚点的偏移）
		fScale = 2,-- 初始的缩放值
		nBlend = 0, -- 需要加亮
	   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
		tActions = {
			 {
				nType = 1, -- 序列帧播放
				sImgName = "rwww_sjbs_d_bk_",
				nSFrame = 1, -- 开始帧下标
				nEFrame = 12, -- 结束帧下标
				tValues = nil, -- 参数列表
			},
		},
	}
	local pArm = MArmatureUtils:createMArmature(
        tArmData2, 
        self, 
        nZoder, 
        cc.p(nX,nY),
        function ( _pArm )
        	_pArm:removeSelf()
        end, Scene_arm_type.world)
    if pArm then
    	WorldFunc.setCameraMaskForView(pArm)
    	pArm:play(1)
    end

    local tArmData3  =  {
		nFrame = 16, -- 总帧数
		pos = {7, 15}, -- 特效的x,y轴位置（相对中心锚点的偏移）
		fScale = 1.5,-- 初始的缩放值
		nBlend = 1, -- 需要加亮
	  	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
		tActions = {
			{
				nType = 2, -- 透明度
				sImgName = "rwww_sjbs_dlxg_dl_002",
				nSFrame = 1,
				nEFrame = 5,
				tValues = {-- 参数列表
					{125, 255}, -- 开始, 结束透明度值
				}, 
			},
			{
				nType = 2, -- 透明度
				sImgName = "rwww_sjbs_dlxg_dl_002",
				nSFrame = 6,
				nEFrame = 16,
				tValues = {-- 参数列表
					{255, 0}, -- 开始, 结束透明度值
				}, 
			},
		},
	}
	local pArm = MArmatureUtils:createMArmature(
        tArmData3, 
        self, 
        nZoder, 
        cc.p(nX,nY),
        function ( _pArm )
        	_pArm:removeSelf()
        end, Scene_arm_type.world)
    if pArm then
    	WorldFunc.setCameraMaskForView(pArm)
    	pArm:play(1)
    end

    local tArmData4  =  {
		nFrame = 16, -- 总帧数
		pos = {3, 8}, -- 特效的x,y轴位置（相对中心锚点的偏移）
		fScale = 1,-- 初始的缩放值
	        fScaleX = 3.38, 
	        fScaleY = 1.87, 
		nBlend = 1, -- 需要加亮
	  	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
		tActions = {
			{
				nType = 2, -- 透明度
				sImgName = "rwww_sjbs_dlxg_dl_004",
				nSFrame = 1,
				nEFrame = 3,
				tValues = {-- 参数列表
					{255, 100}, -- 开始, 结束透明度值
				}, 
			},
			{
				nType = 2, -- 透明度
				sImgName = "rwww_sjbs_dlxg_dl_004",
				nSFrame = 4,
				nEFrame = 14,
				tValues = {-- 参数列表
					{95, 0}, -- 开始, 结束透明度值
				}, 
			},
		},
	}
	local pArm = MArmatureUtils:createMArmature(
        tArmData4, 
        self, 
        nZoder, 
        cc.p(nX,nY),
        function ( _pArm )
        	_pArm:removeSelf()
        end, Scene_arm_type.world)
    if pArm then
    	WorldFunc.setCameraMaskForView(pArm)
    	pArm:play(1)
    end
 	-- local pArm = MArmatureUtils:createMArmature(
  --       tArmData4, 
  --       self.pLayBlast, 
  --       999, 
  --       cc.p(nX,nY),
  --       function ( _pArm )
  --       	_pArm:removeSelf()
  --       end, Scene_arm_type.world)
  --   if pArm then
  --   	pArm:setCameraMask(nCaremaMask,true)
  --   	pArm:play(1)
  --   end


	-- 扩散动画1：
	-- “rwww_sjbs_dlxg_dl_006”
	-- 时间       透明度      缩放值
	-- 0秒         100%      （x=513%,y=215%）
	-- 0.55秒      0%        （x=587%,y=246%）
	local pImgSpread1 = display.newSprite("#rwww_sjbs_dlxg_dl_006.png")
	pImgSpread1:setPosition(nX, nY)
	self:addChild(pImgSpread1, nZoder)
	WorldFunc.setCameraMaskForView(pImgSpread1)
	pImgSpread1:setScale(5.13, 2.15)
	local pAct = cc.Sequence:create({
		cc.Spawn:create({
			cc.FadeOut:create(0.55),
			cc.ScaleTo:create(0.55, 5.87, 2.46),
		}),
		cc.CallFunc:create(function ( )
	 		pImgSpread1:removeSelf()
	 	end),
		})
	pImgSpread1:runAction(pAct)

	-- 扩散动画2：
	-- “rwww_sjbs_dlxg_dl_005”
	-- 时间       透明度      缩放值             是否加亮
	-- 0秒         100%     （x=525%,y=244%）       加亮
	-- 0.23秒      65%      （x=640%,y=300%）       加亮
	-- 0.73秒      0%       （x=771%,y=357%）       加亮
	local pImgSpread2 = display.newSprite("#rwww_sjbs_dlxg_dl_005.png")
	pImgSpread2:setPosition(nX, nY)
	self:addChild(pImgSpread2, nZoder)
	WorldFunc.setCameraMaskForView(pImgSpread2)
	pImgSpread2:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	pImgSpread2:setScale(5.25, 2.44)
	local pAct = cc.Sequence:create({
		cc.Spawn:create({
			cc.FadeTo:create(0.23, 255 * 0.65),
			cc.ScaleTo:create(0.23, 6.4, 3),
		}),
		cc.Spawn:create({
			cc.FadeOut:create(0.73 - 0.23),
			cc.ScaleTo:create(0.73 - 0.23, 7.71, 3.57),
		}),
		cc.CallFunc:create(function ( )
	 		pImgSpread2:removeSelf()
	 	end),
		})
	pImgSpread2:runAction(pAct)

	--播放振屏
	if self:getIsCanPlayShake() then
		sendMsg(ghd_show_tlboss_shake)
	end
end

--一定距离才播放振动
function TLBossDot:getIsCanPlayShake( )
	if Player:getUIHomeLayer():getCurChoice() == 2 then
		if self:isVisible() then
			local nX, nY = self:getPosition()
			local nCX, nCY = self.pWorldLayer:getViewCenterMapPos()
			local nDes = cc.pGetDistance(cc.p(nX, nY), cc.p(nCX, nCY))
			if nDes < 800 then
				return true
			end
		end
	end
	return false
end

--获取是否
function TLBossDot:getIsDeath( )
	return self.bIsDeath
end
-------------------------------------------------------进场动画和打地

-------------------------------------------------------显示或最后名字
--最后名字
function TLBossDot:showLastName( )
	local sName = Player:getTLBossData():getLastName()
	if not sName then
		self:hideLastName()
		return
	end

	if self.pLayLastName then
		self.pLayLastName:setVisible(true)
		self.pTxtLastName:setString(sName)
	else
		local nX, nY = self.nBossX, self.nBossY - UNIT_HEIGHT/2 + 100
		local pNode = display.newNode()
		self.pLayLastName = pNode
		pNode:setPosition(nX, nY)
		self:addChild(pNode, nLastNameZorder)

		local sImg = "#v2_fonts_zuizhongjisha.png"
		local pImgFont = display.newSprite(sImg)
		pImgFont:setOpacity(0.5*255) --因为渲染了两次，所以这里减少一半透明度
		pNode:addChild(pImgFont, 1)
		pImgFont:setPosition(0, 33/2)

		local pImgName = display.newSprite("#v1_img_namebg3.png")
		pImgName:setOpacity(0.5*255) --因为渲染了两次，所以这里减少一半透明度
		pNode:addChild(pImgName, 2)
		pImgName:setPosition(0, - 28/2 - 2)

		local pTxtName = MUI.MLabel.new({
	            text = sName,
	            size = 20,})
		pTxtName:setOpacity(0.5*255) --因为渲染了两次，所以这里减少一半透明度
		pNode:addChild(pTxtName, 3)
		pTxtName:setPosition(0, - 28/2 - 2 - 1)
		self.pTxtLastName = pTxtName

		pNode:setCameraMask(nCaremaMask,true)
	end
end

--隐藏最后的名字
function TLBossDot:hideLastName( )
	if self.pLayLastName then
		self.pLayLastName:setVisible(false)
	end
end
-------------------------------------------------------显示或最后名字

-------------------------------------------------------播放音效
function TLBossDot:playSoundEffect( sKey )
	if self:getIsCanPlayShake() then
		Sounds.playEffect(sKey)
	end
end

-------------------------------------------------------播放音效

-------------------------------------------------------显示或隐藏手指光效
function TLBossDot:updateFinger( )
	local bIsShowed = Player:getTLBossData():getIsShowedFinger()
	if bIsShowed then
		self:hideClickFinger()
	else
		self:showClickFinger()
	end
end

function TLBossDot:showClickFinger( )
	if self.pLayFinger then
		self.pLayFinger:setVisible(true)
	else
		self.pLayFinger = display.newNode()
		self.pLayFinger:setContentSize(100, 100)
		self.pLayFinger:setCascadeOpacityEnabled(true)
		self.pLayFinger:setOpacity(255*0.8)
		self.pLayFinger:setPosition(self.nBossX, self.nBossY)
		self:addChild(self.pLayFinger, nFingerZorder)

		--光圈
		local sName = createAnimationBackName("tx/exportjson/", "sg_jmtx_szdj_sa_001")
	    local pLightArm = ccs.Armature:create(sName)
	    self.pLayFinger:addChild(pLightArm)
	    pLightArm:getAnimation():play("gqks_01", 1)
	    pLightArm:setScale(0.8)

	    --手指
	 	-- 锚点坐标（0，0）
		-- “v1_img_shouzhi.png”
		-- 时间     缩放值    
		-- 0秒      100%
		-- 0.42秒   70%
		-- 1.04秒   100%
		-- 1.29秒   100%
		local pImgFinger = MUI.MImage.new("#v1_img_shouzhi.png")
		pImgFinger:setAnchorPoint(0, 0)
		self.pLayFinger:addChild(pImgFinger, 2)
		local pAct = cc.Sequence:create({
			cc.ScaleTo:create(0.42, 0.7),
			cc.ScaleTo:create(1.04 - 0.42, 1),
			cc.ScaleTo:create(1.29 - 1.04, 1),
		 	})
		pImgFinger:runAction(cc.RepeatForever:create(pAct))

		self.pLayFinger:setCameraMask(nCaremaMask,true)
	end
end

function TLBossDot:hideClickFinger( )
	if self.pLayFinger then
		self.pLayFinger:setVisible(false)
	end
end
-------------------------------------------------------显示或隐藏手指光效


return TLBossDot
