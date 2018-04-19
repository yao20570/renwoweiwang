-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-12-15 15:00:23 星期一
-- Description: 竞技场 竞技场分页
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemArenaLayer = require("app.layer.arena.ItemArenaLayer")
local ArenaFunc = require("app.layer.arena.ArenaFunc")

local ArenaLayer = class("ArenaLayer", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)


function ArenaLayer:ctor(_tSize)
	-- body
	self:setContentSize(_tSize)
	self:myInit()
	parseView("lay_arena_main", handler(self, self.onParseViewCallback))
end
--解析布局回调事件
function ArenaLayer:onParseViewCallback( pView )
	-- body
	
	self:addView(pView)
	self:setupViews()	
	self:onResume()
	 --注册析构方法
	self:setDestroyHandler("ArenaLayer",handler(self, self.onDestroy))
end

-- --初始化参数
function ArenaLayer:myInit()
	-- body

end

--初始化控件
function ArenaLayer:setupViews( )
	-- body	
	--顶部信息层
	self.pLayTopInfo 	= 		self:findViewByName("lay_top_info")
	self.pLayIcon 		= 		self:findViewByName("lay_icon")
	self.pImgCountry 	= 		self:findViewByName("img_country")
	self.pLbLevel 		= 		self:findViewByName("lb_level")
	self.pLbCombat 		= 		self:findViewByName("lb_combat")
	self.pLbPar1 		= 		self:findViewByName("lb_par")
	self.pLbCd 			= 		self:findViewByName("lb_cd")
	self.pLayClose 		= 		self:findViewByName("lay_close_cd")	


	self.pImgRes 		= 		self:findViewByName("img_res")	
	self.pLbResNum 		= 		self:findViewByName("lb_res_num")
	self.pLbRank 		= 		self:findViewByName("lb_my_rank")
	self.pLbChallenge 	= 		self:findViewByName("lb_challenge")
	self.pLayIncrease 	= 		self:findViewByName("lay_increase")	

	self.pLayList 		= 		self:findViewByName("lay_list")
	
	self.pLayBot 		= 		self:findViewByName("lay_bot")	
	self.pLayBtnLeft 	= 		self:findViewByName("lay_btn_left")	

	self.pLayBtnRight 	= 		self:findViewByName("lay_btn_right")
	--资源图片
	self.pImgRes:setCurrentImage(getCostResImg(e_type_resdata.medal))
	--增加挑战次数按钮
	self.pBtnPlus 					= 			getSepButtonOfContainer(self.pLayIncrease,TypeSepBtn.PLUS,TypeSepBtnDir.center)
	self.pBtnPlus:onMViewClicked(handler(self, self.onIncreaseBtnCallBack))--按钮点击消息	
	--减战败CD
	self.pBtnClose 					= 			getSepButtonOfContainer(self.pLayClose,TypeSepBtn.CROSS,TypeSepBtnDir.center)
	self.pBtnClose:onMViewClicked(handler(self, self.onCloseFailCd))--按钮点击消息		
	--

	self.pBtnLeft = getCommonButtonOfContainer(self.pLayBtnLeft,TypeCommonBtn.L_BLUE,getConvertedStr(6,10699), false)
    --左边按钮点击事件
	self.pBtnLeft:onCommonBtnClicked(handler(self, self.onLeftClicked))
			    

	
	self.pBtnRight = getCommonButtonOfContainer(self.pLayBtnRight,TypeCommonBtn.L_BLUE,getConvertedStr(6,10680), false)
    --中间按钮点击事件
	self.pBtnRight:onCommonBtnClicked(handler(self, self.onRightClicked))	
	-- local nCost = tonumber(getArenaParam("refresh") or 0)
	-- local tBtnTable = {}		
	-- tBtnTable.img = getCostResImg(e_type_resdata.money)
	-- --文本
	-- tBtnTable.tLabel = {
	-- 	{nCost,getC3B(_cc.green)}
	-- }
	-- tBtnTable.awayH = 2
	-- self.pBtnRight:setBtnExText(tBtnTable)

	self.pLbPar1:setString(getConvertedStr(6, 10683), false)
	self.pImgRes:setPositionX(self.pLbPar1:getPositionX() + self.pLbPar1:getWidth())
	self.pLbResNum:setPositionX(self.pImgRes:getPositionX() + self.pImgRes:getWidth())
end

