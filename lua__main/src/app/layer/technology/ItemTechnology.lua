-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-05-09 15:35:18 星期二
-- Description: 可研究的科技item
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local MRichLabel = require("app.common.richview.MRichLabel")

local ItemTechnology = class("ItemTechnology", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--nType：列表
function ItemTechnology:ctor( nType )
	-- body
	self:myInit()
	self.nType = nType or self.nType
	if self.nType == 1 then
		parseView("item_technology", handler(self, self.onParseViewCallback))
	elseif self.nType == 2 then
		parseView("item_technology_tree", handler(self, self.onParseViewCallback))
	elseif self.nType == 3 then
		parseView("item_technology_tree_locked", handler(self, self.onParseViewCallback))
	end
end

--初始化成员变量
function ItemTechnology:myInit(  )
	-- body
	self.tCurData 		= 	 nil 		--当前数据
	self.nType 			= 	 1 			--类型  1：研究列表  2：科技树  3：科技树锁住
end

--解析布局回调事件
function ItemTechnology:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self.pSubView = pView
	self:addView(pView)

	self:setupViews()
	-- self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemTechnology",handler(self, self.onItemTechnologyDestroy))
end

--初始化控件
function ItemTechnology:setupViews( )
	-- body
	--设置可点击，截获事件
	self.pSubView:setViewTouched(true)
	self.pSubView:setIsPressedNeedScale(false)
	self.pSubView:setIsPressedNeedColor(false)

	--item
	if self.nType == 1 then
		self.pLayItem 			= 		self:findViewByName("lay_item")
	else
		self.pLayItem 			= 		self:findViewByName("default")
	end
	
	--icon
	self.pLayIcon 			= 		self:findViewByName("lay_icon")
	--按钮
	self.pLayBtn  	 		= 		self:findViewByName("lay_btn")
	self.pBtnAction = getCommonButtonOfContainer(self.pLayBtn,TypeCommonBtn.M_BLUE,getConvertedStr(1,10174))
	self.pBtnAction:onCommonBtnClicked(handler(self, self.onActionClicked))
	self.pBtnAction:onCommonBtnDisabledClicked(handler(self, self.onActionClicked))

	--描述
	self.pLbDesc 			= 		self:findViewByName("lb_msg")
	-- setTextCCColor(self.pLbDesc,_cc.pwhite)
	
    --状态(科技树才会有)
    -- self.pLbState 			= 		self:findViewByName("lb_state")
    self.pImgState 			= 		self:findViewByName("img_state")

    --类型3才有
    self.pLbLocked 			= 		self:findViewByName("lb_locked")
    --推荐(类型1才有)
    self.pLayTj 			= 		self:findViewByName("img_tuijian")
    -- self.pLbTj 			    = 		self:findViewByName("lb_tj")
    -- if self.pLayTj then
    -- 	setTextCCColor( self.pLbTj,_cc.white)
    -- 	self.pLbTj:setString(getConvertedStr(1, 10193))
    -- end

    self.pSubView:onMViewClicked(function ()
		--如果没有正在研究中的科技且没满级且未锁住则可以点
	    if not self.tUpingTnoly and not self.tCurData:isMaxLv() and not self.tCurData:checkisLocked() then
			self:onActionClicked()
		end
	end)

	self.pLayMsg = self:findViewByName("lay_msg")

	--线
	self.pImgLine = self:findViewByName("line")

end

-- 修改控件内容或者是刷新控件数据
function ItemTechnology:updateViews(  )
	-- body
	self.tUpingTnoly = Player:getTnolyData():getUpingTnoly()
	if self.tCurData then
		--设置icon
		local nScale = nil
		if self.nType == 1 then
			nScale = 0.8
		end
		self.pIcon = getIconGoodsByType(self.pLayIcon,TypeIconGoods.NORMAL,type_icongoods_show.item,self.tCurData, nScale)
		self.pIcon:setIconClickedCallBack(function (  )
			
			if not self.tUpingTnoly and not self.tCurData:isMaxLv() and not self.tCurData:checkisLocked() then
				self:onActionClicked()
			end
		end)
		--名字、等级、参数1和2
		if not self.pLbTnoly then
			self.pLbTnoly = MUI.MLabel.new({text="", size=20})
			self.pLbTnoly:setAnchorPoint(0,0.5)
			local lbName = self:findViewByName("lb_name")
			self.pLbTnoly:setPosition(lbName:getPosition())
			self.pLayMsg:addView(self.pLbTnoly, 10)
		end

		local sParam1, sParam2 = self:getUpValue()
		local tStr
		-- if sParam1 ~= "" and sParam2 ~= "" then
		-- 	tStr = {
		-- 		{text = self.tCurData.sName.." ", color = getC3B(_cc.blue),},
		-- 		{text = getLvString(self.tCurData.nLv,true), color = getC3B(_cc.white)},
		-- 		{text = getSpaceStr(7)..sParam1, color = getC3B(_cc.white)},
		-- 		{text = " - ", color = getC3B(_cc.white)},
		-- 		{text = sParam2, color = getC3B(_cc.green)}
		-- 	}
		-- else
		-- 	tStr = {
		-- 		{text = self.tCurData.sName.." ", color = getC3B(_cc.blue),},
		-- 		{text = getLvString(self.tCurData.nLv,true), color = getC3B(_cc.white)},
		-- 	}
		-- end

		--显示进度
		if not self.pLbProgress then
			self.pLbProgress = MUI.MLabel.new({text="", size=20})
			self.pLbProgress:setAnchorPoint(0.5, 0.5)
			local lbName = self:findViewByName("lb_name")
			self.pLbProgress:setPositionY(90)
			self.pLbProgress:setPositionX(self.pLayBtn:getPositionX() + self.pLayBtn:getWidth() / 2)
			self.pLayItem:addView(self.pLbProgress, 10)
		end
		--获得下一级升级数据
		local tNextLimitData = self.tCurData:getNextLimitData()
		local strProgress = {
	    	{color=_cc.pwhite, text = getConvertedStr(1, 10176)},--进度
	    	{color=_cc.green, text = self.tCurData.nCurIndex},
	    	{color=_cc.pwhite, text = getConvertedStr(6, 10115)},--"/"
	    	{color=_cc.pwhite, text = tNextLimitData.section},
	    }
		self.pLbProgress:setString(strProgress)
		--当前等级和下一等级
		if self.tCurData:isMaxLv() then
			tStr = {
				{text = self.tCurData.sName.." ", color = getC3B(_cc.blue),},
				{text = getLvString(self.tCurData.nLv,true), color = getC3B(_cc.white)},
			}
		else
			tStr = {
				{text = self.tCurData.sName.." ", color = getC3B(_cc.blue),},
				{text = getLvString(self.tCurData.nLv,true), color = getC3B(_cc.white)},
				{text = " →", color = _cc.white},
				{text = getLvString(self.tCurData.nLv + 1,true), color = getC3B(_cc.green)}
			}
		end
		self.pLbTnoly:setString(tStr)

		--操作按钮文字
		if self.tUpingTnoly and self.tCurData.sTid ~= self.tUpingTnoly.sTid then
			self.pBtnAction:updateBtnText(getConvertedStr(1,10234))
		else
			local tNextLimitData = self.tCurData:getNextLimitData()
			if tNextLimitData and tNextLimitData.section > 1 and self.tCurData.nCurIndex > 0 then
			-- if self.tCurData.nLv == 0 then
				self.pBtnAction:updateBtnText(getConvertedStr(1,10175))
			else
				self.pBtnAction:updateBtnText(getConvertedStr(1,10174))
			end
		end

		--设置升级数值变化
		-- self:setUpValue()

		--设置状态
		if self.nType == 2 then --科技树（未锁住）
			if self.pImgState then
				if self.tCurData:isMaxLv() then
					self.pImgState:setVisible(true)
					-- setTextCCColor(self.pLbState,_cc.green)
					-- self.pLbState:setString(getConvertedStr(1, 10187))
					self.pImgState:setCurrentImage("#v2_fonts_dengjiyiman.png")
					self.pBtnAction:setVisible(false)
					self.pLbProgress:setVisible(false)
				else
					if self.tUpingTnoly and self.tCurData.sTid == self.tUpingTnoly.sTid then
						self.pBtnAction:updateBtnText(getConvertedStr(1,10234))
					end
					self.pImgState:setVisible(false)
					self.pBtnAction:setVisible(true)
					self.pLbProgress:setVisible(true)
				end
			end
		elseif self.nType == 3 then --科技树（锁住）
			if self.pImgState then
				local bLocked, sTips = self.tCurData:checkisLocked(true)
				if bLocked then
					self.pImgState:setVisible(true)
					-- setTextCCColor(self.pLbState,_cc.red)
					-- self.pLbState:setString(getConvertedStr(1, 10188))
					self.pBtnAction:setVisible(false)
					self.pLbProgress:setVisible(false)
					setTextCCColor(self.pLbLocked, _cc.red)

					self.pLbLocked:setString(getConvertedStr(1,10189)..sTips)
				else
					self.pImgState:setVisible(false)
					self.pBtnAction:setVisible(true)
					self.pLbProgress:setVisible(true)
				end
			end
		elseif self.nType == 1 then --科技研究（推荐）
			if self.pLayTj then
				if self.tCurData.nOrder <= 10 then
					self.pLayTj:setVisible(true)
					-- self.pLbTj:setVisible(true)
				else
					self.pLayTj:setVisible(false)
					-- self.pLbTj:setVisible(false)
				end			
			end
			if self.pImgState then
				if self.tCurData:isMaxLv() then--满级
					self.pImgState:setVisible(true)
					-- setTextCCColor(self.pLbState,_cc.green)
					-- self.pLbState:setString(getConvertedStr(1, 10187))
					self.pImgState:setCurrentImage("#v2_fonts_dengjiyiman.png")
					self.pBtnAction:setVisible(false)
					self.pLbProgress:setVisible(false)
					self.pLbLocked:setVisible(false)
				else
					local bLocked, sTips = self.tCurData:checkisLocked(true)
					if bLocked then--未解锁
						self.pImgState:setVisible(true)
						self.pImgState:setCurrentImage("#v2_fonts_weijiesuo.png")
						self.pBtnAction:setVisible(false)
						self.pLbProgress:setVisible(false)
						self.pLbLocked:setVisible(true)
						setTextCCColor(self.pLbLocked, _cc.red)

						self.pLbLocked:setString(getConvertedStr(1,10189) .. sTips)						
					else
						if self.tUpingTnoly and self.tCurData.sTid == self.tUpingTnoly.sTid then
							self.pBtnAction:updateBtnText(getConvertedStr(1,10234))
						end
						self.pImgState:setVisible(false)
						self.pBtnAction:setVisible(true)
						self.pLbProgress:setVisible(true)
						self.pLbLocked:setVisible(false)
					end				
				end
			end
		end
		--判断是否满足研究条件，不满足则按钮置灰
		local tNextLimitData = self.tCurData:getNextLimitData()
		if tNextLimitData then
			local nWood = tonumber(tNextLimitData.woodcost)
			local nHasWood = Player:getPlayerInfo().nWood
			local nCoin = tonumber(tNextLimitData.coincost)
			local nHasCoin = Player:getPlayerInfo().nCoin
			--缺少消耗资源
			local bLackRes = nWood > nHasWood or nCoin > nHasCoin
			if bLackRes and self.pBtnAction:getBtnText() ~= getConvertedStr(1,10234) then
				self.pBtnAction:setBtnEnable(false)
			else
				self.pBtnAction:setBtnEnable(true)
			end
			self.bLackRes = bLackRes
		end

	end
end


-- 析构方法
function ItemTechnology:onItemTechnologyDestroy(  )
	-- body
end

--设置当前数据
function ItemTechnology:setCurData( _data, _tarId )
	-- body
	self.tCurData = _data
	self:updateViews()

	self.nTarId = _tarId

	--新手引导特效展示
	if _tarId and _data.sTid == _tarId then
		--长方形特效, 先暂时注释以免以后改回来
		-- if not self.pTx then
		-- 	self.pTx = getRectangleTx()
		-- 	self.pLayItem:addView(self.pTx, 100)
		-- 	centerInView(self.pLayItem, self.pTx)
		-- end

		-- self.pTx:setVisible(true)

		if self.pBtnAction:getBtnText() == getConvertedStr(1,10174) or
			self.pBtnAction:getBtnText() == getConvertedStr(1,10175) or
			self.pBtnAction:getBtnText() == getConvertedStr(1,10234) then
			self.pBtnAction:showLingTx()
		end

		--新手引导
		Player:getNewGuideMgr():setNewGuideFinger(self.pLayItem, e_guide_finer.item_technology)
	else
		-- if self.pTx then
		-- 	self.pTx:setVisible(false)
		-- end
		self.pBtnAction:removeLingTx()
	end
end

--推荐科技设置
function ItemTechnology:setRecommendData()
	self.pImgLine:setVisible(false)
	--隐藏未解锁图片
	self.pImgState:setVisible(false)
	local bLocked, sTips, nLockedType = self.tCurData:checkisLocked(true)
	if nLockedType == 2 then --科技院等级不足
		self.pBtnAction:updateBtnText(getConvertedStr(7, 10362)) --去升级
		self.pBtnAction:updateBtnType(TypeCommonBtn.M_YELLOW)
		self.pBtnAction:setVisible(true)
		self.pBtnAction:setBtnEnable(true)
	end
	if not bLocked then
		local tUpingTnoly = Player:getTnolyData():getUpingTnoly()
		if tUpingTnoly == nil and not self.bLackRes then
			self.pBtnAction:showLingTx()
		else
			self.pBtnAction:removeLingTx()
		end
	end
end

--操作按钮点击事件
function ItemTechnology:onActionClicked( pView )
	-- body
	if self.pBtnAction:getBtnText() == getConvertedStr(7, 10362) then --去升级
		closeDlgByType(e_dlg_index.technology, false)
		--跳到科技院升级界面
		local tObject = {}
		tObject.nType = e_dlg_index.buildlvup --dlg类型
		tObject.nFromWhat = 0 --1,2表示从左对联进来的
		tObject.nCell = e_build_cell.tnoly
		sendMsg(ghd_show_dlg_by_type,tObject)
		--发送消息放大基地
		local tOb = {}
		tOb.nType = 1
		tOb.nCell = e_build_cell.tnoly
		sendMsg(ghd_scale_for_buildup_dlg_msg,tOb)
		--发送hometop界面调整消息
		local tmsgObj = {}
		tmsgObj.nType = 1
		sendMsg(ghd_home_change_for_buildup_msg, tmsgObj)
	else
		--研究科技详情对话框
		local tObject = {}
		tObject.data = self.tCurData
		tObject.nType = e_dlg_index.uptnolycost --dlg类型
		sendMsg(ghd_show_dlg_by_type,tObject)

		if self.nTarId and self.nTarId == self.tCurData.sTid then
			--新手引导已点
			Player:getNewGuideMgr():onClickedNewGuideFinger(self.pLayItem)
		end
	end
end

--获取升级数值变化
function ItemTechnology:getUpValue()
	-- body
	local sParam1 = ""
	local sParam2 = ""
	local tCurLimitData = self.tCurData:getCurLimitData()
	
	--获得下一级升级数据
	local tNextLimitData = self.tCurData:getNextLimitData()
	--神兵暴击
	if self.tCurData.sTid == 3014 then
		-- if tNextLimitData then
		-- 	self.pLbDesc:setString(tNextLimitData.desc)
		-- else
		-- 	self.pLbDesc:setString(tCurLimitData.desc)
		-- end
		local tCritsData = getTnolyInintDataFromDB("artifactCrits")
		if not tCritsData then
			sParam1 = "0"
			sParam2 = "0"
		else
			if tCritsData[self.tCurData.nLv] then  --当前等级
				sParam1 = tCritsData[self.tCurData.nLv]
			else
				sParam1 = "0"
			end
			if tCritsData[self.tCurData.nLv+1] then  --下一等级
				sParam2 = tCritsData[self.tCurData.nLv+1]
			else
				sParam2 = ""
			end
		end
	--其他科技
	else
		--获得当前已经升级的数据
		-- if tCurLimitData then
		-- 	local tBuffData = getBuffDataByIdFromDB(tCurLimitData.buffid)
		-- 	local sValue, nType = Player:getTnolyData():getEffectsValue(tBuffData)
		-- 	sParam1 = sValue
		-- end
		if tNextLimitData then

			-- self.pLbDesc:setString(tNextLimitData.desc)
			--获得buff
			local tNextBuffData = getBuffDataByIdFromDB(tNextLimitData.buffid)
			-- dump(tNextBuffData, "tNextBuffData")
			local sValue, nType = Player:getTnolyData():getEffectsValue(tNextBuffData)
			sParam2 = sValue

			-- if nType == 0 then
			-- 	print(tNextLimitData.desc)
			-- 	sParam1 = ""
			-- else
			-- 	if tCurLimitData == nil then
			-- 		if nType == 1 then
			-- 			sParam1 = "0%"
			-- 		elseif nType == 2 then
			-- 			sParam1 = "0"
			-- 		end
			-- 	end
			-- end
		else
			--没有下一等级，那么就显示 当前等级(理论上这个在科技树才会用到)
			-- self.pLbDesc:setString(tCurLimitData.desc)
			if tCurLimitData then
				sParam2 = ""
				local tBuffData = getBuffDataByIdFromDB(tCurLimitData.buffid)
				local sValue, nType = Player:getTnolyData():getEffectsValue(tBuffData)
				sParam1 = sValue
			end
		end
	end

	if tCurLimitData then
		if sParam2 ~= "" then
			local tStr = {
				{text = tCurLimitData.desc, color = _cc.pwhite},
				{text = " → ", color = _cc.pwhite},
				{text = sParam2, color = _cc.green}
			}
			self.pLbDesc:setString(tStr)
		else
			self.pLbDesc:setString(tCurLimitData.desc)
		end
	end

	return sParam1, sParam2
	
end

return ItemTechnology