----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-10-09 11:11:04
-- Description: 世界季节界面
-----------------------------------------------------
local MDialog = require("app.common.dialog.MDialog")
local ItemWorldSeason = require("app.layer.worldseason.ItemWorldSeason")
local DlgWorldSeason = class("DlgWorldSeason", function()
	return MDialog.new()
end)

function DlgWorldSeason:ctor(  )
	--解析文件
	self:setDialogType(e_dlg_index.season)
	parseView("dlg_season", handler(self, self.onParseViewCallback))
	self:setName(UIAction.TAG_SMALL_DLG)
end

--解析界面回调
function DlgWorldSeason:onParseViewCallback( pView )
	self:setContentView(pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgWorldSeason",handler(self, self.onDlgWorldSeasonDestroy))
end

-- 析构方法
function DlgWorldSeason:onDlgWorldSeasonDestroy(  )
    self:onPause()
end

function DlgWorldSeason:regMsgs(  )
	regMsg(self, gud_world_season_day_change, handler(self, self.updateViews))
end

function DlgWorldSeason:unregMsgs(  )
	unregMsg(self, gud_world_season_day_change)
end

function DlgWorldSeason:onResume(  )
	self:regMsgs()
end

function DlgWorldSeason:onPause(  )
	self:unregMsgs()
end

function DlgWorldSeason:setupViews(  )
	local pTxtTitle = self:findViewByName("txt_title")
	pTxtTitle:setString(getConvertedStr(3, 10445))

	local pImgClose = self:findViewByName("img_close")
	pImgClose:setViewTouched(true)
	pImgClose:onMViewClicked(handler(self, self.closeDlg))

	local pTxtBanner1 = self:findViewByName("txt_banner1")
	pTxtBanner1:setString(getConvertedStr(3, 10452))

	local pTxtBanner2 = self:findViewByName("txt_banner2")
	pTxtBanner2:setString(getConvertedStr(3, 10453))

	local pLaySeasonBg1 = self:findViewByName("lay_season_bg1")
	self.pItemSeasonToday = ItemWorldSeason.new(0)
	pLaySeasonBg1:addView(self.pItemSeasonToday)

	local pLaySeasonBg2 = self:findViewByName("lay_season_bg2")
	local nBgHeight = pLaySeasonBg2:getContentSize().height
	self.pItemSeasonNext1 = ItemWorldSeason.new(1)
	local nItemHeight = self.pItemSeasonNext1:getContentSize().height
	self.pItemSeasonNext1:setPosition(0, nBgHeight - nItemHeight)
	pLaySeasonBg2:addView(self.pItemSeasonNext1)

	self.pItemSeasonNext2 = ItemWorldSeason.new(2)
	self.pItemSeasonNext2:setPosition(0, nBgHeight - nItemHeight * 2)
	pLaySeasonBg2:addView(self.pItemSeasonNext2)

	self.pItemSeasonNext3 = ItemWorldSeason.new(3)
	self.pItemSeasonNext3:setPosition(0, nBgHeight - nItemHeight * 3)
	pLaySeasonBg2:addView(self.pItemSeasonNext3)

end

function DlgWorldSeason:updateViews(  )
	local nSeasonDay = Player:getWorldData().nSeasonDay
	if nSeasonDay == nil or nSeasonDay == 0 then
		nSeasonDay = 2 --默认是春季，改表的话，这里要改
	end

	--今天
	local tData = getWorldSeasonData(nSeasonDay)
	if tData then
		self.pItemSeasonToday:setData(tData)
	end

	--未来3天
	--15天一个周期，改表的话，这里要改
	local nMaxDay = 14
	nSeasonDay = nSeasonDay + 1
	if nSeasonDay > nMaxDay then
		nSeasonDay = 1
	end
	local tData = getWorldSeasonData(nSeasonDay)
	if tData then
		self.pItemSeasonNext1:setData(tData)
	end

	nSeasonDay = nSeasonDay + 1
	if nSeasonDay > nMaxDay then
		nSeasonDay = 1
	end
	local tData = getWorldSeasonData(nSeasonDay)
	if tData then
		self.pItemSeasonNext2:setData(tData)
	end

	nSeasonDay = nSeasonDay + 1
	if nSeasonDay > nMaxDay then
		nSeasonDay = 1
	end
	local tData = getWorldSeasonData(nSeasonDay)
	if tData then
		self.pItemSeasonNext3:setData(tData)
	end
end

return DlgWorldSeason