-- 修改控件内容或者是刷新控件数据
function ArenaLayer:updateViews(  )
	-- body
	local pData = Player:getArenaData()	
	if not pData then
		return
	end		
	--头像
	local data = Player:getPlayerInfo():getActorVo()
	local pIconHero = getIconGoodsByType(self.pLayIcon, TypeIconHero.NORMAL,type_icongoods_show.header, data, TypeIconHeroSize.M)
	pIconHero:setIconIsCanTouched(false)
	--国家标识
	local nInfluence = Player:getPlayerInfo().nInfluence
	self.pImgCountry:setCurrentImage(getCountryImg(nInfluence))
	--等级
	local nLv = Player:getPlayerInfo().nLv
	local sStr1 = {
		{color=_cc.pwhite,text=getConvertedStr(6, 10812)},
		{color=_cc.white,text=getLvString(nLv, false)},
	}
	self.pLbLevel:setString(sStr1, false)
	--阵容战力
	local sStr2 = {
		{color=_cc.pwhite,text=getConvertedStr(6, 10711)},
		{color=_cc.blue,text=formatCountToStr(pData.nTsc)},
	}
	self.pLbCombat:setString(sStr2, false)
	--竞技场奖章数量
	self.pLbResNum:setString(formatCountToStr(getMyGoodsCnt(e_resdata_ids.medal)))
	--排名
	local sStr3 = {
		{color=_cc.pwhite,text=getConvertedStr(6, 10685)},
		{color=_cc.blue,text=pData.nMyRank},
	}	
	if pData:isRankLucky(pData.nMyRank) then
		table.insert(sStr3, {color=_cc.purple,text=getConvertedStr(6, 10725)})
	end
	self.pLbRank:setString(sStr3, false)
	--挑战次数
	local nTotal = tonumber(getArenaParam("fightInitCount") or 0)
	local SColor= _cc.red
	if pData.nChallenge > 0 then
		SColor= _cc.green
	end
	local sStr4 = {
		{color=_cc.pwhite, text=getConvertedStr(6, 10682)},
		{color=SColor, text=pData.nChallenge},
		{color=_cc.white, text="/"..nTotal},
		{color=_cc.white, text=getConvertedStr(6, 10814)},
	}
	self.pLbChallenge:setString(sStr4, false)
	--战败冷却	
	unregUpdateControl(self)
	local nLeft = pData:getChallengeCd()
	if nLeft > 0 then
		local sStr5 = {
			{color=_cc.red, text=getConvertedStr(6, 10815)},
			{color=_cc.red, text=formatTimeToMs()},
		}	
		self.pLbCd:setString(sStr5, false)
		regUpdateControl(self, handler(self, self.onUpdate))
	end
	self.pLbCd:setVisible(nLeft > 0)
	self.pLayClose:setVisible(nLeft > 0)	
	--根据界面数据刷新确定列表中各项的按钮状态
	if self.pListView then
		self.pListView:notifyDataSetChange(false)
	end	

	self:updateFightRecordRed()
end

function ArenaLayer:updateFightRecordRed(  )
	-- body
	local pData = Player:getArenaData()	
	if not pData then
		return
	end			
	if self.pLayBtnLeft then		
		showRedTips(self.pLayBtnLeft,0,pData:getMyFightRed(), 2)	
	end		
end

function ArenaLayer:updateListView(  )
	-- body
	self.tArenaViews = Player:getArenaData():getArenaViewDatas()	
	self.nSelectIdx = Player:getArenaData():getMyArenaIdx()	
	local nItemCnt = #self.tArenaViews 
	if not self.pListView then
	    self.pListView = MUI.MListView.new {
            bgColor = cc.c4b(255, 255, 255, 250),
            viewRect = cc.rect(0, 0, 600, self.pLayList:getHeight()),
            itemMargin = {left = 0,
            right = 0,
            top = 10 ,
            bottom = 5 },
            direction = MUI.MScrollView.DIRECTION_VERTICAL ,--listView方向
        }
        self.pListView:setBounceable(true) --是否回弹
        self.pListView:setPosition((self.pLayList:getWidth() - self.pListView:getWidth())/2, 0)
        self.pLayList:addView(self.pListView, 10)
        --上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)
		self.pListView:setItemCount(nItemCnt)
		self.pListView:setItemCallback(handler(self, self.onEveryCallback))
		if self.nSelectIdx then
			self.pListView:scrollToPosition(self.nSelectIdx, true) 	
		end			
		self.pListView:reload(false)	
	else
		if self.nSelectIdx then
			self.pListView:scrollToPosition(self.nSelectIdx, true) 	
		end			
		self.pListView:notifyDataSetChange(false, nItemCnt)
	end	
