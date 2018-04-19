--
-- Author: liangzhaowei
-- Date: 2017-04-14 17:18:15
-- 副本特殊关卡入口关卡
local MRichLabel = require("app.common.richview.MRichLabel")
local MCommonView = require("app.common.MCommonView")
local ItemFubenSpecialLevel = class("ItemFubenSpecialLevel", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)
 

 --特殊关卡类型
 -- SPLVTYPE.recruit
local SPLVTYPE = {
	recruit = 1, --招募
	countryWp = 2, --国器
	resource = 3,  --资源(补给)
	equip =  4, --装备
	drawing = 5, --图纸

}

--_index
function ItemFubenSpecialLevel:ctor()
	-- body
	self:myInit()

	regUpdateControl(self, handler(self, self.updateCd))

	parseView("item_fuben_special_level", handler(self, self.onParseViewCallback))
	
	--注册析构方法
	self:setDestroyHandler("ItemFubenSpecialLevel",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemFubenSpecialLevel:myInit()
	self.pData = {} --章节数据
	self.tConscribeHero = {} --招募英雄列表
	self.nBuyHeroCoin = 0 --招募英雄花费
end

--解析布局回调事件
function ItemFubenSpecialLevel:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)


	self:setViewTouched(true)
	self:setIsPressedNeedScale(false)
	self:onMViewClicked(handler(self, self.onViewClick))

	--ly
	self.pLyBuyHero =  self:findViewByName("ly_buy_hero") 
	self.pLyMain =  self:findViewByName("ly_main") 
	self.pLyQiPao =  self:findViewByName("ly_qipao") 


	self.pLyBuyHero:setVisible(false)               	


	--lb
	self.pLbBuyPrice = self:findViewByName("lb_buy_price")
	setTextCCColor(self.pLbBuyPrice,_cc.yellow)
	self.pLbIcon = self:findViewByName("lb_con")
	self.pLbTime = self:findViewByName("lb_time")

	--img
	self.pImgIcon = self:findViewByName("img_content")
	-- self.pImContent:setCurrentImage("ui/daitu.png")
	self.pImgCoin   = self:findViewByName("img_coin")
	self.pImgQipao   = self:findViewByName("img_qipao")

	self.pImgLock = self:findViewByName("img_lock")

	self.pLbLockTip = MUI.MLabel.new({text = "", size = 16})
	self.pLyMain:addView(self.pLbLockTip, 10)
	setTextCCColor(self.pLbLockTip, _cc.red)
	self.pLbLockTip:setPosition(self.pLyMain:getWidth()/2, 18)
	self.pLbLockTip:setVisible(false)

end

--初始化控件
function ItemFubenSpecialLevel:setupViews( )

end

--时间函数
function ItemFubenSpecialLevel:updateCd()
	if self.pData then
		if self.pData.nType == SPLVTYPE.resource then
			if self.pData:getBuyResCd() > 0 then --资源 then
				self.pLbTime:setString("("..formatTimeToHms(self.pData:getBuyResCd())..")")
			elseif self.pData:getBuyResCd() == 0 then
				self.pLbTime:setString("")
				local tObject = {}
				if self.pData.nRf >= self.pData.nFeedTime then
					tObject.nId = self.pData.nId
				end
				sendMsg(ghd_refresh_special_level, tObject) --通知刷新特殊关卡
			end
		end
	end
end

