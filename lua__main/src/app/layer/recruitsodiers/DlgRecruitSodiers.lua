-----------------------------------------------------
-- author: dshulan
-- updatetime:  2018-04-02 20:44:58 星期一
-- Description: 募兵府界面
-----------------------------------------------------
local ItemRecruit = require("app.layer.recruitsodiers.ItemRecruit")
local DlgBase = require("app.common.dialog.DlgBase")
local DlgAlert = require("app.common.dialog.DlgAlert")
local DlgBuyRecruit = require("app.layer.camp.DlgBuyRecruit")
local DlgBuyRecTime = require("app.layer.camp.DlgBuyRecTime")

local DlgRecruitSodiers = class("DlgRecruitSodiers", function()
	-- body
	return DlgBase.new(e_dlg_index.dlgrecruitsodiers)
end)

--_nBuildType: 募兵类型(1步,2骑,3弓)
function DlgRecruitSodiers:ctor()
	-- body
	self:myInit()
	self.tBuildInfo = Player:getBuildData():getBuildById(e_build_ids.mbf)
	self.nBuildType = self.tBuildInfo.nRecruitTp 	--募兵类型(1步,2骑,3弓)
	-- dump(self.tBuildInfo, "募兵府 ==")
	if not self.tBuildInfo then
		print("募兵府数据为 nil")
		return
	end
	if self.nBuildType == 1 then
		self.nBuildTypeId = e_build_ids.infantry
	elseif self.nBuildType == 2 then
		self.nBuildTypeId = e_build_ids.sowar
	elseif self.nBuildType == 3 then
		self.nBuildTypeId = e_build_ids.archer
	end
	self.nBuildTypeData = Player:getBuildData():getBuildById(self.nBuildTypeId, true)
	parseView("dlg_camp", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgRecruitSodiers:myInit(  )
	-- body
	self.nBuildTypeId 		= 		nil 			   		--兵营id
	self.nBuildTypeData 	= 		nil 			   		--兵营数据
	self.tBuildInfo 		= 		nil 					--募兵府数据
	self.tMadingLists 		= 		nil 					--募兵队列
	self.nOpenCampIdx 		= 		0
	self.nEndFreeTeamIdx 	= 		0
	self.nFoodCost          =       nil                       --粮草消耗量
end

--解析布局回调事件
function DlgRecruitSodiers:onParseViewCallback( pView )
	-- body
	self:addContentView(pView) --加入内容层
	self:addContentTopSpace()
	self:setupViews()
	self:initDatas()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgRecruitSodiers",handler(self, self.onDlgRecruitSodiersDestroy))
end

--初始化控件
function DlgRecruitSodiers:setupViews( )
	-- body
	--设置标题
	self:setNameAndLv()
	--头顶横条(banner)
	local pBannerImage 		= 		self:findViewByName("lay_banner_bg")
	setMBannerImage(pBannerImage,TypeBannerUsed.by)
	--设置标志
	self.pImgType 			= 		self:findViewByName("img_typs")
	self.pImgArm 			= 		self:findViewByName("img_arm")

	--增益
	self.pLayZy 			= 		self:findViewByName("lay_zy")
	self.pLayZy:setViewTouched(true)
	self.pLayZy:setIsPressedNeedScale(false)
	self.pLayZy:onMViewClicked(handler(self, self.onZyClicked))
	--募兵令
	self.pLayZyIcon  		= 		self:findViewByName("lay_icon_1")	
	self.pLbFP 				= 		self:findViewByName("lb_f_param")
	setTextCCColor(self.pLbFP, _cc.red)
	--季节
	self.pLayJj 			= 		self:findViewByName("lay_jj")
	self.pLayJj:setViewTouched(true)
	self.pLayJj:setIsPressedNeedScale(false)
	self.pLayJj:onMViewClicked(handler(self, self.onJjClicked))
	--显示季节图标	
	self.pLayJjIcon 		= 		self:findViewByName("lay_icon_2")
	self.pLbSP 				= 		self:findViewByName("lb_s_param")
	setTextCCColor(self.pLbSP, _cc.red)
	--克制
	self.pLbKzTips 			= 		self:findViewByName("lb_pa_tips1")	
	setTextCCColor(self.pLbKzTips,_cc.white)
	self.pLbKzTips:setString(getConvertedStr(1, 10126),false)
	self.pLbKz 				= 		self:findViewByName("lb_param1")
	setTextCCColor(self.pLbKz,_cc.blue)
	--容量
	self.pLbRlTips 			= 		self:findViewByName("lb_pa_tips2")	
	setTextCCColor(self.pLbRlTips,_cc.white)
	self.pLbRlTips:setString(getConvertedStr(1, 10127),false)
	self.pLbRl 				= 		self:findViewByName("lb_param2")
	setTextCCColor(self.pLbRl,_cc.blue)
	--兵力
	self.pLbBlTips 			= 		self:findViewByName("lb_pa_tips3")	
	setTextCCColor(self.pLbBlTips,_cc.white)
	self.pLbBlTips:setString(getConvertedStr(1, 10128),false)
	self.pLbBl 				= 		self:findViewByName("lb_param3")
	setTextCCColor(self.pLbBl,_cc.blue)
	--加成
	self.pLbJcTips 			= 		self:findViewByName("lb_pa_tips4")	
	setTextCCColor(self.pLbJcTips,_cc.white)
	self.pLbJcTips:setString(getConvertedStr(1, 10129),false)
	self.pLbJc 				= 		self:findViewByName("lb_param4")
	setTextCCColor(self.pLbJc,_cc.blue)

	--设置标志
	local sBuyTips = getConvertedStr(1, 10117) .. getConvertedStr(1, 10081)
	if self.nBuildTypeId == e_build_ids.infantry then   --步兵
		self.pImgType:setCurrentImage("#v1_img_bubing.png")
		self.pImgArm:setCurrentImage("#v1_img_bubingqs.png")
		sBuyTips = getConvertedStr(1, 10117) .. getConvertedStr(1, 10081)
	elseif self.nBuildTypeId == e_build_ids.sowar then  --骑兵
		self.pImgType:setCurrentImage("#v1_img_qibing.png")
		self.pImgArm:setCurrentImage("#v1_img_qibingqs.png")
		sBuyTips = getConvertedStr(1, 10117) .. getConvertedStr(1, 10082)
	elseif self.nBuildTypeId == e_build_ids.archer then --弓兵
		self.pImgType:setCurrentImage("#v1_img_gongbing.png")
		self.pImgArm:setCurrentImage("#v1_img_gongbingqs.png")
		sBuyTips = getConvertedStr(1, 10117) .. getConvertedStr(1, 10083)
	end

	--底部按钮
	self.pLayLeft 			= 		self:findViewByName("lay_btn_left")
	self.pLayRight 			= 		self:findViewByName("lay_btn_right") 

	self.pBtnLeft = getCommonButtonOfContainer(self.pLayLeft,TypeCommonBtn.L_YELLOW,sBuyTips)
	self.pBtnRight = getCommonButtonOfContainer(self.pLayRight,TypeCommonBtn.L_BLUE,getConvertedStr(1,10132))
	--左边按钮点击事件
	self.pBtnLeft:onCommonBtnClicked(handler(self, self.onLeftClicked))
    self.pBtnLeft:onCommonBtnDisabledClicked(handler(self, self.onLeftDisabledClicked))
    --右边按钮点击事件
	self.pBtnRight:onCommonBtnClicked(handler(self, self.onRightClicked))
    self.pBtnRight:onCommonBtnDisabledClicked(handler(self, self.onRightDisabledClicked))

	local pLayRed = MUI.MLayer.new()
	pLayRed:setLayoutSize(20, 20)
	local x = self.pLayRight:getPositionX() + 155
	local y = self.pLayRight:getPositionY() + 62
	pLayRed:setPosition(x, y)
	pLayRed:setVisible(false)
	self.pLayBottom 		= 		self:findViewByName("lay_camp_bottom")
	self.pLayBottom:addView(pLayRed, 10)
	self.pLayRed = pLayRed


	--国家化文字
	local pLbText 			= 		self:findViewByName("lb_f_name")	
	setTextCCColor(pLbText,_cc.blue)
	pLbText:setString(getConvertedStr(1, 10130))

	local pLbSText 				= 		self:findViewByName("lb_s_name")	
	setTextCCColor(pLbSText,_cc.blue)
	self.pLbSText = pLbSText
end

-- 修改控件内容或者是刷新控件数据
function DlgRecruitSodiers:updateViews(  )
	-- body
	--容量
	self.pLbRl:setString(self.tBuildInfo:getTotalCpy())
	--动态设置位置
	self.pLbRl:setPositionX(self.pLbRlTips:getPositionX() + self.pLbRlTips:getWidth() + 5)

	--兵力  克制
	if self.nBuildTypeId == e_build_ids.infantry then   --步兵
		self.pLbBl:setString(Player:getPlayerInfo().nInfantry)
		self.pLbKz:setString(getConvertedStr(1, 10083))
	elseif self.nBuildTypeId == e_build_ids.sowar then  --骑兵
		self.pLbBl:setString(Player:getPlayerInfo().nSowar)
		self.pLbKz:setString(getConvertedStr(1, 10081))
	elseif self.nBuildTypeId == e_build_ids.archer then --弓兵
		self.pLbBl:setString(Player:getPlayerInfo().nArcher)
		self.pLbKz:setString(getConvertedStr(1, 10082))
	end
	--动态设置位置
	self.pLbBl:setPositionX(self.pLbBlTips:getPositionX() + self.pLbBlTips:getWidth() + 5)
	self.pLbKz:setPositionX(self.pLbKzTips:getPositionX() + self.pLbKzTips:getWidth() + 5)

	--加成
	self.pLbJc:setString("+" .. self.tBuildInfo.nMoreQue)
	--动态设置位置
	self.pLbJc:setPositionX(self.pLbJcTips:getPositionX() + self.pLbJcTips:getWidth() + 5)

	--刷新募兵队列数据
	self:refreshLvItem()

	--募兵上限
	if self.tBuildInfo.nRecruitMore >= getMaxCountRecruit() then
		self.pBtnRight:setBtnEnable(false)
	else
		self.pBtnRight:setBtnEnable(true)
	end	
	local nRedNum = self:getRecuitRedNum()
	self.pLayRed:setVisible(nRedNum > 0)	
	showRedTips(self.pLayRed,0,nRedNum)	

	--刷新募兵令Buff状态
	self:updateFPShow()
	--刷新季节显示
	self:updateSPShow()
end

--刷新募兵令Buff状态
function DlgRecruitSodiers:updateFPShow()
	-- body
	self.nFBuffID = nil
	if not self.pZyIcon then
		self.pZyIcon 			= 		getIconGoodsByType(self.pLayZyIcon, TypeIconGoods.NORMAL, type_icongoods_show.item, nil, 0.7)		
		self.pZyIcon:setIconIsCanTouched(false)
	end
	local ItemData 			= 		getGoodsByTidFromDB(e_id_item.recruitment)
	self.pZyIcon:setCurData(ItemData)
	local sBuffId = ItemData:getVipBuffId(Player:getPlayerInfo().nVip)
	local buffData = Player:getBuffData():getRecruitmentBuff()
	if buffData and buffData:getRemainCd() > 0 then
		self.nFBuffID = sBuffId
		self.pLbFP:setString(formatTimeToHms(buffData:getRemainCd()))
		showRedTips(self.pZyIcon,0,0,3)		
	else
		self.pLbFP:setString(getConvertedStr(6, 10501))
		showRedTips(self.pZyIcon,0,1,3)		
	end
	--
end	

--刷新季节显示
function DlgRecruitSodiers:updateSPShow(  )
	-- body
	local nSeasonDay = Player:getWorldData().nSeasonDay
	local bIsNoOpen = false --未开启
	if nSeasonDay == nil or nSeasonDay == 0 then
		nSeasonDay = 2 --默认是春季，改表的话，这里要改
		bIsNoOpen = true
	end
	local tData = getWorldSeasonData(nSeasonDay)
	if tData then		
		local sImgPath = tData.sIcon
		if not self.pImgSeason then
			self.pImgSeason = MUI.MImage.new(sImgPath)
			self.pImgSeason:setScale(0.7)
			-- centerInView(self.pLayIcon, self.pImgSeason)
			-- WorldFunc.fixScaleToContent(self.pLayJjIcon, self.pImgSeason)
			self.pImgSeason:setAnchorPoint(0,0)
			self.pLayJjIcon:addView(self.pImgSeason)
			centerInView(self.pLayJjIcon, self.pImgSeason)
			self.pImgSeason:setPosition(self.pImgSeason:getPositionX()+8,self.pImgSeason:getPositionY()+8)
		else
			self.pImgSeason:setCurrentImage(sImgPath)
		end
		

		--未激活
		if bIsNoOpen then
			self.pImgSeason:setToGray(true)

			self.pLbSP:setString(getConvertedStr(6, 10501), false)		
			setTextCCColor(self.pLbSP, _cc.red)	
			self.pLayJjIcon:setViewEnabled(false)


			self.pLbSText:setString(getConvertedStr(1, 10131))
		else
			self.pImgSeason:setToGray(false)

			local BuffVo = getBuffDataByIdFromDB(tData.buffid)		
			if BuffVo then
				self.pLbSP:setString(BuffVo.sDesc, false)	
				setTextCCColor(self.pLbSP, _cc.yellow)
				self.pLayJjIcon:setViewEnabled(true)		
			end	

			self.pLbSText:setString(tData.name)
		end
	end		
end
	
--计时刷新
function DlgRecruitSodiers:onUpdateTime(  )
	-- body
	--获取募兵令Buff
	-- local fBuffData = Player:getBuffData():getBuffVo(self.nFBuffID)
	local fBuffData = Player:getBuffData():getRecruitmentBuff()
	if fBuffData and fBuffData:getRemainCd() > 0 then
		self.pLbFP:setString(formatTimeToHms(fBuffData:getRemainCd()))			
	else
		self.pLbFP:setString(getConvertedStr(6, 10501))
	end		
end

--粮草消耗刷新
function DlgRecruitSodiers:updateFoodCost(sMsgName, pMsgObj)
	-- body
	if pMsgObj and pMsgObj.nFoodCost then
		self.nFoodCost = pMsgObj.nFoodCost
		self.nCoinCost = pMsgObj.nCoinCost
	end
end

-- 析构方法
function DlgRecruitSodiers:onDlgRecruitSodiersDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgRecruitSodiers:regMsgs( )
	-- body
	-- 注册兵营士兵招募队列刷新消息
	regMsg(self, ghd_refresh_camp_recruit_msg, handler(self, self.onRefreshDatas))
	-- 注册Buff数据更新消息
	regMsg(self, gud_buff_update_msg, handler(self, self.onRefreshBuff))
	-- 注册玩家数据刷新消息
	regMsg(self, gud_refresh_playerinfo, handler(self, self.updateViews)) 
	-- 注册季节消息
	regMsg(self, gud_world_season_day_change, handler(self, self.updateSPShow))
	-- 注册募兵消耗粮草消息
	regMsg(self, ghd_refresh_house_recruit, handler(self, self.updateFoodCost))
	--物品变化刷新
	regMsg(self, gud_refresh_baginfo, handler(self, self.updateViews))
end

-- 注销消息
function DlgRecruitSodiers:unregMsgs(  )
	-- body
	-- 销毁兵营士兵招募队列刷新消息
	unregMsg(self, ghd_refresh_camp_recruit_msg)
	--注销buff数据刷新
	unregMsg(self, gud_buff_update_msg)
	-- 注销玩家数据刷新消息
	unregMsg(self, gud_refresh_playerinfo)
	-- 注销季节消息
	unregMsg(self, gud_world_season_day_change)
	-- 注销募兵消耗粮草消息
	unregMsg(self, ghd_refresh_house_recruit)
	unregMsg(self, gud_refresh_baginfo)
end


--暂停方法
function DlgRecruitSodiers:onPause( )
	-- body
	self:unregMsgs()
	unregUpdateControl(self)
end

--继续方法
function DlgRecruitSodiers:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	regUpdateControl(self, handler(self, self.onUpdateTime))
end

--设置名字和等级
function DlgRecruitSodiers:setNameAndLv(  )
	-- body
	self:setTitle(self.tBuildInfo.sName .. getLvString(self.tBuildInfo.nLv,true))
end

--初始化队列数据
function DlgRecruitSodiers:initDatas(  )
	-- body
	if self.tMadingLists and table.nums(self.tMadingLists) > 0 then
		self.tMadingLists = nil
	end
	self.tMadingLists = {}

	--是否正在招募
	self.bIsRecuiting = false
	--正在招募的队列数据
	self.tRecuitingData = nil
	--是否有可领取队列
	self.bCanGetRecruit = false

	--获得从后端发送过来的招募队列(已经使用的队列)
	local tDatasUse = self.tBuildInfo:getRecruitTeams()
	if tDatasUse and table.nums(tDatasUse) > 0 then
		for k, v in pairs(tDatasUse) do
			if v.nType == e_camp_item.ing then
				self.bIsRecuiting = true
				self.tRecuitingData = v
			else
				table.insert(self.tMadingLists, v)
				if v.nType == e_camp_item.finish then
					self.bCanGetRecruit = true
				end
			end
		end

		local nUseNum = table.nums(tDatasUse)
		if self.bIsRecuiting then
			self.nOpenCampIdx = nUseNum - 1
		else
			self.nOpenCampIdx = nUseNum
		end
		

	else
		--未使用队列的位置
		self.nOpenCampIdx = 0
	end

	--获得未使用的队列
	local tDatasFree = self.tBuildInfo:getFreeTeams()
	if tDatasFree and table.nums(tDatasFree) > 0 then
		for k, v in pairs (tDatasFree) do
			table.insert(self.tMadingLists, v)
		end
	end
	self.nEndFreeTeamIdx = (table.nums(self.tMadingLists) or 0)--空闲队列结束序列
	--获得可扩充队列
	local tDatasMore = self.tBuildInfo:getMoreTeam()
	if tDatasMore and table.nums(tDatasMore) > 0 then
		for k, v in pairs (tDatasMore) do
			table.insert(self.tMadingLists, v)
		end
	end

	--优先级排序
	-- table.sort(self.tMadingLists, function ( a, b )
	-- 	if a.nType == b.nType then
	-- 		return a.nId < b.nId
	-- 	else
	-- 		return a.nType < b.nType
	-- 	end		
	-- end)
end

--刷新队列数据
function DlgRecruitSodiers:refreshLvItem(  )
	-- body
	--listview
	if not self.pLayListView then
		self.pLayListView   	= 		self:findViewByName("lay_camp_center")
	end
	--招募中队列
	if not self.pLayRecruiting then
		self.pLayRecruiting   	= 		self:findViewByName("lay_recruiting")
	end

	--如果有正在招募的队列
	if self.bIsRecuiting then
		-- self.nOpenCampIdx = self.nOpenCampIdx -1
		if self.pRecruitingItem == nil then
			self.pRecruitingItem = ItemRecruit.new()
			self.pRecruitingItem:resetRecuitingBg()
			-- self.pRecruitingItem.pBg:removeBackground()
			-- self.pRecruitingItem.pBg:setBackgroundImage("#v2_img_jinduyanjiudi.png",{scale9 = true,capInsets=cc.rect(2,22, 1, 1)})
			-- self.pRecruitingItem.pBg:setPositionX(self.pRecruitingItem:getPositionX()+20)
			self.pLayRecruiting:addView(self.pRecruitingItem)
		end
		self.pRecruitingItem:setClickCallBack(handler(self, self.onActionClicked))
		self.pRecruitingItem:setCurData(self.tRecuitingData, self.tBuildInfo)
		self.pLayRecruiting:setVisible(true)
		self:requestLayout()
	else
		self.pLayRecruiting:setVisible(false)
		self:requestLayout()
	end

	-- if self.nOpenCampIdx >= 4 and self.nOpenCampIdx <= self.nEndFreeTeamIdx  then
	-- 	nPos = self.nOpenCampIdx - 2
	-- -- elseif self.nOpenCampIdx < 4 then
	-- -- 	nPos = self.nOpenCampIdx
	-- end		
	local nItemCnt = #self.tMadingLists
	if not self.pListView then 
		self.pListView = MUI.MListView.new {
		    viewRect = cc.rect(0, 0, self.pLayListView:getWidth(), self.pLayListView:getHeight()),
		    itemMargin = {
		    	left =  20,
			    right = 0,
			    top = 0,
			    bottom = 0},
		    direction = MUI.MScrollView.DIRECTION_VERTICAL}
		self.pLayListView:addView(self.pListView)

		--上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)	
				
		self.pListView:setBounceable(true)
		self.pListView:setItemCallback(handler(self, self.onListViewItemCallBack))
		self.pListView:setItemCount(nItemCnt) 
		self:refreshScrollPos()	
		self.pListView:reload(false)
	else
		self:refreshScrollPos()	
		self.pListView:notifyDataSetChange(false, nItemCnt)
	end

