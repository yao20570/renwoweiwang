----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-10-09 11:11:04
-- Description: 世界季节界面 横条
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local ItemWorldSeason = class("ItemWorldSeason", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--nDayIndex 0表示今日
function ItemWorldSeason:ctor( nDayIndex )
	self.nDayIndex = nDayIndex
	--解析文件
	parseView("item_season", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemWorldSeason:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemWorldSeason",handler(self, self.onItemWorldSeasonDestroy))
end

-- 析构方法
function ItemWorldSeason:onItemWorldSeasonDestroy(  )
    self:onPause()
end

function ItemWorldSeason:regMsgs(  )
end

function ItemWorldSeason:unregMsgs(  )
end

function ItemWorldSeason:onResume(  )
	self:regMsgs()
end

function ItemWorldSeason:onPause(  )
	self:unregMsgs()
end

function ItemWorldSeason:setupViews(  )
	self.pImgSeason = self:findViewByName("img_season")
	self.pTxtSeason = self:findViewByName("txt_season")
	self.pTxtBuff = self:findViewByName("txt_buff")
	local pTxtDay = self:findViewByName("txt_day")
	if self.nDayIndex == 0 then
		pTxtDay:setString(getConvertedStr(3, 10454))
		setTextCCColor(pTxtDay, _cc.green)
	else
		if self.nDayIndex == 1 then
			pTxtDay:setString(getConvertedStr(3, 10455))
		elseif self.nDayIndex == 2 then
			pTxtDay:setString(getConvertedStr(3, 10456))
		elseif self.nDayIndex == 3 then
			pTxtDay:setString(getConvertedStr(3, 10457))
		end
	end
end

function ItemWorldSeason:updateViews(  )
	if not self.tSeason then
		return
	end

	self.pImgSeason:setCurrentImage(self.tSeason.sIcon)
	local pImgSize = self.pImgSeason:getContentSize()
	if self.nPrevWidth ~= pImgSize.width then
		self.nPrevWidth = pImgSize.width
		self.pImgSeason:setScale(57/self.nPrevWidth)
	end

	self.pTxtSeason:setString(self.tSeason.name)
	local tBuffVo = getBuffDataByIdFromDB(self.tSeason.buffid)		
	if tBuffVo then
		self.pTxtBuff:setString(tBuffVo.sDesc)	
	end	
end

--tSeason  --world_season 表中的单条数据
function ItemWorldSeason:setData( tSeason )
	self.tSeason = tSeason
	self:updateViews()
end

return ItemWorldSeason


