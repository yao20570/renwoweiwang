-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-02-07 17:27:51 星期二
-- Description: 战斗表现层 rootlayer
-----------------------------------------------------

import(".data.FightDatasDefine")
import(".FightUtils")

local MCommonView = require("app.common.MCommonView")
local FightController = require("app.layer.fight.FightController")
local ItemFightHero = require("app.layer.fight.ItemFightHero")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")

local FightLayer = class("FightLayer", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MROOTLAYER)
end)

--_tReport：战报
--_nCallBack：战斗结束回调
--是否可以直接跳过战斗
function FightLayer:ctor( _tReport,_nCallBack, _bCanJumpFight)
	-- body
	self.tt = getSystemTime(false)

	self:myInit()
	__isFightOver = false
	self.tReport = _tReport -- copyTab(tReport[4])
	self.bCanJumpFight = _bCanJumpFight
	self:setFightCallback(_nCallBack)
	--暂停基地或者世界背景音乐
	Sounds.stopMusic(true)
	--添加战斗缓存纹理
	-- addFightTexture(self.tReport, handler(self, self.endTextureCallBack))
	parseView("layout_fight_ver_b", handler(self, self.onParseViewCallback))
end

function FightLayer:myInit(  )
	-- body
	self.pFightController 				= 			nil 			--战斗控制类
	self.tReport 						= 			nil 			--战报
	self.nFightEndCallback 				= 			nil 			--战斗结束回调
	bHasEndCallback 					= 			false  			--是否已经结束回调

	self.tHeroItemL 					= 			nil 			--左边正在战斗的武将
	self.tLHeroLists 					= 			{} 				--左边武将列表
	self.tHeroItemR 					= 			nil 			--右边正在战斗的武将
	self.tRHeroLists 					= 			{} 				--右边武将列表


	self.fItemScaleA 					= 			0.5 			--武将头像缩放值1
	self.fItemScaleB 					= 			0.7 			--武将头像缩放值2
	self.nItemOffset 					= 			15 				--武将item间隔大小


end

--解析布局回调事件
function FightLayer:onParseViewCallback( pView )
	-- body
	pView:setLayoutSize(self:getLayoutSize())
	self:addView(pView, 10)
	centerInView(self, pView)

	Player:initUIFightLayer(self)

	self:onResume()
	self:setupViews()
	
	-- dump(self.tReport,"战报===",10)
	--注册析构方法
	self:setDestroyHandler("FightLayer",handler(self, self.onFightLayerDestroy))
end

