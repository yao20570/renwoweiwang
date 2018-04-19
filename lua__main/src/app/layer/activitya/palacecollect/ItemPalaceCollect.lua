-- Author: maheng
-- Date: 2017-12-07 16:55:12
-- 王宫采集
local MCommonView = require("app.common.MCommonView")
local ItemActContent = require("app.layer.activitya.ItemActContent")

local ItemPalaceCollect = class("ItemPalaceCollect", function()
	return ItemActContent.new(e_id_activity.magiccrit)
end)

--创建函数
function ItemPalaceCollect:ctor()
	-- body
	self:myInit()

	self:setupViews()
	self:updateViews()

	self:regMsgs()

	--注册析构方法
	self:setDestroyHandler("ItemPalaceCollect",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemPalaceCollect:myInit()
	self.pData = {} --数据
end



--初始化控件
function ItemPalaceCollect:setupViews( )
	self:setMHandler(handler(self, self.onClicked))
	self:setMBtnText(getConvertedStr(5, 10225)) --去挑战
end

--点击回调
function ItemPalaceCollect:onClicked()
	--print("跳转阿房宫")
	local pCityData = getWorldCityDataById( e_syscity_ids.EpangPalace )
	if not pCityData then
		return
	end
	if not WorldFunc.checkIsInLockBlock(pCityData.tCoordinate.x, pCityData.tCoordinate.y) then
		sendMsg(ghd_world_location_dotpos_msg, {nX = pCityData.tCoordinate.x, nY = pCityData.tCoordinate.y, isClick = false})	
		closeDlgByType( e_dlg_index.actmodela, false)	
	end
	--dump(pCityData, "pCityData", 100)

end

-- 修改控件内容或者是刷新控件数据
function ItemPalaceCollect:updateViews(  )
	self:setActTime()
end

--析构方法
function ItemPalaceCollect:onDestroy(  )
	self:unregMsgs()
end


-- 注册消息
function ItemPalaceCollect:regMsgs( )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
end

-- 注销消息
function ItemPalaceCollect:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
end


--设置数据 _data
function ItemPalaceCollect:setData(_tData)
	if not _tData then
		return
	end

	self.pData = _tData or {}
	self:setCurData(self.pData)

end


return ItemPalaceCollect