-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-04-18 15:12:23 星期二
-- Description: 王宫界面
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local ItemPalaceCivil = require("app.layer.palace.ItemPalaceCivil")
local ItemPalaceRes = require("app.layer.palace.ItemPalaceRes")
local ItemPalaceFunc = require("app.layer.palace.ItemPalaceFunc")

local DlgPalace = class("DlgPalace", function()
	-- body
	return DlgBase.new(e_dlg_index.palace)
end)

function DlgPalace:ctor(  )
	-- body
	self:myInit()
	parseView("dlg_palace", handler(self, self.onParseViewCallback))
end

function DlgPalace:myInit(  )
	-- body

end

--解析布局回调事件
function DlgPalace:onParseViewCallback( pView )
	-- body
	self:addContentView(pView) --加入内容层
	self:addContentTopSpace()
	
	--设置标题
	self:setTitle(getConvertedStr(6,10082))

	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgPalace",handler(self, self.onDlgPalaceDestroy))
end

--控件刷新
function DlgPalace:updateViews(  )
	gRefreshViewsAsync(self, 7, function ( _bEnd, _index )
		if(_index == 1) then
			--获取王宫数据
			local  palacedata = Player:getBuildData():getBuildById(e_build_ids.palace)
			if palacedata then
				--王宫界面标题
				local stitle = palacedata.sName..getLvString(palacedata.nLv) -- 王宫 Lv.12
				self:setTitle(stitle)
				--设置文官数据
			end
			--顶部图片层
			if(not self.pLayImage) then
				self.pLayImage = self:findViewByName("lay_top")
			end
			--文官信息层
			if(not self.pLayCivil) then
				self.pLayCivil = self:findViewByName("lay_civil")
				self.pItemPalaceCivil = ItemPalaceCivil.new(e_hire_type.official, true) --文官信息Item	
				self.pLayCivil:addView(self.pItemPalaceCivil, 10)		
				centerInView(self.pLayCivil, self.pItemPalaceCivil)
				self.pItemPalaceCivil:hideDiBg()
			else
				-- 刷新内容
				self:updateItemPalaceCivil()				
			end

		elseif(_index == 2) then
			--资源信息标题层
			if(not self.pLayResTitle) then
				self.pLayResTitle = self:findViewByName("lay_res_title")
				self.pLbResTitle = self:findViewByName("lb_res_title")--资源标题
				self.pLbResTitle:setString(getConvertedStr(6, 10098))
				self.pLayBtnShare = self:findViewByName("lay_btn_share")--分享按钮层
				self.pBtnShare = getCommonButtonOfContainer(self.pLayBtnShare, TypeCommonBtn.M_BLUE, getConvertedStr(6, 10099), false)	
				self.pBtnShare:onCommonBtnClicked(handler(self, self.onShareBtnClicked))
				setMCommonBtnScale(self.pLayBtnShare, self.pBtnShare, 0.8)
				--头顶横条(banner)
				local pBannerImage = self:findViewByName("lay_banner_bg")
				setMBannerImage(pBannerImage,TypeBannerUsed.wg)
			end
		elseif(_index == 3) then
			--底部功能层
			if(not self.pLayBottom) then
				self.pLayBottom = self:findViewByName("lay_bot")
				--主城保护	
				self.pItemCityProtect = ItemPalaceFunc.new(1)
				self.pItemCityProtect:setPosition(0, 0)
				self.pLayBottom:addView(self.pItemCityProtect, 10)	
				self.pItemCityProtect:setTitle(getConvertedStr(6, 10096))
				-- ActionIn(self.pItemCityProtect, "left", 0.5)
				--建筑队列	
				self.pItemBuildingQueue = ItemPalaceFunc.new(2)
				self.pItemBuildingQueue:setPosition(320,0)
				self.pLayBottom:addView(self.pItemBuildingQueue, 10)
				self.pItemBuildingQueue:setTitle(getConvertedStr(6, 10097))	
				-- ActionIn(self.pItemBuildingQueue, "right", 0.5)
			end
			--建筑队列面板刷新
			self:updateItemBuildingQueue()
			--主城保护面板刷新
			self:updateItemCityProtect()
		elseif(_index >= 4 and _index <= 7) then
			--资源信息层
			if(not self.pLayResInfo) then
				self.pLayResInfo = self:findViewByName("lay_res_info")
				self.tResItems = {}
			end
			local x = 0
			local y = 0
			local itemH = 110
			local newIndex = _index - 3
			if(not self.tResItems[newIndex]) then
				local resItem = ItemPalaceRes.new(newIndex)
				resItem:setPosition(0, 7 + (4-newIndex)*itemH)
				self.pLayResInfo:addView(resItem)
				self.tResItems[newIndex] = resItem
				-- ActionIn(resItem, "top", 0.35)
			end
			self.tResItems[newIndex]:updateViews()
		end
	end)
	
