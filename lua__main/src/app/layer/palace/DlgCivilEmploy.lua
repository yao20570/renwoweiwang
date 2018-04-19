-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-04-19 14:07:23 星期三
-- Description: 雇用文官界面
-----------------------------------------------------

local DlgCommon = require("app.common.dialog.DlgCommon")
local ItemPalaceCivil = require("app.layer.palace.ItemPalaceCivil")
local ItemEmployCivil = require("app.layer.palace.ItemEmployCivil")

local DlgCivilEmploy = class("DlgCivilEmploy", function()
	-- body
	return DlgCommon.new(e_dlg_index.civilemploy)
end)

function DlgCivilEmploy:ctor(_nemployType)
	-- body
	self:myInit(_nemployType)
	parseView("dlg_civil", handler(self, self.onParseViewCallback))
end

function DlgCivilEmploy:myInit( _nemployType )
	-- body
	self.pData 		= {}	--当前文官数据
	self.pDataList 	= {} 	--文官列表数据
	self.nEmployType = _nemployType or e_hire_type.official
	--self:setDlgSecondType(_nemployType)
end

--解析布局回调事件
function DlgCivilEmploy:onParseViewCallback( pView )
	-- body
	self:addContentView(pView) --加入内容层
	--self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgCivilEmploy",handler(self, self.onDlgCivilEmployDestroy))
end


--计算雇佣时间
function DlgCivilEmploy:getTimeStr( _fTime )
	-- body
	local str = _fTime..getConvertedStr(7, 10073)
	if _fTime > 86400 then
		str = (_fTime/86400)..getConvertedStr(7, 10077)
	elseif _fTime > 3600 then
		str = (_fTime/3600)..getConvertedStr(7, 10076)
	elseif _fTime > 60 then
		str = (_fTime/60)..getConvertedStr(7, 10075)
	end
	return str
end