end

function DlgRecruitSodiers:refreshScrollPos(  )
	-- body
	local nItemCnt = #self.tMadingLists
	if nItemCnt <= 0 or self.nOpenCampIdx <= 0 then
		self.pListView:scrollToBegin()
		return
	end
	--如果有可领取队列置顶
	if self.bCanGetRecruit then
		self.pListView:scrollToBegin()
		return
	end
	--移动位置
	local nPos = 0	
	if self.nOpenCampIdx >= 4 and self.nOpenCampIdx <= self.nEndFreeTeamIdx  then
		nPos = self.nOpenCampIdx - 2
	end
	if nPos <= 0 then
		self.pListView:scrollToBegin()
	else
		self.pListView:scrollToPosition(nPos, true) 
	end	
end

--列表项回调
function DlgRecruitSodiers:onListViewItemCallBack( _index, _pView )
	-- body
	local tTempData = self.tMadingLists[_index]
	local tFirstData = self.tMadingLists[1]
    local pTempView = _pView
    if pTempView == nil then
        pTempView = ItemRecruit.new()  
        -- pTempView:setPositionX(20)
    end
    pTempView:setClickCallBack(handler(self, self.onActionClicked))
    
    pTempView:setCurData(tTempData, self.tBuildInfo, tFirstData)
    pTempView:showFreeStatus(((_index > self.nOpenCampIdx + 1) and _index <= self.nEndFreeTeamIdx))--显示空闲    
    return pTempView
