----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-03-26 20:22:00
-- Description: 决战阿房宫 详情
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local EpwDetail = class("EpwDetail", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

function EpwDetail:ctor( _tSize )
    self:setContentSize(_tSize)
	--解析文件
	parseView("layout_epw_detail", handler(self, self.onParseViewCallback))
end

--解析界面回调
function EpwDetail:onParseViewCallback( pView )
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("EpwDetail", handler(self, self.onEpwDetailDestroy))
end

-- 析构方法
function EpwDetail:onEpwDetailDestroy(  )
    self:onPause()
end

function EpwDetail:regMsgs(  )
end

function EpwDetail:unregMsgs(  )
end

function EpwDetail:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function EpwDetail:onPause(  )
	self:unregMsgs()

end

function EpwDetail:setupViews(  )
	local pTxtDesc = self:findViewByName("txt_desc")
	pTxtDesc:setString(getTextColorByConfigure(getTipsByIndex(20152)))

	local pTxtCityName = self:findViewByName("txt_city_name")
	pTxtCityName:setString(getConvertedStr(3, 10961))
	local pTxtCityLv = self:findViewByName("txt_city_lv")
	pTxtCityLv:setString(1)

	local pLayBtn = self:findViewByName("lay_btn")
	local pGoBtn = getCommonButtonOfContainer(pLayBtn ,TypeCommonBtn.L_BLUE, getConvertedStr(3, 10162))
	pGoBtn:onCommonBtnClicked(handler(self, self.onGoClicked))
	self.pLayContent = self:findViewByName("lay_content")
end


function EpwDetail:updateViews(  )
end

function EpwDetail:onGoClicked( )
	local pCityData = getWorldCityDataById( e_syscity_ids.EpangPalace )
	if not pCityData then
		return
	end
	if not WorldFunc.checkIsInLockBlock(pCityData.tCoordinate.x, pCityData.tCoordinate.y) then
		closeAllDlg()
		sendMsg(ghd_world_location_dotpos_msg, {nX = pCityData.tCoordinate.x, nY = pCityData.tCoordinate.y, isClick = false})	
	end
end

return EpwDetail



