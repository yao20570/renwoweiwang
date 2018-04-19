-- Author: dshulan
-- Date: 2017-11-14 16:16:14
-- 资源产量


local DlgCommon = require("app.common.dialog.DlgCommon")
local ItemPalaceCivil = require("app.layer.palace.ItemPalaceCivil")
local ItemHomeRes = require("app.layer.home.ItemHomeRes")

local DlgResCollect = class("DlgResCollect", function ()
	return DlgCommon.new(e_dlg_index.rescollect)
end)

--构造
function DlgResCollect:ctor()
	-- body
	self:myInit()	
	parseView("res_collect", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgResCollect:myInit()
	-- body
	self.tLbResValues = {} 	-- 产量和加成数据文本框
	--资源田征收满了的时间
	self.nTimeMax = Player:getBuildData():getResCollectTimeMax()
	--资源田可征收时间间隔(恢复一次征收的时间)
	self.nEveryTime = Player:getBuildData():getResCollectTime()
	--总征收次数
	self.nTotalCollect = self.nTimeMax/self.nEveryTime
	self.bLeftCanClick = true
	self.bRightCanClick = true

end
  
--解析布局回调事件
function DlgResCollect:onParseViewCallback( pView )
	-- body
	self:addContentView(pView, true)
	self:setupViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgResCollect",handler(self, self.onDlgResCollectDestroy))
end

--设置左边按钮点击事件
--征收资源一次
function DlgResCollect:onLeftBtnClicked()
	-- body
	if not self.bLeftCanClick then
		return
	end
	self.bLeftCanClick = false
	SocketManager:sendMsg("collectRes", {nil, 1}, handler(self, self.onGetCallBack))
				
	--setShowGetItemResUis(3, self.pItemCoin, self.pItemWood, self.pItemFood, self.pItemIron)
end

function DlgResCollect:onGetCallBack( __msg, __oldMsg )
	-- body
	if __msg.head.type == MsgType.collectRes.id then
		if __msg.head.state == SocketErrorType.success then	
			--获取资源特效
			local tSubBuild = {}
			local tSuburbs = Player:getBuildData():getSuburbBuilds()
			if tSuburbs and table.nums(tSuburbs) > 0 then
				for k, v in pairs(tSuburbs) do					
					local nResType = v:getLevyResType()
					if not tSubBuild[nResType] then
						tSubBuild[nResType] = 1
					else
						tSubBuild[nResType] = tSubBuild[nResType] + 1
					end
				end				
			end
			--获取获得资源总量(以资源类型为key)
			local tGetRes = {}
			for i=1,#__msg.body.o do
				local k = __msg.body.o[i].k
				local v = __msg.body.o[i].v
				tGetRes[k] = v
			end
			for k, v in pairs(tGetRes) do
				local nResType = k 
				local nLevyResNum = tGetRes[nResType] or 0
				
				--显示资源数 目前资源田征收飘出的最小数量为2，按2小时以内最小值计的，改为最小数量为4，超过4小时再往上增加
				local nResFlyNum = tSubBuild[nResType]
				if nResFlyNum < 4 then
					nResFlyNum = 4
				end
				--是否是一键征数
				local bIsMulit = table.nums(tSuburbs) > 1				
				--一键征收，每块有产出的资源田，只飘出最小数量，4个，以免数量太多而卡顿明显
				if bIsMulit then
					nResFlyNum = math.min(nResFlyNum, 4)
				end
				showLevyRes(self:getStartUI(nResType), nResType, nResFlyNum, function ( ... )
					-- body
					local pEndUi = getShowGetItemResUis(3, nResType)
					if self and self.playNumJump then						
						self:playNumJump(pEndUi, nLevyResNum)
					end
				end, self.pLayBase)					
			end				
			if __oldMsg[2] == 1 then	
				self.bLeftCanClick = true
			elseif __oldMsg[2] == 2 then
				self.bRightCanClick = true
			end

			if self.bIsTasking then
				--延迟1秒自动关闭界面
				doDelayForSomething(self, function( )
					self:closeCommonDlg()
				end, 1)
			end		
		end
	end	
end
function DlgResCollect:playNumJump( pUi, nResNum )
	-- body
	if not pUi then
		return
	end
	--播放跳字动画
	local pLayArm = showNumJump(nResNum)
	if pLayArm then
		pUi:addView(pLayArm, 99)
		local pSize = pUi:getContentSize()
		pLayArm:setPosition(pSize.width/2, pSize.height/2)
	end	
end

function DlgResCollect:getStartUI( nResType )
	-- body
	if not nResType then
		return nil
	end
	local pUi = nil
	if nResType == e_resdata_ids.yb then
		pUi = self.tLbResValues[6]
	elseif nResType == e_resdata_ids.mc then
		pUi = self.tLbResValues[12]
	elseif nResType == e_resdata_ids.lc then
		pUi = self.tLbResValues[18]							
	elseif nResType == e_resdata_ids.bt then
		pUi = self.tLbResValues[24]
	end	
	return pUi
end

function DlgResCollect:getEndUI( nResType )
	-- body
	if not nResType then
		return
	end
	local pUi = nil
	if nResType == e_resdata_ids.yb then
		pUi = self.tLbResValues[6]
	elseif nResType == e_resdata_ids.mc then
		pUi = self.tLbResValues[12]
	elseif nResType == e_resdata_ids.lc then
		pUi = self.tLbResValues[18]							
	elseif nResType == e_resdata_ids.bt then
		pUi = self.tLbResValues[24]
	end	
	return pUi
end
--设置右键按钮点击事件
--一键征收
function DlgResCollect:onRithtBtnClicked()
	-- body
	-- if not self.bRightCanClick then
	-- 	return
	-- end
	--新手引导已点击一键征收
	Player:getNewGuideMgr():setNewGuideFingerClicked(e_guide_finer.res_collectall_btn)

	self.bRightCanClick = false
	SocketManager:sendMsg("collectRes", {nil, 2}, handler(self, self.onGetCallBack))
end

--按钮无效回调
function DlgResCollect:onDisabledHandler()
	-- body
	TOAST(getConvertedStr(7, 10241)) 	--征收次数尚未恢复
end


--初始化控件
function DlgResCollect:setupViews()

	--设置标题
	self:setTitle(getConvertedStr(7, 10228))

	self:setLeftBtnType(TypeCommonBtn.L_BLUE)
	self:setLeftBtnText(getConvertedStr(7, 10229))

	--设置左边按钮点击事件
	self:setLeftHandler(handler(self, self.onLeftBtnClicked))
	--可征收次数
	self.pLbColTimes = MUI.MLabel.new({text = "", size = 20})
	self.pLayBottom:addView(self.pLbColTimes, 10)
	self.pLbColTimes:setPosition(self.pLayLeft:getPositionX() + self.pLayLeft:getWidth()/2, 
		self.pLayLeft:getPositionY() + self.pLayLeft:getHeight())

	self:setRightBtnType(TypeCommonBtn.L_YELLOW)
	self:setRightBtnText(getConvertedStr(7, 10230))
	--设置右键按钮点击事件
	self:setRightHandler(handler(self, self.onRithtBtnClicked))


	self:setLeftDisabledHandler(handler(self, self.onDisabledHandler))
	self:setRightDisabledHandler(handler(self, self.onDisabledHandler))

    --左边文字
	local tStr = 
	{
		[1] = getConvertedStr(7, 10232), 	--资源
		[2] = getConvertedStr(7, 10233), 	--产量
		[3] = getConvertedStr(7, 10234), 	--基础产量
		[4] = getConvertedStr(7, 10235), 	--科技加成
		[5] = getConvertedStr(7, 10236), 	--季节加成
		[6] = getConvertedStr(7, 10237), 	--文官加成
		[7] = getConvertedStr(7, 10238), 	--活动加成
		[8] = getConvertedStr(7, 10239) 	--总产量
	}
	for i = 1, 8 do
		local pLb = self:findViewByName("lb_left_"..i)
		pLb:setString(tStr[i])
		if i == 8 then
			setTextCCColor(pLb,_cc.blue)
		end
	end


	--资源总拥有量
	self.pLayRes = self:findViewByName("lay_res")
	--平均宽度
	local nW = self.pLayRes:getWidth() / 4
	--银币
	self.pItemCoin 				= 		ItemHomeRes.new(1)
	self.pLayRes:addView(self.pItemCoin)
	self.pItemCoin:setPosition(0, 13)
	--木头
	self.pItemWood 				= 		ItemHomeRes.new(2)
	self.pLayRes:addView(self.pItemWood)
	self.pItemWood:setPosition(nW, 13)
	--粮食
	self.pItemFood 				= 		ItemHomeRes.new(3)
	self.pLayRes:addView(self.pItemFood)
	self.pItemFood:setPosition(nW * 2, 13)
	--铁
	self.pItemIron 				= 		ItemHomeRes.new(4)
	self.pLayRes:addView(self.pItemIron)
	self.pItemIron:setPosition(nW * 3, 13)


	--设置获得物品资源ui
	setShowGetItemResUis(3, self.pItemCoin, self.pItemWood, self.pItemFood, self.pItemIron)

	--产量和加成数据
	for i = 1, 24 do
		local pLb = self:findViewByName("lb_num_"..i)
		--总产量显示蓝色
		if i%6 == 0 then
			setTextCCColor(pLb,_cc.blue)
		end
		self.tLbResValues[i] = pLb
	end

	--文官信息层
	self.pLayCivil = self:findViewByName("lay_employ")
	self.pItemPalaceCivil = ItemPalaceCivil.new(e_hire_type.official, true) --文官信息Item	
	self.pLayCivil:addView(self.pItemPalaceCivil, 10)		
	centerInView(self.pLayCivil, self.pItemPalaceCivil)
	self.pItemPalaceCivil:resetSize()
	self.pItemPalaceCivil:hideDiBg()

	--新手引导一键征收按钮
	self.pRBtn = self:getRightButton()
	Player:getNewGuideMgr():setNewGuideFinger(self.pRBtn, e_guide_finer.res_collectall_btn)
	local tTask = Player:getPlayerTaskInfo():getCurAgencyTask()
	if tTask then
		local nCurTaskId = tTask.sTid
		--一键征收按钮显示特效
		if nCurTaskId == e_special_task_id.collect_res then
			showSequenceFunc(e_show_seq.rescollect)
			self.bIsTasking = true
			self.pRBtn:showLingTx()

		else
			self.bIsTasking = false
			self.pRBtn:removeLingTx()
		end
	end

end

-- 修改控件内容或者是刷新控件数据
function DlgResCollect:updateViews()
	-- body
	--资源建筑的征收累积时间, 用来计算征收次数
	local nCollectCd = Player:getBuildData():getCollectLeftTime()

	if nCollectCd > self.nTimeMax then
		nCollectCd = self.nTimeMax
	end

	--可征收次数
	local nCanCollect = math.floor(nCollectCd/self.nEveryTime)

	--如果征收次数为0
	if nCanCollect == 0 then
		--设置按钮无效
		self:setLeftBtnEnabled(false)
		self:setRightBtnEnabled(false)
		--启动线程
		regUpdateControl(self, handler(self, self.onUpdate))
		self.pRBtn:removeLingTx()
	else
		self:setLeftBtnEnabled(true)
		self:setRightBtnEnabled(true)
		unregUpdateControl(self)
		--征收次数
		local sStr = {
			{text = getConvertedStr(7, 10231), color = _cc.pwhite},
			{text = nCanCollect, color = _cc.blue},
			{text = "/", color = _cc.pwhite},
			{text = self.nTotalCollect, color = _cc.pwhite},
		}
		self.pLbColTimes:setString(sStr)
	end


	--资源产量和加成数据
	local resourceData = Player:getResourceData()
	if not resourceData then
		return
	end
	--银币
	self:setLabelValue(self.tLbResValues[1], resourceData.tBase.coin)
	self:setLabelValue(self.tLbResValues[2], resourceData.tScience.coin, "+")
	self:setLabelValue(self.tLbResValues[3], resourceData.tSeason.coin, "+")
	self:setLabelValue(self.tLbResValues[4], resourceData.tOfficer.coin, "+")
	self:setLabelValue(self.tLbResValues[5], resourceData.tAcitvity.coin, "+")
	self:setLabelValue(self.tLbResValues[6], resourceData.tAll.coin)
	--木材
	self:setLabelValue(self.tLbResValues[7], resourceData.tBase.wood)
	self:setLabelValue(self.tLbResValues[8], resourceData.tScience.wood, "+")
	self:setLabelValue(self.tLbResValues[9], resourceData.tSeason.wood, "+")
	self:setLabelValue(self.tLbResValues[10], resourceData.tOfficer.wood, "+")
	self:setLabelValue(self.tLbResValues[11], resourceData.tAcitvity.wood, "+")
	self:setLabelValue(self.tLbResValues[12], resourceData.tAll.wood)
	--粮食
	self:setLabelValue(self.tLbResValues[13], resourceData.tBase.food)
	self:setLabelValue(self.tLbResValues[14], resourceData.tScience.food, "+")
	self:setLabelValue(self.tLbResValues[15], resourceData.tSeason.food, "+")
	self:setLabelValue(self.tLbResValues[16], resourceData.tOfficer.food, "+")
	self:setLabelValue(self.tLbResValues[17], resourceData.tAcitvity.food, "+")
	self:setLabelValue(self.tLbResValues[18], resourceData.tAll.food)
	--铁矿
	self:setLabelValue(self.tLbResValues[19], resourceData.tBase.iron)
	self:setLabelValue(self.tLbResValues[20], resourceData.tScience.iron, "+")
	self:setLabelValue(self.tLbResValues[21], resourceData.tSeason.iron, "+")
	self:setLabelValue(self.tLbResValues[22], resourceData.tOfficer.iron, "+")
	self:setLabelValue(self.tLbResValues[23], resourceData.tAcitvity.iron, "+")
	self:setLabelValue(self.tLbResValues[24], resourceData.tAll.iron)
	
end

--每秒刷新距离下一次可征收的时间
function DlgResCollect:onUpdate()
	-- body
	--剩余时间
	local fLeftTime = self.nEveryTime - Player:getBuildData():getCollectLeftTime()
	if fLeftTime > 0 then
		local sStr = {
			{text = formatTimeToMs(fLeftTime), color = _cc.red},
			{text = getConvertedStr(7, 10242), color = _cc.pwhite},
		}
		self.pLbColTimes:setString(sStr)
	else
		--关闭倒计时
		unregUpdateControl(self)
		self.pLbColTimes:setString("")
	end
end


--设置数值标签的数值 仅仅本类中的item组的数值标签
--splus:加号
function DlgResCollect:setLabelValue( _plabel, _svalue, splus )
	-- body
	if not _plabel then
		return
	end
	local svalur = tonumber(_svalue)
	if svalur and svalur > 0 then     --数值小于等于0 的时候设置为默认 "--"
		local str = getResourcesStr(svalur)
		-- if svalur > 9999 then
		-- 	str = (math.ceil(svalur/1000)).."k"
		-- end
		if splus then
			str = splus..str
		end
		_plabel:setString(str)
	else				
		_plabel:setString(getConvertedStr(7, 10240))
	end
end


--刷新资源总量
function DlgResCollect:updateResTotalValue()
	self.pItemFood:updateValue()
	self.pItemWood:updateValue()
	self.pItemIron:updateValue()
	self.pItemCoin:updateValue()
end

--文官雇用信息刷新消息响应
function DlgResCollect:updateItemPalaceCivil()
	-- body
	if self.pItemPalaceCivil then
		self.pItemPalaceCivil:updateViews()
	end
end

--析构方法
function DlgResCollect:onDlgResCollectDestroy()
	self:onPause()
end

-- 注册消息
function DlgResCollect:regMsgs( )
	-- body
	regMsg(self, gud_refresh_palace_resource, handler(self, self.updateViews))
	--注册成功雇用文官事件
	regMsg(self, ghd_refresh_palacecivil, handler(self, self.updateItemPalaceCivil))
	-- 注册玩家数据变化的消息
	regMsg(self, gud_refresh_playerinfo, handler(self, self.updateResTotalValue))
	-- 资源田征收后数据变化的消息
	regMsg(self, gud_refresh_suburb_data, handler(self, self.updateViews))
	-- 刷新资源田征收状态的消息
	regMsg(self, ghd_refresh_suburb_state_mulit_msg, handler(self, self.updateViews))
end

-- 注销消息
function DlgResCollect:unregMsgs(  )
	-- body
	-- 注销王宫界面资源数据刷新	
	unregMsg(self, gud_refresh_palace_resource)
	-- 注销雇用文官事件
	unregMsg(self, ghd_refresh_palacecivil)
	-- 销毁玩家数据变化的消息
	unregMsg(self, gud_refresh_playerinfo)
	-- 销毁资源田征收后数据变化的消息
	unregMsg(self, gud_refresh_suburb_data)
	-- 销毁资源田征收状态的消息
	unregMsg(self, ghd_refresh_suburb_state_mulit_msg)
end


--暂停方法
function DlgResCollect:onPause( )
	-- body
	self:unregMsgs()
	if self.bIsTasking then
		--允许提示弹框
		showNextSequenceFunc(e_show_seq.rescollect)
	end
end

--继续方法
function DlgResCollect:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end


--确定按钮回调
function  DlgResCollect:onSureBtnClicked( pView )
	-- body
	self:closeCommonDlg()
end


return DlgResCollect