end

function DlgRecruitSodiers:onActionClicked( _data )
	-- body
	if _data then
		if _data.nType == e_camp_item.free then --可招募
			local nMinute = _data.nCurSD / 60 --转化为分钟
			if not self.nFoodCost then
				self.nFoodCost, self.nCoinCost = self.tBuildInfo:getNeedCostFood(_data.nCurNum)
			end
			local nPlayerFood = Player:getPlayerInfo().nFood
			local nPlayerCoin = Player:getPlayerInfo().nCoin
			--募兵需要消耗粮食少于拥有的数量
			if self.nFoodCost < nPlayerFood and self.nCoinCost < nPlayerCoin then
				SocketManager:sendMsg("recruitSolider", {nMinute,self.tBuildInfo.sTid}, handler(self, self.onResponse))
			else
				tResList = {}
				tResList[e_resdata_ids.lc] = self.nFoodCost
				tResList[e_resdata_ids.bt] = 0
				tResList[e_resdata_ids.mc] = 0
				tResList[e_resdata_ids.yb] = self.nCoinCost
				--资源不足弹框
				if self.nFoodCost > nPlayerFood then
					goToBuyRes(e_resdata_ids.lc, tResList)
					return
				end
				if self.nCoinCost > nPlayerCoin then
					goToBuyRes(e_resdata_ids.yb, tResList)
				end
			end
		elseif _data.nType == e_camp_item.finish then --完成募兵
			--发送消息募兵操作
			local tObject = {}
			tObject.nBuildId = self.tBuildInfo.sTid
			tObject.nType = 5
			tObject.sId = _data.nId
			sendMsg(ghd_recruit_action_msg,tObject)
		elseif _data.nType == e_camp_item.wait then --等待
			--发送消息募兵操作
			local tObject = {}
			tObject.nBuildId = self.tBuildInfo.sTid
			tObject.nType = 4
			tObject.sId = _data.nId
			sendMsg(ghd_recruit_action_msg,tObject)
		elseif _data.nType == e_camp_item.more then --扩充
			--弹出扩充对话框
		    local pDlg, bNew = getDlgByType(e_dlg_index.buyrecruit)
		    if not pDlg then
		    	pDlg = DlgBuyRecruit.new(e_build_ids.mbf)
		    end
		    pDlg:setRightHandler(function (  )
		    	-- body
	    		local nCost = _data.nCost
	    	    local strTips = {
	    	    	{color=_cc.pwhite,text=getConvertedStr(1, 10138) .. "?"},--扩充招募队列
	    	    }
	    	    --展示购买对话框
	    		showBuyDlg(strTips,nCost,function (  )
	    			-- body
	    			--发送兵营调整操作
	    			local tObject = {}
	    			tObject.nBuildId = self.tBuildInfo.sTid
	    			tObject.nType = 1
	    			sendMsg(ghd_update_camp_msg,tObject)	    			
	    		end)
	    		pDlg:closeDlg()
		    end)
		    pDlg:setCurData(self.tBuildInfo)
		    pDlg:showDlg(bNew)
		elseif _data.nType == e_camp_item.ing then --募兵中
			if _data.nFree == 1 then
				--发送消息募兵操作
				local tObject = {}
				tObject.nBuildId = self.tBuildInfo.sTid
				tObject.nType = 7
				tObject.sId = _data.nId
				sendMsg(ghd_recruit_action_msg,tObject)
			else
				local tObject = {}
				tObject.nFunType = 2
				tObject.nType = e_dlg_index.buildprop --dlg类型
				tObject.nCell = self.tBuildInfo.nCellIndex
				sendMsg(ghd_show_dlg_by_type,tObject)
			end

		end
	end
