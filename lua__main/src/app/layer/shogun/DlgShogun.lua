-----------------------------------------------------
-- author: liangzhaowei
-- Date: 2017-05-08 10:10:33
-- Description: 将军府
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local ItemShogunHero = require("app.layer.shogun.ItemShogunHero")
local ItemShogunList = require("app.layer.shogun.ItemShogunList")
local TCommonTabHost = require("app.common.tabhost.TCommonTabHost")
local MCommonView = require("app.common.MCommonView")

local MRichLabel = require("app.common.richview.MRichLabel")

local DlgShogun = class("DlgShogun", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function DlgShogun:ctor( _tSize )

    self:setContentSize(_tSize)
	
	self:myInit()


	-- self:setTitle(getConvertedStr(5, 10060))
	parseView("dlg_shogun", handler(self, self.onParseViewCallback))

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgShogun",handler(self, self.onDestroy))

end

--初始化成员变量
function DlgShogun:myInit()
	--资质开关
	self.strOpenTalent =  getLocalInfo("ShogunTalentSw"..Player:getPlayerInfo().pid, "0")
	self.pBuildBjt = Player:getBuildData():getBuildById(e_build_ids.bjt)--酒馆数据
	self.tShogunList = {} --英雄展示列表
	self.tShogunHeroItem = {} --各种品质的英雄item
	self.nSelect = 1 --当前所选星级

	self.tTitles = 
	{
		[1] = getConvertedStr(7,10283),
		[2] = getConvertedStr(7,10284),
		[3] = getConvertedStr(7,10285),
		[4] = getConvertedStr(7,10286),
		[5] = getConvertedStr(7,10287)
	}
	-- for i=1,5 do
	-- 	self.tTitles[i] = i..getConvertedStr(5,10235)
	-- end

    self.tShogunList =  Player:getHeroInfo():getShogunList()  --获取显示的英雄列表
   	self.tStarHeroList =   self:getStarList()
end

--当前星级列表数据
function DlgShogun:getStarList()
	local tList = {}
	local tData = Player:getHeroInfo():getStarHeroList()

	if tData[self.nSelect] then
		tList = separateTable(tData[self.nSelect],3) 

		local bShow = false
		if self.strOpenTalent == "1" then
			bShow = true
		end
		--是否显示资质
		for k,v in pairs(tList) do
			for x,y in pairs(v) do
				y.bShowTl = bShow
			end
		end
	end

	-- dump(tList,"tList")
	return tList
end

--解析布局回调事件
function DlgShogun:onParseViewCallback( pView )
	-- body
	self.pView = pView
	pView:setContentSize(self:getContentSize())
    pView:requestLayout()
	self:addView(pView)
	centerInView(self, pView)


	self:updateViews()

end

--初始化控件
function DlgShogun:setupViews( )

end




-- 没帧回调 _index 下标 _pView 视图
function DlgShogun:everyCallback( _index, _pView )
	local pView = _pView
	if not pView then
		if self.tStarHeroList[_index] then
			pView = ItemShogunList.new(_index,self.tStarHeroList[_index])
		end
	end

	if _index and self.tStarHeroList[_index] then
		pView:setCurData(self.tStarHeroList[_index])	
	end

	return pView
end


--下标选择回调事件
function DlgShogun:onIndexSelected( _index )

	self.nSelect = _index --当前所选星级
	self:refreshHeroData()
	--刷新列表
	self:updateTabHost()
end

--刷新列表
function DlgShogun:refreshListView()
	-- body
	if self.pListView then
		if self.pListView:getItemCount() then
			if self.pListView:getItemCount() > 0 then
				self.pListView:removeAllItems()
			end
			if self.tStarHeroList then
				-- print("table.nums(self.tStarHeroList) =====  ", table.nums(self.tStarHeroList))
				self.pListView:setItemCount(table.nums(self.tStarHeroList) or 0) 
				self.pListView:reload()
			end
		end

		if #self.tStarHeroList > 0 then
			self.pNullUi:setVisible(false)
		else
			self.pNullUi:setVisible(true)
		end
	end
end


--椭圆形开关
function DlgShogun:onOvalSw()
	if self.strOpenTalent == "0" then
		self.strOpenTalent = "1"
		self.pOvalSw:setState(1)
	else
	 	self.strOpenTalent = "0"
		self.pOvalSw:setState(0)
	end

	self:refreshLayer()

	saveLocalInfo("ShogunTalentSw"..Player:getPlayerInfo().pid, self.strOpenTalent)

end

--标题按钮回调
function DlgShogun:onTitleClicked()

	if getIsReachOpenCon(18) then
	    local tObject = {}
	    sendMsg(ghd_buy_hero_update_msg,tObject)
	end

end

--获取聚贤馆是否开启
function DlgShogun:bBuyHeroOpen()
	local bGotoDlg = false
	if self.pBuildBjt  then
		if not self.pBuildBjt.bLocked then
			bGotoDlg = true
		else
			bGotoDlg = false
		end
	else
		bGotoDlg = false
	end
	return bGotoDlg
end

-- 修改控件内容或者是刷新控件数据
function DlgShogun:updateViews(  )

	gRefreshViewsAsync(self, 6, function ( _bEnd, _index )
		if(_index == 1) then
			--ly
			--顶部按钮层
			if not self.pLyTop then
				self.pLyTop     			= 		self:findViewByName("lay_top")
				self.pLyList     			= 		self:findViewByName("ly_list")
				self.pLyTitleBtn   			= 		self:findViewByName("ly_title_btn")--标题按钮
				self.pLyTalentSw   			= 		self:findViewByName("ly_talent_switch")--资质显示按钮
				-- self.pLyOnline   			= 		self.pView:findViewByName("ly_online")--在线列表


				--img
				self.pImgBaner              =       self:findViewByName("img_banner")

				--lb
				self.pLbTopL                =       self:findViewByName("lb_top_l")
				self.pLbTopR                =       self:findViewByName("lb_top_r")
				self.pLbTalentTips          =       self:findViewByName("lb_talent_tips")

				--头顶横条(banner)
				local pBannerImage 			= 		self:findViewByName("lay_banner_bg")
				setMBannerImage(pBannerImage,TypeBannerUsed.jjf)
			end



			--前往酒馆按钮
			if not self.pTitleBtn then
			    self.pTitleBtn = getCommonButtonOfContainer(self.pLyTitleBtn,TypeCommonBtn.M_BLUE,getConvertedStr(1,10325))
				self.pTitleBtn:onCommonBtnClicked(handler(self, self.onTitleClicked))
				-- local strText1 = ""
			end

			--酒馆是否已经开启
			if self:bBuyHeroOpen() then
				-- tText = getTextColorByConfigure(getTipsByIndex(10002))
			     self.pTitleBtn:setVisible(true)
			     self.pTitleBtn:setBtnEnable(true)
			else
				-- tText = getTextColorByConfigure(getTipsByIndex(10001))
			     self.pTitleBtn:setVisible(false)
			     self.pTitleBtn:setBtnEnable(false)
			end


			if not  self.pRichViewTips1 then
				if self.strOpenTalent == "0" then -- 隐藏资质状态
					local strText1 = getTextColorByConfigure(getTipsByIndex(10002))
				    self.pRichViewTips1 = MRichLabel.new({str=strText1,fontSize=20, rowWidth=300})
				else --显示资质状态
					local strText1 = getTextColorByConfigure(getTipsByIndex(10002))
				    self.pRichViewTips1 = MRichLabel.new({str=strText1,fontSize=20, rowWidth=300})
				end
			    self.pRichViewTips1:setPosition(580,130)
			    self.pRichViewTips1:setAnchorPoint(cc.p(1,0.5))
			    self.pLyTop:addView(self.pRichViewTips1,10)
			end			

			--椭圆形开关
			if not self.pOvalSw then
			    local nBtnState = 0
			    if self.strOpenTalent == "1" then
			    	nBtnState = 1
			    end
			    self.pOvalSw = getOvalSwOfContainer(self.pLyTalentSw,handler(self, self.onOvalSw),nBtnState)
			end
			
			--在线英雄数据
			local bShow = false
			if self.strOpenTalent == "1" then
				bShow = true
			end
			-- if not self.tShogunHeroItem[1] then
			-- 	self.tShogunHeroItem[1] = ItemShogunHero.new(1)
			-- 	self.pLyOnline:addView(self.tShogunHeroItem[1])
			-- end
			-- self.tShogunHeroItem[1]:setCurData(self.tShogunList[1],bShow)

			
		elseif(_index == 2) then



			--显示资质文本
			local tText = {}
			local bShow = false
			if self.strOpenTalent == "0" then -- 隐藏资质状态
			    self.pLbTalentTips:setString(getConvertedStr(5, 10051))
			else --显示资质状态
			    self.pLbTalentTips:setString(getConvertedStr(5, 10050))
			     bShow = true
			end

			--等级文本刷新
			if self.pRichViewTips1 then

				if tText and table.nums(tText)> 0 then
					for k,v in pairs(tText) do
						self.pRichViewTips1:updateLbByNum(k,v.text)
					end
				end
			end

			--刷新在线武将数据
			-- for k,v in pairs(self.tShogunList) do
			-- 	if self.tShogunHeroItem[k] then
			-- 		self.tShogunHeroItem[k]:setCurData(v,bShow)
			-- 	end
			-- end

		elseif(_index == 4) then
			--刷新列表
			self:updateTabHost()
		end
	end)


end

--更新切换卡
function DlgShogun:updateTabHost()

		--创建类表中的英雄
		if not self.pTComTabHost then
			self.pLyContent 	  =		self:findViewByName("ly_list")
			self.pTComTabHost = TCommonTabHost.new(self.pLyContent,1,1,self.tTitles,handler(self, self.onIndexSelected))
			self.pLyContent:addView(self.pTComTabHost,10)
			self.pTComTabHost:removeLayTmp1()
			--默认选中第一项
			self.pTComTabHost:setDefaultIndex(1)
			-- ActionIn(self.pLyContent, "bottom", 0.2)	
		end

		--listview
		local nListLongBh = table.nums(self.tStarHeroList)
		if(not self.pListView) then
	 		local tLabel = {
			    str = getConvertedStr(3, 10220),
			}
			local pNullUi = getLayNullUiImgAndTxt(tLabel)
			self.pLyContent:addView(pNullUi)
			centerInView(self.pLyContent, pNullUi)
			self.pNullUi = pNullUi

			self.pListView = createNewListView(self.pTComTabHost:getContentLayer(),nil,nil,nil,20,0,20)
			--上下箭头
			local pUpArrow, pDownArrow = getUpAndDownArrow()
			self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)	
			
			self.pListView:setItemCallback(handler(self, self.everyCallback))
			self.pListView:setItemCount(nListLongBh)
			self.pListView:reload(true)
		else
			self.pListView:setItemCount(nListLongBh)
			self.pListView:notifyDataSetChange(true)
		end

		--显示空的提示
		if #self.tStarHeroList > 0 then
			if self.pNullUi:isVisible() then
				self.pNullUi:setVisible(false)
			end
		else
			if not self.pNullUi:isVisible() then
				self.pNullUi:setVisible(true)
			end
		end

end

--刷新界面
function DlgShogun:refreshLayer()

	self:refreshHeroData()
	self:updateViews()
end

--更新英雄数据
function DlgShogun:refreshHeroData()
	self.tShogunList =  Player:getHeroInfo():getShogunList()  --获取显示的英雄列表
	self.tStarHeroList =   self:getStarList()

end

-- 析构方法
function DlgShogun:onDestroy(  )
	-- body
	self:onPause()
	nCollectCnt = 1
	collectgarbage("collect")
end

-- 注册消息
function DlgShogun:regMsgs( )
	-- 注册英雄界面刷新
	regMsg(self, gud_refresh_hero, handler(self, self.refreshLayer))
end

-- 注销消息
function DlgShogun:unregMsgs(  )
	-- 注销英雄界面刷新
	unregMsg(self, gud_refresh_hero)
end




--暂停方法
function DlgShogun:onPause( )
	-- body
	self:unregMsgs()

	
end

--继续方法
function DlgShogun:onResume( )
	-- body
	self:refreshHeroData()
	self:regMsgs()
	
end

return DlgShogun