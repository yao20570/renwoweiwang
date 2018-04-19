----------------------------------------------------- 
-- author: maheng
-- updatetime: 2018-04-08 11:44:14
-- Description: 国家功能项
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local ItemZhouWangDotInfo = class("ItemZhouWangDotInfo", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)


function ItemZhouWangDotInfo:ctor( )
	-- body
	self:myInit()
	parseView("layout_kingzhou_dot_msg", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemZhouWangDotInfo:myInit(  )
	-- body
	self.tCurData = nil
end

--解析布局回调事件
function ItemZhouWangDotInfo:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()	
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemZhouWangDotInfo",handler(self, self.onDestroy))
end

--初始化控件
function ItemZhouWangDotInfo:setupViews( )
	-- body
	self.pLayRoot = self:findViewByName("lay_root")

	self.pLayIcon = self:findViewByName("lay_icon")	
	self.pLbName = self:findViewByName("lb_name")
	self.pLayBtn = self:findViewByName("lay_btn")
	self.pLayBar = self:findViewByName("lay_bar")
	self.pLbPos = self:findViewByName("lb_pos")
	self.pLbTime = self:findViewByName("lb_time")
	setTextCCColor(self.pLbName, _cc.blue)
	setTextCCColor(self.pLbPos, _cc.blue)
	setTextCCColor(self.pLbTime, _cc.green)

	self.pProgressBar = MCommonProgressBar.new({bar = "v1_bar_yellow_3.png",barWidth = 247, barHeight = 16})
	self.pLayBar:addView(self.pProgressBar, 10)
	self.pProgressBar:setPosition(125, 10)	

	self.pBtn = getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.M_BLUE, getConvertedStr(6, 10216))
	setMCommonBtnScale(self.pLayBtn, self.pBtn, 0.8)
	self.pBtn:onCommonBtnClicked(handler(self, self.onJumpToWorldPoint))
end

-- 修改控件内容或者是刷新控件数据
function ItemZhouWangDotInfo:updateViews( )
	-- body
	if not self.tCurData then
		return
	end
	local pKingZhou = WorldFunc.getKingZhouConfData()
	local pData = self.tCurData
	self.pLbName:setString(pKingZhou.sName..getLvString(pKingZhou.nLevel, true))
	self.pLbPos:setString(getConvertedStr(6, 10850)..getPosStrNoSign(pData.nX, pData.nY), false)

	self.nRatio = tonumber(getKingZhouInitData("marchQuickRate"))
	local nNeedTime = WorldFunc.getMyArmyMoveTime(pData.nX, pData.nY, self.nRatio)
	local sNeedTime = formatTimeToMs(nNeedTime)
	self.pLbTime:setString(getConvertedStr(3, 10019) .. sNeedTime)
	local nPer = pData.nKzt/pData.nKztt*100
	self.pProgressBar:setPercent(nPer)

	self.pProgressBar:setProgressBarText(nPer.."%")
end

function ItemZhouWangDotInfo:onJumpToWorldPoint( )
	-- body
	if not self.tCurData then
		return
	end
	local pData = self.tCurData
	sendMsg(ghd_world_location_dotpos_msg, {nX = pData.nX, nY = pData.nY, isClick = true})	
	closeDlgByType(e_dlg_index.dlgzhouwangdots, false)
end


-- 析构方法
function ItemZhouWangDotInfo:onDestroy(  )
	-- body
end

function ItemZhouWangDotInfo:setCurData( _data )
	-- body
	self.tCurData = _data
	self:updateViews()
end
return ItemZhouWangDotInfo