end

--析构方法
function DlgPalace:onDlgPalaceDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgPalace:regMsgs(  )
	-- body
	--注册成功雇用文官事件
	regMsg(self, ghd_refresh_palacecivil, handler(self, self.updateItemPalaceCivil))	
	--注册建筑队列刷新消息
	regMsg(self, gud_build_data_refresh_msg, handler(self, self.updateItemBuildingQueue))
	--注册王宫资源刷新消息
	regMsg(self, gud_refresh_palace_resource, handler(self, self.updateViews))
	--buff数据刷新
	regMsg(self, gud_buff_update_msg, handler(self, self.updateItemCityProtect))
end
--注销消息
function DlgPalace:unregMsgs(  )
	-- body
	--注销雇用文官事件
	unregMsg(self, ghd_refresh_palacecivil)	
	--注销建筑队列刷新消息
	unregMsg(self, gud_build_data_refresh_msg)
	--注销王宫资源刷新消息
	unregMsg(self, gud_refresh_palace_resource)
	--注销buff数据刷新
	unregMsg(self, gud_buff_update_msg)
end

--暂停方法
function DlgPalace:onPause( )
	-- body
	self:unregMsgs()
	if ( not gIsNull(self.pItemBuildingQueue)) then
		self.pItemBuildingQueue:onPause()
	end
	if ( not gIsNull(self.pItemCityProtect)) then
		self.pItemCityProtect:onPause()
	end
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgPalace:onResume( _bReshow )
	-- body	
	self:updateViews()
	self:regMsgs()
	if(_bReshow) then
		if(not gIsNull(self.pItemBuildingQueue)) then
			self.pItemBuildingQueue:onResume(_bReshow)
		end
		if(not gIsNull(self.pItemCityProtect)) then
			self.pItemCityProtect:onResume(_bReshow)
		end
	end
end

--分享按钮点击
function DlgPalace:onShareBtnClicked( pView )
	-- body
	local nCoin = Player:getResourceData():getResCntUnitTime(e_type_resdata.coin)
	local nWood = Player:getResourceData():getResCntUnitTime(e_type_resdata.wood)
	local nFood = Player:getResourceData():getResCntUnitTime(e_type_resdata.food)
	local nIron = Player:getResourceData():getResCntUnitTime(e_type_resdata.iron)
	openShare(pView, e_share_id.res_output, {getResourcesStr(nCoin), getResourcesStr(nWood), getResourcesStr(nFood), getResourcesStr(nIron)})
end
--建筑队列数据刷新消息响应
function DlgPalace:updateItemBuildingQueue( )
 	-- body
 	if self.pItemBuildingQueue then
 		self.pItemBuildingQueue:updateViews()
 	end
end
--文官雇用信息刷新消息响应
function DlgPalace:updateItemPalaceCivil(  )
	-- body
	if self.pItemPalaceCivil  then
		self.pItemPalaceCivil:updateViews()
	end
end

--主城保护Buff信息刷新消息响应
function DlgPalace:updateItemCityProtect(  )
	-- body
	if self.pItemCityProtect then
		self.pItemCityProtect:updateViews()
	end	
end
return DlgPalace