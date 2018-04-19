-- KillHeroFightLayer.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2018-3-14 14:17:06 星期三
-- Description: 过关斩将 闯关分页
-----------------------------------------------------
local HomeXLBTipsLayer = require("app.layer.home.HomeXLBTipsLayer")
local FightSecBloodLayer = require("app.layer.fightsec.FightSecBloodLayer")
local MCommonView = require("app.common.MCommonView")
local DlgAlert = require("app.common.dialog.DlgAlert")
local KillHeroFightLayer = class("KillHeroFightLayer", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

local nSoldierZorder = 10 -- 士兵层次
local nWJcircle = 15
local nWJZorder = 20 --武将层次
local nHurtZorder = 30 --受击层次

local tPosEnemy = {
	cc.p(160, 470),
	cc.p(236, 432),
	cc.p(360, 370),
	cc.p(436, 332),
}

local tPosWJEnemy = cc.p(220, 315)
local tPosWJMy = cc.p(140, 312)
local tPosWJFight = cc.p(195, 337)
local tPassPos = cc.p(400, 433)
local tPosWJStart = cc.p(-40, 234)
local tPosDeadPos = cc.p(240, 335)

function KillHeroFightLayer:ctor(_tSize)
	-- body
	self:setContentSize(_tSize)
	self:myInit()
	--新手教程
	sendMsg(ghd_guide_finger_show_or_hide, true)
	parseView("lay_fight_main", handler(self, self.onParseViewCallback))
end
--解析布局回调事件
function KillHeroFightLayer:onParseViewCallback( pView )
	-- body
	self:addView(pView)
	self:setupViews()	
	self:onResume()
	 --注册析构方法
	self:setDestroyHandler("KillHeroFightLayer",handler(self, self.onDestroy))
end

-- --初始化参数
function KillHeroFightLayer:myInit()
	self.pData = nil --对应关卡信息
	self.pEnemies = {} --敌将的左边兵力
	self.pMyWJLayer = nil
	self.pMyWJ = nil --己方武将
	self.pEnemyWJLayer = nil
	self.pEnemyWJ = nil --敌方武将
	self.nType = 1 --1：步兵  2：骑兵  3：弓兵
	self.tCircleArms = nil --底部光圈
	self.nLastOid = nil --记录的上一关
	self.sPassTalk = nil --过关对话框
	self.tRelativetPos = {
			tPosEnemy[1],
			tPosEnemy[2],
			tPosEnemy[3],
			tPosEnemy[4],
			tPosWJEnemy
		}
end

--初始化控件
function KillHeroFightLayer:setupViews( )
	-- body
	--重置按钮
	self.pLayBot 		= 		self:findViewByName("lay_bot")
	local pLayBtnLeft 	= 		self:findViewByName("lay_btn")
	self.pBotBtn = getCommonButtonOfContainer(pLayBtnLeft,TypeCommonBtn.L_BLUE,getConvertedStr(7, 10374))
    --重置按钮点击事件
	self.pBotBtn:onCommonBtnClicked(handler(self, self.onBotBtnClicked))
	--重置按钮上的扩展文字
	self.pBtnExText = MUI.MLabel.new({text = "", size = 20})
	setTextCCColor(self.pBtnExText, _cc.white)
	self.pLayBot:addView(self.pBtnExText, 9)
	self.pBtnExText:setPosition(pLayBtnLeft:getPositionX()+pLayBtnLeft:getWidth()/2, 
		pLayBtnLeft:getPositionY()+pLayBtnLeft:getHeight()+7)

	--战斗按钮
	local pLayBtnFight 	= 		self:findViewByName("lay_btn_fight")
	self.pBtnFight = getCommonButtonOfContainer(pLayBtnFight,TypeCommonBtn.L_YELLOW,getConvertedStr(7, 10386))
    --战斗按钮点击事件
	self.pBtnFight:onCommonBtnClicked(handler(self, self.onBtnFightClicked))

	--战斗层
	self.pLayFight 	= 		self:findViewByName("lay_fight")

	self.pImgFont 	= 		self:findViewByName("img_font")
	--关卡艺术字
	self.pLbLevel1 = MUI.MLabelAtlas.new({text="1", 
	    png="ui/atlas/v2_bg_guoguan1dao10.png", pngw=34, pngh=39, scm=49})
	self.pLbLevel1:setPosition(self.pImgFont:getPosition())
	self.pLbLevel1:setRotation(25)
	self.pLayFight:addView(self.pLbLevel1, 5)
	self.pLbLevel2 = MUI.MLabelAtlas.new({text="", 
	    png="ui/atlas/v2_bg_guoguan1dao10.png", pngw=34, pngh=39, scm=49})
	self.pLbLevel2:setPosition(self.pImgFont:getPosition())
	self.pLbLevel2:setRotation(25)
	self.pLayFight:addView(self.pLbLevel2, 5)

	self.pLyShow = self:findViewByName("lay_show")  --动画展示层 

	-- MUI.MLayer.new()
	-- 战斗前预加载的图片
	local tPreLoadFightTx = {}
	tPreLoadFightTx[1] = "tx/fight/p1_fight_wj_circle"
	addTextureToCache(tPreLoadFightTx[1], 1)	
end

-- 修改控件内容或者是刷新控件数据
function KillHeroFightLayer:updateViews( _isReset )
	-- body
	local pData = Player:getPassKillHeroData()
	if not pData then
		return
	end
	--刷新重置次数
	local nLeftReset = pData:getLeftVipResetTimes()
	self.pBtnExText:setString(string.format(getConvertedStr(7, 10375), nLeftReset))
	--没死的武将
	local tNotDeadList = pData:getNotDeadHeroList()
	if table.nums(tNotDeadList) == 0 then
		self.pBtnFight:setBtnEnable(false)
	else
		self.pBtnFight:setBtnEnable(true)
	end
	--第几关
	if pData.pOutpostVo and pData.pOutpostVo.nOid then
		self.nOid = pData.pOutpostVo.nOid
		--没有通关动画
		if (self.nLastOid == nil or self.nLastOid == self.nOid) and not pData.nChange then
			--设置关卡
			self:setLevel()

			local tEnemy = pData.pOutpostVo:getEnemy() --敌方部队
			if tEnemy then
				if not pData:isPassAllOid() then
					if tEnemy and tEnemy[1] then
						--重置
						if _isReset then
							self:onResetShow()
						elseif not (self.blackFullScene and self.blackFullScene:getOpacity() >  0) then
							self:onEnterWJ()
							-- self:setWJ(1,1,tPosWJMy)
							self:setWJ(2,1,tPosWJEnemy)
					 	    --存在的状态
					 	    self:setEnemyState(1)
					 	    self:setEnemy(tEnemy[1].nKind,1)
						end
					end
				else
					asyncLoadPlist("tx/fight/p2_fight_gb_s",2)
					asyncLoadPlist("tx/fight/p2_fight_bb_s",2)
					asyncLoadPlist("tx/fight/p2_fight_wj_s",2)
					self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(function()
											if #self.pEnemies == 0 then
												self:setEnemy(tEnemy[1].nKind,1)
											end
											if not self.pEnemyWJ then
												self:setWJ(2,1,tPosWJEnemy)
											end
											self:setDead(tEnemy[1].nKind)		
								end)))
				end
			end
			--通关就不赋值了，放到结算界面赋值用于判断是否播放通过动画
			if self.nLastOid == nil then
				self.nLastOid = self.nOid
			end
		end
	end