--点击事件
function ItemFubenSpecialLevel:onViewClick(pView)

	if not self.pData.bOpen then
		local tLockMyData = Player:getFuben():getLockMyData(self.pData.nId)
		if tLockMyData then
			local str = string.format(getTipsByIndex(10069), tLockMyData.sName)
			TOAST(str)
		end
	else

		if self.pData.nType  == SPLVTYPE.recruit then --招募
			local tObject = {}
			tObject.nType = e_dlg_index.conscribehero --dlg类型
			tObject.tHeroData = self.tConscribeHero
			tObject.nBuyHeroCoin = self.nBuyHeroCoin
			tObject.nId = self.pData.nId
			sendMsg(ghd_show_dlg_by_type, tObject)

			--新手引导招募已点击
		    Player:getNewGuideMgr():setNewGuideFingerClicked(e_guide_finer.fuben_first_post_cruit)
		    
		elseif self.pData.nType == SPLVTYPE.countryWp then --国器
			local tLevleData = self.pData
			if tLevleData.nF >= tLevleData.nFragmentmax then
				--神兵id
				local sWpTid = tonumber(tLevleData.sTarget)
				--跳到对应的神兵界面
				local tObject = {}
				tObject.nType = e_dlg_index.dlgweaponinfo --dlg类型
				tObject.nIndex = sWpTid - 200
				sendMsg(ghd_show_dlg_by_type, tObject)
			else
				if tLevleData and table.nums(tLevleData)> 0 then
					local tObject = {}
					tObject.nType = e_dlg_index.armylayer --dlg类型
				    tObject.nArmyType = en_army_type.fuben -- 部队类型
					tObject.sTitle = tLevleData.sName -- 部队界面标题
					tObject.tMyArmy = Player:getHeroInfo():getOnlineHeroList(true) --我方部队
					tObject.tEnemy = getNpcGropById(tLevleData.nMonsters) --地方部队
					tObject.nEnemyArmyFight = getNpcGropListDataById(tLevleData.nMonsters).score or 0 --敌方战力
					tObject.nExpendEnargy = tLevleData.nCost --战斗所需要能量
					tObject.tFubenData = tLevleData  --副本章节数据
					tObject.bSpecialPost = true      --特殊关卡
					sendMsg(ghd_show_dlg_by_type,tObject)
				end
			end
		elseif self.pData.nType == SPLVTYPE.resource then --资源
			if self.pData and self.pData.nId then
				if self.pData.nRf and self.pData.nFeedTime then 
					local nLeftTime = self.pData.nFeedTime - self.pData.nRf
					if nLeftTime == 0 then
						if self.pData.nRb < table.nums(self.pData:getFeedBuyCost()) then --不大于购买次数
							--打开购买框
							local DlgFubenBuyItemTips = require("app.layer.fuben.DlgFubenBuyItemTips")
							local pDlg, bNew = getDlgByType(fubenbutyitemtips)
						    if not pDlg then
						    	pDlg = DlgFubenBuyItemTips.new()
						    end
						    pDlg:setCurData(self.pData)
						    pDlg:showDlg(bNew)
						else
							--todo
						end
					else
						if nLeftTime > 0 then
							SocketManager:sendMsg("fubenSupplyRes", {self.pData.nId},
								function ( __msg )
									if __msg.body then
										if __msg.body.as then
											showGetAllItems(__msg.body.as,1)
										end
										sendMsg(ghd_refresh_special_level) --刷新特殊关卡
									end
								end)
						end
					end
				end

			end
		elseif self.pData.nType == SPLVTYPE.equip then --装备
			--打开购买框
			local DlgFubenBuyItemTips = require("app.layer.fuben.DlgFubenBuyItemTips")
			local pDlg, bNew = getDlgByType(fubenbutyitemtips)
		    if not pDlg then
		    	pDlg = DlgFubenBuyItemTips.new()
		    end
		    pDlg:setCurData(self.pData)
		    pDlg:showDlg(bNew)

		elseif self.pData.nType == SPLVTYPE.drawing then--图纸
			local tLevleData = self.pData
			if tLevleData == nil then return end
			--如果图纸已满点击定位到主城对应的资源田位置并模拟打开操作
			if tLevleData.nRd >= tLevleData.nFragmentmax then
				local tStr = luaSplit(tLevleData.sTarget, ":")
				--资源田格子下标
				local nResCell = tonumber(tStr[2])

				local tOb = {}
				tOb.nCell = nResCell
				tOb.nFunc = function()
					--模拟执行一次点击行为
					--发送消息关闭除了自身以外有打开的操作按钮，并且打开自身
					local tObject = {}
					tObject.nCell = nResCell
					sendMsg(ghd_show_build_actionbtn_msg,tObject)
				end
				sendMsg(ghd_home_show_base_or_world, 1) 	--先切换到主城
				sendMsg(ghd_move_to_build_dlg_msg, tOb)
				closeDlgByType(e_dlg_index.fubenmap, false)
			else
				if table.nums(tLevleData)> 0 then
					local tObject = {}
					tObject.nType = e_dlg_index.armylayer --dlg类型
				    tObject.nArmyType = en_army_type.fuben -- 部队类型
					tObject.sTitle = tLevleData.sName -- 部队界面标题
					tObject.tMyArmy = Player:getHeroInfo():getOnlineHeroList(true) --我方部队
					tObject.tEnemy = getNpcGropById(tLevleData.nMonsters) --地方部队
					tObject.nEnemyArmyFight = getNpcGropListDataById(tLevleData.nMonsters).score or 0 --敌方战力
					tObject.nExpendEnargy = tLevleData.nCost --战斗所需要能量
					tObject.tFubenData = tLevleData  --副本章节数据
					tObject.bSpecialPost = true      --特殊关卡
					sendMsg(ghd_show_dlg_by_type,tObject)
				end
			end
		end
	end

