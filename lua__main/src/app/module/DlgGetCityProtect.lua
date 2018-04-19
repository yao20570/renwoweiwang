
-- Author: maheng
-- Date: 2017-05-04 16:54:24
-- 获取主城保护对话框


local DlgCommon = require("app.common.dialog.DlgCommon")
local TCommonTabHost = require("app.common.tabhost.TCommonTabHost")
local ItemInfo = require("app.module.ItemInfo")


local DlgGetCityProtect = class("DlgGetCityProtect", function ()
	return DlgCommon.new(e_dlg_index.getcityprotect)
end)

--构造
--_nDefaultIndex：默认选择哪一项
function DlgGetCityProtect:ctor( _nDefaultIndex)	
	-- body	
	self:myInit()	
	self.nDefaultIndex = _nDefaultIndex or self.nDefaultIndex
	parseView("dlg_city_protect", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgGetCityProtect:myInit()
	-- body	
	self.tCurLists = {} --资源数据
	self.nCurIndex = 0  --当前选项	
	self.nDefaultIndex = 1 --默认选择哪一项
end
  
--解析布局回调事件
function DlgGetCityProtect:onParseViewCallback( pView )
	-- body
	self:addContentView(pView,false)
	self:setupViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgGetCityProtect",handler(self, self.onDlgGetCityProtectDestroy))
end

--初始化控件
function DlgGetCityProtect:setupViews()
	-- body
	--设置标题
	self:setTitle(getConvertedStr(6,10164))

	self.pLayRoot = self:findViewByName("root")
	--内容层
	self.pLayTop 			= 		self:findViewByName("lay_top")
	--建筑层 放置建筑图片
	self.pLayJianzhu = self:findViewByName("lay_jianzhu")
	self.pImgCityIcon = MUI.MImage.new("#v1_img_wanjia01.png", {scale9=false})
	self.pImgCityIcon:setLayoutSize(self.pLayJianzhu:getWidth(), self.pLayJianzhu:getHeight())
	self.pLayJianzhu:addView(self.pImgCityIcon)
	centerInView(self.pLayJianzhu, self.pImgCityIcon)
	--国家图标层
	self.pLayFlag = self:findViewByName("lay_flag")

	--玩家名字
	self.pLbPlayerName = self:findViewByName("lb_playername")
	setTextCCColor(self.pLbPlayerName, _cc.yellow)
	--玩家等级
	self.pLbPlayerLv = self:findViewByName("lb_playerLv")
	setTextCCColor(self.pLbPlayerLv, _cc.white)	
	--位置
	self.pLbPos	= self:findViewByName("lb_pos")
	setTextCCColor(self.pLbPos, _cc.gray)
	self.pLbPos:setString(getConvertedStr(6, 10168))
	--坐标值
	self.pLbPosValue = self:findViewByName("lb_pos_value")
	setTextCCColor(self.pLbPosValue, _cc.white)
	--文字标签，保护倒计时
	self.pLbProtectTime = self:findViewByName("lb_protecttime")
	setTextCCColor(self.pLbProtectTime, _cc.green)
	self.pLbProtectTime:setString(getConvertedStr(6, 10169))
	--计时器
	self.pLbTimer = self:findViewByName("lb_timer")
	setTextCCColor(self.pLbTimer, _cc.green)
	--国旗
	self.pImgFlag = self:findViewByName("img_flag")	
	--显示内容下拉列表
	self.pLayList = self:findViewByName("lay_bot_list")
    self.pListView = MUI.MListView.new {
    	viewRect = cc.rect(0, 10, 532, 344),
    	direction = MUI.MScrollView.DIRECTION_VERTICAL,
    	itemMargin = {left = 0,
    	right = 0,
    	top = 7,
    	bottom = 7}}	
	self.pListView:setItemCount(0)
	self.pListView:setBounceable(true)   
	self.pListView:setItemCallback(handler(self, self.onListViewItemCallBack))
	self.pLayList:addView(self.pListView, 10)
	self.pListView:reload()
	
	--提示文字
	self.pLbTip = MUI.MLabel.new({
	    text = getTipsByIndex(10045),
	    size = 20,
	    anchorpoint = cc.p(0.5, 0.5),
	    align = cc.ui.TEXT_ALIGN_CENTER,
		valign = cc.ui.TEXT_VALIGN_CENTER,
	    color = cc.c3b(255, 255, 255),
	    dimensions = cc.size(400, 0),
	})
	self.pLbTip:setPosition(280, 457)
	self.pLayRoot:addView(self.pLbTip, 10)
	setTextCCColor(self.pLbTip, _cc.pwhite)

end

-- 修改控件内容或者是刷新控件数据
function DlgGetCityProtect:updateViews()
	-- body
	--玩家信息显示
	local playerinfo = Player:getPlayerInfo()
	if playerinfo then
		self.pLbPlayerName:setString(playerinfo.sName, false)--玩家名字刷新
		self.pLbPlayerLv:setString(getLvString(playerinfo.nLv, false))--玩家等级刷新
		self.pLbPlayerLv:setPositionX(self.pLbPlayerName:getPositionX() + self.pLbPlayerName:getWidth())
		local sImg = getPlayerCityIcon(Player:getBuildData():getBuildById(e_build_ids.palace).nLv, playerinfo.nInfluence)
		if sImg then
			self.pImgCityIcon:setCurrentImage(sImg)
		end
	end
	local worlddata = Player:getWorldData()
	if worlddata then
		local  x, y = worlddata:getMyCityDotPos() --玩家城池的坐标刷新
		self.pLbPosValue:setString(x.."."..y)
		local nCountry = Player:getPlayerInfo().nInfluence --worlddata:getCountry()
		self.pImgFlag:setCurrentImage(WorldFunc.getCountryFlagImg(nCountry))

		local buffvo = Player:getBuffData():getBuffVo(e_buff_ids.cityprotect)	
		if buffvo and buffvo:getRemainCd() > 0 then	
			local nprotectCD = buffvo:getRemainCd()		
			unregUpdateControl(self)--停止计时刷新
			regUpdateControl(self, handler(self, self.onUpdateTime))
			self.pLbProtectTime:setVisible(true)
			self.pLbTimer:setVisible(true)
		else
			unregUpdateControl(self)--停止计时刷新
			self.pLbProtectTime:setVisible(false)
			self.pLbTimer:setVisible(false)
		end
	else
		unregUpdateControl(self)--停止计时刷新
	end
	--刷新列表
	self:updateProtectItemListView()

end

--析构方法
function DlgGetCityProtect:onDlgGetCityProtectDestroy()
	self:onPause()
end

-- 注册消息
function DlgGetCityProtect:regMsgs( )
	-- body
	-- 注册背包物品变化消息
	regMsg(self, gud_refresh_baginfo, handler(self, self.updateProtectItemListView))
	-- 注册玩家数据变化的消息
	regMsg(self, gud_refresh_playerinfo, handler(self, self.updateViews))
	-- 注册玩家位置修改的消息
	regMsg(self, gud_world_my_city_pos_change_msg, handler(self, self.updatePlayerPos))
	-- 注册Buff数据更新消息
	regMsg(self, gud_buff_update_msg, handler(self, self.updateViews))
end

-- 注销消息
function DlgGetCityProtect:unregMsgs(  )
	-- body
	-- 销毁背包物品变化消息
	unregMsg(self, gud_refresh_baginfo)
	-- 销毁玩家数据变化的消息
	unregMsg(self, gud_refresh_playerinfo)
	-- 销毁玩家位置修改的消息
	unregMsg(self, gud_world_my_city_pos_change_msg)
	-- 注销Buff数据更新消息
	unregMsg(self, gud_buff_update_msg)
end


--暂停方法
function DlgGetCityProtect:onPause( )
	-- body
	self:unregMsgs()
	unregUpdateControl(self)--停止计时刷新
end

--继续方法
function DlgGetCityProtect:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

--刷新玩家主城位置
function DlgGetCityProtect:updatePlayerPos( )
	-- body
	local worlddata = Player:getWorldData()
	if worlddata then
		local  x, y = worlddata:getMyCityDotPos() --玩家城池的坐标刷新
		self.pLbPosValue:setString(x.."."..y)
	end
end

--刷新保护物品列表
function DlgGetCityProtect:updateProtectItemListView(  )
	-- body
	self.tCurLists = getProtectItemLists()
	if self.pListView:getItemCount() > 0 then
		self.pListView:removeAllItems()
	end
	if self.tCurLists then
		self.pListView:setItemCount(table.nums(self.tCurLists) or 0)
		self.pListView:reload()
	end
end

--列表项回调
function DlgGetCityProtect:onListViewItemCallBack( _index, _pView )
	-- body
	local tTempData = self.tCurLists[_index]
    local pTempView = _pView
    if pTempView == nil then
        pTempView = ItemInfo.new(TypeItemInfoSize.M)  
    end
    pTempView:setClickCallBack(handler(self, self.onActionClicked))
    pTempView:setCurData(tTempData)
    if tTempData then
    	if tTempData.nCt == 0 then
    		pTempView:changeExToGold()
    	else
    		pTempView:changeExToHad()
    	end
    end
    return pTempView
end

--操作按钮点击事件
function DlgGetCityProtect:onActionClicked( _tItemInfo )
	-- body
	if _tItemInfo.nCt == 0 then
		local nCost = _tItemInfo.nPrice
	    local strTips = {
	    	{color=_cc.pwhite,text=getConvertedStr(1, 10146)},--购买并使用
	    	{color=_cc.yellow,text=_tItemInfo.sName},--名字
	    	{color=_cc.pwhite,text="?"},
	    }
	    --展示购买对话框
		showBuyDlg(strTips,nCost,function (  )
			-- body
			--发送使用物品消息
			local tObject = {}
			tObject.useId = _tItemInfo.sTid
			tObject.useNum = 1
			tObject.type = 2--购买并使用
			sendMsg(ghd_useItems_msg,tObject)
		end)
	else
		showUseItemDlg(_tItemInfo.sTid)    	
	end
end

--计时刷新
function DlgGetCityProtect:onUpdateTime()
	-- body
	local nprotectCD = 0
	local buffvo = Player:getBuffData():getBuffVo(e_buff_ids.cityprotect)
	if buffvo then	
		nprotectCD = buffvo:getRemainCd()
	else
		nprotectCD = 0
	end
	if nprotectCD > 0 then
		self.pLbTimer:setString(formatTimeToHms(nprotectCD))
	else
		unregUpdateControl(self)--停止计时刷新
	end
end
return DlgGetCityProtect