end

function KillHeroFightLayer:setDead(_type)
	if self.pEnemies then
		for i=1,#self.pEnemies do
			if self.pEnemies[i] and self.pEnemies[i].stopForImg then
				if _type == 1 then
					self.pEnemies[i]:stopForImg("zd_bb_s_ts_aa_06")
				elseif _type == 2 then
					self.pEnemies[i]:stopForImg("zd_gb_s_ts_aa_09")
				elseif _type == 3 then
					self.pEnemies[i]:stopForImg("zd_gb_s_ts_aa_09")
				end
			end
		end
	end
	self:setWJ(1,1,tPosWJMy)
	if self.pEnemyWJ and self.pEnemyWJ.stopForImg then
		self.pEnemyWJ:stopForImg("zd_wj_s_ts_aa_11")
		self.pEnemyWJLayer:setPosition(tPosDeadPos)
	end
	self:setEnemyState(2)
end

--_type 	兵种 1步兵， 2骑兵， 3弓兵 
--_action   动作类型 1待机， 2跑步， 3普攻， 4强攻， 5死亡
function KillHeroFightLayer:setEnemy(_type, _action, _idDead)
	local sKeyStr = "2_".._type.."_".._action.."_1"
	if self.sKeyAction ~= sKeyStr then
		local tArmData1 = tFightSecArmDatas[sKeyStr]
		if tArmData1 then
			for i=1, 4 do
				if not self.pEnemies[i] then
					self.pEnemies[i] = MArmatureUtils:createMArmature(
											tArmData1, 
											self.pLyShow, 
											nSoldierZorder,
											tPosEnemy[i],
											function ( _pArm )
											    -- _pArm:removeSelf()
											end, Scene_arm_type.normal)
					self.pEnemies[i]:play(-1)
				else
					self.pEnemies[i]:setVisible(true)
					self.pEnemies[i]:setData(tArmData1)
				end
				self.pEnemies[i].nKind = _type
				if _action == 1 or _action == 2 then
					self.pEnemies[i]:play(-1)
				else
					--被打败
					local bStop = false
					if _action == 5 then
						if _idDead then
							self.pEnemies[i]:setFrameEventCallFunc(nil)--function(ncur)
							-- 		if ncur == 9 then
							-- 			if self and self.pEnemies and self.pEnemies[i] then
							-- 				self.pEnemies[i]:stop()
							-- 			end
							-- 		end
							-- end)
							self.pEnemies[i]:setMovementEventCallFunc(function() 
									if i==1 then 
										if self.pEnemies and self.pEnemies[1] then
											local nType = self.pEnemies[1].nKind or 1
											self:setDead(nType)
										end
									end
								end)
						else
							self.pEnemies[i]:setFrameEventCallFunc(nil)
							self.pEnemies[i]:setMovementEventCallFunc(function()
								if self and self.pEnemies and self.pEnemies[i] then
										self.pEnemies[i]:setVisible(false)
								end
							end)
						end
					else
						self.pEnemies[i]:setFrameEventCallFunc(nil)
						self.pEnemies[i]:setMovementEventCallFunc(nil)
						
					end
					if not bStop then
						self.pEnemies[i]:play(1)
					end
				end
			end
		end
	end