end

--播放动作
function ItemFubenSpecialLevel:showAction()
	-- body
	if not self.pActPos then
		self.pActPos = cc.p(60, 88)
	end
	--新关卡开启动画
	local pImg2 = MUI.MImage.new("#sg_fbbkdh_kq_x_06.png")
	self.pLyMain:addView(pImg2, 10)
	pImg2:setPosition(self.pActPos)
	pImg2:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	local pSequence = cc.Sequence:create({
	    cc.FadeTo:create(0.17, 255*0.73),
	    cc.FadeTo:create(0.29 - 0.17, 255*0.53),
	    cc.FadeTo:create(0.58 - 0.29, 0),
	    cc.CallFunc:create(function()
	        pImg2:removeSelf()
	    end)
	    })
	pImg2:runAction(pSequence)

	local pImg3 = MUI.MImage.new("#sg_fbbkdh_kq_x_06.png")
	self.pLyMain:addView(pImg3, 10)
	pImg3:setPosition(self.pActPos)
	pImg3:setScale(1.44)
	pImg3:setOpacity(255*0.35)
	pImg3:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	local pSequence = cc.Sequence:create({
		cc.Spawn:create({
	        cc.ScaleTo:create(0.7, 1.79),
	        cc.FadeTo:create(0.7, 0)
	        }),
	    cc.CallFunc:create(function()
	        pImg3:removeSelf()
	    end)
	    })
	pImg3:runAction(pSequence)
end

--显示解锁条件
function ItemFubenSpecialLevel:showLockTip(_bShow)
	-- body
	if _bShow then
		local str = string.format(getConvertedStr(7, 10275), self.pData.nCount)
		self.pLbLockTip:setString(str)
	end
	self.pLbLockTip:setVisible(_bShow)
end