function FightLayer:setupViews( )
	-- body
	--注意这里可分帧加载也可以不分帧加载----------------------------
	--内容层
	self.pLayContent 	= 		self:findViewByName("main")
	self.pLayContent:setLayoutSize(self:getLayoutSize())
	self.pLayContent:getParent():requestLayout()
	--顶部层
	self.pLayTop 		=  		self:findViewByName("lay_con_top")
	--中间层
	self.pLayCenter 	=  		self:findViewByName("lay_con_center")
	self.pLayCenter:setLayoutSize(display.width, self.pLayContent:getHeight() - self.pLayTop:getHeight())
	--设置锚点
	self.pLayCenter:setAnchorPoint(cc.p(0.5, 0.5))
	self.pLayCenter:ignoreAnchorPointForPosition(true)
	--对中心点赋值
	__fightCenterX = self.pLayCenter:getWidth() / 2
	__fightCenterY = self.pLayCenter:getHeight() / 2
	--背景图
	self.pImgBg 		= 		MUI.MImage.new("ui/bg_fight/bg_fight.jpg")
	self.pLayCenter:addView(self.pImgBg)
	--设置位置（居中显示）
	self.pImgBg:setPosition(320, self.pLayCenter:getHeight() / 2 + 70)

	--计算位置
	local nGateX = self.pImgBg:getPositionX() + (940 - self.pImgBg:getWidth() / 2)
	local nGateY = self.pImgBg:getPositionY() + (1168 - self.pImgBg:getHeight() / 2)
	self.pImgGate:setPosition(nGateX, nGateY)
	self.pLayCenter:addView(self.pImgGate,10)
	--初始化各种参数值
	--初始化缩放，旋转，位移值
	self.pLayCenter:setScale(__fSScale)
	self.pLayCenter:setRotation(-2)
	self.pLayCenter:setPositionY(100)
	--注意这里可分帧加载也可以不分帧加载----------------------------


	-- 分帧执行实际的加载刷新
	gRefreshViewsAsync(self, 2, function ( _bEnd, _index )
		if(_index == 1) then
			--设置位置（置顶）
			self.pLayTop:setPositionY(self:getHeight() - self.pLayTop:getHeight())
			--底部层
			self.pLayBottom 	=  		self:findViewByName("lay_con_bottom")
			--左边国家
			self.pImgCL 		= 		MUI.MImage.new(WorldFunc.getCountryFlagImg(self.tReport.oc))
			self.pImgCL:setPosition(25, 130)
			self.pLayTop:addView(self.pImgCL)
			--左边玩家名字
			self.pLbPNameL 		= 		MUI.MLabel.new({text = self.tReport.on,size = 20})
			setTextCCColor(self.pLbPNameL, _cc.pwhite)
			self.pLbPNameL:setPosition(140, 132)
			self.pLayTop:addView(self.pLbPNameL)

			--右边国家
			self.pImgCR 		= 		MUI.MImage.new(WorldFunc.getCountryFlagImg(self.tReport.dc))
			self.pImgCR:setPosition(615, 130)
			self.pLayTop:addView(self.pImgCR)
			--右边玩家名字
			self.pLbPNameR 		= 		MUI.MLabel.new({text = self.tReport.dn,size = 20})
			setTextCCColor(self.pLbPNameR, _cc.pwhite)
			self.pLbPNameR:setPosition(500, 132)
			self.pLayTop:addView(self.pLbPNameR)

			--武将列表背景框
			self.pLayTopOfB 	= 		MUI.MLayer.new()
			self.pLayTopOfB:setLayoutSize(640, 112)
			self.pLayTopOfB:setBackgroundImage("#v1_bg_honglanquyu.png",{scale9 = true,capInsets=cc.rect(320,32, 1, 1)})
			self.pLayTop:addView(self.pLayTopOfB)
			--左边血条
			self.pLayBgBarL 	= 		MUI.MLayer.new() 
			self.pLayBgBarL:setLayoutSize(188, 18)
			self.pLayBgBarL:setBackgroundImage("ui/bar/v1_bar_b1.png",{scale9 = true,capInsets=cc.rect(45,9, 1, 1)})
			self.pLayBgBarL:setPosition(10, 5)
			self.pLayTopOfB:addView(self.pLayBgBarL)
			self.pBloodBarL     =       MCommonProgressBar.new({name = "fight_bar_blood",bar = "v1_bar_yellow_1.png",barWidth = 184, barHeight = 14, dir = 1})
			self.pBloodBarL:setPercent(100)
			self.pLayBgBarL:addView(self.pBloodBarL)
			centerInView(self.pLayBgBarL,self.pBloodBarL)
			self.pBloodBarL:setPositionY(self.pLayBgBarL:getHeight() / 2 + 1)
			--整块掉血进度条
			-- self.pBloodBarLM     =       MCommonProgressBar.new({name = "fight_bar_blood_l", bar = "v1_bar_green_3.png",barWidth = 184, barHeight = 14, dir = 1})
			-- self.pBloodBarLM:setPercent(100)
			-- self.pLayBgBarL:addView(self.pBloodBarLM,10)
			-- centerInView(self.pLayBgBarL,self.pBloodBarLM)
			-- self.pBloodBarLM:setPositionY(self.pLayBgBarL:getHeight() / 2 + 1)
			--右边血条
			self.pLayBgBarR 	= 		MUI.MLayer.new() 
			self.pLayBgBarR:setLayoutSize(188, 18)
			self.pLayBgBarR:setBackgroundImage("ui/bar/v1_bar_b1.png",{scale9 = true,capInsets=cc.rect(45,9, 1, 1)})
			self.pLayBgBarR:setPosition(442, 5)
			self.pLayTopOfB:addView(self.pLayBgBarR)
			self.pBloodBarR     =       MCommonProgressBar.new({name = "fight_bar_blood",bar = "v1_bar_yellow_1.png",barWidth = 184, barHeight = 14})
			self.pBloodBarR:setPercent(100)
			self.pLayBgBarR:addView(self.pBloodBarR)
			centerInView(self.pLayBgBarR,self.pBloodBarR)
			self.pBloodBarR:setPositionY(self.pLayBgBarR:getHeight() / 2 + 1)
			--整块掉血进度条
			-- self.pBloodBarRM     =       MCommonProgressBar.new({name = "fight_bar_blood_r", bar = "v1_bar_yellow_13.png",barWidth = 184, barHeight = 14})
			-- self.pBloodBarRM:setPercent(100)
			-- self.pLayBgBarR:addView(self.pBloodBarRM)
			-- centerInView(self.pLayBgBarR,self.pBloodBarRM)
			-- self.pBloodBarRM:setPositionY(self.pLayBgBarR:getHeight() / 2 + 1)

			--左边武将名字等级
			self.pLbHNameL 		= 		MUI.MLabel.new({text = "",size = 18,anchorpoint = cc.p(1, 0.5)})
			self.pLbHNameL:setPosition(313, 15)
			self.pLayTopOfB:addView(self.pLbHNameL)
			self.pLbHLvL 		= 		MUI.MLabel.new({text = "",size = 18,anchorpoint = cc.p(0, 0.5)})
			self.pLbHLvL:setPosition(203, 15)
			self.pLayTopOfB:addView(self.pLbHLvL)
			setTextCCColor( self.pLbHLvL, _cc.blue)

			--右边武将名字等级
			self.pLbHNameR 		= 		MUI.MLabel.new({text = "",size = 18,anchorpoint = cc.p(0, 0.5)})
			self.pLbHNameR:setPosition(327, 15)
			self.pLayTopOfB:addView(self.pLbHNameR)
			self.pLbHLvR 		= 		MUI.MLabel.new({text = "",size = 18,anchorpoint = cc.p(1, 0.5)})
			self.pLbHLvR:setPosition(438, 15)
			self.pLayTopOfB:addView(self.pLbHLvR)
			setTextCCColor( self.pLbHLvR, _cc.blue)
		elseif(_index == 2) then
			--武将列表存放层(左)
			self.pLayHeroListsL = 		MUI.MLayer.new() 
			self.pLayHeroListsL:setLayoutSize(300, 80)
			self.pLayHeroListsL:setPosition(0, 25)
			self.pLayTopOfB:addView(self.pLayHeroListsL)
			--武将列表存放层(右)
			self.pLayHeroListsR = 		MUI.MLayer.new() 
			self.pLayHeroListsR:setLayoutSize(300, 80)
			self.pLayHeroListsR:setPosition(340, 25)
			self.pLayTopOfB:addView(self.pLayHeroListsR)
			--兵种克制箭头
			self.pImgArrow 		= 		MUI.MImage.new("#v1_img_lanjiantou.png")
			self.pImgArrow:setPosition(320, 65)
			self.pImgArrow:setScale(0.5)
			self.pLayTopOfB:addView(self.pImgArrow)
			--战斗类型
			self.pLbTitle 		= 		MUI.MLabel.new({text = getFightType(self.tReport.t),size = 32})
			setTextCCColor(self.pLbTitle, _cc.white)
			self.pLbTitle:setPosition(320, 132)
			self.pLayTop:addView(self.pLbTitle)
			--跳过按钮
			self.pLayFinish 	= 		self:findViewByName("lay_btn_finish")
			self.pBtnFinish = getCommonButtonOfContainer(self.pLayFinish,TypeCommonBtn.L_YELLOW,getConvertedStr(1,10213))
			--点击事件
			self.pBtnFinish:onCommonBtnClicked(handler(self, self.onFinishClicked))
			--跳过战斗按钮提示语
			self.pLbJumpTips 	=		self:findViewByName("lb_jump_tips")
			setTextCCColor(self.pLbJumpTips,_cc.yellow)
			self.pLbJumpTips:enableOutline(cc.c4b(0, 0, 0, 255),2)
			self.pLbJumpTips:setString(getConvertedStr(1, 10267))
			--默认隐藏
			self:setBtnFastVisible(false)

			--战斗展示层赋值
			__showFightLayer = self.pLayCenter
			--保存战斗顶部高度
			__nFightLayerTopH = self.pLayTop:getHeight()
		end 
		if(_bEnd) then
			if not self.pFightController then
				self.pFightController = FightController.new(self,self.pLayCenter,copyTab(self.tReport))
				 -- 加载战斗背景音乐
    			Sounds.preloadMusic(Sounds.Music.battle)
				if self.nCallShowFightLayer then
					self:nCallShowFightLayer()
				end
			end
		end
	end)

