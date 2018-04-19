-----------------------------------------------------
-- author: liangzhaowei
-- Date: 2017-05-11 15:17:10
-- Description: 城墙
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local LayWallHeros = require("app.layer.wall.LayWallHeros")
local LayWallNpcs = require("app.layer.wall.LayWallNpcs")
local LayWallMain = class("LayWallMain", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

function LayWallMain:ctor(_tSize)
	-- body
	self:setContentSize(_tSize)
	self:myInit()
	--self:refreshData() --刷新数据
	parseView("dlg_home_wall", handler(self, self.onParseViewCallback))
	

end

--初始化成员变量
function LayWallMain:myInit()
	-- body
	self.pData = nil --城墙数据
 	self.bBtnLExText = nil --左边按钮额外 
 	self.pHeroScorll = nil
end

--刷新数据
function LayWallMain:refreshData()
	self.pData = Player:getBuildData():getBuildById(e_build_ids.gate) --城墙数据
end
--解析布局回调事件
function LayWallMain:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("LayWallMain",handler(self, self.onDestroy))	
end

--初始化控件
function LayWallMain:setupViews( )
	
end

-- 修改控件内容或者是刷新控件数据
function LayWallMain:updateViews()
	self:refreshData() --刷新数据

	if not self.pData then
		return
	end

	gRefreshViewsAsync(self, 2, function ( _bEnd, _index )
		if _index == 1 then

			--ly
			--顶部按钮层
			if not self.pLayTop then
				self.pLayTop 				= 		self:findViewByName("ly_top")
				self.pLayTop:setZOrder(10)			  
			    --头顶横条(banner)
			    local pBannerImage 			= 		self:findViewByName("lay_banner_bg")
			    setMBannerImage(pBannerImage,TypeBannerUsed.cm)
			    self.pLayTitle 				= 		self:findViewByName("lay_desc")
			    self.pLayTitle:setZOrder(5)
			end

			--武将显示层
			if not self.pLyHeroScorll then
				self.pLyHeroScorll = self:findViewByName("lay_scroll")								
			end
			local pSize = self.pLyHeroScorll:getContentSize()
			if not self.pHeroScorll then								
				self.pHeroScorll = MUI.MScrollLayer.new( {
	                viewRect = cc.rect(0,0,pSize.width,pSize.height),
	                touchOnContent = true,
	                direction = MUI.MScrollLayer.DIRECTION_VERTICAL
	            })
	            -- self.pHeroScorll:setName("self.pHeroScorll")
				self.pHeroScorll:setPosition(0, 0)				
				self.pHeroScorll:setBounceable(false)	
				self.pLyHeroScorll:addView(self.pHeroScorll, 10)										
				-- --上下箭头
				local pUpArrow, pDownArrow = getUpAndDownArrow()
				self.pHeroScorll:setUpAndDownArrow(pUpArrow, pDownArrow)

			    self.pLayHeroAtk = LayWallHeros.new(e_hero_team_type.normal)
			    self.pHeroScorll:addView(self.pLayHeroAtk)

			    self.pLayHeroDef = LayWallHeros.new(e_hero_team_type.walldef)			    		
			    self.pHeroScorll:addView(self.pLayHeroDef)

			    self.pLayWallNpcs = LayWallNpcs:new()			    			    
			    self.pHeroScorll:addView(self.pLayWallNpcs)	
			
			    local nHeight = self.pLayHeroAtk:getContentSize().height + self.pLayHeroDef:getContentSize().height + self.pLayWallNpcs:getContentSize().height
			    -- myprint("nHeight---------", nHeight)
				self.pHeroScorll:scrollToBegin(false)			    
			else	
				self.pLayHeroAtk:updateViews()									
				self.pLayHeroDef:updateViews()
				self.pLayWallNpcs:updateViews()			
			end								
			self.pHeroScorll:updateSizeFromChild()

			--按钮
			if not self.pLyBtnL then
				self.pLyBtnL     			= 		self:findViewByName("ly_btn_l")
				self.pLyBtnR    			= 		self:findViewByName("ly_btn_r")
				self.pLyTitle   			= 		self:findViewByName("ly_title")

				showRedTips( self.pLyBtnR,0,0)

				self.pBtnL =  getCommonButtonOfContainer(self.pLyBtnL,TypeCommonBtn.L_YELLOW,getConvertedStr(5,10073))
				self.pBtnR =  getCommonButtonOfContainer(self.pLyBtnR,TypeCommonBtn.L_BLUE,getConvertedStr(5,10074))				
				self.pBtnL:onCommonBtnClicked(handler(self, self.onBtnLClicked))
				self.pBtnR:onCommonBtnClicked(handler(self, self.onBtnRClicked))	

				local tBtnRTable = {}
				--文本
				local tRLabel = {
					{getConvertedStr(5, 10068),getC3B(_cc.green)},
				}
				tBtnRTable.tLabel = tRLabel
				self.RightExText =  self.pBtnR:setBtnExText(tBtnRTable) --按钮上扩展的文本

				--一键提升
				local tBtnLUpTable = {}
				--文本
				local tUpLLabel = {
					{self.pData:getUpdateAllGateNpcGold(),getC3B(_cc.pwhite)},
				}
				tBtnLUpTable.tLabel = tUpLLabel
				tBtnLUpTable.img = "#v1_img_qianbi.png"
				self.bBtnLExText =  self.pBtnL:setBtnExText(tBtnLUpTable)

			end	
			--刷新一键提升金币个数
			self.pBtnL:setExTextLbCnCr(1,self.pData:getUpdateAllGateNpcGold())

			--刷新底部按钮
			self:resetDownBtn()

			--初始化文字
			if not self.pLbTop2 then
				--lb
				self.pLbTop2                 =     self:findViewByName("lb_title_2")

				self.pLbOnlineTitlel         =     self:findViewByName("lb_online_title_l")
				self.pTip 					 = 	   self:findViewByName("lb_tips")
				--初始化文字
				self.pLbTop2:setString(getTipsByIndex(10008)) --标题提示语
				self.pLbOnlineTitlel:setString(getConvertedStr(5, 10072))
				-- 
			end
		    --城防军守卫数量
			self.pTip:setString(self:getDefenseArmyState(), false)
		elseif _index == 2 then
			--刷新标题按钮状态
			self:updateBotBtnState()

		end
	end)



end

--获取守卫军数量状态
function LayWallMain:getDefenseArmyState()
	local tStr = {}

	if self.pData then
		local nNum = self:getWallMaxNums() --城防军容量
	    tStr = {
	    	{color=_cc.green,text=getConvertedStr(7, 10278)},
	    	{color=_cc.green,text=table.nums(self.pData.tDs)},
	    	{color=_cc.white,text="/"..nNum},
	    }
	end

	return tStr
end

--获取城防军容量
function LayWallMain:getWallMaxNums()
	local nNum = getWallBaseDataByLv(self.pData.nLv).num or 0 --城防军容量
	return nNum 
end

--标题按钮状态
function LayWallMain:updateBotBtnState()
	local nNum = self:getWallMaxNums() --城防军容量
	if table.nums(self.pData.tDs) < nNum then
		self.pBtnR:setBtnEnable(true)
		if self.pData:getRecruitCd() > 0 then
	       self.pBtnR:setButton(TypeCommonBtn.L_YELLOW,getConvertedStr(5,10070))
	       self.RightExText:setImg("#v1_img_shizhong.png",false)
	       self.RightExText:setLabelCnCr(1,formatTimeToHms(self.pData:getRecruitCd()),getC3B(_cc.red))
	       showRedTips( self.pLyBtnR,0,0)
	    else
	       self.pBtnR:setButton(TypeCommonBtn.L_BLUE,getConvertedStr(5,10069))
	       self.RightExText:setImg()
	       self.RightExText:setLabelCnCr(1,getConvertedStr(5, 10069),getC3B(_cc.green))
	       showRedTips( self.pLyBtnR,0,1)
		end
	else
	   showRedTips( self.pLyBtnR,0,0)
       self.pBtnR:setBtnEnable(false)
       self.RightExText:setImg()
       self.RightExText:setLabelCnCr(1,getConvertedStr(5, 10076),getC3B(_cc.pwhite))
	end
end

--时间刷新函数
function LayWallMain:updateCd()

	if self.pData:getRecruitCd() > 0 and self:bLackWallDef() and self.RightExText then
       self.RightExText:setLabelCnCr(1,formatTimeToHms(self.pData:getRecruitCd())) 
       if self.pData:getRecruitCd() == 1 then
       		doDelayForSomething(self,function ()
       			self:updateViews()
       		end,1)
       end
	end
end

-- 重置底部按钮数据
function LayWallMain:resetDownBtn(  )

	--是否需要一键提升
	if self.pData:getUpdateAllGateNpcGold() > 0 then
		self.bBtnLExText:setVisible(true)
		self.pBtnL:setBtnEnable(true)
		self.pBtnL:setVisible(true)
		self.pLyBtnR:setPositionX(410)
	else
		self.bBtnLExText:setVisible(false)
		self.pBtnL:setBtnEnable(false)
		self.pBtnL:setVisible(false)
		self.pLyBtnR:setPositionX(242)
	end


	-- if Player:getWorldData():getHaveNewHelpMsgs() then
	-- 	showRedTips( self.pLyBtnR,0,1)
	-- else
	-- 	showRedTips( self.pLyBtnR,0,0)
	-- end

	--是否满足驻防条件
	-- local nLimitLv = tonumber(getWallInitParam("guardLv")) 
	-- if self.pData.nLv < nLimitLv then
	-- 	self.pBtnR:setBtnEnable(false)
	-- 	self.RightExText:setLabelCnCr(1,string.format(getConvertedStr(5, 10092),nLimitLv),getC3B(_cc.white))
	-- 	self.RightExText:setLabelCnCr(2,"")
	-- 	self.RightExText:setLabelCnCr(3,"")
	-- else
	-- 	local tHelpMsgs = Player:getWorldData():getHelpMsgs()
	-- 	self.pBtnR:setBtnEnable(true)
	-- 	self.RightExText:setLabelCnCr(1,table.nums(tHelpMsgs),getC3B(_cc.green))
	-- 	self.RightExText:setLabelCnCr(2,"/")
	-- 	self.RightExText:setLabelCnCr(3,getWallBaseDataByLv(self.pData.nLv).guardnum)
	-- end
end

--城防npc数量是否少于城防容量  true 为缺少
function LayWallMain:bLackWallDef()
	local nNum = self:getWallMaxNums() --城防军容量
	local nNowNpc = table.nums(self.pData.tDs) --现在城防npc个数
	local bLcak = false

	if nNowNpc < nNum then
		bLcak = true
	else
		bLcak = false
	end

	return bLcak
end


--接收服务端发回的登录回调
function LayWallMain:onGetDataFunc( __msg )
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.wallRecruitDef.id then
			self:updateViews()
			TOAST(getConvertedStr(6, 10728))
		elseif __msg.head.type == MsgType.wallOperation.id then
			self:updateViews()
        end
    else
        --弹出错误提示语
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end


--左边按钮点击事件
function LayWallMain:onBtnLClicked(pView)

	local bUpDate = self.pData:getBCureDef()

	if bUpDate then
		TOAST(getConvertedStr(5, 10217)) --一键提升需要先治疗受伤守卫 by 青山
		return
	end

	local nCost = self.pData:getUpdateAllGateNpcGold()
	if nCost > 0 then
		local tTextLb = {
	    	{color=_cc.pwhite,text=getConvertedStr(5,10084)},
    	}
		showBuyDlg(tTextLb, nCost, function ()
			SocketManager:sendMsg("wallOperation", {2}, handler(self, self.onGetDataFunc))
		end)
	end

end

--右边按钮点击事件
function LayWallMain:onBtnRClicked(pView)

	if self:bLackWallDef() then
		local nType = 1
		local nCd = self.pData:getRecruitCd()
		if nCd > 0 then
			nType = 2
		end

		if nType == 1 then
	    	SocketManager:sendMsg("wallRecruitDef", {nType}, handler(self, self.onGetDataFunc))
	    else
			local nCost = 0
			nCost =  math.ceil(math.ceil(nCd/60) * tonumber(getWallInitParam("deleteCD")))
    		if nCost > 0 then
				local tTextLb = {
			    	{color=_cc.pwhite,text=getConvertedStr(5,10083)},--招募
		    	}
				showBuyDlg(tTextLb, nCost, function ()
					SocketManager:sendMsg("wallRecruitDef", {nType}, handler(self, self.onGetDataFunc))
				end,0,true)
			end
		end
	end
end

-- 析构方法
function LayWallMain:onDestroy(  )
	-- body	
	self:onPause()
end

-- 注册消息
function LayWallMain:regMsgs( )
	-- body
	regUpdateControl(self, handler(self, self.updateCd))
	-- 注册招募城墙守卫刷新消息
	regMsg(self, ghd_recruit_wall_wall, handler(self, self.onBtnRClicked))
	--注册刷新城墙界面
	regMsg(self, gud_refresh_wall, handler(self, self.updateViews))
	-- 注册英雄界面刷新
	regMsg(self, gud_refresh_hero, handler(self, self.updateViews))
	
end

-- 注销消息
function LayWallMain:unregMsgs(  )
	unregUpdateControl(self)
	--注销招募城墙守卫
	unregMsg(self, ghd_recruit_wall_wall)
	--注销刷新城墙界面
	unregMsg(self, gud_refresh_wall)
	--注销英雄界面刷新
	unregMsg(self, gud_refresh_hero)
end


--暂停方法
function LayWallMain:onPause( )

	removeTextureFromCache("tx/other/sg_tx_jmtx_smjsj")

	-- if self.pLayHeroAtk then
	-- 	self.pLayHeroAtk:saveHeroLocation()
	-- end
	-- if self.pLayHeroDef then
	-- 	self.pLayHeroDef:saveHeroLocation()
	-- end

	self:unregMsgs()
end

--继续方法
function LayWallMain:onResume( )
	addTextureToCache("tx/other/sg_tx_jmtx_smjsj")
	
	self:updateViews()
	self:regMsgs()
end

return LayWallMain