end

--_dir方向 1下 2上
--_action   动作类型 1待机， 2跑步， 3普攻， 4强攻， 5死亡
--_idEnd 是否为最后一关
function KillHeroFightLayer:setWJ(_dir, _action, _pos, _idEnd, _endHandler)
    -- print("KillHeroFightLayer:setWJ",_dir, _action, _pos)
	local sKeyStr = _dir.."_4_".._action.."_1"
	local tArmData = tFightSecArmDatas[sKeyStr]
	--下方武将
	if _dir == 1 then
		if not self.pMyWJ then
			if not self.pMyWJLayer then
				self.pMyWJLayer = MUI.MLayer.new()
				self.pMyWJLayer:setContentSize(cc.size(1,1))
				self.pLyShow:addView(self.pMyWJLayer, nWJZorder)
				self.pMyWJLayer:setPosition(tPosWJStart)
			end
			self.pMyWJ = MArmatureUtils:createMArmature(
								tArmData, 
								self.pMyWJLayer, 
								nWJZorder,
								cc.p(0,0),
								function ( _pArm )
									-- _pArm:removeSelf()
								end, Scene_arm_type.normal)
			self.pMyWJ:play(-1)
		else
			self.pMyWJ:setData(tArmData)
		end
		if _action == 1 or _action == 2 then
			self.pMyWJ:play(-1)
		else
			self.pMyWJ:play(1)
		end
		if _pos then
			self.pMyWJLayer:setPosition(_pos)
		end
		--如果是强攻就要播放受击
		if _action == 4 then
			self.pMyWJ:setFrameEventCallFunc(function ( nCurFrame )
				-- 第六帧播放
				if nCurFrame == 6 then
					self:playHurtArm()
					self:playHurt(_idEnd)
					self:setEnemyState(2)
				end
			end)
		else
			self.pMyWJ:setFrameEventCallFunc(nil)
		end
	--上方武将
	elseif _dir == 2 then
		if not self.pEnemyWJ then
			if not self.pEnemyWJLayer then
				self.pEnemyWJLayer = MUI.MLayer.new()
				self.pEnemyWJLayer:setContentSize(cc.size(80,100))
				self.pLyShow:addView(self.pEnemyWJLayer, nWJZorder)
				self.pEnemyWJLayer:setPosition(tPosWJEnemy)
				self.pEnemyWJLayer:setViewTouched(true)
				self.pEnemyWJLayer:setIsPressedNeedScale(false)
				self.pEnemyWJLayer:onMViewClicked(handler(self, self.onWJClick))
				-- onMViewClicked
			end
			self.pEnemyWJ = MArmatureUtils:createMArmature(
								tArmData, 
								self.pEnemyWJLayer, 
								nWJZorder,
								cc.p(40,50),
								function ( _pArm )
									-- _pArm:removeSelf()
								end, Scene_arm_type.normal)
		else
			self.pEnemyWJLayer:setVisible(true)
			self.pEnemyWJ:setData(tArmData)
		end
		if _action == 1 or _action == 2 then
			self.pEnemyWJ:play(-1)
			self.pEnemyWJ:setFrameEventCallFunc(nil)
			self.pEnemyWJ:setMovementEventCallFunc(nil)
		else
			local bStop = false
			if _action == 5 then
			    --是否通关
				if _idEnd then
					self.pEnemyWJ:setFrameEventCallFunc(function(ncur)
						if ncur == 6 then
							if self and self.pEnemyWJ then
								-- self.pEnemyWJ:stop()
								--这里想播放完
								self.pEnemyWJLayer:setPosition(tPosDeadPos)
								self:setWJ(1,1,tPosWJMy)
								self:showXLBTips()
							end
						end
					end)
					self.pEnemyWJ:setMovementEventCallFunc(nil)
				else
					self.pEnemyWJ:setFrameEventCallFunc(nil)
					self.pEnemyWJ:setMovementEventCallFunc(function()
						if self and self.pEnemyWJ then
							self.pEnemyWJLayer:setVisible(false)
						end
						local pDelay = cc.DelayTime:create(0.2)
						local pAction = cc.MoveTo:create(1.5, tPassPos)
						local pSpawn = cc.Spawn:create(pAction, cc.CallFunc:create(function ()
							if self and self.onBlackJM then
								self:setWJ(1,2)
								self:onBlackJM()
							end
						end))
						if self.pMyWJLayer then
							self.pMyWJLayer:runAction(cc.Sequence:create(pDelay, pSpawn))
						end
					end)
				end
			else
				self.pEnemyWJ:setFrameEventCallFunc(nil)
				self.pEnemyWJ:setMovementEventCallFunc(nil)
			end
			if not bStop then
				self.pEnemyWJ:play(1)
			end
		end
		if _pos then
			self.pEnemyWJLayer:setPosition(_pos)
		end
	end