end

--请求数据回调
function DlgRecruitSodiers:onResponse( __msg, __oldMsg )
	-- body
	if __msg.head.type == MsgType.recruitSolider.id then 			--招募士兵
		if __msg.head.state == SocketErrorType.success then
			TOAST(getConvertedStr(1, 10164))
			--播放音效
			Sounds.playEffect(Sounds.Effect.soldier)
		else
		    TOAST(SocketManager:getErrorStr(__msg.head.state))
        end
    end
end

--增益点击事件
function DlgRecruitSodiers:onZyClicked( pView )
	-- body
	local data = getShopDataById(e_id_item.recruitment)	
	if not data then
		TOAST(getConvertedStr(6, 10438))
		return 
	end					
	local tObject = {
	    nType = e_dlg_index.shopbatchbuy, --dlg类型
	    tShopBase = data,
	}
	sendMsg(ghd_show_dlg_by_type, tObject)
end

--季节点击事件
function DlgRecruitSodiers:onJjClicked( pView )
	-- body
	print("增益")
	local tObject = {
	    nType = e_dlg_index.season, --dlg类型
	}
	sendMsg(ghd_show_dlg_by_type, tObject)	
end

-- 取消左边无效按钮事件
function DlgRecruitSodiers:onLeftDisabledClicked(pView)
    print("取消左边无效按钮事件")