-- 修改控件内容或者是刷新控件数据
function ItemFubenSpecialLevel:updateViews()
	if self.pImgRing then
		self.pImgRing:setVisible(false)
	end
	--如果是新关卡开启并且还不能刷新数据(等播放特效后刷新)
	local bTar = false
	if self.pData.bOpen then
		if self.tOpenPost then
			for _, id in pairs(self.tOpenPost) do
				if self.pData.nId == id then
					bTar = true
				end
			end
		end
	end
	if bTar and not self.bCanRefresh then
		self:setViewTouched(false)
		return
	end
	self:setViewTouched(true)

	--设置特殊关卡图片
	self.pImContent:setCurrentImage(self.pData.sIcon)
	self.pImContent:setScale(0.85)
	--设置气泡图片
	-- self.pImgQipao:setCurrentImage(self.pData.sRealBIcon)
	-- local nScale = 30/self.pImgQipao:getWidth()
	-- self.pImgQipao:setScale(nScale)

	if self.bCanRefresh then
		--播放动作
		self:showAction()
	end
	
	if self.pResText then
		self.pResText:setVisible(false)
	end

	setTextCCColor(self.pLbTime,_cc.pwhite)
	self.pLbTime:setAnchorPoint(0.5, 0.5)

	self.pLyBuyHero:setPositionX(1)
	if self.pData.nType  == SPLVTYPE.recruit then --招募
		self.pLyBuyHero:setVisible(false) --默认关闭
		self.pLbTime:setString("")


		if self.pRichViewTips1 then
			self.pRichViewTips1:removeFromParent(true)
			self.pRichViewTips1 = nil
		end

		local tShowHeroList = self.pData:getSpLvHeroList()--产出英雄列表
			

		local tHeroList = {}
		if tShowHeroList and table.nums(tShowHeroList)> 0 then
			for k,v in pairs(tShowHeroList) do
				-- local pHero = Player:getHeroInfo():getHero(v.nId)
				local pHero = getHeroDataById(v.nId)
				if pHero then
					table.insert(tHeroList,pHero)
				end
			end
		end

		if not self.pData.bOpen then
			self.pImContent:setToGray(true)
			self.pImgLock:setVisible(true)
			--显示英雄名字
			if table.nums(tHeroList)> 0 then
				self.pLbIcon:setString(tHeroList[1].sName or "")
			end
			--显示解锁条件
			self:showLockTip(true)
			
		else
			self:showLockTip(false)
			self.pImContent:setToGray(false)
			self.pImgLock:setVisible(false)
			--移除抽到的英雄
			if tHeroList and table.nums(tHeroList)> 0 then
				table.sort(tHeroList,function (a,b)
					return a:getNowTotalTalent() > b:getNowTotalTalent()
				end)
				for i=table.nums(tHeroList),1,-1 do
					if self.pData.nLh and tHeroList[i].nKey == self.pData.nLh then
						table.remove(tHeroList,i)
					end
				end
			end

			--移除购买到的英雄
			if tHeroList and table.nums(tHeroList)> 0 then
				table.sort(tHeroList,function (a,b)
					return a:getNowTotalTalent() > b:getNowTotalTalent()
				end)
				for i=table.nums(tHeroList),1,-1 do
					if self.pData.nBh and tHeroList[i].nKey == self.pData.nBh then
						table.remove(tHeroList,i)
					end
				end
			end
			if tHeroList and table.nums(tHeroList)> 0 then
				local nCost = 0
				if self.pData.nBh == 0 and self.pData.nLh > 0  then
					for k,v in pairs(tShowHeroList) do
						if tHeroList[1].nKey == v.nId then
							nCost = v.nCost or 0
						end

					end
				end
				self.nBuyHeroCoin = nCost
				if nCost > 0 then
					--显示购买信息
					self.pLyBuyHero:setVisible(true) 
					self.pImgCoin:setVisible(true)         	
					self.pLbBuyPrice:setString(tostring(nCost))
				--可免费招募显示特效
				else
					self:showCircleTx()
				end

				--显示英雄名字
				self.pLbIcon:setString(tHeroList[1].sName or "")
				self.tConscribeHero = tHeroList --招募英雄列表
			end
		end


	elseif self.pData.nType == SPLVTYPE.countryWp then --国器
		self.pLyBuyHero:setVisible(false) --默认关闭
		self.pLbIcon:setString(self.pData.sName or "")
		if not self.pData.bOpen then
			self.pImContent:setToGray(true)
			self.pImgLock:setVisible(true)
			self.pLbTime:setString("")
			--显示解锁条件
			self:showLockTip(true)
		else
			self:showLockTip(false)
			self.pImContent:setToGray(false)
			self.pImgLock:setVisible(false)
			self.pLbTime:setString(getConvertedStr(5, 10185)..self.pData.nF.."/"..self.pData.nFragmentmax)
			if self.pData.nF >= self.pData.nFragmentmax then
				--显示转圈特效
				self:showCircleTx()
			end
		end

	elseif self.pData.nType == SPLVTYPE.resource then --资源
		setTextCCColor(self.pLbTime,_cc.red)
		self.pLbTime:setAnchorPoint(0, 0.5)
		self.pLbIcon:setString(self.pData.sName or "")
		if not self.pData.bOpen then
			self.pImContent:setToGray(true)
			self.pImgLock:setVisible(true)
			self.pLyBuyHero:setVisible(false)
			self.pLbTime:setString("")
			--显示解锁条件
			self:showLockTip(true)
		else
			self:showLockTip(false)
			self.pImContent:setToGray(false)
			self.pImgLock:setVisible(false)
			self.pLyBuyHero:setVisible(true)
			--名称
			local nLeftTime = self.pData.nFeedTime - (self.pData.nRf or 0)
			if nLeftTime then
				if not self.pResText then
					self.pResText = MUI.MLabel.new({text = "", size = 16})
					self.pResText:setAnchorPoint(0, 0.5)
					self.pLyMain:addView(self.pResText, 10)
				end
				self.pResText:setPosition(0, 20)
				self.pResText:setVisible(true)
				if nLeftTime > 0 then
					--如果有剩余次数就居中显示购买次数
					self.pImgCoin:setVisible(false)
	            	self.pLbBuyPrice:setString("")
					local str = {
						{text = getConvertedStr(7, 10142)},
						{text = nLeftTime, color = getC3B(_cc.green)},
						{text = getConvertedStr(7, 10143)},
					}
					
					self.pResText:setString(str)
					self.pLbTime:setPositionX(self.pResText:getWidth() + 2)
	            	if self.pData:getBuyResCd() <= 0 then
	            		self.pResText:setPosition(32, 20)
						self.pLbTime:setString("")	            		
	            	end
	            	--显示转圈特效
					self:showCircleTx()
				elseif nLeftTime == 0 then
					if self.pData.nRb then
						self.pLyBuyHero:setPositionX(-26)
						self.pImgCoin:setVisible(true)
						if self.pResText then
							self.pResText:setVisible(false)
						end
						local tCost = self.pData:getFeedBuyCost()
						if table.nums(tCost) > 0 then
							local nIndex = self.pData.nRb +1
							if nIndex > table.nums(tCost) then
								nIndex = table.nums(tCost)
							end
							self.pLbBuyPrice:setString(tCost[nIndex])
						end
					end

				end
			end
		end


	elseif self.pData.nType == SPLVTYPE.equip then --装备
		--显示关卡名称
		self.pLbIcon:setString(self.pData.sName or "")
		self.pLbTime:setString("")
		if not self.pData.bOpen then
			self.pImContent:setToGray(true)
			self.pImgLock:setVisible(true)
			--隐藏购买信息
			self.pLyBuyHero:setVisible(false)
			self.pImgCoin:setVisible(false)
			--显示解锁条件
			self:showLockTip(true)
		else
			self:showLockTip(false)
			self.pImContent:setToGray(false)
			self.pImgLock:setVisible(false)
			--显示购买信息
			self.pLyBuyHero:setVisible(true) 
			-- self.pLbBuyPrice:setPositionX(46)     
			self.pImgCoin:setVisible(true)         	
			self.pLbBuyPrice:setString(tostring(self.pData.nWeaponPaperCost))
		end

	elseif self.pData.nType == SPLVTYPE.drawing then--图纸
		self.pLyBuyHero:setVisible(false) --默认关闭
		-- self.pLbTime:setString("") --这个状态不显示时间

		self.pLbIcon:setString(self.pData.sName or "")
		if not self.pData.bOpen then
			self.pImContent:setToGray(true)
			self.pImgLock:setVisible(true)
			self.pLbTime:setString("")
			--显示解锁条件
			self:showLockTip(true)
		else
			self:showLockTip(false)
			self.pImContent:setToGray(false)
			self.pImgLock:setVisible(false)

			local strTips1 = {}
		    if self.pData.nRd >= self.pData.nFragmentmax then
				--显示转圈特效
				self:showCircleTx()
				strTips1 = {
			    	{color=_cc.pwhite,text=getConvertedStr(5, 10085)},
			    	{color=_cc.green,text=self.pData.nRd},
			    	{color=_cc.pwhite,text="/"},
			    	{color=_cc.pwhite,text=self.pData.nFragmentmax},
			    }
			else
				strTips1 = {
			    	{color=_cc.pwhite, text=getConvertedStr(5, 10085)},
			    	{color=_cc.red, text=self.pData.nRd},
			    	{color=_cc.pwhite, text="/"},
			    	{color=_cc.pwhite, text=self.pData.nFragmentmax},
			    }
			end
		    
		    self.pLbTime:setString(strTips1) --这个状态不显示时间
		end
	end
