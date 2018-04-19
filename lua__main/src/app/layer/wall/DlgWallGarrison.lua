----------------------------------------------------- 
-- author: liangzhaowei
-- Date: 2017-05-19 14:20:18
-- Description: 城墙驻防
-----------------------------------------------------
local DlgCommon = require("app.common.dialog.DlgCommon")
local ItemCityGarrison = require("app.layer.world.ItemCityGarrison")
local DlgWallGarrison = class("DlgWallGarrison", function()
	return DlgCommon.new(e_dlg_index.wallgarrison)
end)

function DlgWallGarrison:ctor(  )
	parseView("dlg_wall_garrison", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgWallGarrison:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容层

	self:setTitle(getConvertedStr(5, 10093))

	self:setupViews()
	self:refreshLayer()



	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgWallGarrison",handler(self, self.onDestroy))
end

--刷新界面
function DlgWallGarrison:refreshLayer()
	self:setData(Player:getWorldData():getHelpMsgs())
end

-- 析构方法
function DlgWallGarrison:onDestroy(  )
    self:onPause()
end

function DlgWallGarrison:regMsgs(  )
	regMsg(self, ghd_world_city_garrison_call_msg, handler(self, self.onCityGarrisonCall))
	regMsg(self, gud_refresh_wall, handler(self, self.refreshLayer))

end

function DlgWallGarrison:unregMsgs(  )
	unregMsg(self, ghd_world_city_garrison_call_msg)
	unregMsg(self, gud_refresh_wall)
end

function DlgWallGarrison:onResume(  )
	self:regMsgs()
end

function DlgWallGarrison:onPause(  )
	self:unregMsgs()
end

function DlgWallGarrison:setupViews(  )
	self.pLayIcon = self:findViewByName("lay_icon")
	self.pTxtName = self:findViewByName("txt_name")
	setTextCCColor(self.pTxtName, _cc.blue)
	self.pTxtName:setZOrder(3)
	local pTxtHeroCountTitle = self:findViewByName("txt_hero_count_title")
	pTxtHeroCountTitle:setString(getConvertedStr(3, 10178))
	self.pLayRichtextHeroCount = self:findViewByName("lay_richtext_hero_count")
	self.pTxtTroops = self:findViewByName("txt_troops")
	self.pImgFlag = self:findViewByName("img_flag")
	local pBannerTitle1 = self:findViewByName("txt_banner_title1")
	pBannerTitle1:setString(getConvertedStr(3, 10180))
	local pBannerTitle2 = self:findViewByName("txt_banner_title2")
	pBannerTitle2:setString(getConvertedStr(3, 10181))
	local pBannerTitle3 = self:findViewByName("txt_banner_title3")
	pBannerTitle3:setString(getConvertedStr(3, 10182))
	local pBannerTitle4 = self:findViewByName("txt_banner_title4")
	pBannerTitle4:setString(getConvertedStr(3, 10183))
	local pBannerTitle5 = self:findViewByName("txt_banner_title5")
	pBannerTitle5:setString(getConvertedStr(3, 10184))

	self.pDesc = self:findViewByName("lb_desc")
	setTextCCColor(self.pDesc, _cc.pwhite)
	self.pDesc:setString(getTipsByIndex(10009))


	--列表
	self.tHelpMsgList = {}
	local pLayContent = self:findViewByName("lay_content")
	self.pListView = MUI.MListView.new {
		viewRect   = cc.rect(0, 0, pLayContent:getContentSize().width, pLayContent:getContentSize().height),
		direction  = MUI.MScrollView.DIRECTION_VERTICAL,
    }
    pLayContent:addView(self.pListView)
    centerInView(pLayContent, self.pListView )
    self.pListView:setItemCallback(function ( _index, _pView ) 
    	local pItemData = self.tHelpMsgList[_index]
        local pTempView = _pView
        if pTempView == nil then
        	pTempView   = ItemCityGarrison.new()
    	end
    	pTempView:setData(pItemData)
        return pTempView
	end)

    --人数显示
	local tStr = {
		{color=_cc.blue,text="0"},
		{color=_cc.white,text="/9"}, --znftodo 上限配表
	}
	self.pRichtextHeroCount = getRichLabelOfContainer(self.pLayRichtextHeroCount, tStr)


end

function DlgWallGarrison:updateViews(  )

	self.pTxtName:setString(string.format("%s %s",Player:getPlayerInfo().sName,
	 getLvString(Player:getPlayerInfo().nLv)))
	WorldFunc.setImgCountryFlag(self.pImgFlag, Player:getPlayerInfo().nInfluence) --势力

	--图标
	WorldFunc.getCityIconOfContainer(self.pLayIcon, Player:getPlayerInfo().nInfluence,Player:getBuildData():getBuildById(e_build_ids.palace).nLv, true)
end

function DlgWallGarrison:updateListView(  )
	local nCount = #self.tHelpMsgList
	--列表
	self.pListView:removeAllItems()
	--列表数据
    self.pListView:setItemCount(nCount)
	-- 载入所有展示的item
	self.pListView:reload()

	--人数显示
	self.pRichtextHeroCount:updateLbByNum(1, tostring(nCount))
	local pWall = Player:getBuildData():getBuildById(e_build_ids.gate) --城墙数据
	if pWall and pWall.nLv then
		if getWallBaseDataByLv(pWall.nLv) then
			local nNums = getWallBaseDataByLv(pWall.nLv).guardnum
			if nNums then
				self.pRichtextHeroCount:updateLbByNum(2,"/"..nNums)--城防容量
			end
		end
	end


	--兵力数
	local nTroops = 0
	for i=1,#self.tHelpMsgList do
		nTroops = nTroops + self.tHelpMsgList[i].nTroops
	end
	self.pTxtTroops:setString(getConvertedStr(3, 10179) .. tostring(nTroops))
end


--tData:tViewDotMsg
function DlgWallGarrison:setData( tData )
	self.tHelpMsgList = tData or {}
	self:updateViews()
	self:updateListView()

end


--遣返友军驻防成功
function DlgWallGarrison:onCityGarrisonCall( sMsgName, pMsgObj)
	if pMsgObj then
		local sTid = pMsgObj
		for i=1,#self.tHelpMsgList do
			if self.tHelpMsgList[i].sTid == sTid then
				table.remove(self.tHelpMsgList, i)
				break
			end
		end
		self:updateListView()
	end
end


return DlgWallGarrison