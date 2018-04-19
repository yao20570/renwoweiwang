--
-- Author: tanqian
-- Date: 2017-09-25 19:49:09
--世界帮助->协防玩家
local MCommonView = require("app.common.MCommonView")
local DefenseHelp = class("DefenseHelp", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function DefenseHelp:ctor(_parent)
	self:myInit()
	self.pParent = _parent
	parseView("lay_help_4", handler(self, self.onParseViewCallback))
end

--读入控件后,初始化参数值
function DefenseHelp:myInit()
	self.pParent 				= 		nil 			--父层
	self.pEnemyLine				= 		nil 
	self.tEnemyPos				=		{}

	self.tLine					= 		{} 
	self.tPos					=		{}
	self.tPosIndex				= 		{} 
	
	
end
--解析界面回调
function DefenseHelp:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DefenseHelp", handler(self, self.onResourceHelpLayerDestroy))
end
function DefenseHelp:setupViews(  )
	--内容层
	self.pLayContent 	= 			self:findViewByName("middle")
	--城池图片
	self.pImgCity 		= 			self:findViewByName("img_my")
	
	--行军提示图片
	-- self.pImgHorse 		= 			self:findViewByName("img_horse")
	for i=1,3 do
		local pLv = self:findViewByName("txt_lv"..i)
		pLv:setString("20",false)
	end

    self.pBgRed = {}		
    self.pBgBlueUp = {}		
    self.pBgBlueDown = {} 
    for i = 1, 4 do	
	    self.pBgRed[i] 		= 		self:findViewByName("img_lj_red_" .. (i -1 ))
	    self.pBgBlueUp[i] 	= 		self:findViewByName("img_my_blue1_" .. (i -1 ))
	    self.pBgBlueDown[i]	= 		self:findViewByName("img_my_blue2_" .. (i -1 ))
	end

	self.pLbMy1 		= 			self:findViewByName("txt_name1")
	self.pLbMy2 		= 			self:findViewByName("txt_name2")
	self.pLbEnemyName 	= 			self:findViewByName("txt_name3")

	self.pLayDefense 	=			self:findViewByName("lay_defense")

	self:setCountry(self.pLbMy1,getConvertedStr(8, 10026),getConvertedStr(8, 10031),getC3B(_cc.blue))
	self:setCountry(self.pLbMy2,getConvertedStr(8, 10029),getConvertedStr(8, 10031),getC3B(_cc.blue))
	self:setCountry(self.pLbEnemyName,getConvertedStr(8, 10027),getConvertedStr(8, 10034),getC3B(_cc.red))
	
	self.pHero1,self.pArm1 =			self.pParent:createHero(self,"blueArmyLeftUToRightD",10,cc.p(0,0))
	self.pHero1:setAnchorPoint(cc.p(0,0))
	self.pEnemy			   =			self.pParent:createHero(self,"redArmyLeftDToRightU",10,cc.p(0,0))

	self.pImgMy1       =           self:findViewByName("img_my1")
	self.pImgMy1:setScale(0.26)
	self.pImgMy2       =           self:findViewByName("img_my2")
	self.pImgMy2:setScale(0.26)
	self.pImgEnenmy       =           self:findViewByName("img_enenmy")
	self.pImgEnenmy:setScale(0.26)
end
function DefenseHelp:setCountry( _pLabel,_sName,_sCountryName,_sCountryColor )
	if not _pLabel then
		return 
	end
	local tLabel = {
		{text = _sCountryName,color = _sCountryColor},
		{text = _sName, color = getC3B(_cc.white)}
	}
	
	_pLabel:setString(tLabel)
end
function DefenseHelp:setDefenseShow( show )
	self.pLayDefense:setVisible(show)
end
function DefenseHelp:updateViews()
	self:playAnim()
end
--播放动画
function DefenseHelp:playAnim(  )
	self:stopAllActions()
	self.pEnemy:setVisible(false)
	self:setDefenseShow(false)
	self.pHero1:setVisible(false)
	doDelayForSomething(self,function (  )
		self:playStepOne()
	end,0.5)
end
function DefenseHelp:playStepOne()
	self:setArmFlippedData(self.pArm1,false,0,"blueArmyLeftUToRightD")
  	self.pHero1:setVisible(true)
   --画行军路线
   local tStart1, tEnd1 = self:addLine(1,1,1)
   self.pHero1:setPosition(tStart1.x,tStart1.y)
   local function moveStep1CallBack()
   		self:releaseLine(self.pLine1)
   		self:setDefenseShow(true)
   		--骑兵消失
   		self.pHero1:setVisible(false)
   		
   		--敌军出发
   		doDelayForSomething(self,function (  )
   			self:playEnemyAnim()
   		end,0.2)
   		

   end
   --小马移动
  
   local pMove = cc.MoveTo:create(3,cc.p(( tEnd1.x ) ,tEnd1.y))
   local callBack = cc.CallFunc:create(moveStep1CallBack)
   local seqAct = cc.Sequence:create(pMove, callBack)
	self.pHero1:runAction(seqAct)

	
	
	
end

function DefenseHelp:playEnemyAnim()
	self.pEnemy:setVisible(true)
	local tStart1 	= cc.p(self.pBgRed[1]:getPositionX() + 2 ,self.pBgRed[1]:getPositionY() + 20 - 48)
	local tEnd1 	= cc.p(self.pBgBlueDown[1]:getPositionX() + 1 ,self.pBgBlueDown[1]:getPositionY() + 56  - 48)


	local tEnd 		= 	cc.p((tStart1.x + tEnd1.x ) / 2  ,(tStart1.y + tEnd1.y) / 2)
	local tPos,pLine = self.pParent:drawLine(self,tStart1,tEnd1,2)
	self.pEnemyLine = pLine
	self.tEnemyPos = tPos
	self.pEnemy:setPosition(tStart1.x,tStart1.y  )
	table.insert(self.tLine,pLine)
	table.insert(self.tPos,tPos)
	table.insert(self.tPosIndex,0)
	local function moveStep3CallBack1(  )
		
	
	end
	local moveAction1 = cc.MoveTo:create(3, cc.p(tEnd.x - 30 , tEnd.y - 20))
	local moveCallback1 = cc.CallFunc:create(moveStep3CallBack1)
	local seqAct1 = cc.Sequence:create(moveAction1, moveCallback1)
	self.pEnemy:runAction(seqAct1)



	self:setArmFlippedData(self.pArm1,true,0,"blueArmyLeftUToRightD")
	--我方从友军城池出来
	doDelayForSomething(self,function ( )
		self.pHero1:setVisible(true)
		local tStart = cc.p(self.pBgBlueDown[1]:getPositionX() + 1 ,self.pBgBlueDown[1]:getPositionY() + 56  - 48)
		local tEnd 	= cc.p(self.pBgRed[1]:getPositionX() + 2 ,self.pBgRed[1]:getPositionY() + 20 - 48)
		local tMoveEnd = cc.p((tStart.x + tEnd.x) / 2,(tStart.y + tEnd.y) / 2)
		local function moveCallBack()
			self:playSwordAnim(tMoveEnd)
		end

		-- local tPos,pLine = self.pParent:drawLine(self,tStart,tMoveEnd,1)
		-- self.pLine2 = pLine
		-- table.insert(self.tLine,pLine)
		-- table.insert(self.tPos,tPos)
		-- table.insert(self.tPosIndex,0)

		local moveAction = cc.MoveTo:create(2, cc.p(tMoveEnd.x + 30 , tMoveEnd.y + 5))
		local moveCallback = cc.CallFunc:create(moveCallBack)
		local seqAct = cc.Sequence:create(moveAction,moveCallback)
		self.pHero1:runAction(seqAct)
	end,1)

end

function DefenseHelp:setArmFlippedData( _pArm,_bFliip,_nRotate,_sName )
	_bFliip = _bFliip or false 
	_nRotate = _nRotate or 0 
	_sName = _sName or "redArmyLeftUToRightD"
	if _pArm  then
		
		_pArm:setFlippedX(_bFliip)
		_pArm:setRotation(_nRotate)
		_pArm:setData(EffectWorldDatas[_sName])	
	end
end
function DefenseHelp:playSwordAnim(tPos)

	-- for i=1,3 do
	-- 	local pArm = MArmatureUtils:createMArmature(
	-- 		tNormalCusArmDatas["47_"..i],
	-- 		self,
	-- 		10,
	-- 		cc.p(tPos.x,tPos.y + 50),
	-- 		function ( _pArm )
	-- 			_pArm:removeSelf()
	-- 			_pArm = nil 
	-- 		end, Scene_arm_type.world)
	-- 	if pArm then
	-- 		pArm:play(3)
	-- 	end
	-- 	if i == 3 and pArm then
	-- 		pArm:setMovementEventCallFunc(function ( _pArm )
	-- 			_pArm:removeSelf()
	-- 			_pArm = nil 
	-- 			--敌方骑兵消失
	-- 			self.pEnemy:setVisible(false)
	-- 			self:releaseLine(self.pEnemyLine)  --释放敌方骑兵线路
	-- 			-- self:releaseLine(self.pLine2)  --释放我方骑兵从友军城池中走出来的线路

	-- 			--我方骑兵返回
	-- 			self:playBackAnim()

				
	-- 		end)
	-- 	end
	-- end

	self.nArmLoopIndex = 0
	local sName = createAnimationBackName("tx/exportjson/", "rwww_gjtx_yhyb_001")
    local pSwordArm = ccs.Armature:create(sName)
    local fX, fY = tPos.x,tPos.y + 50
    pSwordArm:setPosition(fX, fY)
    self:addChild(pSwordArm,10)
    pSwordArm:getAnimation():setMovementEventCallFunc(function ( arm, eventType, movmentID )
		if (eventType == MovementEventType.LOOP_COMPLETE) then
			self.nArmLoopIndex = self.nArmLoopIndex + 1
			if self.nArmLoopIndex >= 3 then
				pSwordArm:removeFromParent(true)
				--敌方骑兵消失
				self.pEnemy:setVisible(false)
				self:releaseLine(self.pEnemyLine)  --释放敌方骑兵线路
				-- self:releaseLine(self.pLine2)  --释放我方骑兵从友军城池中走出来的线路

				--我方骑兵返回
				self:playBackAnim()
			end
		end
	end)
	pSwordArm:getAnimation():play("Animation1", -1)
	

end

--添加一条行军路线
--_nType：1：前进  2：返回
function DefenseHelp:addLine(_nType,_nDirct,_nLineType)
	local tStart,tEnd = nil ,nil 
	if _nDirct == 1 then
		tStart 	= cc.p(self.pBgBlueUp[1]:getPositionX() + 1 ,self.pBgBlueUp[1]:getPositionY() + 44 - 48)
		tEnd 	= cc.p(self.pBgBlueDown[1]:getPositionX() + 1 ,self.pBgBlueDown[1]:getPositionY() + 56 - 48)
		if _nType == 2 then
			tEnd 	= cc.p(self.pBgBlueUp[1]:getPositionX() + 1,self.pBgBlueUp[1]:getPositionY() - 48 + 44)
			tStart 	= cc.p(self.pBgRed[1]:getPositionX() ,self.pBgRed[1]:getPositionY() + 56 - 48)
			
		end
	
	end
	local tPos,pLine = self.pParent:drawLine(self,tStart,tEnd,_nLineType)
	self.pLine1 = pLine
	table.insert(self.tLine,pLine)
	table.insert(self.tPos,tPos)
	table.insert(self.tPosIndex,0)
	

	
	return tStart, tEnd
end
--释放行军路线
function DefenseHelp:releaseLine(_pLine)
	if _pLine then
		_pLine:removeFromParent(true)
		_pLine = nil
	end
end
--播放返回特效
function DefenseHelp:playBackAnim()
	self:setArmFlippedData(self.pArm1,false,0,"blueArmyLeftDToRightU")
	local tStart1 = cc.p(self.pBgBlueDown[1]:getPositionX() + 1 ,self.pBgBlueDown[1]:getPositionY() + 56  - 48)
	local tEnd1 	= cc.p(self.pBgRed[1]:getPositionX() + 2 ,self.pBgRed[1]:getPositionY() + 20 - 48)
	local tMoveEnd = cc.p((tStart1.x + tEnd1.x) / 2,(tStart1.y + tEnd1.y) / 2)
	local tStart = cc.p(tMoveEnd.x + 30 , tMoveEnd.y + 10)
	local tEndPos =  cc.p(self.pBgBlueDown[1]:getPositionX() + 1 ,self.pBgBlueDown[1]:getPositionY() + 56  - 48)
	self.pHero1:setPosition(tStart.x,tStart.y)
	-- local tPos,pLine = self.pParent:drawLine(self,tStart,tEndPos,1)
	-- self.pLine3 = pLine
	-- table.insert(self.tLine,pLine)
	-- table.insert(self.tPos,tPos)
	-- table.insert(self.tPosIndex,0)
	local function moveStep3CallBack(  )
		self.pHero1:setVisible(false)
		-- self:releaseLine(self.pLine3)
		-- self:setDefenseShow(false)

		
		self:performWithDelay(function (  )
			self:playAnim()
		end,3)
		

	end
	local moveAction = cc.MoveTo:create(3.0, cc.p(tEndPos.x, tEndPos.y))
	local moveCallback = cc.CallFunc:create(moveStep3CallBack)
	local seqAct = cc.Sequence:create(moveAction, moveCallback)
	self.pHero1:runAction(seqAct)

end

function DefenseHelp:onLineMove(  )
	for k,v in pairs(self.tPos or {}) do
		local pLine = self.tLine[k]
		local pPosList = v
		local pPosIndex = self.tPosIndex[k]
		if pLine  and pPosList and pPosIndex then
			pPosIndex = pPosIndex + 1
			if pPosIndex > #pPosList then
				pPosIndex = 1
			end
			self.tPosIndex[k] = pPosIndex
			local pos = pPosList[pPosIndex]
			local pBatchNode = pLine.pBatchNode 
			if pBatchNode then
				pBatchNode:setPosition(pos)
			end
		end
	end
end
function DefenseHelp:onResume(  )
	self.nUpdateScheduler = MUI.scheduler.scheduleGlobal(function ()
		self:onLineMove()
	end,0.1)
	self:updateViews()
end


function DefenseHelp:onPause(  )
	if self.nUpdateScheduler then
	    MUI.scheduler.unscheduleGlobal(self.nUpdateScheduler)
	    self.nUpdateScheduler = nil
	end

	for k,v in pairs(self.tLine) do
		if not tolua.isnull(v) then
			v:removeFromParent(true)
			v = nil
		end
	end
end
-- 析构方法
function DefenseHelp:onResourceHelpLayerDestroy(  )
   self:onPause()
end
return DefenseHelp