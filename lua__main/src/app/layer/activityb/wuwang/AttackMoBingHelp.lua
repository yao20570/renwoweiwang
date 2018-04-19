--
-- Author: tanqian
-- Date: 2017-09-22 14:45:29
--世界帮助->攻打敌人 znf修改
local MCommonView = require("app.common.MCommonView")
local WorldHelpFunc = require("app.layer.worldhelp.WorldHelpFunc")
local AttackMoBingHelp = class("AttackMoBingHelp", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function AttackMoBingHelp:ctor( pParent )
	self:myInit(pParent)
	parseView("lay_help_mobing", handler(self, self.onParseViewCallback))
end

--读入控件后,初始化参数值
function AttackMoBingHelp:myInit(pParent)
	self.pParent 				= 		pParent 			--父层
	self.pHero 					=		nil 
	self.pArm 					= 		nil 
	self.pLine 					= 		nil 
	self.pPosIndex				= 		0 			
	self.tPosList			 	= 		{} 			--记录所有存在的行军路线
	
	
end
--解析界面回调
function AttackMoBingHelp:onParseViewCallback( pView )
	self.pView = pView
	self:setContentSize(pView:getContentSize())
	self:addView(pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("AttackMoBingHelp", handler(self, self.onAtkHelpLayerDestroy))
end
function AttackMoBingHelp:setupViews(  )
	--内容层
	self.pLayContent 	= 			self:findViewByName("middle")
	--城池图片
	self.pImgCity 		= 			self.pView:findViewByName("img_my")
	--乱军图片
	self.pImgLj 		= 			self.pView:findViewByName("img_lj")
	--行军提示图片
	
    self.pBgRed = {}
    self.pBgBlue = {}
    for i = 1, 4 do
	    self.pBgRed[i] 		= 			self.pView:findViewByName("img_lj_red_" .. (i-1))
	    self.pBgBlue[i] 		= 			self.pView:findViewByName("img_my_blue_" .. (i-1))
    end
	for i=1,2 do
		local pLv = self:findViewByName("txt_lv"..i)
		pLv:setString("20",false)
	end
	self.pLbMy 			= 			self.pView:findViewByName("txt_name1")
	self.pLbEnemy 		= 			self.pView:findViewByName("txt_name2")
	
	self.pTxtMobingLv3 		= 			self.pView:findViewByName("txt_mobing_lv3")
	self.pTxtMoBingName3 	= 			self.pView:findViewByName("txt_mobing_name3")
	self.pTxtMobingLv3:setString(20)
	self.pTxtMoBingName3:setString(getConvertedStr(3, 10080))

	self.pTxtMobingLv4 		= 			self.pView:findViewByName("txt_mobing_lv4")
	self.pTxtMoBingName4 	= 			self.pView:findViewByName("txt_mobing_name4")
	self.pTxtMobingLv4:setString(20)
	self.pTxtMoBingName4:setString(getConvertedStr(3, 10080))
	

	self.pLbMy:setString(getConvertedStr(8, 10026))
	self.pLbEnemy:setString(getConvertedStr(3, 10080))

	self.pHero,self.pArm =			WorldHelpFunc.createHero(self,"blueArmyLeftUToRightD",10,cc.p(0,0))
	
	self.pLayLjName		=			self:findViewByName("lay_name2")
end
function AttackMoBingHelp:updateViews()
	self:playAnim()
end


function AttackMoBingHelp:setLjShow( show )
	self.pLayLjName:setVisible(show)
	self.pImgLj:setVisible(show)
	
    for i = 1, 4 do
	    self.pBgRed[i]:setVisible(show)
    end
end
--播放动画
function AttackMoBingHelp:playAnim(  )
	self:stopAllActions()
	self.pHero:setVisible(false)
	self:setLjShow(true)
	doDelayForSomething(self,function (  )
		self:playStepOne()
	end,0.5)
end
function AttackMoBingHelp:playStepOne()
	--画行军路线
   	local tStart, tEnd = self:addLine(1,1)
   self:setArmFlipped(false,0,"blueArmyLeftUToRightD")
   self.pHero:setVisible(true)
   
   
  
   self.pHero:setPosition(cc.p(tStart.x,tStart.y))
   local function moveStep1CallBack(  )

   		--释放行军路线
		self:releaseLine()
   		--骑兵消失
   		self.pHero:setVisible(false)
   		
   		--两把剑在乱军头上碰撞3下
   		doDelayForSomething(self,function (  )
   			self:playSwordAnim()
   		end,0.8)
   		

   end
   --小马移动
  
   local pMove = cc.MoveTo:create(5,cc.p(( tEnd.x ) ,tEnd.y))
   local callBack = cc.CallFunc:create(moveStep1CallBack)
   local seqAct = cc.Sequence:create(pMove, callBack)
	self.pHero:runAction(seqAct)
	
	
end


function AttackMoBingHelp:setArmFlipped( _bFlip,_nRotate,_sName )
	if not self.pArm then
		return 
	end
	if self.pArm then

		self.pArm:setFlippedX(_bFlip)
		self.pArm:setRotation(_nRotate)
		self.pArm:setData(EffectWorldDatas[_sName])
	end
end

function AttackMoBingHelp:playSwordAnim()

	-- for i=1,3 do
	-- 	local pArm = MArmatureUtils:createMArmature(
	-- 		tNormalCusArmDatas["47_"..i],
	-- 		self,
	-- 		10,
	-- 		cc.p(self.pImgLj:getPositionX(),self.pImgLj:getPositionY()+20),
	-- 		function ( _pArm )
	-- 			_pArm:removeSelf()
	-- 			_pArm = nil 
	-- 		end, Scene_arm_type.normal)
	-- 	if pArm then
	-- 		pArm:play(3)
	-- 	end
	-- 	if i == 3  then
	-- 		pArm:setMovementEventCallFunc(function ( _pArm )
	-- 			_pArm:removeSelf()
	-- 			_pArm = nil 
	-- 			--剑碰撞3下后乱军消失，骑兵从乱军位置原路返城池，
	-- 			self:setLjShow(false)
 --   				doDelayForSomething(self,function (  )
 --   					self:playBackAnim()
 --   				end,0.3)
	-- 		end)
	-- 	end
	-- end
	self.nArmLoopIndex = 0
	local sName = createAnimationBackName("tx/exportjson/", "rwww_gjtx_yhyb_001")
    local pSwordArm = ccs.Armature:create(sName)
    local fX, fY = self.pImgLj:getPositionX(),self.pImgLj:getPositionY()+20
    pSwordArm:setPosition(fX, fY)
    self:addChild(pSwordArm,10)
    pSwordArm:getAnimation():setMovementEventCallFunc(function ( arm, eventType, movmentID )
		if (eventType == MovementEventType.LOOP_COMPLETE) then
			self.nArmLoopIndex = self.nArmLoopIndex + 1
			if self.nArmLoopIndex >= 3 then
				pSwordArm:removeFromParent(true)
				self:setLjShow(false)
				--剑碰撞3下后乱军消失，骑兵从乱军位置原路返城池
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
function AttackMoBingHelp:addLine(_nType,_nLineType)
	


	local tStart = cc.p(self.pBgBlue[1]:getPositionX() + 1 ,self.pBgBlue[1]:getPositionY() - 48 + self.pArm:getContentSize().height / 2*self.pArm:getScale())
	local tEnd = cc.p(self.pBgRed[1]:getPositionX() +1,
		self.pBgRed[1]:getPositionY() + self.pArm:getContentSize().height / 2 *self.pArm:getScale()  - 48)


	if _nType == 2 then
		 tEnd = cc.p(self.pBgBlue[1]:getPositionX() + 1 ,self.pBgBlue[1]:getPositionY() - 48 + self.pArm:getContentSize().height / 2*self.pArm:getScale())
		 tStart = cc.p(self.pBgRed[1]:getPositionX() +1,
		self.pBgRed[1]:getPositionY() + self.pArm:getContentSize().height / 2 *self.pArm:getScale()  - 48)
	end
	local tPos,pLine = WorldHelpFunc.drawLine(self,tStart,tEnd,_nLineType)
	self.tPosList = tPos
	self.pLine = pLine 

	return tStart, tEnd
end

--释放行军路线
function AttackMoBingHelp:releaseLine( )
	if not tolua.isnull(self.pLine)  then
		self.pLine:removeFromParent(true)
		self.pLine = nil
	end
end

--播放返回特效
function AttackMoBingHelp:playBackAnim()
	self.pHero:setVisible(true)
	
	self:setArmFlipped(true,0,"blueArmyLeftToRight")
	local tStart, tEnd = self:addLine(2,1)
	self.pHero:setPosition(cc.p(tStart.x,tStart.y))
	local function moveStep3CallBack(  )
		--释放行军路线
		self:releaseLine()
		self.pHero:setVisible(false)

		local bIsCanShow = self.pParent:getIsCanShowGetItem()
		if bIsCanShow then
			--【4】骑兵回到我的城池后消失，显示物品特效（10K银币）。播放结束
			local tItemList = {{k= 100154,v = 1}}
			showGetAllItems(tItemList, 2)
		end
		self:performWithDelay(function (  )
			self:playAnim()
		end,3)
		

	end
	local moveAction = cc.MoveTo:create(5.0, cc.p(tEnd.x, tEnd.y))
	local moveCallback = cc.CallFunc:create(moveStep3CallBack)
	local seqAct = cc.Sequence:create(moveAction, moveCallback)
	self.pHero:runAction(seqAct)
end
function AttackMoBingHelp:onResume(  )
	--刷新监听
	self.nUpdateScheduler = MUI.scheduler.scheduleGlobal(function ()
		self:onLineMove()
	end,0.1)
	self:updateViews()
end

--移动起来
function AttackMoBingHelp:onLineMove( )
	local pLine = self.pLine
	local pPosList = self.tPosList
	local pPosIndex = self.pPosIndex
	if pLine and pPosList and pPosIndex then
		pPosIndex = pPosIndex + 1
		if pPosIndex > #pPosList then
			pPosIndex = 1
		end
		
		--更新位置
		self.pPosIndex = pPosIndex
		local pPos = pPosList[pPosIndex]
		local pBatchNode = pLine.pBatchNode
		if pBatchNode then
			pBatchNode:setPosition(pPos)
		end
	end
end


function AttackMoBingHelp:onPause(  )
	
end
-- 析构方法
function AttackMoBingHelp:onAtkHelpLayerDestroy(  )

	--去掉监听刷新
	if self.nUpdateScheduler then
	    MUI.scheduler.unscheduleGlobal(self.nUpdateScheduler)
	    self.nUpdateScheduler = nil
	end

   self:stopAllActions()

   self:releaseLine()
end
return AttackMoBingHelp