end


function FightLayer:setShowFightLayerCallBack( _nHnalder )
	-- body
	self.nCallShowFightLayer = _nHnalder
end

--纹理加载完成回调
function FightLayer:endTextureCallBack(  )
	-- body

end

-- 析构方法
function FightLayer:onFightLayerDestroy(  )
	self:onPause()
	--发送消息开启背景音乐（世界或者基地）
	sendMsg(ghd_open_worldorbase_music_msg)
	Player:releaseUIFightLayer()
	__showFightLayer = nil

	if self.nAddHeroLcheduler ~= nil then
        MUI.scheduler.unscheduleGlobal(self.nAddHeroLcheduler)
        self.nAddHeroLcheduler = nil
	end
	if self.nAddHeroRcheduler ~= nil then
        MUI.scheduler.unscheduleGlobal(self.nAddHeroRcheduler)
        self.nAddHeroRcheduler = nil
	end

	--释放战斗缓存纹理
	-- releaseFightTexture()
	--清除为使用的纹理
	-- removeUnusedTextures()
end

--跳过点击事件
function FightLayer:onFinishClicked( pView )
	-- body
	local nCanSkip = getAvatarVIPByLevel(Player:getPlayerInfo().nVip).canskip
	if nCanSkip == 1 or self.bCanJumpFight then
		self:onFightEndCallback()
	else
		TOAST(getTipsByIndex(539))
	end
