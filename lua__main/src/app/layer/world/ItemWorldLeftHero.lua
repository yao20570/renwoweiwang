----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-19 14:57:36
-- Description: 世界大地图左边 武将列表 子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local ItemWorldLeftHero = class("ItemWorldLeftHero", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--nIndex 下标
function ItemWorldLeftHero:ctor( nIndex )
	self.nIndex = nIndex
	--解析文件
	parseView("item_world_left_hero", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemWorldLeftHero:onParseViewCallback( pView )
	self.pView = pView
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemWorldLeftHero",handler(self, self.onItemWorldLeftHeroDestroy))
end

-- 析构方法
function ItemWorldLeftHero:onItemWorldLeftHeroDestroy(  )
    self:onPause()
end

function ItemWorldLeftHero:regMsgs(  )
end

function ItemWorldLeftHero:unregMsgs(  )
end

function ItemWorldLeftHero:onResume(  )
	self:regMsgs()
	--更新
	regUpdateControl(self, handler(self, self.updateCd))
end

function ItemWorldLeftHero:onPause(  )
	self:unregMsgs()

	unregUpdateControl(self)
end

function ItemWorldLeftHero:setupViews(  )
	self.pLayInfo = self:findViewByName("lay_info")
	self.pImgArrow = self:findViewByName("img_arrow")
	self.pTxtTask = self:findViewByName("txt_task")
	--定位
	self.pLayLocation = self:findViewByName("lay_location")
	self.pLayLocation:setViewTouched(true)
	self.pLayLocation:setIsPressedNeedScale(false)
	self.pLayLocation:onMViewClicked(handler(self, self.onLocationClicked))

	--名字
	local pLayGroupName = self:findViewByName("lay_group_name")
	local tConTable = {}
	local tLabel = {
	 {"XXX"},
	 {"0",getC3B(_cc.blue)},
	}
	tConTable.tLabel = tLabel
	self.pGroupName =  createGroupText(tConTable)
	pLayGroupName:addView(self.pGroupName)

	self.pTxtCd = self:findViewByName("txt_cd")
	setTextCCColor(self.pTxtCd, _cc.green)
	self.pLayBtn1 = self:findViewByName("lay_btn1")
	self.pBtn1 = getCommonButtonOfContainer(self.pLayBtn1,TypeCommonBtn.M_BLUE)
	setMCommonBtnScale(self.pLayBtn1, self.pBtn1, 0.8)
	self.pLayBtn2 = self:findViewByName("lay_btn2")
	self.pBtn2 = getCommonButtonOfContainer(self.pLayBtn2,TypeCommonBtn.M_BLUE)
	setMCommonBtnScale(self.pLayBtn2, self.pBtn2, 0.8)
	self.pLayIcon = self:findViewByName("lay_icon")
	self.pLayMuiltIcon = self:findViewByName("lay_mulit_icon")
	local pLayIcon1 = self:findViewByName("lay_icon1")
	local pLayIcon2 = self:findViewByName("lay_icon2")
	local pLayIcon3 = self:findViewByName("lay_icon3")
	local pLayIcon4 = self:findViewByName("lay_icon4")
	self.pLayIcons = {
		pLayIcon1,
		pLayIcon2,
		pLayIcon3,
		pLayIcon4,
	}
	self.pIcons = {}

	self.pTxtNoHeroTip = self:findViewByName("txt_no_hero_tip")
	self.pTxtNoHeroTip:setString(getConvertedStr(3, 10132), false)
	centerInView(self.pView, self.pTxtNoHeroTip)
end

function ItemWorldLeftHero:updateViews(  )
end

function ItemWorldLeftHero:updateCd()
	--更换形态
	if self.sTaskId then
		--更新数据
		local tTask = Player:getWorldData():getTaskMsgByUuid(self.sTaskId)
		if tTask then
			local nCd = tTask:getCd()
			if nCd then
				local sCdTitle = ""
				if self.nState == e_type_task_state.go then
					sCdTitle = getConvertedStr(3, 10133)
				elseif self.nState == e_type_task_state.back then
					sCdTitle = getConvertedStr(3, 10087)
				else
					if self.nTaskType == e_type_task.collection then
						sCdTitle = getConvertedStr(3, 10079)
					elseif self.nTaskType == e_type_task.countryWar then
						sCdTitle = getConvertedStr(3, 10082)
					elseif self.nTaskType == e_type_task.cityWar then
						sCdTitle = getConvertedStr(3, 10081)
					elseif self.nTaskType == e_type_task.garrison then
						sCdTitle = getConvertedStr(3, 10083)
					end
				end
				self.pTxtCd:setString(string.format("%s %s", sCdTitle, formatTimeToMs(nCd)))
			end
		end
	end
end

--tData:  
function ItemWorldLeftHero:setData( tData )
	self.tData = tData
	self.sTaskId = nil

	if self.tData then
		self.pLayInfo:setVisible(true)
		self.pTxtNoHeroTip:setVisible(false)

		--设置任务
		if self.tData.tTask then
			self.sTaskId = self.tData.tTask.sUuid
			local tTask = Player:getWorldData():getTaskMsgByUuid(self.sTaskId)
			if tTask then
				self.nState = tTask.nState
				self.nTaskType = tTask.nType
				if self.nTaskType == e_type_task.collection then
					self:setCollectionStyle(tTask)
				elseif self.nTaskType == e_type_task.wildArmy then
					self:setArmyStyle(tTask)
				elseif self.nTaskType == e_type_task.cityWar then
					self:setCityWarStyle(tTask)
				elseif self.nTaskType == e_type_task.countryWar then
					self:setCountryWarStyle(tTask)
				elseif self.nTaskType == e_type_task.garrison then
					self:setGarrisonStyle(tTask)
				end
				self:setMulitHero(tTask.tArmy)
			end
		elseif self.tData.heroId then --设置武将
			self:setIdleSytle()
		end

		self:updateCd()
	else
		self.pLayInfo:setVisible(false)
		self.pTxtNoHeroTip:setVisible(true)
		--武将已出阵
		local nOnlineNums = #Player:getHeroInfo():getOnlineHeroList() --已上阵人数
		if self.nIndex <= nOnlineNums then
			--武将已出战
			self.pTxtNoHeroTip:setString(getConvertedStr(3, 10363))
		else 
			local nOnlineNumsMax = Player:getHeroInfo().nOnlineNums --可上阵
			if self.nIndex <= nOnlineNumsMax then
				--武将未上阵
				self.pTxtNoHeroTip:setString(getConvertedStr(3, 10364))
			else
				--武将位未开启
				self.pTxtNoHeroTip:setString(getConvertedStr(3, 10132))
			end
		end

	end
end

--设置乱军
function ItemWorldLeftHero:setArmyStyle( tTask )
	--任务名
	self.pTxtTask:setString(getConvertedStr(3, 10080))
	--箭头图片
	self.pImgArrow:setCurrentImage("#v1_img_chengbiaoqian.png")
	--乱军名+等级
	if tTask then
		self.pGroupName:setLabelCnCr(1, tTask.sTargetName or getConvertedStr(3, 10080)) 
		self.pGroupName:setLabelCnCr(2, getLvString(tTask.nTargetLv))
	end
	--前往
	if self.nState == e_type_task_state.go then
		--召回
		self:setBtnCallBack(self.pBtn1)
		--加速
		self:setBtnQuick(self.pBtn2)
	--返回
	elseif self.nState == e_type_task_state.back then
		--加速
		self:setBtnQuick(self.pBtn1)
		--目标
		self:setBtnTarget(self.pBtn2)
	end

	self.pLayBtn1:setVisible(true)
	self.pLayBtn2:setVisible(true)
	self.pGroupName:setVisible(true)
	self.pTxtCd:setVisible(true)
	self.pLayIcon:setPositionX(6)
	self.pLayLocation:setVisible(true)
end

--设置采集
function ItemWorldLeftHero:setCollectionStyle( tTask )
	--任务名
	self.pTxtTask:setString(getConvertedStr(3, 10079))
	--箭头图片
	self.pImgArrow:setCurrentImage("#v1_img_lvqian.png")
	--采集+等级
	if tTask then
		self.pGroupName:setLabelCnCr(1, tTask.sTargetName or getConvertedStr(3, 10079)) 
		self.pGroupName:setLabelCnCr(2, getLvString(tTask.nTargetLv))
	end
	--前往
	if self.nState == e_type_task_state.go then
		--召回
		self:setBtnCallBack(self.pBtn1)
		--加速
		self:setBtnQuick(self.pBtn2)
	elseif self.nState == e_type_task_state.back then
		--加速
		self:setBtnQuick(self.pBtn1)
		--目标
		self:setBtnTarget(self.pBtn2)
	--采集
	elseif self.nState == e_type_task_state.collection then
		--返回
		self:setBtnBack(self.pBtn1)
		--目标
		self:setBtnTarget(self.pBtn2)
	end
	

	self.pLayBtn1:setVisible(true)
	self.pLayBtn2:setVisible(true)
	self.pGroupName:setVisible(true)
	self.pTxtCd:setVisible(true)
	self.pLayIcon:setPositionX(6)
	self.pLayLocation:setVisible(true)
end

--设置国战
function ItemWorldLeftHero:setCountryWarStyle( tTask )
	--任务名
	self.pTxtTask:setString(getConvertedStr(3, 10082))
	--箭头图片
	self.pImgArrow:setCurrentImage("#v1_img_zibiaoqian.png")
	--国战+等级
	if tTask then
		self.pGroupName:setLabelCnCr(1, tTask.sTargetName or getConvertedStr(3, 10082)) 
		self.pGroupName:setLabelCnCr(2, getLvString(tTask.nTargetLv))
	end
	--前往
	if self.nState == e_type_task_state.go then
		--召回
		self:setBtnCallBack(self.pBtn1)
	--返回
	elseif self.nState == e_type_task_state.back then
		--加速
		self:setBtnQuick(self.pBtn1)
	--国战
	elseif self.nState == e_type_task_state.waitbattle then
		--返回
		self:setBtnBack(self.pBtn1)
	end
	--目标
	self:setBtnTarget(self.pBtn2)

	self.pLayBtn1:setVisible(true)
	self.pLayBtn2:setVisible(true)
	self.pGroupName:setVisible(true)
	self.pTxtCd:setVisible(true)
	self.pLayIcon:setPositionX(6)
	self.pLayLocation:setVisible(true)
end

--设置城战
function ItemWorldLeftHero:setCityWarStyle( tTask )
	--任务名
	self.pTxtTask:setString(getConvertedStr(3, 10081))
	--箭头图片
	self.pImgArrow:setCurrentImage("#v1_img_lanbiaoqian.png")
	--城战+等级
	if tTask then
		self.pGroupName:setLabelCnCr(1, tTask.sTargetName or getConvertedStr(3, 10081)) 
		self.pGroupName:setLabelCnCr(2, getLvString(tTask.nTargetLv))
	end
	--前往
	if self.nState == e_type_task_state.go then
		--召回
		self:setBtnCallBack(self.pBtn1)
	--返回
	elseif self.nState == e_type_task_state.back then
		--加速
		self:setBtnQuick(self.pBtn1)
	--城战
	elseif self.nState == e_type_task_state.waitbattle then
		--返回
		self:setBtnBack(self.pBtn1)
	end
	--目标
	self:setBtnTarget(self.pBtn2)

	self.pLayBtn1:setVisible(true)
	self.pLayBtn2:setVisible(true)
	self.pGroupName:setVisible(true)
	self.pTxtCd:setVisible(true)
	self.pLayIcon:setPositionX(6)
	self.pLayLocation:setVisible(true)
end

--设置驻防
function ItemWorldLeftHero:setGarrisonStyle( tTask )
	self.pTxtTask:setString(getConvertedStr(3, 10083))
	self.pImgArrow:setCurrentImage("#v1_img_lanbiaoqian.png")
	--驻防+等级
	if tTask then
		self.pGroupName:setLabelCnCr(1, tTask.sTargetName or getConvertedStr(3, 10083)) 
		self.pGroupName:setLabelCnCr(2, getLvString(tTask.nTargetLv))
	end
	--前往
	if self.nState == e_type_task_state.go then
		--召回
		self:setBtnCallBack(self.pBtn1)
	--返回
	elseif self.nState == e_type_task_state.back then
		--加速
		self:setBtnQuick(self.pBtn1)
	--城战
	elseif self.nState == e_type_task_state.garrison then
		--返回
		self:setBtnBack(self.pBtn1)
	end
	--目标
	self:setBtnTarget(self.pBtn2)

	self.pLayBtn1:setVisible(true)
	self.pLayBtn2:setVisible(true)
	self.pGroupName:setVisible(true)
	self.pTxtCd:setVisible(true)
	self.pLayIcon:setPositionX(6)
	self.pLayLocation:setVisible(true)
end

--设置空闲状态
function ItemWorldLeftHero:setIdleSytle(  )
	self.pImgArrow:setCurrentImage("#v1_img_lvqian.png")
	self.pTxtTask:setString(getConvertedStr(3, 10078))
	self.pLayBtn1:setVisible(false)
	self.pLayBtn2:setVisible(false)
	self.pGroupName:setVisible(false)
	self.pTxtCd:setVisible(false)
	self.pLayLocation:setVisible(false)

	self.pLayIcon:setPositionX(6 + 72)
	if self.tData then
		self:setHero(self.tData.heroId)
	end
end

--设置多个或一个武将
function ItemWorldLeftHero:setMulitHero( tArmy )
	if #tArmy == 1 then
		self:setHero(tArmy[1])
	else
		self.pLayMuiltIcon:setVisible(true)
		self.pLayIcon:setVisible(false)
		for i=1,#self.pLayIcons do
			local pLayIcon = self.pLayIcons[i]
			local heroId = tArmy[i]
			if heroId then
				local pHero = Player:getHeroInfo():getHero(heroId)
				if pHero then
					if not pLayIcon.pHeroIcon then
						pLayIcon.pHeroIcon = getIconHeroByType(pLayIcon,TypeIconHero.NORMAL,pHero,TypeIconHeroSize.L)
						pLayIcon.pHeroIcon:setScale(0.5)
						pLayIcon.pHeroIcon:setIconIsCanTouched(false)
					else
						pLayIcon.pHeroIcon:setCurData(pHero)
					end
				end
				pLayIcon:setVisible(true)
			else
				pLayIcon:setVisible(false)
			end
		end
	end
end

--设置单个英雄
function ItemWorldLeftHero:setHero( heroId )
	self.pLayMuiltIcon:setVisible(false)
	self.pLayIcon:setVisible(true)
	local pHero = Player:getHeroInfo():getHero(heroId)
	if pHero then
		if not self.pHeroIcon then
			self.pHeroIcon = getIconHeroByType(self.pLayIcon,TypeIconHero.NORMAL,pHero,TypeIconHeroSize.M)
			self.pHeroIcon:setIconIsCanTouched(false)
		else
			self.pHeroIcon:setCurData(pHero)
		end
	end
end

--定位回调
function ItemWorldLeftHero:onLocationClicked(  )
	if not self.tData then
		return
	end
	if not self.tData.tTask then
		return
	end
	local fX, fY = WorldFunc.getMyHeroPosByTask(self.tData.tTask)
	sendMsg(ghd_world_location_mappos_msg, {fX = fX, fY = fY})
end


--目标定位
function ItemWorldLeftHero:onLocationTarget(  )
	if not self.tData then
		return
	end
	if not self.tData.tTask then
		return
	end
	local fX, fY = WorldFunc.getMapPosByDotPosEx(self.tData.tTask.nTargetX, self.tData.tTask.nTargetY)
	sendMsg(ghd_world_location_mappos_msg, {fX = fX, fY = fY, isClick = true})
end

--加速回调
function ItemWorldLeftHero:onQuickClicked(  )
	if self.sTaskId then
		local tTask = Player:getWorldData():getTaskMsgByUuid(self.sTaskId)
		if tTask then
			local tObject = {}
		    tObject.nType = e_dlg_index.worlduseresitem --dlg类型
		    tObject.tItemList = {100030,100031}
		    tObject.tTaskCommend = { nOrder = e_type_task_input.quick, sTaskUuid = tTask.sUuid}
		    sendMsg(ghd_show_dlg_by_type,tObject)
		end
	end
end

--召回回调
function ItemWorldLeftHero:onCallClicked(  )
	if self.sTaskId then
		local tTask = Player:getWorldData():getTaskMsgByUuid(self.sTaskId)
		if tTask then
			--前往的时候召回要弹出使用道具页面
			if tTask.nState == e_type_task_state.go then
				local tObject = {}
			    tObject.nType = e_dlg_index.worlduseresitem --dlg类型
			    tObject.tItemList = {100032,100033}
			    tObject.tTaskCommend = { nOrder = e_type_task_input.call, sTaskUuid = tTask.sUuid}
			    sendMsg(ghd_show_dlg_by_type,tObject)
			else
				-- --驻防召回
				-- if tTask.nType == e_type_task.garrison and tTask.nState == e_type_task_state.garrison then
				-- 	SocketManager:sendMsg("reqWorldGarrisonBack", {tTask.sUuid})
				-- else
					--行军召回
					SocketManager:sendMsg("reqWorldTaskInput", {tTask.sUuid, e_type_task_input.call, nil})
				-- end
			end
		end
	end
end

--设置按钮返回
function ItemWorldLeftHero:setBtnBack( pBtn )
	pBtn:updateBtnText(getConvertedStr(3, 10087))
	pBtn:updateBtnType(TypeCommonBtn.M_YELLOW)
	pBtn:onCommonBtnClicked(handler(self, self.onCallClicked))
end

--设置按钮召回
function ItemWorldLeftHero:setBtnCallBack( pBtn )
	pBtn:updateBtnText(getConvertedStr(3, 10085))
	pBtn:updateBtnType(TypeCommonBtn.M_RED)
	pBtn:onCommonBtnClicked(handler(self, self.onCallClicked))
end

--设置按钮加速
function ItemWorldLeftHero:setBtnQuick( pBtn )
	pBtn:updateBtnText(getConvertedStr(3, 10084))
	pBtn:updateBtnType(TypeCommonBtn.M_YELLOW)
	pBtn:onCommonBtnClicked(handler(self, self.onQuickClicked))
end

--设置按钮目标
function ItemWorldLeftHero:setBtnTarget( pBtn )
	pBtn:updateBtnText(getConvertedStr(3, 10358))
	pBtn:updateBtnType(TypeCommonBtn.M_BLUE)
	pBtn:onCommonBtnClicked(handler(self, self.onLocationTarget))
end

	

return ItemWorldLeftHero