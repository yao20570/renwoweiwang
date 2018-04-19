-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-04-18 15:12:23 星期二
-- Description: 王宫界面文官面板  应用于王宫界面和文官雇用界面
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local MBtnExText = require("app.common.button.MBtnExText")
local ItemEmployCivil = class("ItemEmployCivil", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)


function ItemEmployCivil:ctor(_nemploytype)
	-- body
	self:myInit(_nemploytype)

	parseView("item_civilpanel_employ", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemEmployCivil",handler(self, self.onItemEmployCivilDestroy))
	
end

--初始化参数
function ItemEmployCivil:myInit(_nemploytype)
	-- body
	self.bisHaveCivil = false --是否使用文官	
	self.pCurData = nil --文官数据
	self.nEmployType = _nemploytype or e_hire_type.official
end

function ItemEmployCivil:setEmployType( _nemploytype )
	-- body
	self.nEmployType = _nemploytype or e_hire_type.official
end

--解析布局回调事件
function ItemEmployCivil:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemEmployCivil:setupViews( )
	self.pLyRoot = self:findViewByName("root")
	--ly
	self.pLyKuang =  self:findViewByName("lay_civil_kuang")--头像层  	                
	self.pLyCivil =  self:findViewByName("lay_civil_value")--文官信息层 
	self.pLyRS = self:findViewByName("lay_researcher_value")--研究员信息层
	self.pLyCivil:setVisible(true)

	--文管信息
	self.pLbCivilName = self:findViewByName("lb_civil_name")--文官名字
	self.pLbCivilName:setString("")
	setTextCCColor(self.pLbCivilName, _cc.green)

	self.pLbCivilLv = self:findViewByName("lb_civil_lv")--文官等级
	self.pLbCivilLv:setString("")
	setTextCCColor(self.pLbCivilLv, _cc.blue)

	self.pLbFunc1 = self:findViewByName("lb_func1")--功能1
	self.pLbFunc1:setString(getConvertedStr(6, 10083))
	setTextCCColor(self.pLbFunc1, _cc.pwhite)
	self.pLbFunc1Value = self:findViewByName("lb_func1_value")--功能1值	
	self.pLbFunc1Value:setString(getConvertedStr(6, 10149))
	setTextCCColor(self.pLbFunc1Value, _cc.green)
	
	self.pLbFunc2 = self:findViewByName("lb_func2")--功能2
	setTextCCColor(self.pLbFunc2, _cc.pwhite)
	self.pLbFunc2:setString(getConvertedStr(6, 10084))
	self.pLbFunc2Value = self:findViewByName("lb_func2_value")--功能2值
	setTextCCColor(self.pLbFunc2Value, _cc.blue)
	self.pLbFunc2Value:setString(getConvertedStr(6, 10149))

	--研究员信息层
	self.pLbRsName = self:findViewByName("lb_rs_name")--研究员名字
	setTextCCColor(self.pLbRsName, _cc.green)
	self.pLbRsLv = self:findViewByName("lb_rs_lv")--研究员等级
	setTextCCColor(self.pLbRsLv, _cc.blue)
	self.pLbRsFunc = self:findViewByName("lb_func3")--研究员功能说明

	self.pLbTime = self:findViewByName("lb_time")--铁匠持续时间

	--头像
	self.pIcon = getIconHeroByType(self.pLyKuang, TypeIconHero.NORMAL, nil, TypeIconHeroSize.M)
	self.pIcon:setIconIsCanTouched(false)		
	--
	self.pLyBtnEmploy = self:findViewByName("lay_btn_employ")--雇用按钮
	self.pLyLocked =  self:findViewByName("lay_locked")--无法雇用时候显示遮罩
	self.pLyLocked:setVisible(false)
	self.pLbStatus = self:findViewByName("lb_status")--解锁条件	
	setTextCCColor(self.pLbStatus, _cc.red)
	self.pLbStatus:setVisible(false)
	local sstr = getConvertedStr(6,  10151)..tostring(1)..getConvertedStr(6, 10152)
	self.pLbStatus:setString(sstr)
	--雇用按钮
	self.pBtnEmploy = getCommonButtonOfContainer(self.pLyBtnEmploy, TypeCommonBtn.M_YELLOW, getConvertedStr(6, 10095), false)	
	self.pBtnEmploy:onCommonBtnClicked(handler(self, self.onEmployBtnClicked))
	local tBtnTable = {}
	tBtnTable.parent = self.pBtnEmploy
	tBtnTable.img = "#v1_img_qianbi.png"
	local value = 500
	--文本
	tBtnTable.tLabel = {
		{value,getC3B(_cc.yellow)}
	}
	self.pBtnExTextEmploy = MBtnExText.new(tBtnTable)

end

-- 修改控件内容或者是刷新控件数据
function ItemEmployCivil:updateViews(  )
	-- body
	if self.pCurData then
		--解锁等级
		local nlimitLv = nil
		local nopenLv = nil
		local buildName = ""
		if self.nEmployType == e_hire_type.official then
			self:refreshOfficalInfo(self.pCurData)
			nlimitLv = Player:getBuildData():getBuildById(e_build_ids.palace).nLv
			buildName = Player:getBuildData():getBuildById(e_build_ids.palace).sName
			nopenLv = self.pCurData.nLimit
		elseif self.nEmployType == e_hire_type.researcher then
			self:refreshResearcherInfo(self.pCurData)
			nlimitLv = Player:getBuildData():getBuildById(e_build_ids.tnoly).nLv
			buildName = Player:getBuildData():getBuildById(e_build_ids.tnoly).sName
			nopenLv = self.pCurData.nLimit
		elseif self.nEmployType == e_hire_type.smith then
			self:refreshSmithInfo(self.pCurData)
			nlimitLv = Player:getBuildData():getBuildById(e_build_ids.palace).nLv
			buildName = Player:getBuildData():getBuildById(e_build_ids.palace).sName
			nopenLv = self.pCurData.nLimit
		else
			print("错误的雇用类型")
		end
		-- print("nlimitLv="..nlimitLv)
		-- print("nopenLv="..nopenLv)
		if not nlimitLv or not nopenLv then
			print("错误的雇员数据或建筑数据")
			return
		end

		if nlimitLv >= nopenLv then--可以雇用
			self.pLyBtnEmploy:setVisible(true)
			self.pBtnExTextEmploy:setVisible(true)
			self.pLbStatus:setVisible(false)
			--self.pLyLocked:setVisible(false)
			local tcost = luaSplit(self.pCurData.sCost, ":")
			local nCost = tonumber(tcost[2] or 0)
			local bEnougth = true
			if tonumber(tcost[1]) == e_resdata_ids.yb then
				self.pBtnExTextEmploy:setImg("#v1_img_tongqian.png")
				bEnougth = Player:getPlayerInfo().nCoin >= nCost			
			elseif tonumber(tcost[1]) == e_resdata_ids.ybao then
				self.pBtnExTextEmploy:setImg("#v1_img_qianbi.png")
				bEnougth = Player:getPlayerInfo().nMoney >= nCost				
			end
			if bEnougth then
				self.pBtnExTextEmploy:setLabelCnCr(1, formatCountToStr(nCost), getC3B(_cc.yellow))
			else
				self.pBtnExTextEmploy:setLabelCnCr(1, formatCountToStr(nCost), getC3B(_cc.red))
			end
			if self.nEmployType == e_hire_type.smith then
				local bisfree = Player:getEquipData():getIsCanFreeHire(self.pCurData.sTid)				
				if bisfree == true then
					self.pBtnEmploy:updateBtnType(TypeCommonBtn.M_BLUE)
					self.pBtnExTextEmploy:setLabelCnCr(1, getConvertedStr(6, 10319), getC3B(_cc.pwhite))
					self.pBtnExTextEmploy:setImg()

					--新手引导雇用按钮(显示按钮特效)
					--如果当前主线任务id是 20057 或 20072
					local pAgencyTask = Player:getPlayerTaskInfo():getCurAgencyTask()					
					local nCurTaskId = 0
					if pAgencyTask then
						nCurTaskId = pAgencyTask.sTid
					end
					if nCurTaskId == e_special_task_id.hire_smith or nCurTaskId == e_special_task_id.change_smith then
						self.pBtnEmploy:showLingTx()
						Player:getNewGuideMgr():setNewGuideFinger(self.pBtnEmploy, e_guide_finer.hire_smith_btn)
					else
						self.pBtnEmploy:removeLingTx()
					end

					local tStr1 = {
						{color=_cc.blue,text=getConvertedStr(7, 10447)},   --免费铁匠
						{color=_cc.pwhite,text=getConvertedStr(7, 10448)}, --持续时间为
						{color=_cc.blue,text=getTimeFormatCn(self.pCurData.nTime)},		
					}
					self.pLbTime:setString(tStr1)
				else
					--消耗黄金雇佣
					self.pBtnEmploy:updateBtnType(TypeCommonBtn.M_YELLOW)
					local tStr1 = {
						{color=_cc.pwhite,text=getConvertedStr(6, 10539)},
						{color=_cc.blue,text=getTimeFormatCn(self.pCurData.nGoldTime)},		
					}
					self.pLbTime:setString(tStr1)
				end
			end
			self:setLocked(false)
		else
			self.pLyBtnEmploy:setVisible(false)
			self.pBtnExTextEmploy:setVisible(false)
			self.pLbStatus:setVisible(true)
			local sstr = buildName..nopenLv..getConvertedStr(6, 10152)
			self.pLbStatus:setString(sstr)
			--self.pLyLocked:setVisible(true)
			self:setLocked(true)
		end	
	end
end

--析构方法
function ItemEmployCivil:onItemEmployCivilDestroy(  )
	-- body
end

function ItemEmployCivil:setLocked( _blocked )
	-- body
	if _blocked == true then
		self.pLyRoot:setBackgroundImage("#v1_img_black30.png",{scale9 = true,capInsets=cc.rect(10,10, 1, 1)})
	else
		self.pLyRoot:setBackgroundImage("ui/daitu.png")
	end
end

--设置数据 _data 服务端返回数据核实基本数据在这里补全
function ItemEmployCivil:setCurData(_data)
	--根据ID获取文官基础数据
	if _data then
		self.pCurData = _data	
	else
		self.pCurData = nil
	end
	self:updateViews()
end

--获取章节数据
function ItemEmployCivil:getData()
	return self.pCurData
end

--刷新文官信息
function ItemEmployCivil:refreshOfficalInfo( _data )
	-- body
	self.pLyCivil:setVisible(true)
	self.pLyRS:setVisible(false)
	self.pIcon:setNormalState()
	self.pIcon:setCurData(_data)

	setLbTextColorByQuality(self.pLbCivilName, _data.nQuality)	
	self.pLbCivilName:setString(_data.sName)
	--self.pLbCivilLv:setString(getLvString(_data.nLv, false))
	local str = {
		{color=getColorByQuality(_data.nQuality), text=_data.sName.." "},
		-- {color=_cc.blue, text=getLvString(_data.nLv, false)}
	}
	self.pLbCivilName:setString(str, false)
	
	local rate = _data.nRate*100
	self.pLbFunc1Value:setString("+"..tostring(rate)..getConvertedStr(6, 10170))
	if _data.nQuality == 1 then
		self.pLbFunc2Value:setString(getConvertedStr(6, 10149))
	elseif _data.nQuality == 4 then
		self.pLbFunc2Value:setString(getConvertedStr(6, 10150))
	end
end

--刷新为研究院信息
function ItemEmployCivil:refreshResearcherInfo( _data )
	-- body
	-- dump(_data, "refreshResearcherInfo=", 100)
	self.pLyCivil:setVisible(false)
	self.pLyRS:setVisible(true)
	self.pIcon:setNormalState()
	self.pIcon:setCurData(_data)

	self.pLbRsName:setString(_data.sName)
	setLbTextColorByQuality(self.pLbRsName, _data.nQuality)
	
	-- self.pLbRsLv:setString(getLvString(_data.nLv, false))
	self.pLbRsLv:setString("")
	local tStr = ""
	if _data.nQuality > 1 then
		tStr = {
			{color=_cc.pwhite,text=getConvertedStr(6, 10206)},--	10318				
			{color=_cc.blue,text=getTimeFormatCn(_data.nTime)},
			{color=_cc.pwhite,text=getConvertedStr(6, 10674)}
		}
	else
		tStr = {
			{color=_cc.pwhite,text=getConvertedStr(6, 10206)},--	10318				
			{color=_cc.blue,text=getTimeFormatCn(_data.nTime)}
		}		
	end
	self.pLbRsFunc:setString(tStr, false)
end
--刷新雇用铁匠数据、
function ItemEmployCivil:refreshSmithInfo( _data )
	-- body
	self.pLyCivil:setVisible(false)
	self.pLyRS:setVisible(true)
	self.pIcon:setNormalState()
	self.pIcon:setCurData(_data)
	self.pLbRsName:setString(_data.sName)
	setLbTextColorByQuality(self.pLbRsName, _data.nQuality)
		
	-- self.pLbRsLv:setString(getLvString(_data.nLv, false))
	self.pLbRsLv:setString("")
	-- local tStr = {
	-- 	{color=_cc.pwhite,text=getConvertedStr(6, 10318)},--	10318				
	-- 	{color=_cc.blue,text=getTimeFormatCn(_data.nRate)}
	-- }
	local nlimitLv = Player:getBuildData():getBuildById(e_build_ids.palace).nLv
	local nopenLv = self.pCurData.nLimit
	local nWorkTime = _data.nTime
	if nlimitLv < nopenLv then
		nWorkTime = _data.nGoldTime
	end
	local sStr = getTextColorByConfigure(string.format(getTipsByIndex(20104), getTimeFormatCn(_data.nRate)))
	self.pLbRsFunc:setString(sStr, false)
	local tStr1 = {
		{color=_cc.pwhite,text=getConvertedStr(6, 10539)},
		{color=_cc.blue,text=getTimeFormatCn(nWorkTime)},		
	}
	self.pLbTime:setString(tStr1)
end

--雇用按钮
function ItemEmployCivil:onEmployBtnClicked( pView )
	-- body
	local tcost = luaSplit(self.pCurData.sCost, ":")
	local ntype = 0
	self.tResList = nil
	if tonumber(tcost[1]) == e_resdata_ids.ybao then--消耗黄金
		if self.nEmployType == e_hire_type.smith then
			local bisfree = Player:getEquipData():getIsCanFreeHire(self.pCurData.sTid)				
			if bisfree == true then
				self:sendEmployRequest()
				return
			end			
		end		
		showBuyDlg(self:getEmployTip(),tonumber(tcost[2]),handler(self, self.sendEmployRequest))	
	elseif tonumber(tcost[1]) == e_resdata_ids.yb then--消耗银币
		self.tResList = {}
		self.tResList[e_resdata_ids.lc] = 0
		self.tResList[e_resdata_ids.bt] = 0
		self.tResList[e_resdata_ids.mc] = 0
		self.tResList[e_resdata_ids.yb] = tonumber(tcost[2])
		self:sendEmployRequest()
	end

	--新手雇佣按钮已点
	Player:getNewGuideMgr():onClickedNewGuideFinger(self.pBtnEmploy)

end
--获取提示富文本 _ntype 1 替换已经雇用
function ItemEmployCivil:getEmployTip(  )	
	-- body	
	local bisEmpoy = true	
	--判断是否已经雇用文官或者研究员
	local olddata = nil
	if self.nEmployType == e_hire_type.official then
		olddata = Player:getBuildData():getBuildById(e_build_ids.palace):getOfficalBaseData()--已经雇用文官
	elseif self.nEmployType == e_hire_type.researcher then
		olddata = Player:getTnolyData():getResearcherBaseData()--已经雇用研究员
	elseif self.nEmployType == e_hire_type.smith then
		olddata = Player:getEquipData():getSmithConfigData()--已经雇用铁匠
	else
		bisEmpoy = false
	end	
	if not olddata then--未雇用
		bisEmpoy = false
	end

	local strTips1 = nil
	if bisEmpoy == false then
		strTips1 = {
    		{color=_cc.pwhite,text=getConvertedStr(6, 10095)},--替换已雇用/雇用
    		{color=_cc.blue,text=self.pCurData.sName},--文官名字等级
    		{color=_cc.pwhite,text="?"}
    	}
	else
		strTips1 = {
    		{color=_cc.pwhite,text=getConvertedStr(6, 10095)},--替换已雇用/雇用
    		{color=_cc.blue,text=self.pCurData.sName},--文官名字等级    		
    		{color=_cc.pwhite,text=getConvertedStr(6, 10102)},--替换已雇用/雇用
    		{color=_cc.blue,text=olddata.sName},--文官名字等级
    		{color=_cc.pwhite,text="?"}
    	}
	end
    return strTips1  
end
--发送雇用请求
function ItemEmployCivil:sendEmployRequest(  )
	-- body
	local id = self.pCurData.sTid		
	if self.nEmployType == e_hire_type.official then
		SocketManager:sendMsg("employCivil", {id}, handler(self, self.employCivilCallBack))
	elseif self.nEmployType == e_hire_type.researcher then
		SocketManager:sendMsg("employResearcher", {id}, handler(self, self.employRSCallBack))
	elseif self.nEmployType == e_hire_type.smith then
		SocketManager:sendMsg("reqSmithHire", {id}, handler(self, self.employSmithCallBack))
	end
end
--雇用文官回调
function ItemEmployCivil:employCivilCallBack( __msg, __old )
	-- body
	if __msg.head.state == SocketErrorType.success	then				
		--雇用成功界面响应
		--dump(__old, "__old", 100)
		local tdata = getPalaceOfficialByID(__old[1])
		TOAST(tdata.sName..getConvertedStr(6, 10439))
		closeDlgByType(e_dlg_index.civilemploy)
	else		
    	local nResID = nil
		if __msg.head.state == 233 then --银币不足
			nResID = e_resdata_ids.yb
		elseif __msg.head.state == 231 then--木材不足
			nResID = e_resdata_ids.mc
		elseif __msg.head.state == 232 then--粮草不足
			nResID = e_resdata_ids.lc
		elseif __msg.head.state == 230 then--铁矿不足			
			nResID = e_resdata_ids.bt
		else
			TOAST(SocketManager:getErrorStr(__msg.head.state))	
			return	
		end
		if nResID then
			goToBuyRes(nResID,self.tResList)
		end	
	end
end

--雇用研究员回调
function ItemEmployCivil:employRSCallBack( __msg, __old )
	-- body
	if __msg.head.state == SocketErrorType.success	then				
		--雇用成功界面响应	
		--dump(__old, "__old", 100)
		local tdata = getResearcherDataByID(__old[1])
		TOAST(tdata.sName..getConvertedStr(6, 10439))
		closeDlgByType(e_dlg_index.civilemploy)
	else		
    	local nResID = nil
		if __msg.head.state == 233 then --银币不足
			nResID = e_resdata_ids.yb
		elseif __msg.head.state == 231 then--木材不足
			nResID = e_resdata_ids.mc
		elseif __msg.head.state == 232 then--粮草不足
			nResID = e_resdata_ids.lc
		elseif __msg.head.state == 230 then--铁矿不足			
			nResID = e_resdata_ids.bt
		else
			TOAST(SocketManager:getErrorStr(__msg.head.state))	
			return	
		end
		if nResID then
			goToBuyRes(nResID,self.tResList)
		end	
	end
end
--雇用铁匠回调
function ItemEmployCivil:employSmithCallBack(__msg, __old )
		-- body
	if __msg.head.state == SocketErrorType.success	then				
		--雇用成功界面响应		
		--dump(__old, "__old", 100)
		local tdata = getBlackSmithByID(__old[1])
		TOAST(tdata.sName..getConvertedStr(6, 10439))
		closeDlgByType(e_dlg_index.civilemploy)
	else		
    	local nResID = nil
		if __msg.head.state == 233 then --银币不足
			nResID = e_resdata_ids.yb
		elseif __msg.head.state == 231 then--木材不足
			nResID = e_resdata_ids.mc
		elseif __msg.head.state == 232 then--粮草不足
			nResID = e_resdata_ids.lc
		elseif __msg.head.state == 230 then--铁矿不足			
			nResID = e_resdata_ids.bt
		else
			TOAST(SocketManager:getErrorStr(__msg.head.state))	
			return	
		end
		if nResID then
			goToBuyRes(nResID,self.tResList)
		end	
	end
end
return ItemEmployCivil