end

-- 注册消息
function FightLayer:regMsgs( )
	-- body
	-- 注册结束消息
	regMsg(self, ghd_fight_play_end, handler(self, self.onFightEndCallback))
	-- 注册关闭战斗界面消息
	regMsg(self, ghd_fight_close, handler(self, self.onCloseFight))
	-- 注册整块掉血的消息
	-- regMsg(self, ghd_fight_show_blood_onmain_block, handler(self, self.onShowBloodDrop))
end

-- 注销消息
function FightLayer:unregMsgs(  )
	-- body
	-- 注销结束消息
	unregMsg(self, ghd_fight_play_end)
	-- 注销关闭战斗界面消息
	unregMsg(self, ghd_fight_close)
	-- 注销整块掉血消息
	-- unregMsg(self, ghd_fight_show_blood_onmain_block)
	
end

--暂停方法
function FightLayer:onPause( )
	-- body
	self:unregMsgs()
	if not gIsNull(self.pFightController) then
		self.pFightController:onPause()
	end
end

--继续方法
function FightLayer:onResume( )
	-- body
	self:regMsgs()
end

-- 设置战斗结束回调
function FightLayer:setFightCallback( _nCallback )
	self.nFightEndCallback = _nCallback
end

-- 战斗结束回调
function FightLayer:onFightEndCallback(  )
	-- 战斗结束回调
	if (self.nFightEndCallback and not bHasEndCallback) then
		bHasEndCallback = true -- 已经回调
		self.nFightEndCallback()
		self.pFightController:stopAllFightActions()
		--停止技能表现相关动画
		self.pFightController:removeCallSkillArm()
		self.pFightController:removeAllSkillArms()
		--停止播放战斗背景音乐
		Sounds.stopMusic(true)
	end
end

-- 关闭战斗界面消息回调
function FightLayer:onCloseFight(  )
	-- body
	--已经在战斗结果对话框做数据的回收了，这里注释一下，以后有需要可以在这里添加
	-- nCollectCnt = 3 
	RootLayerHelper:finishRootLayer(self)
end