--控件刷新
function DlgCivilEmploy:updateViews(  )
	-- body	
	local bisHaveCivil = false
	gRefreshViewsAsync(self, 3, function ( _bEnd, _index )
		if(_index == 1) then
			--设置标题
			if self.nEmployType == e_hire_type.official then--雇用文官
				self:setTitle(getConvertedStr(6,10093))
			elseif self.nEmployType == e_hire_type.researcher then
				self:setTitle(getConvertedStr(6, 10185))
			elseif self.nEmployType == e_hire_type.smith then
				self:setTitle(getConvertedStr(6, 10317))
			end
			--系统标题层
			if not self.pLbSysTip then
				self.pLbSysTip				=			self:findViewByName("lb_sysTip")--系统提示
				setTextCCColor(self.pLbSysTip, _cc.white)				
			end
			if self.nEmployType == e_hire_type.official then
				local tData = getPalaceOfficialByID(1)				
				self.pLbSysTip:setString(string.format(getTipsByIndex(10023), self:getTimeStr(tData.nTime)))		
			elseif self.nEmployType == e_hire_type.researcher then--研究员
				local tData = getResearcherDataByID(1)				
				self.pLbSysTip:setString(string.format(getTipsByIndex(10021), self:getTimeStr(tData.nDuration)))		
			elseif self.nEmployType == e_hire_type.smith then--铁匠
				-- local tData = getBlackSmithByID(1)				
				-- self.pLbSysTip:setString(string.format(getTipsByIndex(10022), self:getTimeStr(tData.nTime)))		
				self.pLbSysTip:setString(getTipsByIndex(10022))		
			end

			--文官列表标题层
			if not self.pLyCivilListTitle then
				self.pLyCivilListTitle		=			self:findViewByName("lay_civillist_title")
				self.pLbCivilTitle 			= 			self:findViewByName("lb_civil_title")--文官列表标题
				self.pLbCivilTitle:setString(getConvertedStr(6, 10094))
			end
		elseif (_index == 2) then
			if not self.pLyCurCivil then
				self.pLyCurCivil 			=			self:findViewByName("lay_cur_civil")
			end
			if not self.pCurCivilItem then
				self.pCurCivilItem			=			ItemPalaceCivil.new(self.nEmployType, false)--显示当前文官显示
				self.pLyCurCivil:addView(self.pCurCivilItem, 10)				
			else
				self.pCurCivilItem:setEmployType(self.nEmployType)
				self.pCurCivilItem:updateViews()
			end			
			if self.pCurCivilItem then
				bisHaveCivil = self.pCurCivilItem.bisHaveCivil
				self.pCurCivilItem:setVisible(bisHaveCivil)
			end					
			if bisHaveCivil then
				self.pLyCivilListTitle:setPositionY(455)
			else
				self.pLyCivilListTitle:setPositionY(590)
			end
			if not self.pLyCivilList then
				self.pLyCivilList 			= 			self:findViewByName("lay_civil_list")
			end			
			if bisHaveCivil then				
				self.pLyCivilList:setContentSize(cc.size(526 , 440))	
			else				
				self.pLyCivilList:setContentSize(cc.size(526 , 570))	
			end			
		elseif (_index == 3) then
			--文官列表层
			--刷新列表数据			
		    self:updateCivilListData()

			if not self.pCivilListView then
				self.pCivilListView = MUI.MListView.new {
			        bgColor = cc.c4b(255, 255, 255, 250),
			        viewRect = cc.rect(0, 0, self.pLyCivilList:getWidth(), self.pLyCivilList:getHeight()),	      
			  		direction = MUI.MScrollView.DIRECTION_VERTICAL,
			        itemMargin = {left =  0,
			         right =  0,
			         top =  0,
			         bottom =  0}}
			    self.pLyCivilList:addView(self.pCivilListView)
			    self.pCivilListView:setName("civillistview")
			    self.pCivilListView:setBounceable(true)
			    self.pCivilListView:setItemCallback(handler(self, self.onCivilItemCallBack))
			    self.pCivilListView:setItemCount(#self.pDataList)
			    self.pCivilListView:reload(true)
			else
				self.pCivilListView:setViewRect(cc.rect(0, 0, self.pLyCivilList:getWidth(), self.pLyCivilList:getHeight()))							    
				self.pCivilListView:notifyDataSetChange(true, #self.pDataList)											
			end			
		end
	end)
end

--析构方法
function DlgCivilEmploy:onDlgCivilEmployDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgCivilEmploy:regMsgs(  )
	-- body
	--注册成功雇用文官事件
	regMsg(self, ghd_refresh_palacecivil, handler(self, self.updateViews))	
	--注册雇用研究员信息刷新
	regMsg(self, ghd_refresh_researcher_msg, handler(self, self.updateViews))
	--注册雇用铁匠信息刷新
	regMsg(self, gud_equip_smith_hire_msg, handler(self, self.updateViews))
	-- 注册玩家基础信息刷新消息
	regMsg(self, gud_refresh_playerinfo, handler(self, self.updateViews))
end
--注销消息
function DlgCivilEmploy:unregMsgs(  )
	-- body
	-- 销毁玩家基础信息刷新消息
	unregMsg(self, gud_refresh_playerinfo)	
	--注销雇用文官事件
	unregMsg(self, ghd_refresh_palacecivil)
	unregMsg(self, ghd_refresh_researcher_msg)
	unregMsg(self, gud_equip_smith_hire_msg)
end

--暂停方法
function DlgCivilEmploy:onPause( )
	-- body		
	self:unregMsgs()
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgCivilEmploy:onResume( _bReshow )
	-- body	
	if _bReshow and self.pCivilListView then
		-- 如果是重新显示，定位到顶部
		self.pCivilListView:scrollToBegin()	
	end
	self:updateViews()
	self:regMsgs()
end

--列表单元刷新方法
function DlgCivilEmploy:onCivilItemCallBack( _index, _pView  )
	-- body
    local pTempView = _pView
    if pTempView == nil then
        pTempView = ItemEmployCivil.new(self.nEmployType)
        pTempView:setViewTouched(false)
    else            
    	pTempView:setEmployType(self.nEmployType)
    end
    pTempView:setCurData(self.pDataList[_index])
    return pTempView    
end
--刷新文官列表
function DlgCivilEmploy:updateCivilListData( )	
	-- body
	--根据当前雇用文官的情况刷新雇用列表数据
	-- local buildLv = 1	
	-- local employData = nil
	-- if self.nEmployType == e_hire_type.official then --雇用文官、
	-- 	buildLv = Player:getBuildData():getBuildById(e_build_ids.palace).nLv
	-- 	employData = Player:getBuildData():getBuildById(e_build_ids.palace):getOfficalBaseData()
	-- elseif self.nEmployType == e_hire_type.researcher then --雇用研究员
	-- 	buildLv = Player:getBuildData():getBuildById(e_build_ids.tnoly).nLv
	-- 	employData = Player:getTnolyData():getResearcherBaseData()
	-- elseif self.nEmployType == e_hire_type.smith then
	-- 	buildLv = Player:getBuildData():getBuildById(e_build_ids.palace).nLv
	-- 	employData = Player:getEquipData():getSmithConfigData()
	-- else
	-- 	print("异常的雇用类型")
	-- end
	
	-- local tmplist = getEmployList(buildLv, self.nEmployType)
	-- --dump(tmplist, "tmplist", 100)
	-- self.pDataList = {}
	-- for i, employer in pairs(tmplist) do				
	-- 	local isadd = false
	-- 	if not employData then--未雇用文官
	-- 		--print("当前未雇用")
	-- 		isadd = true	
	-- 	else
	-- 		if self.nEmployType == e_hire_type.official or self.nEmployType == e_hire_type.researcher then
	-- 			if employer.nLv > employData.nLv then--
	-- 				isadd = true
	-- 			elseif (employer.nLv == employData.nLv) and (employer.nCanChange > employData.nCanChange) then
	-- 				isadd = true
	-- 			end
	-- 		elseif self.nEmployType == e_hire_type.smith then
	-- 			--edit by shulan, 现在是等级高的才能替换当前正在雇佣的
	-- 			if employer.nLv > employData.nLv then
	-- 				isadd = true
	-- 			end
	-- 		end
	-- 	end
	-- 	if isadd then
	-- 		table.insert(self.pDataList, employer)
	-- 	end
	-- end	

	self.pDataList=getShowCivilListData(self.nEmployType)
end

--雇用类型
function DlgCivilEmploy:setEmployType( nType )
	-- body
	self.nEmployType = nType or self.nEmployType
	--self:setDlgSecondType(self.nEmployType)
end
return DlgCivilEmploy