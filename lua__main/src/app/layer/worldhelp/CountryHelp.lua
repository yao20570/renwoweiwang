--
-- Author: tanqian
-- Date: 2017-09-25 18:06:48
--国战帮助

local MCommonView = require("app.common.MCommonView")

local CountryHelp = class("CountryHelp", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function CountryHelp:ctor(_parent)
	self:myInit()
	self.pParent = _parent
	parseView("lay_help_3", handler(self, self.onParseViewCallback))
end

--读入控件后,初始化参数值
function CountryHelp:myInit()
	self.pParent 				= 		nil 			--父层
	self.pHero1 				=		nil 
	self.pArm1 					= 		nil 
	self.pLine1 				= 		nil 
	self.pPosIndex1				= 		0 			
	self.tPosList1			 	= 		{} 			--记录所有存在的行军路线


	self.pHero1 				=		nil 
	self.pArm1 					= 		nil
	self.pLine2 				= 		nil 
	self.pPosIndex2				= 		0 			
	self.tPosList2			 	= 		{} 			--记录所有存在的行军路线
end
--解析界面回调
function CountryHelp:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("CountryHelp", handler(self, self.onCountryHelpLayerDestroy))
end

function CountryHelp:setArmFlippedData( _pArm,_bFliip,_nRotate,_sName )
	_bFliip = _bFliip or false 
	_nRotate = _nRotate or 0 
	_sName = _sName or "redArmyLeftUToRightD"
	if _pArm  then
		
		_pArm:setFlippedX(_bFliip)
		_pArm:setRotation(_nRotate)
		_pArm:setData(EffectWorldDatas[_sName])	
	end
end
function CountryHelp:setupViews(  )
	--内容层
	self.pLayContent 	= 			self:findViewByName("middle")
	--城池图片
	self.pImgCity1 		= 			self:findViewByName("img_my1")
	self.pImgCity1:setScale(0.26)
	self.pImgCity2 		= 			self:findViewByName("img_my2")
	self.pImgCity2:setScale(0.26)
	--乱军图片
	self.pImgLj 		= 			self:findViewByName("img_enenmy")
	self.pImgLj:setScale(0.52)
	
	
	self.pLv = {}
	for i=1,3 do

		local pLv = self:findViewByName("txt_lv"..i)
		if pLv then
			pLv:setString("20")
			
		end
		self.pLv[i] = pLv
		
	end

	

	
	self.pLbMy1 		= 			self:findViewByName("txt_name1")
	self.pLbMy2 		= 			self:findViewByName("txt_name2")
	self.pLbCunName 	= 			self:findViewByName("txt_name3")

    self.pBgRed = {}		
    self.pBgBlueUp = {} 		
    self.pBgBlueDown = {}
    for i = 1, 4 do
	    self.pBgRed[i] 		= 		self:findViewByName("img_lj_red_" .. (i-1))
	    self.pBgBlueUp[i] 	= 		self:findViewByName("img_my_blue1_" .. (i-1))
	    self.pBgBlueDown[i] = 		self:findViewByName("img_my_blue2_" .. (i-1))
	end

	local tLabel1 = {
		{text = getConvertedStr(8, 10031) , color = getC3B(_cc.blue)},
		{text = getConvertedStr(8, 10026), color = getC3B(_cc.white)}
	}

	local tLabel2 = {
		{text = getConvertedStr(8, 10031) , color = getC3B(_cc.blue)},
		{text = getConvertedStr(8, 10029), color = getC3B(_cc.white)}
	}
	self.pLbMy1:setString(tLabel1)
	self.pLbMy2:setString(tLabel2)

	self.pHero1,self.pArm1 =			self.pParent:createHero(self,"blueArmyLeftUToRightD",10,cc.p(0,0))

	self.pHero2,self.pArm2 =			self.pParent:createHero(self,"blueArmyLeftDToRightU",10,cc.p(0,0))
	self:setCountryShow(false)
end
function CountryHelp:updateViews()
	self:playAnim()
end
function CountryHelp:setCountryShow( showCountry )
	local tLabel = {

		{text = getConvertedStr(8, 10030), color = getC3B(_cc.white)}
	}
	if showCountry then
		tLabel = {
		{text = getConvertedStr(8, 10031) , color = getC3B(_cc.blue)},
		{text = getConvertedStr(8, 10030), color = getC3B(_cc.white)}
		}
		
	
	end
	self.pLbCunName:setString(tLabel)
end
--播放动画
function CountryHelp:playAnim(  )
	self:stopAllActions()

	self:setCountryShow(false)
	self.pHero1:setVisible(false)
	self.pHero2:setVisible(false)

	self:setArmFlippedData(self.pArm1,false,0,"blueArmyLeftUToRightD")
	self:setArmFlippedData(self.pArm2,false,0,"blueArmyLeftDToRightU")

	doDelayForSomething(self,function (  )
		self:playStepOne()
	end,0.5)
end
function CountryHelp:playStepOne()
	
   
   	self.pHero1:setVisible(true)
   
   
   --画行军路线
   local tStart1, tEnd1 = self:addLine(1,1,1)
   self.pHero1:setPosition(tStart1.x,tStart1.y)
   
   local function moveStep1CallBack1(  )
   		self:releaseLine(self.pLine1)
   		--骑兵消失
   		self.pHero1:setVisible(false)
   		
   		--两把剑在乱军头上碰撞3下
   		doDelayForSomething(self,function (  )
   			self:playSwordAnim()
   		end,0.8)
   		

   end
   --小马移动
   local pMove1 = cc.MoveTo:create(4,cc.p(( tEnd1.x ) ,tEnd1.y))
   local callBack1 = cc.CallFunc:create(moveStep1CallBack1)
   local seqAct1 = cc.Sequence:create(pMove1, callBack1)
   self.pHero1:runAction(seqAct1)


   
   self.pHero2:setVisible(true)
    --画行军路线
   local tStart2, tEnd2 = self:addLine(1,2,1)
   self.pHero2:setPosition(cc.p(tStart2.x,tStart2.y))

   local function moveStep1CallBack2(  )
   		self:releaseLine(self.pLine2)
   		--骑兵消失
   		self.pHero2:setVisible(false)
   		
   		--两把剑在乱军头上碰撞3下
   		-- doDelayForSomething(self,function (  )
   		-- 	-- self:playSwordAnim()
   		-- end,0.8)
   		

   end
   --小马移动
   local pMove2 = cc.MoveTo:create(4,cc.p(( tEnd2.x ) ,tEnd2.y))
   local callBack2 = cc.CallFunc:create(moveStep1CallBack2)
   local seqAct2 = cc.Sequence:create(pMove2, callBack2)
	self.pHero2:runAction(seqAct2)


	
	
end

function CountryHelp:playSwordAnim()

	-- for i=1,3 do
	-- 	local pArm = MArmatureUtils:createMArmature(
	-- 		tNormalCusArmDatas["47_"..i],
	-- 		self,
	-- 		10,
	-- 		cc.p(self.pImgLj:getPositionX(),self.pImgLj:getPositionY()+30),
	-- 		function ( _pArm )
	-- 			_pArm:removeSelf()
	-- 			_pArm = nil 
	-- 		end, Scene_arm_type.world)
	-- 	if pArm then
	-- 		pArm:play(3)
	-- 	end
		
	-- 	if i == 3 and pArm then
	-- 		pArm:setMovementEventCallFunc(function ( _pArm )
	-- 			if _pArm then
	-- 				_pArm:removeSelf()
	-- 				_pArm = nil 
	-- 			end
	-- 			self:setCountryShow(true)
	-- 			--剑碰撞3下后乱军消失，骑兵从乱军位置原路返城池，
 --   				doDelayForSomething(self,function (  )
 --   					self:playBackAnim()
 --   				end,0.3)
	-- 		end)
	-- 	end
	-- end
	self.nArmLoopIndex = 0
	local sName = createAnimationBackName("tx/exportjson/", "rwww_gjtx_yhyb_001")
    local pSwordArm = ccs.Armature:create(sName)
    local fX, fY = self.pImgLj:getPositionX(),self.pImgLj:getPositionY()+30
    pSwordArm:setPosition(fX, fY)
    self:addChild(pSwordArm,10)
    pSwordArm:getAnimation():setMovementEventCallFunc(function ( arm, eventType, movmentID )
		if (eventType == MovementEventType.LOOP_COMPLETE) then
			self.nArmLoopIndex = self.nArmLoopIndex + 1
			if self.nArmLoopIndex >= 3 then
				pSwordArm:removeFromParent(true)
				self:setCountryShow(true)
				--剑碰撞3下后乱军消失，骑兵从乱军位置原路返城池，
				doDelayForSomething(self,function (  )
   					self:playBackAnim()
   				end,0.3)
			end
		end
	end)
	pSwordArm:getAnimation():play("Animation1", -1)

end

--添加一条行军路线
--_nType：1：前进  2：返回
--_nDirct 1:上面路线  2.下面路线
function CountryHelp:addLine(_nType,_nDirct,_nLineType)
	local tStart,tEnd = nil ,nil 
	local tPos,pLine = nil ,nil 
	if _nDirct == 1 then
		
		tStart 	= cc.p(self.pBgBlueUp[1]:getPositionX() + 1 ,self.pBgBlueUp[1]:getPositionY() + 44 - 48)
		
		tEnd 	= cc.p(self.pBgRed[1]:getPositionX() + 1 ,self.pBgRed[1]:getPositionY() + 56 - 48)
		if _nType == 2 then
			tEnd 	= cc.p(self.pBgBlueUp[1]:getPositionX() + 1,self.pBgBlueUp[1]:getPositionY() - 48 + 44)
			tStart 	= cc.p(self.pBgRed[1]:getPositionX() ,self.pBgRed[1]:getPositionY() + 56 - 48)
			
		end
		tPos,pLine 		= self.pParent:drawLine(self,tStart,tEnd,_nLineType)
		self.tPosList1 	= tPos
		self.pLine1 	= pLine 
	elseif _nDirct == 2 then
		tStart 	= cc.p(self.pBgBlueDown[1]:getPositionX()  + 2,self.pBgBlueDown[1]:getPositionY() + 33 - 45 )
		
		tEnd 	= cc.p(self.pBgRed[1]:getPositionX() + 1,self.pBgRed[1]:getPositionY() - 45 + self.pArm2:getContentSize().height / 2 * self.pArm2:getScale())
		if _nType == 2 then
			tEnd 	= cc.p(self.pBgBlueDown[1]:getPositionX()  + 2,self.pBgBlueDown[1]:getPositionY() + 33 - 45 )
			tStart 	= cc.p(self.pBgRed[1]:getPositionX() + 1,self.pBgRed[1]:getPositionY() - 45 + self.pArm2:getContentSize().height / 2 * self.pArm2:getScale())
		end
		tPos,pLine 		= self.pParent:drawLine(self,tStart,tEnd,_nLineType)
		self.tPosList2 	= tPos
		self.pLine2 	= pLine 
	end
	return tStart, tEnd
end

--播放返回特效
function CountryHelp:playBackAnim()
	self:setArmFlippedData(self.pArm1,true,40,"blueArmyLeftToRight")
	self.pHero1:setVisible(true)
	

	local tStart1, tEnd1 = self:addLine(2,1,1)
	 self.pHero1:setPosition(tStart1.x,tStart1.y)
	local function moveStep3CallBack1(  )
		self:releaseLine(self.pLine1)
		self.pHero1:setVisible(false)
		--【4】骑兵回到我的城池后消失，显示物品特效（10K银币）。播放结束
		local tItemList = {
							{k= 100001,v = 1},
							{k= 100002,v = 1},
							{k= 100003,v = 1},
							{k= 100004,v = 1},
						}
		
		showGetAllItems(tItemList, 2)
		self:performWithDelay(function (  )
			self:playAnim()
		end,3)
		

	end
	local moveAction1 = cc.MoveTo:create(4, cc.p(tEnd1.x, tEnd1.y))
	local moveCallback1 = cc.CallFunc:create(moveStep3CallBack1)
	local seqAct1 = cc.Sequence:create(moveAction1, moveCallback1)
	self.pHero1:runAction(seqAct1)


	self.pHero2:setVisible(true)
	
	self:setArmFlippedData(self.pArm2,true,0,"blueArmyLeftUToRightD")
	local tStart2, tEnd2 = self:addLine(2,2,1)
	self.pHero2:setPosition(cc.p(tStart2.x,tStart2.y))
	local function moveStep3CallBack2()
		self:releaseLine(self.pLine2)
		self.pHero2:setVisible(false)
		--【4】骑兵回到我的城池后消失，显示物品特效（10K银币）。播放结束
	
		

	end
	local moveAction2 = cc.MoveTo:create(4, cc.p(tEnd2.x, tEnd2.y))
	local moveCallback2 = cc.CallFunc:create(moveStep3CallBack2)
	local seqAct2 = cc.Sequence:create(moveAction2, moveCallback2)
	self.pHero2:runAction(seqAct2)
end

--释放行军路线
function CountryHelp:releaseLine(_pLine)
	if _pLine then
		_pLine:removeFromParent(true)
		_pLine = nil
	end

end
--移动起来
function CountryHelp:onLineMove( )
	local pLine1 = self.pLine1
	local pPosList1 = self.tPosList1
	local pPosIndex1 = self.pPosIndex1
	if pLine1 and pPosList1 and pPosIndex1 then
		pPosIndex1 = pPosIndex1 + 1
		if pPosIndex1 > #pPosList1 then
			pPosIndex1 = 1
		end
		
		--更新位置
		self.pPosIndex1 = pPosIndex1
		local pPos = pPosList1[pPosIndex1]
		local pBatchNode = pLine1.pBatchNode
		if pBatchNode then
			pBatchNode:setPosition(pPos)
		end
	end


	local pLine2 = self.pLine2
	local pPosList2 = self.tPosList2
	local pPosIndex2 = self.pPosIndex2
	if pLine2 and pPosList2 and pPosIndex2 then
		pPosIndex2 = pPosIndex2 + 1
		if pPosIndex2 > #pPosList2 then
			pPosIndex2 = 1
		end
		
		--更新位置
		self.pPosIndex2 = pPosIndex2
		local pPos = pPosList2[pPosIndex2]
		local pBatchNode = pLine2.pBatchNode
		if pBatchNode then
			pBatchNode:setPosition(pPos)
		end
	end
end
function CountryHelp:onResume(  )
	--刷新监听
	self.nUpdateScheduler = MUI.scheduler.scheduleGlobal(function ()
		self:onLineMove()
	end,0.1)
	self:updateViews()
end


function CountryHelp:onPause(  )
	if self.nUpdateScheduler then
	    MUI.scheduler.unscheduleGlobal(self.nUpdateScheduler)
	    self.nUpdateScheduler = nil
	end

	if not tolua.isnull(self.pLine1) then
		self.pLine1:removeFromParent(true)
		self.pLine1 = nil 
	end

	if not tolua.isnull(self.pLine2) then
		self.pLine2:removeFromParent(true)
		self.pLine2 = nil 
	end
end
-- 析构方法
function CountryHelp:onCountryHelpLayerDestroy(  )
    self:onPause()
end
return CountryHelp