--血量变化
function FightLayer:onBloodChangeOnTop( pMsgObj  )
	-- body
	if pMsgObj then
		local nDir = pMsgObj.nDir
		local nCur = pMsgObj.nCur
		local nAll = pMsgObj.nAll

		if nCur and nAll then
			if nCur < 0 then
				nCur = 0
			end
			if nDir == 1 then
				self.pBloodBarL:setProgressBarText(math.ceil(nCur))
				self.pBloodBarL:setPercent(nCur / nAll * 100)
			else
				self.pBloodBarR:setProgressBarText(math.ceil(nCur))
				self.pBloodBarR:setPercent(nCur / nAll * 100)
			end
		end
		
	end
end

--整块血量变化
function FightLayer:onShowBloodDrop( pMsgName, pMsgObj  )
	-- body
	if pMsgObj then
		local nDir = pMsgObj.nDir
		local nDrop = pMsgObj.nDrop
		local nAll = pMsgObj.nAll
		local nSub = math.ceil(nDrop / nAll * 100)
		if nDrop and nAll then
			if nDir == 1 then
				local nCur = self.pBloodBarLM:getPercent()
				local nRst = (nCur - nSub)
				self.pBloodBarLM:setPercent(nRst)
			else
				local nCur = self.pBloodBarRM:getPercent()
				local nRst = (nCur - nSub)
				self.pBloodBarRM:setPercent(nRst)
			end
		end
		
	end
end

--初始化武将信息
--_heroLists：武将信息
function FightLayer:initAllHeroMsgs( _heroLists )
	-- body
	if _heroLists and table.nums(_heroLists) == 2 then
		local tLeftHeros = _heroLists[1] --左边
		local tRightHeros = _heroLists[2] --右边
		if tLeftHeros then
			for k, v in pairs (tLeftHeros) do
				local pItemHero = ItemFightHero.new()
				local nX = 0
				local nY = 0
				if k == 1 then
					self:setCurHeroInfo(1,v)
					pItemHero:setNameVisible(false)
					nY = -28
					pItemHero:setScale(self.fItemScaleB)
					nX = self.pLayHeroListsL:getWidth() - pItemHero:getWidth()*pItemHero:getScale()
					self.tHeroItemL = pItemHero --对正在战斗的item赋值
				else
					nY = 0
					pItemHero:setScale(self.fItemScaleA)
	    			nX = self.pLayHeroListsL:getWidth() 
	    			 	- (k - 1) * pItemHero:getWidth()*pItemHero:getScale() - (k-1) * self.nItemOffset
	    			 	- pItemHero:getWidth()*self.fItemScaleB
				end
				--保存在列表中
				self.tLHeroLists[k] = pItemHero
				pItemHero:setCurData(v.tHeroInfo)
				pItemHero:setPosition(nX, nY)
				self.pLayHeroListsL:addView(pItemHero)
			end
			self.bLoadHerosLEnd = true
		end
		if tRightHeros then
			for k, v in pairs (tRightHeros) do
				local pItemHero = ItemFightHero.new()
				local nX = 0
				local nY = 0
				if k == 1 then
					self:setCurHeroInfo(2,v)
					pItemHero:setNameVisible(false)
					nY = -28
					pItemHero:setScale(self.fItemScaleB)
					nX = 0
					self.tHeroItemR = pItemHero --对正在战斗的item赋值
				else
					nY = 0
					pItemHero:setScale(self.fItemScaleA)
					nX = (k - 2) * pItemHero:getWidth()*pItemHero:getScale() + (k-1) * self.nItemOffset
					 	+ pItemHero:getWidth()*self.fItemScaleB
				end
				--保存在列表中
				self.tRHeroLists[k] = pItemHero
				pItemHero:setCurData(v.tHeroInfo)
				pItemHero:setPosition(nX, nY)
				self.pLayHeroListsR:addView(pItemHero)
			end
			self.bLoadHerosREnd = true
		end

		--设置克制关系
		self:setArrowState(true)
		
	end
end


--初始化武将信息
--_heroLists：武将信息
function FightLayer:initAllHeroMsgs22( _heroLists )
	-- body
	if _heroLists and table.nums(_heroLists) == 2 then
		local tLeftHeros = _heroLists[1] --左边
		local tRightHeros = _heroLists[2] --右边
		if tLeftHeros then
			self:scheduleAddHeroListsL(tLeftHeros,function (  )
				-- body
				self.bLoadHerosLEnd = true
				--设置克制关系
				self:setArrowState(true)
			end)
		end
		if tRightHeros then
			self:scheduleAddHeroListsR(tRightHeros,function (  )
				-- body
				self.bLoadHerosREnd = true
				--设置克制关系
				self:setArrowState(true)
			end)
		end
	end
