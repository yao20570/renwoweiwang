-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-05-08 10:04:17 星期一
-- Description: 扩充募兵队列
-----------------------------------------------------
local DlgAlert = require("app.common.dialog.DlgAlert")
local MBtnExText = require("app.common.button.MBtnExText")


local DlgBuyRecruit = class("DlgBuyRecruit", function ()
	return DlgAlert.new(e_dlg_index.buyrecruit)
end)

--构造
function DlgBuyRecruit:ctor(_nBuildId)
	-- body
	self.nBuildId = _nBuildId
	self:myInit()
	parseView("dlg_buy_recruit", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgBuyRecruit:myInit()
	-- body
	self.tCurData = nil --当前数据
end
  
--解析布局回调事件
function DlgBuyRecruit:onParseViewCallback( pView )
	-- body
	
	self:addContentView(pView, true)
	self:setupViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgBuyRecruit",handler(self, self.onDlgBuyRecruitDestroy))
end

--初始化控件
function DlgBuyRecruit:setupViews()
	-- body
	--设置背景透明
	self:setContentBgTransparent()
	--设置标题
	self:setTitle(getConvertedStr(1,10141))

	--初始值
	self.pLbSParam1 		= 		self:findViewByName("lb_s_p1")
	setTextCCColor(self.pLbSParam1, _cc.blue)
	self.pLbSParam2 		= 		self:findViewByName("lb_s_p2")
	setTextCCColor(self.pLbSParam2, _cc.blue)
	self.pLbSParam3 		= 		self:findViewByName("lb_s_p3")
	setTextCCColor(self.pLbSParam3, _cc.blue)

	--扩展后
	self.pLbEParam1 		= 		self:findViewByName("lb_e_p1")
	setTextCCColor(self.pLbEParam1, _cc.blue)
	self.pLbEParam2 		= 		self:findViewByName("lb_e_p2")
	setTextCCColor(self.pLbEParam2, _cc.blue)
	self.pLbEParam3 		= 		self:findViewByName("lb_e_p3")
	setTextCCColor(self.pLbEParam3, _cc.blue)

	--增加后
	self.pLbMParam1 		= 		self:findViewByName("lb_m_p1")
	setTextCCColor(self.pLbMParam1, _cc.green)
	self.pLbMParam2 		= 		self:findViewByName("lb_m_p2")
	setTextCCColor(self.pLbMParam2, _cc.green)
	self.pLbMParam3 		= 		self:findViewByName("lb_m_p3")
	setTextCCColor(self.pLbMParam3, _cc.green)



	--国际化文字
	local pLbText 			= 		self:findViewByName("lb_s_tips1")
	setTextCCColor( pLbText, _cc.pwhite)
	pLbText:setString(getConvertedStr(1, 10142))
	pLbText 				= 		self:findViewByName("lb_s_tips2")
	setTextCCColor( pLbText, _cc.pwhite)
	pLbText:setString(getConvertedStr(1, 10143))
	pLbText 				= 		self:findViewByName("lb_s_tips3")
	setTextCCColor( pLbText, _cc.pwhite)
	pLbText:setString(getConvertedStr(1, 10144))
	pLbText 				= 		self:findViewByName("lb_e_tips1")
	setTextCCColor( pLbText, _cc.pwhite)
	pLbText:setString(getConvertedStr(1, 10142))
	pLbText 				= 		self:findViewByName("lb_e_tips2")
	setTextCCColor( pLbText, _cc.pwhite)
	pLbText:setString(getConvertedStr(1, 10143))
	pLbText 				= 		self:findViewByName("lb_e_tips3")
	setTextCCColor( pLbText, _cc.pwhite)
	pLbText:setString(getConvertedStr(1, 10144))

	--设置只有一个按钮
	self:setOnlyConfirm(getConvertedStr(1, 10139))
	self:setOnlyConfirmBtn(TypeCommonBtn.L_YELLOW)

	--额外信息
	local tBtnTable = {}
	tBtnTable.parent = self.pBtnRight
	tBtnTable.img = "#v1_img_qianbi.png"
	--文本
	tBtnTable.tLabel = {
		{"0",getC3B(_cc.blue)},
		{"/",getC3B(_cc.pwhite)},
		{'0',getC3B(_cc.pwhite)}
	}
	tBtnTable.awayH = 0
	self.pBtnExTextGold = MBtnExText.new(tBtnTable)

	
end

-- 修改控件内容或者是刷新控件数据
function DlgBuyRecruit:updateViews()
	-- body

	if self.tCurData then
		-- dump(self.tCurData, "self.tCurData=", 100)
		local pLbText 				= 		self:findViewByName("lb_tips")
		setTextCCColor( pLbText, _cc.gray)
		local sArmyTip = ""
		if self.tCurData.sTid == e_build_ids.infantry then   --步兵
			sArmyTip = getConvertedStr(1, 10081)
		elseif self.tCurData.sTid == e_build_ids.sowar then  --骑兵
			sArmyTip = getConvertedStr(1, 10082)
		elseif self.tCurData.sTid == e_build_ids.archer then --弓兵
			sArmyTip = getConvertedStr(1, 10083)
		end
		local sTip = string.format(getConvertedStr(1, 10145), self.tCurData.sName, sArmyTip)		
		if self.tCurData.sTid == e_build_ids.mbf then --募兵府
			if self.tCurData.nRecruitTp == e_mbf_camp_type.infantry then
				sArmyTip = getConvertedStr(1, 10081)
			elseif self.tCurData.nRecruitTp == e_mbf_camp_type.sowar then
				sArmyTip = getConvertedStr(1, 10082)
			elseif self.tCurData.nRecruitTp == e_mbf_camp_type.archer then
				sArmyTip = getConvertedStr(1, 10083)
			end
			sTip = string.format(getConvertedStr(1, 10145), self.tCurData.sDetailName, sArmyTip)
		end
		pLbText:setString(sTip, false)		


		--原始
		self.pLbSParam1:setString("+" .. self.tCurData.nMoreQue)
		self.pLbSParam2:setString("" .. (self.tCurData.nMoreQue + 1))
		self.pLbSParam3:setString(self.tCurData.nCpy)
		--扩充后原始
		if self.tCurData.nMoreQue == 0 then
			self.pLbEParam1:setString("",false)
		else
			self.pLbEParam1:setString("+" .. self.tCurData.nMoreQue,false)
			self.pLbEParam2:setString("" .. (self.tCurData.nMoreQue + 1),false)
			self.pLbEParam3:setString(self.tCurData.nCpy,false)
		end

		local tCurData = getCampTeamByQueueFromDB(self.tCurData.nMoreQue)
		--获得下个队列增加数据
		local tNextData = getCampTeamByQueueFromDB(self.tCurData.nMoreQue + 1)
		local nNextAddCpy = 0
		local nCost = 0
		if tNextData then
			if self.nBuildId == e_build_ids.mbf then
				if tCurData then
					nNextAddCpy = tNextData.institute*2 - tCurData.institute*2
				else
					nNextAddCpy = tNextData.institute*2
				end
			else
				if tCurData then
					nNextAddCpy = tNextData.institute - tCurData.institute
				else
					nNextAddCpy = tNextData.institute
				end
			end
			nCost = tNextData.gold or 0
		end

		self.pLbMParam1:setString("+1")
		self.pLbMParam2:setString("+1")
		self.pLbMParam3:setString("+" .. nNextAddCpy)
		--动态位置
		self.pLbMParam1:setPositionX(self.pLbEParam1:getPositionX() + self.pLbEParam1:getWidth() + 5)
		self.pLbMParam2:setPositionX(self.pLbEParam2:getPositionX() + self.pLbEParam2:getWidth() + 5)
		self.pLbMParam3:setPositionX(self.pLbEParam3:getPositionX() + self.pLbEParam3:getWidth() + 5)

		--设置金币消耗
		if tonumber(nCost) > Player:getPlayerInfo().nMoney then
			self.pBtnExTextGold:setLabelCnCr(3,nCost)
			self.pBtnExTextGold:setLabelCnCr(1,Player:getPlayerInfo().nMoney,getC3B(_cc.red))
		else
			self.pBtnExTextGold:setLabelCnCr(3,nCost)
			self.pBtnExTextGold:setLabelCnCr(1,Player:getPlayerInfo().nMoney,getC3B(_cc.yellow))
			
		end
		
	end
end

--析构方法
function DlgBuyRecruit:onDlgBuyRecruitDestroy()
	
end

-- 注册消息
function DlgBuyRecruit:regMsgs( )
	-- body
end

-- 注销消息
function DlgBuyRecruit:unregMsgs(  )
	-- body
end


--暂停方法
function DlgBuyRecruit:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgBuyRecruit:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

function DlgBuyRecruit:setCurData( _tData )
	-- body
	self.tCurData = _tData
	self:updateViews()
end



return DlgBuyRecruit