end

function ArenaLayer:onEveryCallback ( _index, _pView ) 
    local pView = _pView
	if not pView then
		pView = ItemArenaLayer.new()
		pView:setViewTouched(true)
		pView:setIsPressedNeedScale(false)					
	end
	pView:setCurData(self.tArenaViews[_index], _index)	
	return pView
end
--挑战按钮回调
function ArenaLayer:onItemClicked( _tData )	
	-- body
	
end
-- 左边按钮点击响应 战斗记录
function ArenaLayer:onLeftClicked( )
	-- body
	local tObject = {}
	tObject.nType = e_dlg_index.arenabattlerecord --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)		
end

-- 右边按钮点击响应 换一批
function ArenaLayer:onRightClicked( )
	-- body
	local pData = Player:getArenaData()
	if not pData then
		return
	end
	local nCost = 0	
	if pData.nRf == 1 then
		nCost = tonumber(getArenaParam("refresh") or 0)
	end
	ArenaFunc.doRefreshArenaView(nCost)
end
--增加按钮点击响应
function ArenaLayer:onIncreaseBtnCallBack(  )
	-- body	
	local pData = Player:getArenaData()
	if not pData then
		return
	end
	local itemdata = Player:getBagInfo():getItemDataById(e_id_item.arenaToken)
	if itemdata and itemdata.nCt > 0 then
		ShowDlgUseArenatToken()
	else			
		local nBuyLeft = pData:getLeftVipChallengeTime()
		if nBuyLeft > 0 then		
			showBuyArenaChallenge()
		else
			if Player:getPlayerInfo():isVipLevelFull() then				
				TOAST(getConvertedStr(6, 10830))--今日挑战次数已耗尽
			else
				TOAST(getConvertedStr(6, 10710))
			end
		end		
	end		
end
--关闭战败Cd
function ArenaLayer:onCloseFailCd( )
	-- body
	local pData = Player:getArenaData()	
	if not pData then
		return
	end	
	local nLeft = pData:getChallengeCd()	
	local nCost = tonumber(getArenaParam("CDCosts") or 0)
	if nLeft > 0 then	
		ArenaFunc.doClearChallengeCd(nCost)--执行清理CD流程
	end	
end

function ArenaLayer:onUpdate(  )
	-- body
	local pData = Player:getArenaData()	
	if not pData then
		return
	end	
	local nLeft = pData:getChallengeCd()	
	if nLeft > 0 then
	    --战败冷却	
		local sStr5 = {
			{color=_cc.red, text=getConvertedStr(6, 10815)},
			{color=_cc.red, text=formatTimeToMs(nLeft)},
		}	
		self.pLbCd:setString(sStr5, false)
	else		--在cd小于0时候通过updateViews方法重置倒计时
		self:updateViews()
	end		
end

--析构方法
function ArenaLayer:onDestroy(  )
	self:onPause()
end

-- 注册消息
function ArenaLayer:regMsgs( )
	-- body
	--竞技场视图数显
	regMsg(self, ghd_refresh_arena_view_msg, handler(self, self.updateListView))
	--竞技场玩家配置数据刷新
	regMsg(self, gud_refresh_arena_msg, handler(self, self.updateViews))

    -- 注册玩家战力变化
    regMsg(self, gud_refresh_playerinfo, handler(self, self.updateViews))

    -- 刷新战斗记录红点
    regMsg(self, ghd_refresh_my_arena_red_msg, handler(self, self.updateFightRecordRed))    
end

-- 注销消息
function ArenaLayer:unregMsgs(  )
	-- body
	unregMsg(self, ghd_refresh_arena_view_msg)
	unregMsg(self, gud_refresh_arena_msg)	
	unregMsg(self, gud_refresh_playerinfo)	
	unregMsg(self, ghd_refresh_my_arena_red_msg)	
end
--暂停方法
function ArenaLayer:onPause( )
	-- body
	self:unregMsgs()	
end

--继续方法
function ArenaLayer:onResume( )
	-- body
	self:regMsgs()
	self:updateViews()	
end

return ArenaLayer