end

function KillHeroFightLayer:showXLBTips()
	
	local numRandom = getLocalInfo("killHeroPassTalkId", "1")
	local sPassTalk = getExpeditePassTalk(numRandom) or getConvertedStr(1,10409)

	if not self.pTipsLayer then
		self.pTipsLayer = HomeXLBTipsLayer.new()
		self.pLyShow:addView(self.pTipsLayer,999)
	else
		self.pTipsLayer:setVisible(true)
	end
	self.pTipsLayer:setTips(sPassTalk)
	if self.pMyWJLayer then
		local nX, nY = self.pMyWJLayer:getPosition()
		local nW = self.pTipsLayer:getContentSize().width
		self.pTipsLayer:setPosition(nX-nW/2, nY+40)
	end
end

function KillHeroFightLayer:hideXLBTips()
	if self.pTipsLayer then
		self.pTipsLayer:setVisible(false)
	end
end

--设置关卡
function KillHeroFightLayer:setLevel()
	-- body
	if self.nOid > 10 then
		self.pLbLevel1:setString(":")
		self.pLbLevel2:setString(self.nOid-10)
		self.pLbLevel1:setPosition(381, 692)
		self.pLbLevel2:setPosition(406, 680)
	else
		if self.nOid == 10 then
			self.pLbLevel1:setString(":")
		else
			self.pLbLevel1:setString(self.nOid)
		end
		self.pLbLevel1:setPosition(self.pImgFont:getPosition())
		self.pLbLevel2:setString("")
	end
end
 

function KillHeroFightLayer:onEnterWJ()
	--设置关卡
	self:setLevel()
	self:setWJ(1,2,tPosWJStart)
	if self.pMyWJLayer and self.pMyWJ then
		self.pMyWJLayer:stopAllActions()
		--初始化位置
		local pMove = cc.MoveTo:create(1.2,tPosWJMy)
		local pSeq = cc.Sequence:create(pMove, cc.CallFunc:create(
							function()
								self:setWJ(1,1)
							end))
		self.pMyWJLayer:runAction(pSeq)
	end