end

function ItemFubenSpecialLevel:showCircleTx()
	-- body
	--转圈特效
	if not self.pImgRing then
		self.pImgRing = MUI.MImage.new("#sg_zjm_rwtih_fk_sdx_xx1.png", {scale9=false})
		self.pImgRing:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		self.pImgRing:setScale(1.23)
		self.pImgRing:setPosition(self.pImgIcon:getPositionX()+1, self.pImgIcon:getPositionY()-4)
		self.pImgRing:setRotation(0)
		self.pLyMain:addView(self.pImgRing, 13)
		local action1 = cc.RotateTo:create(0.5, 180)
		local action2 = cc.RotateTo:create(0.5, 360)
		self.pImgRing:runAction(cc.RepeatForever:create(cc.Sequence:create(action1, action2)))
	end
	self.pImgRing:setVisible(true)
end

--析构方法
function ItemFubenSpecialLevel:onDestroy(  )
	-- body
	unregUpdateControl(self)
end

--设置数据 _data
function ItemFubenSpecialLevel:setCurData(_tData, _tOpenPost, _pImgIcon)
	if not _tData then
		return
	end

	self.pData = _tData or {}
	self.tOpenPost = _tOpenPost
	self.pImContent = _pImgIcon
	self.bCanRefresh = false

	self:updateViews()


end

--可以刷新新开启数据了
function ItemFubenSpecialLevel:refreshOpenData()
	-- body
	self.bCanRefresh = true
	self:updateViews()
end

--获取章节数据
function ItemFubenSpecialLevel:getData()
	return self.pData
end



return ItemFubenSpecialLevel