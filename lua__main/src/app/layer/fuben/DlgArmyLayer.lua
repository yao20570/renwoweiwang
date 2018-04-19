-- Author: liangzhaowei
-- Date: 2017-04-13 16:14:32
-- 副本部队出征界面


local DlgBase = require("app.common.dialog.DlgBase")
local ViewBarUtils = require("app.common.viewbar.ViewBarUtils")
local ItemFubenSection = require("app.layer.fuben.ItemFubenSection")
local ItemAccoutList = require("app.layer.login.ItemAccoutList")
local ItemFubenMyArmy = require("app.layer.fuben.ItemFubenMyArmy")
local ItemFubenEnemyArmy = require("app.layer.fuben.ItemFubenEnemyArmy")

local NARMYITEMH = 116 -- 部队item 高度
local SWEEPTIME = 5 

local DlgArmyLayer = class("DlgArmyLayer", function()
	return DlgBase.new(e_dlg_index.armylayer)
end)



--tData --部队参数列表
function DlgArmyLayer:ctor(_tData)
	-- body
	self:myInit()

	self.nArmyType          = _tData.nArmyType or 0  -- 部队类型
	self.sTitle             = _tData.sTitle    or "" -- 部队界面标题
	self.tMyArmy            = copyTab(_tData.tMyArmy)    or {}   --我方部队
	self.tEnemy             = _tData.tEnemy    or {}  --地方部队
	self.nEnemyArmyFight    = _tData.nEnemyArmyFight or 0 --敌方战力
	self.nExpendEnargy      = tonumber(_tData.nExpendEnargy) or 0 --消耗体力
	self.tFubenData         = _tData.tFubenData or {} --副本数据
	self.bSpecialPost 		= _tData.bSpecialPost     --特殊关卡

	self:initData()
	self:closeLayBHelp()


	parseView("dlg_fuben_army", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("DlgArmyLayer",handler(self, self.onDestroy))
	
end

--初始化参数
function DlgArmyLayer:myInit()

 	self.pFoundItem 		= nil 		-- 找到那一项
	self.bIsFoundItem 		= false 		-- 是否找到了
	self.pCurDropIndex 		= nil 		-- 当前拖拽的下标

	self.tItemDrop = {} --item 
 	self.tItemPos = {} --位置

	self.nArmyType =  0  -- 部队类型
	self.sTitle    =  "" -- 部队界面标题
	self.tMyArmy   =  {}   --我方部队
	self.tEnemy    =  {}  --地方部队
	self.nMyArmyFight       =  0  --我方战力
	self.nEnemyArmyFight    =  0  --敌方战力
	self.nExpendEnargy      =  0 --消耗体力
	self.tFubenData         =  {} --副本数据

	self.nScrollH  =  0  --滑动层高度

	self.pLeftExText = nil  --左边按钮上扩展文字
	self.pRightExText = nil --右边按钮上扩展文字

end

--初始化数据
function DlgArmyLayer:initData()
	self.nMyArmyFight       =  0   --我方战力
	--过关斩将我方战力需要加上主力武将位穿戴的装备增加的战力再乘武将血量百分比
	if self.nArmyType == en_army_type.killherofight then
		-- local tHeroList = Player:getHeroInfo():getHeroOnlineQueueByTeam(e_hero_team_type.normal)
		-- local tPower = {}
		-- for i = 1, #tHeroList do
		-- 	if i <= table.nums(self.tMyArmy) then
		-- 		local nPower = 0
		-- 		local tEquipVos = Player:getEquipData():getEquipVosByPos(tHeroList, i)
		-- 		for k, v in pairs(tEquipVos) do
		-- 			local nEquipPower = v:getEquipPower()
		-- 			nPower = nPower + nEquipPower
		-- 		end
		-- 		tPower[i] = (self.tMyArmy[i].nSc or 0) + nPower
		-- 	end
		-- end
		-- if self.tMyArmy and table.nums(self.tMyArmy)> 0 then
		-- 	for k, v in ipairs(self.tMyArmy) do
		-- 		--武将剩余血量百分比
		-- 		local fBloodPer = Player:getPassKillHeroData():getHeroProById(v.nId)
		-- 		--是否是主力武将, 如果是主力武将直接取后端发的战力
		-- 		local bIsNormalHero = Player:getHeroInfo():getIsNormalHero(v.nId)
		-- 		if bIsNormalHero then
		-- 			self.nMyArmyFight = self.nMyArmyFight + (v.nSc or 0)*fBloodPer
		-- 		else
		-- 			self.nMyArmyFight = self.nMyArmyFight + tPower[k]*fBloodPer
		-- 		end
		-- 	end
		-- end
		-- self.nMyArmyFight = math.floor(self.nMyArmyFight)
		if self.tMyArmy and table.nums(self.tMyArmy)> 0 then
			for k,v in pairs(self.tMyArmy) do
				--武将剩余血量百分比
				local fBloodPer = Player:getPassKillHeroData():getHeroProById(v.nId)
				local nSc = (v.nSc or 0) * fBloodPer
				self.nMyArmyFight = math.floor(self.nMyArmyFight + nSc)
			end
		end
	else
		if self.tMyArmy and table.nums(self.tMyArmy)> 0 then
			for k,v in pairs(self.tMyArmy) do
				local nSc = v.nSc  or 0
				self.nMyArmyFight = self.nMyArmyFight + nSc 
			end
		end
	end
end

--获取当前英雄队列字符串
function DlgArmyLayer:getOnlineListStr()
	local str = ""
	local tOnlineList = self.tMyArmy
	if tOnlineList and table.nums(tOnlineList)> 0 then
		for k,v in pairs(tOnlineList) do
			if k == table.nums(tOnlineList) then
				str = str..v.nId
			else
				str = str..v.nId..";"
			end
		end
	end
	return str 
end


--解析布局回调事件
function DlgArmyLayer:onParseViewCallback( pView )

	self:addContentView(pView) --加入内容层

	self:setupViews()
	self:onResume()
end

--刷新按钮状态
function DlgArmyLayer:setupBtn()
	local pLyBtnL = self:findViewByName("ly_down_btn_l")
	local pLyBtnR = self:findViewByName("ly_down_btn_r")
	local pLyBtnM = self:findViewByName("ly_down_btn_m")
	self.pBtnL =  getCommonButtonOfContainer(pLyBtnL,TypeCommonBtn.L_YELLOW,getConvertedStr(5,10007))
	self.pBtnM =  getCommonButtonOfContainer(pLyBtnR,TypeCommonBtn.L_BLUE,getConvertedStr(1,10383))

	local nPlayerEngy = Player:getPlayerInfo().nEnergy
	self.nTimes = math.floor(nPlayerEngy/ self.nExpendEnargy)
	if self.nTimes == 0 or self.nTimes > SWEEPTIME then
		self.nTimes = SWEEPTIME
	end
	-- self.pBtnR =  getCommonButtonOfContainer(pLyBtnR,TypeCommonBtn.L_BLUE,
	-- 	string.format(getConvertedStr(5,10008), self.nTimes) )
	-- self.pBtnR:setVisible(false)

	self.pBtnL:onCommonBtnClicked(handler(self, self.onTitleBtnLClicked))
	-- self.pBtnR:onCommonBtnClicked(handler(self, self.onTitleBtnRClicked))
	self.pBtnM:onCommonBtnClicked(handler(self, self.onTitleBtnMClicked))

	local tBtnTable = {}
	--文本
	local tLabel = {
		{getConvertedStr(5,10040),getC3B(_cc.pwhite)},
		{Player:getPlayerInfo().nEnergy,getC3B(_cc.green)},
		{"/",getC3B(_cc.pwhite)},
		{tostring(self.nExpendEnargy),getC3B(_cc.pwhite)},
		
	}

	tBtnTable.tLabel = tLabel


	if self.nArmyType == en_army_type.fuben then
		if self.tFubenData.nP == 0 then --未通关
			pLyBtnL:setPositionX(self:getWidth()/2-pLyBtnL:getWidth()/2)
			-- self.pBtnR:setBtnVisible(false)
			-- self.pBtnR:setBtnEnable(false)

			self.pBtnM:setBtnVisible(false)
			self.pBtnM:setBtnEnable(false)

		else
			local tBtnRTable = {}
			if not self:bSweep() then
				-- self.pBtnR:setBtnEnable(false)
				self.pBtnM:setBtnEnable(false)
				-- 文本
				local tRLabel = {
					{string.format(getConvertedStr(5,10041),3,Player:getPlayerInfo():getCanRaidVip()), getC3B(_cc.red)},
				}
				tBtnRTable.tLabel = tRLabel
				self.pBtnM:setBtnExText(tBtnRTable)
			else
				--文本
				-- local tRLabel = {
				-- 	{getConvertedStr(5,10040),getC3B(_cc.blue)},
				-- 	{tostring(self.nExpendEnargy*self.nTimes)},
				-- 	{"/",getC3B(_cc.blue)},
				-- 	{nPlayerEngy,getC3B(_cc.blue)}
				-- }
				-- tBtnRTable.tLabel = tRLabel
				-- self.pRightExText = self.pBtnR:setBtnExText(tBtnRTable)
			end
		end
		--因为需要修改位置,因此必须放在后面
		self.pLeftExText =  self.pBtnL:setBtnExText(tBtnTable)
	elseif self.nArmyType == en_army_type.worldboss then
		--按钮居中
		pLyBtnL:setPositionX(self:getWidth()/2-pLyBtnL:getWidth()/2)
		-- self.pBtnR:setBtnVisible(false)
		-- self.pBtnR:setBtnEnable(false)

		self.pBtnM:setBtnVisible(false)
		self.pBtnM:setBtnEnable(false)
	elseif self.nArmyType == en_army_type.killherofight then
		self.pBtnM:updateBtnText(getConvertedStr(7, 10385)) --最佳克制
		self.pBtnM:updateBtnType(TypeCommonBtn.L_BLUE)
		self.pBtnR = getCommonButtonOfContainer(pLyBtnM,TypeCommonBtn.L_BLUE,getConvertedStr(7, 10384)) --最大战力
		self.pBtnL:updateBtnText(getConvertedStr(7, 10386)) --战斗
		self.pBtnL:updateBtnType(TypeCommonBtn.L_YELLOW)
		self.pBtnR:onCommonBtnClicked(handler(self, self.onTitleBtnRClicked))
		--新手教程
		sendMsg(ghd_guide_finger_show_or_hide, true)
		Player:getNewGuideMgr():setNewGuideFinger(self.pBtnR, e_guide_finer.pkhero_power_btn)
		Player:getNewGuideMgr():setNewGuideFinger(self.pBtnL, e_guide_finer.pkhero_fight_btn)
		
		
	end
end

--是否可以扫荡
function DlgArmyLayer:bSweep()
	local bSp = false
	if self.bSpecialPost then
		--特殊关卡不需要过多的判断条件, 只需要通关了就可以扫荡
		if self.tFubenData and self.tFubenData.nP == 1 then
			bSp = true
		end
	else
		local nCanRaid = getAvatarVIPByLevel(Player:getPlayerInfo().nVip).canraid
		--如果通关星级大于3或达到vip扫荡条件
		-- if (self.tFubenData.nS >= 3) and (nCanRaid==1)  then --扫荡 
		if self.tFubenData and self.tFubenData.nP == 1 and self.tFubenData.nS then--已经通关
			if (self.tFubenData.nS >= 3) or (nCanRaid==1)  then  --扫荡 (老汤要求改)
				bSp = true
			end
		end
	end
	return bSp
end


--刷新数据
-- _data
function DlgArmyLayer:setCurData(_data)
	if not _data then
 		return
	end


end

--初始化控件
function DlgArmyLayer:setupViews( )
	--ly
	self.pLyArmy= self:findViewByName("ly_army")

	self.pLyZhanli = self:findViewByName("lay_zhanli")

	if self.nArmyType == en_army_type.killherofight then
		-- self.pLyZhanli:setVisible(false)
	else
		self.pLyZhanli:setVisible(true)
	end

	self:setupBtn()

	--lb
	self.pLbArmyAcc = self:findViewByName("lb_army_account") --战斗说明
	self.pLbArmyAcc:setString(getTextColorByConfigure(getTipsByIndex(20024)))
	self.pLbEnergy = self:findViewByName("lb_energy") --剩余能量

	self.pLbMyFight    = self:findViewByName("lb_my_fight") --我方战力
	setTextCCColor(self.pLbMyFight,_cc.pwhite)

	self.pLbEnemyFight = self:findViewByName("lb_enemy_fight") --敌方战力
	setTextCCColor(self.pLbEnemyFight,_cc.pwhite)

	if self.nArmyType == en_army_type.killherofight then
		self.pLbArmyAcc:setString(getConvertedStr(7, 10390))
	end



	self:creatNewScrollayer()

	--交换部队部分________________
	self:creatMovePart()


	--交换部队部分________________
 
end

-- 根据位置下标获取坐标
function DlgArmyLayer:getItemPosition( _nIndex )
	return  self.tItemPos[_nIndex] or cc.p(0, 0)
end

--创建一个新的滑动层
function DlgArmyLayer:creatNewScrollayer()

    self.pScrollLayer = MUI.MScrollLayer.new({viewRect=cc.rect(0, 0,self.pLyArmy:getWidth(),self.pLyArmy:getHeight()),
        touchOnContent = false,
        -- scrollbarImgV="ui/bg_map/v3_bg_background_cjjs.jpg",
        direction=MUI.MScrollLayer.DIRECTION_VERTICAL,
        bothSize=cc.size(640, self.pLyArmy:getHeight())})


    self.pLyArmy:addView(self.pScrollLayer)

    self.pScrollLayer:setBounceable(false)
    self.pScrollLayer:onScroll(handler(self,self.onTouch))
  

end


--创建移动层
function DlgArmyLayer:creatMovePart()




	local nEnemyH = table.nums(self.tEnemy)* NARMYITEMH --计算敌人Item总高度

	if nEnemyH > self.pLyArmy:getHeight() then
		self.nScrollH = nEnemyH
	else
		self.nScrollH = self.pLyArmy:getHeight()
	end


	--滑动层的高度

    --新建一个内容层
	self.pItemsView = MUI.MLayer.new()
	-- self.pItemsView:setBackgroundImage("#v3_bg1.png")
	self.pItemsView:setLayoutSize(640, self.nScrollH)
	self.pScrollLayer:addView(self.pItemsView,2)
	self.pItemsView:setPosition(0,0)
	self.pItemsView:setAnchorPoint(cc.p(0,0))


	--初始化敌人信息
	self.tEnemyArmyItem = {} --敌人部队信息
	for k,v in pairs(self.tEnemy) do
		self.tEnemyArmyItem[k] = ItemFubenEnemyArmy.new(k,v,self.nArmyType)
		self.tEnemyArmyItem[k]:setPosition(322, self.nScrollH - (NARMYITEMH +10)*k)
		self.pItemsView:addView(self.tEnemyArmyItem[k])
	end

    -- 初始化坐标
    self:initPos()


	--初始化我的部队item
	for i=1,4 do
		self.tItemDrop[i] = ItemFubenMyArmy.new(i,self,self.nArmyType)
		self.tItemDrop[i]:setPosition(self.tItemPos[i])
		self.pItemsView:addView(self.tItemDrop[i],11)
	end


	--说明文字
	self:showGetRewardLb()


end

--武将下面的说明文字
function DlgArmyLayer:showGetRewardLb()
	-- body
	--10086
	if self.nArmyType == en_army_type.fuben then
		
		local strTips1 = nil
		if self.tFubenData.nType == en_post_type.fragment then --如果为国器关
			local pWeapon = getBaseDataById(tonumber(self.tFubenData.sTarget))
			local str = ""
			--获取神兵名字
			if pWeapon and pWeapon.sName then
				str = string.format(getConvertedStr(5, 10186), pWeapon.sName) --有几率产出%s碎片
			end
		  	strTips1 = {
		    	{color=_cc.white,text=str}
		    }
		elseif self.tFubenData.nType == en_post_type.resdrawing then --如果为图纸关
			local str = ""
			--获取图纸名字(标题名字)
			if self.sTitle then
				str = string.format(getConvertedStr(7, 10302), self.sTitle) --有几率产出%s
			end
		  	strTips1 = {
		    	{color=_cc.white, text=str}
		    }
		else
			--添加活动便签, 关卡通关了才显示
			if self.tFubenData and self.tFubenData.nP == 1 then
				local nActivityId=getIsShowActivityBtn(self.eDlgType)
			    if nActivityId > 0 then
			    	if not self.pLayActBtn then
			    		self.pLayActBtn = MUI.MLayer.new()
			    		self.pLayActBtn:setLayoutSize(124, 39)
			    		self.pItemsView:addView(self.pLayActBtn)
			    		self.pLayActBtn:setPosition(450, self.tItemDrop[4]:getPositionY()-104)
			    	end
			    	self.pActBtn = addActivityBtn(self.pLayActBtn, nActivityId)

			    	self.bInActivity = true --是否在活动期间
			    else
			    	if self.pActBtn then
			    		self.pActBtn:removeSelf()
			    		self.pActBtn=nil
			    	end
			    	self.bInActivity = false
			    end
			else
			    self.bInActivity = false
			end
		    
			local nExp = 0
			if self.tFubenData.nP == 0 then
				nExp = self.tFubenData.nFirstexp --首次经验
			elseif self.tFubenData.nP == 1 then
				nExp = self.tFubenData.nNormalExp --正常经验
			end
			if tonumber(nExp) > 0 and self.bInActivity then
				strTips1 = {
			    	{color=_cc.blue,text=getConvertedStr(5, 10086)},
			    	{color=_cc.white,text=nExp},
			    	{color=_cc.green,text=string.format(getConvertedStr(7, 10256), nExp)},
			    }
			else
			  	strTips1 = {
			    	{color=_cc.blue,text=getConvertedStr(5, 10086)},
			    	{color=_cc.white,text=nExp},
			    }
			    if self.pActBtn then
		    		self.pActBtn:removeSelf()
		    		self.pActBtn=nil
		    	end
			end

		end

	    if not self.pTips1 then
		    self.pTips1 = MUI.MLabel.new({
		    	text="",
		    	size=20,
		    	align = cc.ui.TEXT_ALIGN_LEFT,
    			valign = cc.ui.TEXT_ALIGN_CENTER,
		    	dimensions = cc.size(450, 0)
		    	})
		    self.pTips1:setAnchorPoint(cc.p(0, 0.5))
		    self.pTips1:setPosition(50,self.tItemDrop[4]:getPositionY()-80)
		    self.pItemsView:addView(self.pTips1)
	    end
	    self.pTips1:setString(strTips1)
	end

end

--移动触摸事件
function DlgArmyLayer:onTouch(event)
	-- dump(event)

	if "began" == event.name then

			-- dump(event.x)
			-- dump(event.y)

			for k,pItem in pairs(self.tItemDrop) do
				if (pItem) then
					if (pItem:isPointInItem(event.x,  event.y) and not self.bIsFoundItem) then
						-- pItem:setAnchorPoint((cc.p(0.5, 0.5)))
						-- dump(event.name)
						if pItem:getViewType() == en_army_state.online then --只有当前类型有武将才可以移动
							pItem:getViewType()
							pItem:setScale(0.99)
							pItem:setOpacity(150)
							self.bIsFoundItem = true 
							-- self.pScrollLayer:setIsCanScroll(false)
							self.pFoundItem = pItem
							self.pCurDropIndex = pItem.nPos

							-- 保留偏移的位置
							pItem.fPointX =  event.x - self.tItemPos[self.pCurDropIndex].x
							pItem.fPointY =  event.y - self.tItemPos[self.pCurDropIndex].y
							pItem:setSelected(true)
						end
					else
						-- pItem:setAnchorPoint(cc.p(0.5, 0.5))
						pItem:setScale(1.0)
						pItem:setOpacity(255)
						pItem:setSelected(false)
					end
				end
			end
		return true
	elseif "clicked" == event.name then
		self:changeItem()
		-- print("clicked")

	elseif "moved" == event.name then
			if(self.bIsFoundItem) then
			self.pFoundItem:setPosition(event.x - self.pFoundItem.fPointX, 
				event.y - self.pFoundItem.fPointY)

			-- 判断是否可以进行交换item
			for i, pItem in pairs(self.tItemDrop) do
				if(pItem.nPos ~= self.pCurDropIndex) then
					-- 寻找是否移动到下一个目标
					local bIs = pItem:isCanChange(self.pFoundItem)
					if(bIs) then
						--展示当前可以交换数据
						pItem:showCanChange(true)
					else
						pItem:showCanChange(false)
					end
				end
			end
		end
	else
        -- 交换item
		self:changeItem()
		self.pScrollLayer:scrollTo(0,0,true)
	end
end

-- 重置被选择item的数据
function DlgArmyLayer:resetFoundItem(  )
	if (not self.pFoundItem) then
		return 
	end

	self.pFoundItem:setScale(1.0)
	self.pFoundItem:setOpacity(255)
	self.pFoundItem:setSelected(true)
	self.pFoundItem = nil 
	self.bIsFoundItem = false
	-- self.pScrollLayer:setIsCanScroll(true)
end

-- 交换item
function DlgArmyLayer:changeItem(  )
	if (not self.bIsFoundItem) then
		return 
	end

	local bFound = false
	-- 判断是否存在可交换的item
	for i, p in pairs(self.tItemDrop) do
		if(p.nPos ~= self.pCurDropIndex) then
			-- 寻找是否移动到下一个目标
			local bIs = p:isCanChange(self.pFoundItem)
			if(bIs) then
				-- 交换item的位置
				local pItem = self.tItemDrop[p.nPos]
				self.tItemDrop[p.nPos]= self.pFoundItem
				self.tItemDrop[self.pFoundItem.nPos]= pItem

				--交换临时表数据
				self:changeTempSelTable(p.nPos, self.pFoundItem.nPos)
				self.pFoundItem:changeToIndex(p.nPos, true)
				self.pFoundItem:showChangedArm()
				p:changeToIndex(self.pFoundItem.nOldIndex, true)
				bFound = true
				break
			end
		end
	end

	-- 如果没有找到，直接回到原位
	if(not bFound) then
		self.pFoundItem:changeToIndex(self.pFoundItem.nPos, true)
	end

	-- 重置被选择item的数据
	self:resetFoundItem()
end

-- 交换数据
function DlgArmyLayer:changeTempSelTable( _pos1, _pos2)
	-- 交换数据
	if (not self.tMyArmy or not self.tMyArmy[_pos1] 
		or not self.tMyArmy[_pos2]) then
		self:updateViews()
		return
	end

	--更改位置
	local nPos = self.tMyArmy[_pos1].nP  + 0
	self.tMyArmy[_pos1].nP = self.tMyArmy[_pos2].nP
	self.tMyArmy[_pos2].nP = nPos

	--更改数据
	local tArmy = copyTab(self.tMyArmy[_pos1]) 
	self.tMyArmy[_pos1] = copyTab(self.tMyArmy[_pos2])
	self.tMyArmy[_pos2] = tArmy

	if self.nArmyType == en_army_type.killherofight then
		--保存过关斩将上阵队列
		Player:getPassKillHeroData():setOnlineHero(self.tMyArmy)
	end

	self:updateViews()
end

--初始化坐标
function DlgArmyLayer:initPos()
	if not self.tItemPos then
		self.tItemPos = {}
	end

	--初始化位置
	for i=1,4 do
		self.tItemPos[i] = cc.p(0,self.nScrollH - (NARMYITEMH +10)*i )
	end
end



-- 修改控件内容或者是刷新控件数据
function DlgArmyLayer:updateViews(  )
	--根据章节名称设置标题
	if self.sTitle then
		self:setTitle(self.sTitle)
	end

	--刷新我自己的部队的消息
	for k,v in pairs(self.tItemDrop) do
		if self.tMyArmy[k] then
			local nKind = 0 --敌方兵种
			local nBlood = nil --敌方血量
			if self.tEnemy[k] then
				nKind = self.tEnemy[k].nKind or 0
				nBlood = self.tEnemy[k].nBlood
			end
			v:setCurData(self.tMyArmy[k],nKind, nBlood)
		else
			if k > Player:getHeroInfo().nOnlineNums then
				v:setCurData(en_army_state.lock) --锁住状态
			else
				v:setCurData(en_army_state.free) --可添加状态
			end
		end
	end


	self.pLbMyFight:setString(self.nMyArmyFight)       --我方战力
	self.pLbEnemyFight:setString(self.nEnemyArmyFight) --敌方战力

	self:refreshEnergy()

	-- self.nExpendEnargy    --消耗体力
	--展示体力

end


--左边按钮
function DlgArmyLayer:onTitleBtnLClicked(pView)
	-- body
	-- local strOnlineList = Player:getHeroInfo():getOnlineListStr()
	local strOnlineList = self:getOnlineListStr()
	if self.nArmyType == en_army_type.fuben then

		--能量不足是弹出能量购买对话框
		if  Player:getPlayerInfo().nEnergy < self.nExpendEnargy  then
			local pEnergy = Player:getBagInfo():getItemDataById(e_id_item.energy) 
			if pEnergy and pEnergy.nCt > 0 and Player:getBagInfo():isItemCanUse(e_id_item.energy) then
				showUseItemDlg(e_id_item.energy)
			else
				-- local nLeftBuy = Player:getPlayerInfo():getBuyEnergyLeftTimes()
				-- if nLeftBuy <= 0 then
				-- 	TOAST(getConvertedStr(6, 10502))
				-- else
				-- 	local tObject = {}
				-- 	tObject.nType = e_dlg_index.vitbuy --dlg类型
				-- 	sendMsg(ghd_show_dlg_by_type,tObject)
				-- end
				openDlgBuyEnergy()
			end
		else
			--不允许提示
      		setToastNCState(1)
      		--发送请求
			SocketManager:sendMsg("challengeFubenLevel", {self.tFubenData.nId,strOnlineList}, handler(self, self.onGetDataFunc))
			--禁止部分弹框
			showSequenceFunc(e_show_seq.fight)
			--不再接受能量变化通知
			self:unregEnergy()
		end

	elseif self.nArmyType == en_army_type.worldboss then
		--不允许提示
      	setToastNCState(1)
      	--发送请求
		SocketManager:sendMsg("regAttackWorldBoss", {strOnlineList}, handler(self, self.onGetDataFunc))
		--禁止部分弹框
		showSequenceFunc(e_show_seq.fight)
		--不再接受能量变化通知
		self:unregEnergy()
	elseif self.nArmyType == en_army_type.killherofight then --过关斩将-战斗
		--新手教程
		Player:getNewGuideMgr():setNewGuideFingerClicked(e_guide_finer.pkhero_fight_btn)
		--可上阵数量
		local nCanOnLine = Player:getHeroInfo().nOnlineNums
		local tHasOnline = Player:getPassKillHeroData():getOnlineHero()
		local tNotDeadList = Player:getPassKillHeroData():getNotDeadHeroList()
		if #tNotDeadList == 0 then
			TOAST(getConvertedStr(7, 10398)) -- 上阵武将才可进行战斗！
		else
			if #tHasOnline < nCanOnLine and #tNotDeadList > #tHasOnline then
				TOAST(getConvertedStr(7, 10389)) -- 尚有武将可上阵，满编后可进行战斗！
			else
				SocketManager:sendMsg("reqPassKillHeroFight", {strOnlineList}, handler(self, self.onGetDataFunc))
			end
		end
	end

end

--中间按钮
function DlgArmyLayer:onTitleBtnMClicked(pView)
	if self.nArmyType == en_army_type.killherofight then --过关斩将-最佳克制
		Player:getPassKillHeroData():onlineBestDefeatHeros(self.tEnemy)
	else
		local tObject = {}
		tObject.nType = e_dlg_index.fubenwipeteam --dlg类型
		local tData = {}
		tData.nExpendEnargy = self.nExpendEnargy
		tData.tFubenData = copyTab(self.tFubenData)
		tObject.tData = tData
		sendMsg(ghd_show_dlg_by_type,tObject)
	end
end

--右边按钮
function DlgArmyLayer:onTitleBtnRClicked(pView)
	if self.nArmyType == en_army_type.killherofight then --过关斩将-最大战力
		Player:getPassKillHeroData():onlineMaxPowerHeros()
		--新手教程
		Player:getNewGuideMgr():onClickedNewGuideFinger(self.pBtnR)
	else
		if not self.bIsClicking then
			if self.nArmyType == en_army_type.fuben then
				--能量不足是弹出能量购买对话框
				if  Player:getPlayerInfo().nEnergy < self.nExpendEnargy*self.nTimes then
					gotoBuyEnergy()
					doDelayForSomething(self, function( )
						self.bIsClicking = false
					end, 0.2)
				else
					--不允许提示
		      		setToastNCState(1)
		      		local strOnlineList = self:getOnlineListStr()
					SocketManager:sendMsg("sweepFubenLevel", {self.tFubenData.nId, self.nTimes, strOnlineList}, handler(self, self.onGetDataFunc))
					Player:getHeroInfo():saveLocalHeroOrder(luaSplit(strOnlineList, ";"))
				end


			end
			self.bIsClicking = true
		end
	end

end

--接收服务端发回的登录回调
function DlgArmyLayer:onGetDataFunc( __msg , __oldmsg)

    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.challengeFubenLevel.id then
        	-- dump(__msg.body,"__msg.body",100)
        	if __oldmsg and __oldmsg[2] then
        		Player:getHeroInfo():saveLocalHeroOrder(luaSplit(__oldmsg[2], ";"))
        	end

        	if self and self.nArmyType == en_army_type.fuben then
        		sendMsg(gud_refresh_fuben) --通知刷新界面
        	end
        	--战斗表现
        	showFight(__msg.body.report,function (  )
        		showFightRst(__msg.body)
        	end,nil,function (  )
        		-- body
        		closeDlgByType(e_dlg_index.armylayer,false)
        	end)        	
        elseif __msg.head.type == MsgType.sweepFubenLevel.id  then
        	--todo        
        	--打开战斗结果界面
        	local pData = __msg.body
        	pData.nResult = 1
        	showFightRst(pData)
        	if self and self.nArmyType == en_army_type.fuben then
        		sendMsg(gud_refresh_fuben) --通知刷新界面
        	end
        	closeDlgByType(e_dlg_index.armylayer,false)        	
        elseif __msg.head.type == MsgType.regAttackWorldBoss.id then
        	if __oldmsg and __oldmsg[1] then
        		Player:getHeroInfo():saveLocalHeroOrder(luaSplit(__oldmsg[1], ";"))
        	end
        	--战斗表现
        	showFight(__msg.body.report,function (  )
        		__msg.body.nArmyType = en_army_type.worldboss
        		__msg.body.awards = __msg.body.ob
        		showFightRst(__msg.body)
        	end, nil, function (  )
        		-- body
        		closeDlgByType(e_dlg_index.armylayer,false)
        	end)
        	--播放获得
        	-- showGetAllItems(__msg.body.ob, 2)
        	--设置已击打
        	Player:getWorldData():setAttackedBoss(1)
        	sendMsg(gud_world_target_boss_refresh) 
        elseif __msg.head.type == MsgType.reqPassKillHeroFight.id then --过关斩将
        	closeDlgByType(e_dlg_index.armylayer,false)
        end
    else
        --弹出错误提示语
        TOAST(SocketManager:getErrorStr(__msg.head.state))
        --打开弹窗类提示信息
		setToastNCState(2)
		--允许提示弹框
		showNextSequenceFunc(e_show_seq.fight)
    end
	self.bIsClicking = false
end

--刷新状态
function DlgArmyLayer:refreshState()
	if self.nArmyType == en_army_type.fuben then
		if self:bSweep() then
			-- self.pBtnR:setVisible(false)
			-- self.pBtnR:setBtnEnable(true)
			self.pBtnM:setBtnEnable(true)
		end
	end
end

--刷新能量
function DlgArmyLayer:refreshEnergy()
	local nEnergy = Player:getPlayerInfo().nEnergy
	if self.pLeftExText then
		if nEnergy < self.nExpendEnargy then
			self.pLeftExText:setLabelCnCr(2, nEnergy,getC3B(_cc.red))
		else
			self.pLeftExText:setLabelCnCr(2, nEnergy,getC3B(_cc.green))
		end
	end
	-- if self.pRightExText then
	-- 	self.pRightExText:setLabelCnCr(4, nEnergy)
	-- 	self.nTimes = math.floor(nEnergy/ self.nExpendEnargy)
	-- 	if self.nTimes == 0 or self.nTimes > SWEEPTIME then
	-- 		self.nTimes = SWEEPTIME
	-- 	end
	-- 	self.pRightExText:setLabelCnCr(2, self.nTimes*self.nExpendEnargy)
	-- 	self.pBtnR:updateBtnText(string.format(getConvertedStr(5,10008), self.nTimes))
	-- end
end

--继续方法
function DlgArmyLayer:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	
end

-- 注册消息
function DlgArmyLayer:regMsgs( )
	-- 注册玩家基础信息刷新消息
	regMsg(self, gud_refresh_playerinfo, handler(self, self.refreshState))
	regMsg(self, gud_refresh_hero, handler(self, self.refreshMyArmyData))
	-- 注册玩家能量刷新消息
	regMsg(self, ghd_refresh_energy_msg, handler(self, self.refreshEnergy))
	--过关斩将武将上下阵刷新消息
	regMsg(self, gud_refresh_pass_kill_online_hero_msg, handler(self, self.refreshKillHeroMyArmyData))

end

--注销刷新能量
function DlgArmyLayer:unregEnergy()
	-- body
	--挑战后不需要接受体力变化
	-- 销毁玩家能量刷新消息
	unregMsg(self, ghd_refresh_energy_msg)
end


-- 注销消息
function DlgArmyLayer:unregMsgs(  )
	-- 销毁玩家基础信息刷新消息
	unregMsg(self, gud_refresh_playerinfo)
	unregMsg(self, gud_refresh_hero)
	unregMsg(self, ghd_refresh_energy_msg)
	--销毁过关斩将武将上下阵刷新消息
	unregMsg(self, gud_refresh_pass_kill_online_hero_msg)
end

--更新我方部队
function DlgArmyLayer:refreshMyArmyData()
	local tOnlineList = Player:getHeroInfo():getOnlineHeroList(true)
	local nOnlineNms = table.nums(tOnlineList)
	local nMyArmyNms = table.nums(self.tMyArmy)
	if table.nums(self.tMyArmy) < nOnlineNms then
		for k,v in pairs(tOnlineList) do
			if k > nMyArmyNms then
				table.insert(self.tMyArmy,v)
			end
		end
		self:initData()
		self:updateViews()
	end
end

--更新过关斩将我方部队
function DlgArmyLayer:refreshKillHeroMyArmyData()
	local tOnlineList = Player:getPassKillHeroData():getOnlineHero()
	local nOnlineNms = table.nums(tOnlineList)
	-- local nMyArmyNms = table.nums(self.tMyArmy)
	-- if table.nums(self.tMyArmy) < nOnlineNms then
	-- 	for k, v in pairs(tOnlineList) do
	-- 		if k > nMyArmyNms then
	-- 			table.insert(self.tMyArmy, v)
	-- 		end
	-- 	end
	-- else
	-- end
	self.tMyArmy = tOnlineList
	
	self:initData()
	self:updateViews()
end

--暂停方法
function DlgArmyLayer:onPause( )
	-- body
	self:unregMsgs()
end


--析构方法
function DlgArmyLayer:onDestroy(  )
	nCollectCnt = 3
end

return DlgArmyLayer