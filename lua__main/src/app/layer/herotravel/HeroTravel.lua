-----------------------------------------------------
-- author: luwenjing
-- updatetime:  2017-12-07 20:29:16 星期四
-- Description: 武将游历入口
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local BuildBubbleLayer = require("app.layer.build.BuildBubbleLayer")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")


local HeroTravel = class("HeroTravel", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--_tBuildInfo：建筑数据
function HeroTravel:ctor( )
	-- body
	self:myInit()
	-- if not _tInfo then
	-- 	return
	-- end

	parseView("hero_travel", handler(self, self.onParseViewCallback))

end

--初始化成员变量
function HeroTravel:myInit(  )
	self.tTravelData 			= 		nil 		--建筑展示相关数据

end

--解析布局回调事件
function HeroTravel:onParseViewCallback( pView )
	-- body
	self:addView(pView,200)
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("HeroTravel",handler(self, self.onHeroTravelDestroy))
end

--初始化控件
function HeroTravel:setupViews( )
	-- body	

	self.pItem 			= 		self:findViewByName("default")
	self.pLayIcon 			= 		self:findViewByName("lay_icon")
	self.pLayTime 			=		self:findViewByName("lay_time")
	self.pTxtTime 			=		self:findViewByName("txt_time")
	self.pLayBubble 			=		self:findViewByName("lay_bubble")
	self.pTxtQueue 			=		self:findViewByName("txt_queue")
	self.pTxtQueue:enableOutline(getC4B(_cc.black),2)
	setTextCCColor(self.pTxtQueue, _cc.white)
	self.pLayBar			=		self:findViewByName("lay_bar_bg2")
	self.pItem:setViewTouched(true)
	self.pItem:setIsPressedNeedScale(false)
	self.pItem:onMViewClicked(handler(self, self.onItemClicked))

	self.nLeftTimeId=0
	self.tDbData=nil
end

-- 修改控件内容或者是刷新控件数据
function HeroTravel:updateViews(  )
	-- body
	local tTravelList=Player:getHeroTravelData():getHeroTravelList()
	local fLeftTime=0
	local nQueueCount=0
	local bIsShowTx=false
	self.tDbData=nil
	for k,v in pairs(tTravelList) do
		if v.nCd==0  or Player:getHeroTravelData():getTraveLeftTime(v.nQueueId) == 0 then
			bIsShowTx=true
		elseif Player:getHeroTravelData():getTraveLeftTime(v.nQueueId) > 0 then
			nQueueCount = nQueueCount +1 
			if fLeftTime == 0 or fLeftTime>=Player:getHeroTravelData():getTraveLeftTime(v.nQueueId) then
				self.nLeftTimeId = v.nQueueId
				self.tDbData=getHeroTravelData(v.nTaskId)
				fLeftTime=Player:getHeroTravelData():getTraveLeftTime(v.nQueueId)

			end
		end

	end
	if bIsShowTx then
		self:showIconTx()
	else
		self:hideIconTx()
	end
	if fLeftTime ~=0 then
		-- print("hereeee")
		-- --进度条
		if not self.pLoadingBar then
			self.pLoadingBar = MCommonProgressBar.new({bar = "v1_bar_blue_sc.png",barWidth = 126, barHeight = 16})
			self.pLayBar:addView(self.pLoadingBar)
			centerInView(self.pLayBar,self.pLoadingBar)
		end
		regUpdateControl(self, handler(self, self.onUpdateTime))		--注册更新倒计时
	else
		self.pLayTime:setVisible(false)
		self.nLeftTimeId=0
		unregUpdateControl(self)
	end
	if nQueueCount > 0 then


		self.pTxtQueue:setVisible(true)

		-- local tStr={
		-- 	{color=_cc.white,text=getConvertedStr(9, 10046)},
		-- 	{color=_cc.blue,text=tostring(nQueueCount)},
		-- 	{color=_cc.white,text="/"..#tTravelList},

		-- }
		local sStr= getConvertedStr(9, 10046) .. tostring(nQueueCount) .. "/"..#tTravelList

		self.pTxtQueue:setString(sStr)
	else
		self.pTxtQueue:setVisible(false)
	end
	if nQueueCount ~= #tTravelList  then   --队列满的时候才不显示冒泡  队列都在生产中 没有可领取的时候 
		-- self.pTxtQueue:setVisible(false)
		self:showBubble()
	else

		self:hideBubble()
	end
	
end

-- 析构方法
function HeroTravel:onHeroTravelDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function HeroTravel:regMsgs( )
	-- body
	regMsg(self, ghd_hero_travel_update, handler(self, self.updateViews))
	
end


-- 注销消息
function HeroTravel:unregMsgs(  )
	-- body
	unregMsg(self, ghd_hero_travel_update)
end

function HeroTravel:onItemClicked( )
 	-- body
 	local bIsOpen = getIsReachOpenCon(16, true)
	if not bIsOpen then
		return
	end
 	local tObject = {}
 	tObject.nType = e_dlg_index.dlgherotravel --dlg类型
 	sendMsg(ghd_show_dlg_by_type,tObject)

end

--图标特效
function HeroTravel:showIconTx()
	-- body
	if not self.pImgLight then

		self.pImgLight = MUI.MImage.new("#sg_zcj_ta_tix_01.png")
		self.pImgLight:setOpacity(0)
					
		self.pLayIcon:addView(self.pImgLight, 10)
		-- self.pImgBLight:setScale(2)
		-- self.pImgFcBx:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		

		centerInView(self.pLayIcon,self.pImgLight)
		self.pImgLight:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		local action1 = cc.FadeTo:create(1.2, 0)						       
		local action2 = cc.FadeTo:create(1.2, 0.17 * 255)						       
		self.pImgLight:runAction(cc.RepeatForever:create(cc.Sequence:create(action1, action2)))	
	end
	if not self.pParitcleC then
		self.pParitcleC = createParitcle("tx/other/lizi_zcj_ta_s_005.plist")
		self.pParitcleC:setPosition(self.pLayIcon:getWidth() / 2 ,self.pLayIcon:getHeight() / 2)
		self.pLayIcon:addView(self.pParitcleC, 99)
		centerInView(self.pLayIcon,self.pParitcleC)
	end
end
function HeroTravel:hideIconTx(  )
	-- body
	if self.pImgLight then
		self.pImgLight:stopAllActions()
		self.pImgLight:removeSelf()
		self.pImgLight = nil
	end
	--粒子效果
	if self.pParitcleC then
		self.pParitcleC:removeSelf()
		self.pParitcleC = nil
	end

end

function HeroTravel:onUpdateTime(  )
	-- body
	local fLeftTime=Player:getHeroTravelData():getTraveLeftTime(self.nLeftTimeId)
	if fLeftTime >0 then

		self.pLayTime:setVisible(true)
		self.pTxtTime:setString(formatTimeToHms(Player:getHeroTravelData():getTraveLeftTime(self.nLeftTimeId)),false)

		local nPercent = math.floor( (self.tDbData.times - fLeftTime )/ self.tDbData.times * 100)

		self.pLoadingBar:setPercent(nPercent)

			-- unregUpdateControl(self)
			-- self.pLbParam4:setString(formatTimeToHms(0))
		-- self.pLoadingBar:setPercent(100)
	else 
		self:updateViews()
		-- unregUpdateControl(self)--停止计时刷新
	end

	
end

function HeroTravel:showBubble( )
	-- body
	if not self.pBubbleLayer then

		self.pBubbleLayer = BuildBubbleLayer.new()
		
		self.pLayBubble:addView(self.pBubbleLayer, 101)
		--设置位置
		local nPosX =0
		local nPosY = 0
		self.pBubbleLayer:setPosition(nPosX, nPosY)
		-- centerInView(self.pLayBubble,self.pBubbleLayer)
		self.pBubbleLayer:setClickedCallBack(handler(self, self.onItemClicked))
	end
	--展示冒泡
	self.pLayBubble:setVisible(true)
	self.pBubbleLayer:setVisible(true)
	self.pBubbleLayer:setCurData(2, e_type_bubble.herotravel)
	
end
function HeroTravel:hideBubble( )
	-- body
	if self.pBubbleLayer then
		self.pLayBubble:setVisible(false)
		self.pBubbleLayer:setVisible(false)
	end
end


--暂停方法
function HeroTravel:onPause( )
	-- body
	self:unregMsgs()
end

--继续方法
function HeroTravel:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end


return HeroTravel