end

--设置克制关系
function FightLayer:setArrowState( bFirst )
	-- body
	if self.bLoadHerosLEnd and self.bLoadHerosREnd then
		local pLHData = self.tHeroItemL:getCurData()
		local pRHData = self.tHeroItemR:getCurData()
		if pLHData and pRHData then
			local nRestrainState = getHeroRestrainState(pLHData.nKind, pRHData.nKind)
			if nRestrainState == 0 then --不克制
				self.pImgArrow:setCurrentImage("#v1_img_bukezhi.png")
			elseif nRestrainState == 1 then --克制
				self.pImgArrow:setCurrentImage("#v1_img_lanjiantou.png")
			elseif nRestrainState == 2 then --被克制
				self.pImgArrow:setCurrentImage("#v1_img_hongjiantou.png")
			end
		end
	end

	if bFirst then
		--获得战斗控制类
		-- if not self.pFightController then
		-- 	self.pFightController = FightController.new(self,self.pLayCenter,copyTab(self.tReport))
		-- end
		--添加战斗缓存纹理
		-- addFightTexture(self.tReport, handler(self, self.endTextureCallBack))
	end
end

--_tHeroLists：左边数据
--_handler：回调方法
function FightLayer:scheduleAddHeroListsL(_tHeroLists ,_handler )
    local nIndex = 1
    local nSize = table.nums(_tHeroLists)
    self.nAddHeroLcheduler = MUI.scheduler.scheduleUpdateGlobal(function (  )
    	if _tHeroLists[nIndex] then
    		local pItemHero = ItemFightHero.new()
    		local nX = 0
    		local nY = 0
    		if nIndex == 1 then
    			self:setCurHeroInfo(1,_tHeroLists[nIndex])
    			pItemHero:setNameVisible(false)
    			nY = -28
    			pItemHero:setScale(self.fItemScaleB)
    			nX = self.pLayHeroListsL:getWidth() - pItemHero:getWidth()*pItemHero:getScale()
    			self.tHeroItemL = pItemHero --对正在战斗的item赋值
    		else
    			nY = 0
    			pItemHero:setScale(self.fItemScaleA)
    			nX = self.pLayHeroListsL:getWidth() 
    			 	- (nIndex - 1) * pItemHero:getWidth()*pItemHero:getScale() - (nIndex-1) * self.nItemOffset
    			 	- pItemHero:getWidth()*self.fItemScaleB
    		end
    		--保存在列表中
    		self.tLHeroLists[nIndex] = pItemHero
    		pItemHero:setCurData(_tHeroLists[nIndex].tHeroInfo)
    		pItemHero:setPosition(nX, nY)
    		self.pLayHeroListsL:addView(pItemHero)
    		nIndex = nIndex + 1
			if self ~= nil and self.nAddHeroLcheduler ~= nil and nIndex > nSize then
		        MUI.scheduler.unscheduleGlobal(self.nAddHeroLcheduler)
		        self.nAddHeroLcheduler = nil
		        if _handler then
		        	_handler()
		        end
			end
    	else
			if self ~= nil and self.nAddHeroLcheduler ~= nil then
		        MUI.scheduler.unscheduleGlobal(self.nAddHeroLcheduler)
		        self.nAddHeroLcheduler = nil
		        if _handler then
		        	_handler()
		        end
			end
    	end
    end)
end

