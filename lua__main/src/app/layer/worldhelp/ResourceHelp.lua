--
-- Author: tanqian
-- Date: 2017-09-25 19:48:46
--世界帮组->采集资源

local MCommonView = require("app.common.MCommonView")
local ResourceHelp = class("ResourceHelp", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ResourceHelp:ctor(_parent)
	self:myInit()
	self.pParent = _parent
	parseView("lay_help_5", handler(self, self.onParseViewCallback))
end

--读入控件后,初始化参数值
function ResourceHelp:myInit()
	self.pParent 				= 		nil 			--父层
	self.pHero 					=		nil 
	self.pArm 					= 		nil 
	self.pLine 					= 		nil 
	self.pPosIndex				= 		0 			
	self.tPosList			 	= 		{} 			--记录所有存在的行军路线
end
--解析界面回调
function ResourceHelp:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ResourceHelp", handler(self, self.onResourceHelpLayerDestroy))
end
function ResourceHelp:setupViews(  )
	--内容层
	self.pLayContent 	= 			self:findViewByName("middle")
	--城池图片
	self.pImgCity 		= 			self:findViewByName("img_my")
	--乱军图片
	self.pImgFarm 		= 			self:findViewByName("img_enenmy")
	--行军提示图片
	-- self.pImgHorse 		= 			self:findViewByName("img_horse")
	local pMyLv 		=			self:findViewByName("txt_my_lv")
	local pFarmLv 		=			self:findViewByName("txt_farm_lv")
	self.pLbMy 			= 			self:findViewByName("txt_my_name")
	self.pLbEnemy 		= 			self:findViewByName("txt_far_name")
    
    self.pBgRed = {}
    self.pBgBlue = {}
    for i = 1, 4 do
	    self.pBgRed[i] 	= 			self:findViewByName("img_lj_red_" .. ( i - 1))
	    self.pBgBlue[i] = 			self:findViewByName("img_my_blue_" .. ( i - 1))
	end

	pMyLv:setString("20",false)
	pFarmLv:setString("20",false)
	self.pLbMy:setString(getConvertedStr(8, 10026))
	self.pLbEnemy:setString(getConvertedStr(8, 10032))
	self.pHero,self.pArm =			self.pParent:createHero(self,"blueArmyLeftUToRightD",10,cc.p(0,0))

	self.pImgMy1        =           self:findViewByName("img_my1")
	self.pImgMy1:setScale(0.26)
end
function ResourceHelp:updateViews()
	self:playAnim()
end
--播放动画
function ResourceHelp:playAnim(  )
	self:stopAllActions()
	self.pHero:setVisible(false)
	doDelayForSomething(self,function (  )
		self:playStepOne()
	end,0.5)
end

function ResourceHelp:setArmFlipped( _bFlip,_nRotate,_sName )
	if not self.pArm then
		return 
	end
	if self.pArm then

		self.pArm:setFlippedX(_bFlip)
		self.pArm:setRotation(_nRotate)
		self.pArm:setData(EffectWorldDatas[_sName])
	end
end
function ResourceHelp:playStepOne()
	--画行军路线
   	local tStart, tEnd = self:addLine(1,1)
   self:setArmFlipped(false,0,"blueArmyLeftUToRightD")
   self.pHero:setVisible(true)
   self.pHero:setPosition(cc.p(tStart.x,tStart.y))
   -- self:playHoleAnim()
   local function moveStep1CallBack(  )

   		--释放行军路线
		self:releaseLine()
   		--骑兵消失
   		self.pHero:setVisible(false)
   		
   		--两把剑在乱军头上碰撞3下
   		doDelayForSomething(self,function (  )
   			self:playHoleAnim()
   		end,0.8)
   		

   end
   --小马移动
  
   local pMove = cc.MoveTo:create(5,cc.p(( tEnd.x ) ,tEnd.y))
   local callBack = cc.CallFunc:create(moveStep1CallBack)
   local seqAct = cc.Sequence:create(pMove, callBack)
	self.pHero:runAction(seqAct)
	
	
end

function ResourceHelp:playHoleAnim()
	local pHole =  MUI.MImage.new("#tiegao00_01.png")
	pHole:setZOrder(self.pImgFarm:getLocalZOrder() + 5)
	-- - pHole:getWidth() / 2
	pHole:setPosition(cc.p(self.pImgFarm:getPositionX() ,  
        self.pImgFarm:getPositionY() ))

	 local callback =  function  (  )
     

        -- 添加覆盖层
        local pImgTemp =MUI.MImage.new("#11010_img_hd.png")
     
        pImgTemp:setZOrder(self.pImgFarm:getLocalZOrder() + 1)
        pImgTemp:setScale(1)
        pImgTemp:setPosition(self.pImgFarm:getPosition())
        self.pLayContent:addView(pImgTemp)
        pImgTemp:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
       

        local fadeto = cc.FadeOut:create(0.2)
        pImgTemp:runAction(fadeto)

    end
	local callEnd = cc.CallFunc:create(function (  )
		pHole:stopAllActions()
        pHole:removeFromParent(true)
		--剑碰撞3下后乱军消失，骑兵从乱军位置原路返城池，
   				doDelayForSomething(self,function (  )
   					self:playBackAnim()
   				end,0.3)
	end)
	
	local pSe = cc.Sequence:create({
			cc.RotateTo:create(0.1,60),
			cc.CallFunc:create(callback),
			cc.DelayTime:create(0.15),
			cc.RotateTo:create(0.1,0),
		})
	self.pLayContent:addView(pHole)
	local pRepeat = cc.Repeat:create(pSe, 3)
	
	local pSe = cc.Sequence:create(pRepeat,callEnd)
	pHole:runAction(pSe)
    
	

end

--添加一条行军路线
--_nType：1：前进  2：返回
function ResourceHelp:addLine(_nType,_nLineType)
	local tStart = cc.p(self.pBgBlue[1]:getPositionX() + 1 ,self.pBgBlue[1]:getPositionY() - 48 + self.pArm:getContentSize().height / 2*self.pArm:getScale() - 20)
	local tEnd = cc.p(self.pBgRed[1]:getPositionX() +1,
		self.pBgRed[1]:getPositionY() + self.pArm:getContentSize().height / 2 *self.pArm:getScale()  - 48)


	if _nType == 2 then
 		tEnd = cc.p(self.pBgBlue[1]:getPositionX() + 1 ,self.pBgBlue[1]:getPositionY() - 48 + self.pArm:getContentSize().height / 2*self.pArm:getScale() - 20)
 		tStart = cc.p(self.pBgRed[1]:getPositionX() +1,
		self.pBgRed[1]:getPositionY() + self.pArm:getContentSize().height / 2 *self.pArm:getScale()  - 48)
	end
	local tPos,pLine = self.pParent:drawLine(self,tStart,tEnd,_nLineType)
	self.tPosList = tPos
	self.pLine = pLine 

	return tStart, tEnd
end

--播放返回特效
function ResourceHelp:playBackAnim()
	self.pHero:setVisible(true)
	self:setArmFlipped(true,40,"blueArmyLeftToRight")
	local tStart, tEnd = self:addLine(2,1)
	self.pHero:setPosition(cc.p(tStart.x,tStart.y))
	local function moveStep3CallBack(  )
		self:releaseLine()
		self.pHero:setVisible(false)
		--【4】骑兵回到我的城池后消失，显示物品特效（10K银币）。播放结束
		local tItemList = {{k= 100010,v = 1}}
		showGetAllItems(tItemList, 2)
		self:performWithDelay(function (  )
			self:playAnim()
		end,3)
		

	end
	local moveAction = cc.MoveTo:create(5.0, cc.p(tEnd.x, tEnd.y))
	local moveCallback = cc.CallFunc:create(moveStep3CallBack)
	local seqAct = cc.Sequence:create(moveAction, moveCallback)
	self.pHero:runAction(seqAct)
end

--释放行军路线
function ResourceHelp:releaseLine( )
	if not tolua.isnull(self.pLine) then
		self.pLine:removeFromParent(true)
		self.pLine = nil
	end
end
function ResourceHelp:onResume(  )
	self.nUpdateScheduler = MUI.scheduler.scheduleGlobal(function ()
		self:onLineMove()
	end,0.1)
	self:updateViews()
end
--移动起来
function ResourceHelp:onLineMove( )
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

function ResourceHelp:onPause(  )
	--去掉监听刷新
	if self.nUpdateScheduler then
	    MUI.scheduler.unscheduleGlobal(self.nUpdateScheduler)
	    self.nUpdateScheduler = nil
	end
   	self:releaseLine()
end
-- 析构方法
function ResourceHelp:onResourceHelpLayerDestroy(  )
	self:onPause()
end
return ResourceHelp