end

--冲锋
function KillHeroFightLayer:onFightWJ()
	if self.pMyWJLayer and self.pMyWJ then
		--初始化位置
		self:setWJ(1,2,tPosWJMy)
		local pMove = cc.MoveTo:create(0.5,tPosWJFight)
		local pSeq = cc.Sequence:create(pMove, cc.CallFunc:create(
							function()
								-- self:setWJ(1,4)
							end))
		self.pMyWJLayer:runAction(pSeq)
	end
end


--武将点击回调
function KillHeroFightLayer:onWJClick()
	--过场时没反应	
	if self.blackScene  and self.blackScene:getOpacity() > 0 then
		return 
	end
	--武将没死的时候
	if self.nWJState == 1 then
		self:openFightView()
	elseif self.nWJState == 2 then
		local pData = Player:getPassKillHeroData()
		if pData and pData:isPassAllOid() then
			TOAST(getConvertedStr(1,10388))
		end
	end
	--新手教程
	Player:getNewGuideMgr():setNewGuideFingerClicked(e_guide_finer.pkhero_enemy)
end

--_type兵种 1步兵， 2骑兵， 3弓兵 
function KillHeroFightLayer:playHurtArm()
	local tHurtArm =tFightSecArmDatas["4_10"]
	local tPosList = self.tRelativetPos
	for i=1,#tPosList do
		local pArm = MArmatureUtils:createMArmature(
	        tHurtArm, 
	        self.pLyShow, 
	        nHurtZorder, 
	        self.tRelativetPos[i],
	        function ( _pArm )
	        	_pArm:removeSelf()
	        end, Scene_arm_type.normal)
		if pArm then
			pArm:play(1)
		end
	end
end

--兵受击倒地
--_type兵种 1步兵， 2骑兵， 3弓兵 
function KillHeroFightLayer:playHurt(_isEnd)
	-- self.pEnemies[i].nKind
	local nType = 1
	if self.pEnemies and self.pEnemies[1] and self.pEnemies[1].nKind then
		nType = self.pEnemies[1].nKind
	end
	self:setEnemy(nType, 5, _isEnd)
	self:setWJ(2, 5, nil, _isEnd)  
end

--展示武将底部光圈
function KillHeroFightLayer:showCircleArm(  )

	-- body
	if self.tCircleArms == nil then
		self.tCircleArms = getCircleWhirl(0.15)
		self.pLyShow:addView(self.tCircleArms)
		self.tCircleArms:setPosition(cc.p(tPosWJEnemy.x + 32, tPosWJEnemy.y + 35))
	else
		self.tCircleArms:setVisible(true)
	end
end

--隐藏武将底部光圈
function KillHeroFightLayer:hideCircleArm( )
	-- body
	if self.tCircleArms then
		self.tCircleArms:setVisible(false)
	end
end

--显示敌将血条
function KillHeroFightLayer:showFightBlood()
	if self.pLayFightBlood == nil then
		self.pLayFightBlood = FightSecBloodLayer.new(2)
		self.pLayFightBlood:setPosition(tPosWJEnemy.x - 60, tPosWJEnemy.y+95)
		self.pLyShow:addView(self.pLayFightBlood, 999)
	else
		self.pLayFightBlood:setVisible(true)
	end

	self:updateBlood()
end

--更新血条
function KillHeroFightLayer:updateBlood()
	if self.pLayFightBlood then
		local pData = Player:getPassKillHeroData()
		if not pData or not pData.pOutpostVo then
			return
		end
		local tEnemy = pData.pOutpostVo:getEnemy()--敌方部队

		if pData.pOutpostVo and tEnemy then
			-- dump(tEnemy[1])
			self.pLayFightBlood:setCurData(tEnemy[1], 0, 100, 1)
			self.pLayFightBlood:setIconImg("#i130000_tx.png")
			self.pLayFightBlood:setName(pData.pOutpostVo.sName)
			local nKillTroop = 0
			local nBloor = 0
			for i, data in pairs(pData.pOutpostVo.tBattleArray) do
				nKillTroop = nKillTroop + data.lt
				nBloor = nBloor + data.bloor
			end

			self.pLayFightBlood.nAllTrp = nKillTroop 
			self.pLayFightBlood.nCurTrp = nBloor
			self.pLayFightBlood:setbloodMsg()
		end
	end
end