end

-- 确定右边无效按钮事件
function DlgRecruitSodiers:onRightDisabledClicked(pView)
    TOAST(getConvertedStr(1, 10157))
end

-- 取消左边按钮事件
function DlgRecruitSodiers:onLeftClicked(pView)
	local nVipGifyLv = 0 --兵种购买的对应VIP礼包等级
    local tOb = {}
    tOb.nType = e_dlg_index.shop
    if self.nBuildTypeId == e_build_ids.infantry then
    	nVipGifyLv = getArmyVipLvLimit(e_id_item.bbgm)
    	tOb.nGoodsId = e_resdata_ids.bb
    elseif self.nBuildTypeId == e_build_ids.sowar then
    	nVipGifyLv = getArmyVipLvLimit(e_id_item.qbgm)
    	tOb.nGoodsId = e_resdata_ids.qb
    elseif self.nBuildTypeId == e_build_ids.archer then
    	nVipGifyLv = getArmyVipLvLimit(e_id_item.gbgm)
		tOb.nGoodsId = e_resdata_ids.gb
    end 
     
    if Player:getPlayerInfo():getIsBoughtVipGift(nVipGifyLv) == true then
    	sendMsg(ghd_show_dlg_by_type, tOb)  
    else
    	local tShopBase = getShopDataById(tOb.nGoodsId)
    	-- dump(tShopBase, "tShopBase", 100)
		local tObject = {
		    nType = e_dlg_index.vipgitfgoodtip, --dlg类型
		    tShopBase = tShopBase,
		}
		sendMsg(ghd_show_dlg_by_type, tObject)
    end
