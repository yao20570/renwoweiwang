----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-01-27 21:27:00
-- Description: 系统城池新详细界面
-----------------------------------------------------
local FCommonTabHost = require("app.common.tabhost.FCommonTabHost")
local TabManager = require("app.common.TabManager")
local SysCityDetail = require("app.layer.syscitydetail.SysCityDetail")
local SysCityLevy = require("app.layer.syscitydetail.SysCityLevy")
local DlgCommon = require("app.common.dialog.DlgCommon")
local DlgSysCityDetailNew = class("DlgSysCityDetailNew", function()
	return DlgCommon.new(e_dlg_index.syscitydetail, 800 - 60 - 130, 130)
end)

--nSysCityId :world_city id
function DlgSysCityDetailNew:ctor( nSysCityId, nTab )
	self.nSysCityId = nSysCityId
	self.nFirstTabIndex = nTab or 1
	parseView("dlg_sys_city_detail_new", handler(self, self.onParseViewCallback))
	
end

--解析界面回调
function DlgSysCityDetailNew:onParseViewCallback( pView )
	self.pView = pView
	self:addContentView(pView) --加入内容层

	self:setTitle(getConvertedStr(3, 10021))

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgSysCityDetailNew",handler(self, self.onDlgSysCityDetailNewDestroy))
end

-- 析构方法
function DlgSysCityDetailNew:onDlgSysCityDetailNewDestroy(  )
    self:onPause()
end

function DlgSysCityDetailNew:regMsgs(  )
end

function DlgSysCityDetailNew:unregMsgs(  )
end

function DlgSysCityDetailNew:onResume(  )
	self:regMsgs()
end

function DlgSysCityDetailNew:onPause(  )
	self:unregMsgs()
end

function DlgSysCityDetailNew:setupViews(  )
	--内容层
	self.tTitles = {
		getConvertedStr(3, 10021),
		getConvertedStr(3, 10733),
	}

	local pContent = self:findViewByName("lay_content")

	--初始化红点
	self.pLyContent = pContent
	self.pTabHost = FCommonTabHost.new(self.pLyContent,1,1,self.tTitles,handler(self, self.getLayerByKey), 1)
	self.pTabHost:setTopZoder(1)
	self.pTabHost:setTabChangedHandler(handler(self, self.onTabChanged))
	self.pLyContent:addView(self.pTabHost)
	self.pTabHost:setDefaultIndex(self.nFirstTabIndex)

	--切换卡集
	local pTabItemList = self.pTabHost:getTabItems()
	self.pResLevyTab = pTabItemList[2]
	self.pResLevyTab:onMViewDisabledClicked(handler(self, function (  )
	    TOAST(getConvertedStr(3, 10734))
	end))
end	

function DlgSysCityDetailNew:updateViews(  )
	self:updateResLevyTab()
end

--更新资源征受Tab键
function DlgSysCityDetailNew:updateResLevyTab(  )
	--是否显示图纸和是否显示申请城主
	local bIsShowPaper = false
	local tCityData = getWorldCityDataById(self.nSysCityId)
	if tCityData then
		--都城没有城征收
		if tCityData.kind == e_kind_city.ducheng or tCityData.kind == e_kind_city.zhongxing then
		else
			local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSysCityId)
			if tViewDotMsg then
				--显示图纸
				if tViewDotMsg.nSysCountry == Player:getPlayerInfo().nInfluence then
					bIsShowPaper = true
				end
			end
		end
	end
	if bIsShowPaper then
		self.pResLevyTab:hideTabLock()
		self.pResLevyTab:setViewEnabled(true)
	else
		self.pResLevyTab:showTabLock()
		self.pResLevyTab:setViewEnabled(false)
	end
end

--通过key值获取内容层的layer
function DlgSysCityDetailNew:getLayerByKey( _sKey, _tKeyTabLt )
    -- body
    local pLayer = nil
    local pdata = {}
    if( _sKey == _tKeyTabLt[1] ) then
        pLayer = SysCityDetail.new(self.nSysCityId)  
    elseif (_sKey == _tKeyTabLt[2] ) then
    	pLayer = SysCityLevy.new(self.nSysCityId)
    end 
    return pLayer
end

function DlgSysCityDetailNew:onTabChanged( _sKey, _nType )
    if _sKey == "tabhost_key_1" then
    elseif _sKey == "tabhost_key_2" then
    end
end


return DlgSysCityDetailNew