--隐藏敌将血条
function KillHeroFightLayer:hideFightBlood()
	if self.pLayFightBlood then
		self.pLayFightBlood:setVisible(false)
	end
end

--敌方武将指示
function KillHeroFightLayer:showArrow()
	-- v1_img_zhiyin_sj.png
	if not self.pImgArrow then
		self.pImgArrow = MUI.MImage.new("#v1_img_zhiyin_sj.png")
		self.pImgArrow:setScale(0.6)
		self.pLyShow:addView(self.pImgArrow,999)
		self.pImgArrow:setAnchorPoint(cc.p(0.5,0.5))
		local pAct_1 = cc.MoveBy:create(0.7, cc.p(0, 16))
		local pAct_2 = cc.MoveBy:create(0.7, cc.p(0, -16))
		self.pImgArrow:runAction(cc.RepeatForever:create(cc.Sequence:create(pAct_1, pAct_2)))
		self.pImgArrow:setPosition(tPosWJEnemy.x + 30, tPosWJEnemy.y + 140)
	else
		self.pImgArrow:stopAllActions()
		self.pImgArrow:setVisible(true)
		self.pImgArrow:setPosition(tPosWJEnemy.x + 30, tPosWJEnemy.y + 140)
		local pAct_1 = cc.MoveBy:create(0.5, cc.p(0, 16))
		local pAct_2 = cc.MoveBy:create(0.5, cc.p(0, -16))
		self.pImgArrow:runAction(cc.RepeatForever:create(cc.Sequence:create(pAct_1, pAct_2)))
	end
end

function KillHeroFightLayer:hideArrow()
	if self.pImgArrow then
		self.pImgArrow:stopAllActions()
		self.pImgArrow:setVisible(false)
	end
end

--全屏变黑
function KillHeroFightLayer:onBlackScene(_type, _tData)
	if not _tData or not _tData.report then
		return
	end
	local pRootLayer = RootLayerHelper:getCurRootLayer()
    local pParView = getRealShowLayer(pRootLayer, e_layer_order_type.guidelayer)
    --获得
    if pParView then
    	if not self.blackFullScene then
    		self.blackFullScene =  display.newNode()
    		self.blackFullScene:setContentSize(cc.size(display.width, display.height))
    		local colorLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 0), display.width, display.height)
    		colorLayer:setAnchorPoint(cc.p(0,0))
    		self.blackFullScene:addChild(colorLayer)
    		self.blackFullScene:setTouchEnabled(true)
        	self.blackFullScene:setTouchSwallowEnabled(true)
    		self.blackFullScene:setAnchorPoint(cc.p(0, 0))
    		pParView:addView(self.blackFullScene)
    		local tFadeIn = cc.FadeIn:create(0.5)
    		self:onFightWJ()
    		colorLayer:runAction(cc.Sequence:create(tFadeIn, cc.CallFunc:create(function()
    				showFight(_tData.report, function ()
						local tData = {}
						tData.report = _tData.report
						tData.star = 0
						tData.nEndHandler = function (_bIsShowToast)
												local pData = Player:getPassKillHeroData()
												if not pData then
													return
												end
												self.nOid = pData.pOutpostVo.nOid
												--print("self.nOid > self.nLastOid =>", self.nOid , self.nLastOid, pData:isPassAllOid())
												if self.nOid > self.nLastOid or (self.nOid == self.nLastOid and pData:isPassAllOid()) then
													--通关动画
													self.nLastOid = self.nOid
													local bIsPass = pData:isPassAllOid()
													self:onPassAction(bIsPass)
													if _bIsShowToast then
														local delay = cc.DelayTime:create(0.5)
														self:runAction(cc.Sequence:create(delay, cc.CallFunc:create(function() TOAST(getConvertedStr(1, 10396)) end)))
													end
													if (pData:isPassAllOid()) then
														pData.nChange = false --重置状态
													end
												elseif self.nOid == self.nLastOid then
													self:updateBlood()
													self:setWJ(1,1,tPosWJMy)
													if _bIsShowToast then
														local delay = cc.DelayTime:create(0.5)
														self:runAction(cc.Sequence:create(delay, cc.CallFunc:create(function() TOAST(getConvertedStr(1, 10397)) end)))
													end
												end
											 end
						showFightRst(tData)
		    		end, true)
    				if self and self.blackFullScene then
    					self.blackFullScene:removeFromParent(true)
    					self.blackFullScene = nil
    				end
    			end)))
    	end
    end