--_tHeroLists：左边数据
--_handler：回调方法
function FightLayer:scheduleAddHeroListsR(_tHeroLists ,_handler )
    local nIndex = 1
    local nSize = table.nums(_tHeroLists)
    self.nAddHeroRcheduler = MUI.scheduler.scheduleUpdateGlobal(function (  )
    	if _tHeroLists[nIndex] then
    		local pItemHero = ItemFightHero.new()
    		local nX = 0
    		local nY = 0
    		if nIndex == 1 then
    			self:setCurHeroInfo(2,_tHeroLists[nIndex])
    			pItemHero:setNameVisible(false)
    			nY = -28
				pItemHero:setScale(self.fItemScaleB)
				nX = 0
				self.tHeroItemR = pItemHero --对正在战斗的item赋值
    		else
    			nY = 0
				pItemHero:setScale(self.fItemScaleA)
				nX = (nIndex - 2) * pItemHero:getWidth()*pItemHero:getScale() + (nIndex-1) * self.nItemOffset
				 	+ pItemHero:getWidth()*self.fItemScaleB
    		end
    		--保存在列表中
    		self.tRHeroLists[nIndex] = pItemHero
    		pItemHero:setCurData(_tHeroLists[nIndex].tHeroInfo)
    		pItemHero:setPosition(nX, nY)
    		self.pLayHeroListsR:addView(pItemHero)
    		nIndex = nIndex + 1
			if self ~= nil and self.nAddHeroRcheduler ~= nil and nIndex > nSize then
		        MUI.scheduler.unscheduleGlobal(self.nAddHeroRcheduler)
		        self.nAddHeroRcheduler = nil
		        if _handler then
		        	_handler()
		        end
			end
    	else
			if self ~= nil and self.nAddHeroRcheduler ~= nil then
		        MUI.scheduler.unscheduleGlobal(self.nAddHeroRcheduler)
		        self.nAddHeroRcheduler = nil
		        if _handler then
		        	_handler()
		        end
			end
    	end
    end)
end

--设置武将信息
--_nDir：方向 1：下方 2：上方
--_tInfo：武将信息
--_nIndex：武将下标
--注意：能够调到该方法说明存在下一个武将
function FightLayer:setCurHeroInfo( _nDir, _tInfo, _nIndex)
	-- body
	local sName = ""
	local nQuality = 1
	if _tInfo.tHeroInfo then
		sName = _tInfo.tHeroInfo.sName
		nQuality = _tInfo.tHeroInfo.nQuality
	end
	if _nDir == 1 then
		self.pLbHNameL:setString(sName)
		setLbTextColorByQuality(self.pLbHNameL,nQuality)
		self.pLbHLvL:setString(getLvString( _tInfo.lvl , false))
		self.pBloodBarL:setProgressBarText(math.ceil(_tInfo.trp))
	elseif _nDir == 2 then
		self.pLbHNameR:setString(sName)
		setLbTextColorByQuality(self.pLbHNameR,nQuality)
		self.pLbHLvR:setString(getLvString( _tInfo.lvl , false))
		self.pBloodBarR:setProgressBarText(math.ceil(_tInfo.trp))
	end
	if _nIndex then
		self:showHeroAction(_nDir,_nIndex)
	end
end

--武将列表表现动作
function FightLayer:showHeroAction( _nDir, _nIndex )
	-- body
	local tLists = nil
	if _nDir == 1 then
		tLists = self.tLHeroLists
	elseif _nDir == 2 then
		tLists = self.tRHeroLists
	end

	--判断是否有下一个武将
	local tNextHItem = tLists[_nIndex]
	if tNextHItem then
		tNextHItem:setNameVisible(false)
		--移动
		local tPos = cc.p(0,0)
		if _nDir == 1 then
			tPos = cc.p(self.pLayHeroListsL:getWidth() - tNextHItem:getWidth()*self.fItemScaleB,-30)
		elseif _nDir == 2 then
			tPos = cc.p(0,-28)
		end 
		local actionMoveTo = cc.MoveTo:create(0.3, tPos)
		--缩放
		local actionScaleTo = cc.ScaleTo:create(0.3, self.fItemScaleB)
		--回调
		local fCallback = cc.CallFunc:create(function (  )
			-- body
			if _nDir == 1 then
				self.tHeroItemL = tNextHItem
				-- self.pBloodBarLM:setPercent(100)
			elseif _nDir == 2 then
				self.tHeroItemR = tNextHItem
				-- self.pBloodBarRM:setPercent(100)
			end
			--这里赋值后 应该就是最新战斗的两个将领了
			--设置克制关系
			self:setArrowState()
		end)
		local actions = cc.Spawn:create(actionMoveTo,actionScaleTo)
		tNextHItem:runAction(cc.Sequence:create(actions,fCallback))
	end
	--集体移动
	local nPreIndex = _nIndex - 1
	for k, v in pairs (tLists) do
		if k ~= _nIndex and (k ~= nPreIndex) then
			local nX = v:getWidth() * self.fItemScaleA + self.nItemOffset
			if _nDir == 1 then
				nX = -nX
			end
			local actionMoveBy = cc.MoveBy:create(0.3, cc.p(-nX,0))
			local actions = cc.Sequence:create(actionMoveBy)
			v:runAction(actions)
		end
	end
	--当前正在表现的武将(消失)
	self:fadeOutItemHeroByDir(_nDir,false)