end

-- 确定右边按钮事件
function DlgRecruitSodiers:onRightClicked(pView)
    local pDlg, bNew = getDlgByType(e_dlg_index.buyrectime)
    if not pDlg then
    	pDlg = DlgBuyRecTime.new()
    end
    pDlg:setCurData(self.tBuildInfo)
    pDlg:setRightHandler(function (  )
    	-- body
    	--发送兵营调整操作
    	local tObject = {}
    	tObject.nBuildId = self.tBuildInfo.sTid
    	tObject.nType = 2
    	sendMsg(ghd_update_camp_msg,tObject)
    	pDlg:closeDlg()
    end)
    pDlg:showDlg(bNew)
end

--招募队列数据刷新消息
function DlgRecruitSodiers:onRefreshDatas( sMsgName, pMsgObj )
	-- body
	if pMsgObj then
		local nBuildId = pMsgObj.nBuildId
		if nBuildId and self.tBuildInfo and self.tBuildInfo.sTid == nBuildId then
			self:initDatas()
			self:updateViews()
		end
	end
end

function DlgRecruitSodiers:onRefreshBuff()
	-- body
	self:initDatas()
	self:updateViews()
end

function DlgRecruitSodiers:getRecuitRedNum(  )
	-- body
	local nNum = 0
	--功能开启而且次数不超过2次
	if Player:getPlayerInfo().nLv >= tonumber(getBuildParam("recruitLevel")) and self.tBuildInfo.nRecruitMore < 2 then
		local tNaxt = getRecruitByQueueFromDB(self.tBuildInfo.nRecruitMore + 1)
		local nCost = 0 
		if tNaxt then
			nCost = tonumber(tNaxt.coin or 0)
		end
		--资源充足
		if tonumber(nCost) <= Player:getPlayerInfo().nCoin then--铜钱足够
			nNum = 1
		end		
	end
	return nNum

end

return DlgRecruitSodiers