end

--界面黑屏
function KillHeroFightLayer:onBlackJM()
	if not self.blackScene then
		local tSize = self.pLyShow:getContentSize()
		self.blackScene = cc.LayerColor:create(cc.c4b(0, 0, 0, 0), tSize.width, tSize.height)
		self.blackScene:setAnchorPoint(cc.p(0, 0))
		self.pLyShow:addView(self.blackScene,9999)
	else
		self.blackScene:setOpacity(0)
	end
	local tFadeIn = cc.FadeIn:create(1)
	--这里设置关卡信息
	local function setData()
		self.pMyWJLayer:stopAllActions()
		--我方武将进场
		self:onEnterWJ()
		local pData = Player:getPassKillHeroData()
		if not pData then
			return
		end
		local tEnemy = pData.pOutpostVo:getEnemy()--敌方部队
		--设置敌方信息
		if tEnemy and tEnemy[1] then
			self:setEnemy(tEnemy[1].nKind,1)
		end
	 	self:setWJ(2,1,tPosWJEnemy)
	 	self:setEnemyState(1)		
	end 
	local tFadeOut = cc.FadeOut:create(1)
	self.blackScene:runAction(cc.Sequence:create(tFadeIn, cc.CallFunc:create(setData) ,tFadeOut))
end

--过关动画
--_idEnd是否是最后一关
function KillHeroFightLayer:onPassAction(_idEnd)
	--通关就设置新的对话
	if _idEnd then
		local sTalkId = getLocalInfo("killHeroPassTalkId", "1")
		local sPassTalk = math.random(1,5)
		while tonumber(sTalkId) == sPassTalk do
			sPassTalk = math.random(1,5)
		end
		saveLocalInfo("killHeroPassTalkId",sPassTalk.."")
	end

	self:setWJ(1,1,tPosWJFight)
	self:setWJ(1,4,nil,_idEnd)
end

--_state 敌将状态状态 1武将存在, 2敌方死亡 
function KillHeroFightLayer:setEnemyState(_state)
	-- if self.nWJState == _state then
	-- 	return
	-- end
	self.nWJState = _state
	--存在
	if self.nWJState == 1 then
		self:showArrow()
		self:showFightBlood()
		self:showCircleArm()
		self:hideXLBTips()
		--新手教程
		Player:getNewGuideMgr():setNewGuideFinger(self.pEnemyWJLayer, e_guide_finer.pkhero_enemy)

	elseif self.nWJState == 2 then
		self:hideArrow()
		self:hideFightBlood()
		self:hideCircleArm()
		--如果通过展示对话框
		local pData = Player:getPassKillHeroData()
		if not pData then
			return
		end
		--通关展示对话框
		if pData:isPassAllOid() then
			self:showXLBTips()
		end
		--新手教程
		Player:getNewGuideMgr():setNewGuideFinger(nil, e_guide_finer.pkhero_enemy)
	end
end

--打开对战界面
function KillHeroFightLayer:openFightView()
	--过场时先屏蔽
	if self.blackScene  and self.blackScene:getOpacity() > 0 then
		return 
	end

	local pData = Player:getPassKillHeroData()
	if not pData then
		return
	end
	local tObject = {}
	tObject.nType = e_dlg_index.armylayer --dlg类型
	tObject.nArmyType = en_army_type.killherofight -- 部队类型:过关斩将
	tObject.sTitle = string.format(getConvertedStr(7, 10380), self.nOid) --界面标题
	tObject.tMyArmy = pData:getOnlineHero(true) --我方部队
	tObject.tEnemy = pData.pOutpostVo:getEnemy()
	if pData.pOutpostVo.nNpc == 1 then
		tObject.nEnemyArmyFight = getNpcGropListDataById(pData.pOutpostVo.nId).score or 0 --敌方战力
	else
		local nFight = 0
		for k, v in pairs(tObject.tEnemy) do
			nFight = nFight + v.nSc
		end
		tObject.nEnemyArmyFight = nFight
	end
	sendMsg(ghd_show_dlg_by_type, tObject)
end

