-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-1-18 14:41:40 星期四
-- Description: 竞技场 挑战记录
-----------------------------------------------------
local ArenaFunc = require("app.layer.arena.ArenaFunc")
local MCommonView = require("app.common.MCommonView")
local ItemBattleRecord = class("ItemBattleRecord", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemBattleRecord:ctor(  )
	-- body
	self:myInit()
	parseView("item_battle_record", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemBattleRecord:myInit(  )
	-- body
	self.tCurData 			= 	nil 				--当前数据	
	self.bIsIconCanTouched 	= 	false		
end

--解析布局回调事件
function ItemBattleRecord:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemBattleRecord",handler(self, self.onDestroy))
end

--初始化控件
function ItemBattleRecord:setupViews( )
	-- body
	self.pLayRoot = self:findViewByName("item_battle_record")
	self.pLayMain = self:findViewByName("lay_view")
	self.pImgFlag = self:findViewByName("img_flag")		
	self.pLbCont = self:findViewByName("lb_cont")
	self.pLbRank = self:findViewByName("lb_rank")
	self.pImgNew = self:findViewByName("img_new")
	self.pImgMark = self:findViewByName("img_mark")
	self.pLbTitle = self:findViewByName("lb_title")
	self.pLbTime = self:findViewByName("lb_time")
	setTextCCColor(self.pLbTime, _cc.gray)

	self:setViewTouched(true)
	self:setIsPressedNeedScale(false)
	self:onMViewClicked(handler(self, self.onReportBtnClicked))
	
end

-- 修改控件内容或者是刷新控件数据
function ItemBattleRecord:updateViews( )
	-- body
	if not self.tCurData then
		return
	end
	-- dump(self.tCurData, "self.tCurData", 100)
	local nType = self.tCurData:getReportType()
	if nType == 1 then --进攻成功
		self.pImgMark:setCurrentImage("#v1_img_jingongchenggong.png")
		self.pLbTitle:setString(getConvertedStr(6, 10794), false)
	elseif nType == 2 then 
		self.pImgMark:setCurrentImage("#v1_img_fangshoushibai.png")
		self.pLbTitle:setString(getConvertedStr(6, 10797), false)
	elseif nType == 3 then 	
		self.pImgMark:setCurrentImage("#v1_img_jingongshibai.png")
		self.pLbTitle:setString(getConvertedStr(6, 10795), false)
	elseif nType == 4 then 
		self.pImgMark:setCurrentImage("#v1_img_fangshouchenggong_sj.png")
		self.pLbTitle:setString(getConvertedStr(6, 10796), false)
	end		
	--是否胜利标志
	if self.tCurData:isWin() then
		self.pImgFlag:setCurrentImage("#v2_font_shengli.png")
	else
		self.pImgFlag:setCurrentImage("#v2_font_shibai.png")
	end
	--是否为新战报
	local bNew = false
	if self.nType == 1 then
		bNew = self.tCurData.bNew
	elseif self.nType == 2 then
		local pData = Player:getArenaData()
		bNew = not pData:isTopBattleRecordRead(self.tCurData.nReportId)
	end
	self.pImgNew:setVisible(bNew)
	if bNew then
		self.pLayMain:setBackgroundImage("ui/big_img_sep/v1_img_kelashenyidu.png", {scale9 = false})	
	else
		self.pLayMain:setBackgroundImage("ui/big_img_sep/v1_img_kelashenweidu.png", {scale9 = false})	
	end	
	--时间
	local sTime = formatTimeYMDM(self.tCurData.nOt)
	self.pLbTime:setString(sTime, false)

	--
	local sStr = getTextColorByConfigure(self.tCurData:getMailTypeDes())
	-- dump(sStr, sStr)
	self.pLbCont:setString(sStr, false)

	local pMyInfo = self.tCurData:getMyArenaInfo()
	if pMyInfo then		
		local sColor = _cc.green
		local sMark = "+"
		if pMyInfo.nAr < pMyInfo.nBr then--上升
			sColor = _cc.green
			sMark = "+"
		elseif pMyInfo.nAr > pMyInfo.nBr then
			sColor = _cc.red
			sMark = "-"
		end	
		local sStr = {
			{color=_cc.white, text=getConvertedStr(6, 10685)},
			{color=sColor, text=sMark..math.abs(pMyInfo.nAr - pMyInfo.nBr)}
		}		
		self.pLbRank:setString(sStr, false)	
		self.pLbRank:setVisible(pMyInfo.nAr ~= pMyInfo.nBr)
	else
		print("error data ！")
	end

	

	if self.tCurData.nType == 0 then--进攻方
		if self.tCurData.nWin == 0 then
			--失败
			self.pImgFlag:setCurrentImage("#v2_font_shibai.png")
		else
			--胜利
			self.pImgFlag:setCurrentImage("#v2_font_shengli.png")
		end
	else
		if self.tCurData.nWin == 0 then
			--胜利
			self.pImgFlag:setCurrentImage("#v2_font_shengli.png")
		else
			--失败
			self.pImgFlag:setCurrentImage("#v2_font_shibai.png")
		end
	end
end

-- -- 将时间格式化成时分
-- -- nTime（long）：要格式化的时间
-- -- return（string）：格式化后的字符串
-- -- 格式化时间显示
-- function ItemBattleRecord:formatShowTime( _nTime )
-- 	local tData = os.date("*t", _nTime/1000)
-- 	return string.format("%02d:%02d",tData.hour,tData.min )
-- end
-- 析构方法
function ItemBattleRecord:onDestroy(  )
	-- body
end
--_nType 1--自己的记录  2--大神的记录
function ItemBattleRecord:setCurData( _tData, _nType )
	-- body
	self.tCurData = _tData
	self.nType = _nType or 1
	self:updateViews()
end

--按钮点击回调 查看按钮
-- function ItemBattleRecord:onCheckBtnClicked( pView )
-- 	-- body
-- 	if self.tCurData then
-- 		local tPlayerData = nil
-- 		-- if self.nType == 1 then
-- 			tPlayerData = self.tCurData:getOtherPlayerInfo()
-- 		-- else
-- 		-- 	tPlayerData = self.tCurData:getMyArenaInfo()
-- 		-- end	
-- 		if tPlayerData and tPlayerData.nPlayerId then
-- 			SocketManager:sendMsg("checkArenaPlayer", {tPlayerData.nPlayerId}) --刷新竞技场幸运列表	
-- 		end
-- 	end	
-- end


--按钮点击回调 战报按钮
function ItemBattleRecord:onReportBtnClicked( pView )
	-- body
	if self.tCurData then
		local tObject = {}
		tObject.nType = e_dlg_index.arenafightdetail --dlg类型
		tObject.tFightDetail = self.tCurData
		tObject.bShare = (self.nType == 1)
		sendMsg(ghd_show_dlg_by_type,tObject)	
		--是否为新战报
		local bNew = false
		if self.nType == 1 then
			bNew = self.tCurData.bNew
		elseif self.nType == 2 then
			local pData = Player:getArenaData()
			bNew = not pData:isTopBattleRecordRead(self.tCurData.nReportId)
		end
		if bNew then
			ArenaFunc.readArenaReport(self.tCurData.nReportId, 1, self.nType)	
		end
		
	end	
end
return ItemBattleRecord