end

--武将消失
--_bEnd：是否结束
function FightLayer:fadeOutItemHeroByDir( _nDir, _bEnd )
	-- body
	if _nDir == 1 then
		self:fadeOutCurItemHero(_nDir, self.tHeroItemL,_bEnd)
		if _bEnd then --置灰
			-- self.pLbHNameL:setToGray(true)
			-- self.pLbHLvL:setToGray(true)
		end
	elseif _nDir == 2 then
		self:fadeOutCurItemHero(_nDir, self.tHeroItemR,_bEnd)
		if _bEnd then --置灰
			-- self.pLbHNameR:setToGray(true)
			-- self.pLbHLvR:setToGray(true)
		end
	end
end

--当前武将消失
function FightLayer:fadeOutCurItemHero(_nDir, _pItemHero, _bEnd )
	-- body
	if _pItemHero then
		-- body
		if not _bEnd then --如果是最后一个武将了
			local actionFadeOut = cc.FadeOut:create(0.15)
			local actionFadeIn = cc.FadeIn:create(0.2)
			--回调
			local fCallback = cc.CallFunc:create(function (  )
				-- body
				-- 不移除掉死亡的武将，做置灰效果
				-- _pItemHero:removeSelf()
				-- _pItemHero = nil
				if not _bEnd then
					if _nDir == 1 then --左边
						local nSize = table.nums(self.tLHeroLists) 
						_pItemHero:setScale(self.fItemScaleA) --重置缩放值
						local nX = self.pLayHeroListsL:getWidth() 
							- (nSize - 1) * _pItemHero:getWidth()*_pItemHero:getScale() - (nSize-1) * self.nItemOffset
							- _pItemHero:getWidth()*self.fItemScaleB
						local nY = 0
						_pItemHero:setPosition(nX, nY)
					elseif _nDir == 2 then --右边
						local nSize = table.nums(self.tRHeroLists) 
						_pItemHero:setScale(self.fItemScaleA)
						local nX = (nSize - 2) * _pItemHero:getWidth()*_pItemHero:getScale() + (nSize-1) * self.nItemOffset
						 	+ _pItemHero:getWidth()*self.fItemScaleB
						 local nY = 0
						 _pItemHero:setPosition(nX, nY)
					end
					--展示名字
					_pItemHero:setNameVisible(true)
					_pItemHero:setToGray(true)
					--移除特效品质框(目前武将没有品质特效)
					-- if _pItemHero.pIconHero and _pItemHero.pIconHero.removeQualityTx then
					-- 	_pItemHero.pIconHero:removeQualityTx()
					-- end
				end
				
			end)
			local actions = cc.Sequence:create(actionFadeOut,actionFadeIn,fCallback)
			_pItemHero:runAction(actions)
		else
			--直接置灰
			_pItemHero:setToGray(true)
			--移除特效品质框
			if _pItemHero.pIconHero and _pItemHero.pIconHero.removeQualityTx then
				_pItemHero.pIconHero:removeQualityTx()
			end
		end
	end
end

--设置跳过按钮是否展示
function FightLayer:setBtnFastVisible( bVisible )
	-- body
	self.pLayFinish:setVisible(bVisible)
	if bVisible then
		--跳过按钮提示
		local nCanSkip = getAvatarVIPByLevel(Player:getPlayerInfo().nVip).canskip
		if nCanSkip == 1 or self.bCanJumpFight then
			self.pLbJumpTips:setVisible(false)
		else
			self.pLbJumpTips:setVisible(true)
		end
	else
		self.pLbJumpTips:setVisible(bVisible)
	end

	
end

return FightLayer