-- 重置按钮点击响应
function KillHeroFightLayer:onBotBtnClicked( )
	-- body
	local pData = Player:getPassKillHeroData()
	local nLeftReset = pData:getLeftVipResetTimes()
	if nLeftReset > 0 then
		if pData:isPassAllOid() then --已通过所有关卡
			--请求重置次数
			self:reqReset()
		else
			local bHasHero = pData:getHasNotDeadHero()
			if bHasHero then --是否拥有可上阵的武将(弹出二次确认提示框)
				local pDlg, bNew = getDlgByType(e_dlg_index.alert)
			    if(not pDlg) then
			        pDlg = DlgAlert.new(e_dlg_index.alert)
			    end
			    pDlg:setTitle(getConvertedStr(3, 10091))
			    pDlg:setContent(getConvertedStr(7, 10379))--当前还有武将可进行挑战，是否进行重置？
			    local btn = pDlg:getRightButton()
	    		btn:updateBtnType(TypeCommonBtn.L_BLUE)
	    		pDlg:setRightHandler(function (  )            
			        --请求重置次数
					self:reqReset()
					closeDlgByType(e_dlg_index.alert, false)  
			    end)
			    pDlg:showDlg(bNew)
			    return pDlg
			else
				--请求重置次数
				self:reqReset()
			end
		end
	else
		TOAST(getConvertedStr(7,10377))
	end
end

--请求重置次数
function KillHeroFightLayer:reqReset()
	SocketManager:sendMsg("reqResetFight", {}, function ( __msg )
		-- body
		if  __msg.head.state == SocketErrorType.success then 
			if __msg.head.type == MsgType.reqResetFight.id then
				TOAST(getConvertedStr(7,10378))	 --重置关卡成功！			
			end
	    end
	end, -1)
end

--战斗按钮点击事件
function KillHeroFightLayer:onBtnFightClicked()
	-- body
	self:onWJClick()
end

function KillHeroFightLayer:onResetShow()
	if not self.blackScene then
		local tSize = self.pLyShow:getContentSize()
		self.blackScene = cc.LayerColor:create(cc.c4b(0, 0, 0, 0), tSize.width, tSize.height)
		self.blackScene:setAnchorPoint(cc.p(0, 0))
		self.pLyShow:addView(self.blackScene,9999)
	else
		self.blackScene:setOpacity(0)
	end
	local tFadeIn = cc.FadeIn:create(1)
	--这里设置关卡信息
	local function setData()
 		local pData = Player:getPassKillHeroData()
		if not pData then
			return
		end
		local tEnemy = pData.pOutpostVo:getEnemy() --敌方部队
		if tEnemy then
			self:onEnterWJ()
			self:setWJ(2,1,tPosWJEnemy)
		    --存在的状态
			self:setEnemyState(1)
			self:setEnemy(tEnemy[1].nKind,1)
		end
	end 
	local tFadeOut = cc.FadeOut:create(1)
	self.blackScene:runAction(cc.Sequence:create(tFadeIn, cc.CallFunc:create(setData) ,tFadeOut))
end

--析构方法
function KillHeroFightLayer:onDestroy(  )
	self:onPause()
end

--清楚所有动画
function KillHeroFightLayer:stopAllLayerActions()
	if self.blackFullScene then
		self.blackFullScene:stopAllActions()
		self.blackFullScene:removeFromParent(true)
		self.blackFullScene = nil
	end
	if self.blackScene then
		self.blackScene:stopAllActions()
		self.blackScene:removeFromParent(true)
		self.blackScene = nil
	end
	if self.pImgArrow then
		self.pImgArrow:stopAllActions()
	end
	if self.pMyWJLayer then
		self.pMyWJLayer:stopAllActions()
	end
end

--重置
function KillHeroFightLayer:onReset(_tData)
	--重置数据
	self.nLastOid = nil
	self:stopAllLayerActions()
	if _tData and _tData.isReSet then
		self:updateViews(_tData.isReSet)
	else
		self:updateViews()
	-- self:updateViews(true)
	end
end

-- 注册消息
function KillHeroFightLayer:regMsgs( )
	regMsg(self, ghd_pass_report_update, handler(self, self.onBlackScene))
	-- regMsg(self, ghd_req_Reset_Fight, handler(self, self.onReset))
end

-- 注销消息
function KillHeroFightLayer:unregMsgs(  )
	unregMsg(self, ghd_pass_report_update)
	-- unregMsg(self, ghd_req_Reset_Fight)
end
--暂停方法
function KillHeroFightLayer:onPause( )
	self:stopAllLayerActions()
	self:unregMsgs()
end

--继续方法
function KillHeroFightLayer:onResume( )
	-- body
	self:regMsgs()
end

return KillHeroFightLayer
