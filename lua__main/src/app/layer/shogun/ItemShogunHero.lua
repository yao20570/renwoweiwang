-- Author: liangzhaowei
-- Date: 2017-05-08 11:33:08
-- 将军府item

local MCommonView = require("app.common.MCommonView")
local IconGoods = require("app.common.iconview.IconGoods")
local IconHero = require("app.common.iconview.IconHero")


local ItemShogunHero = class("ItemShogunHero", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数 _nIndex
function ItemShogunHero:ctor(_nIndex)
	-- body
	self:myInit()

	self.nIndex = _nIndex or 1


	parseView("item_shogun_hero", handler(self, self.onParseViewCallback))


	--注册析构方法
	self:setDestroyHandler("ItemShogunHero",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemShogunHero:myInit()
	self.pData = {} --数据
	self.nIndex = 1 --下标
	self.tIconList = {} --Icon列表
	self.nLyMainH = 0
end

--解析布局回调事件
function ItemShogunHero:onParseViewCallback( pView )

	self.pView = pView
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self.nLyMainH = self:getHeight()
	--ly    
	self.pLyIconList = self:findViewByName("ly_icon_list")
	self.pLyTitle = self:findViewByName("ly_title")
	-- self.pLyMain= self:findViewByName("ly_main")

	self:setBackgroundImage("#v1_bg_kelashen.png",{scale9 = true,capInsets=cc.rect(22,22, 1, 1)})



	--lb
	self.pLbN = self:findViewByName("lb_title")


	local nLbIn = 10052 + self.nIndex -1
	self.pLbN:setString(getConvertedStr(5, nLbIn))

	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemShogunHero:setupViews( )

end

-- 修改控件内容或者是刷新控件数据
function ItemShogunHero:updateViews(  )
	-- body
end

--析构方法
function ItemShogunHero:onDestroy(  )
	-- body
	self:cancelScheduleForOnce()
end

-- 每帧加载
function ItemShogunHero:scheduleForOnce( nMax)
    local nIndex = 1
    self.nRefreshSchedule = MUI.scheduler.scheduleUpdateGlobal(function (  )
		local tCurData = self.pData[nIndex] --当前数据
    	if self.nIndex == 1 then --上阵武将
    		if type(tCurData) == "table" then
    			if not self.tIconList[nIndex] then
    				self.tIconList[nIndex] = IconGoods.new(TypeIconGoods.HADMORE,type_icongoods_show.hero)
    				self.tIconList[nIndex].nBiaoji = nIndex
    				self.tIconList[nIndex]:setPosition(self:getPosByIndex(nIndex))
    				self.tIconList[nIndex]:setCurData(tCurData)
    				self.tIconList[nIndex]:showHeroTalent(self.bShow)
    				self.pLyIconList:addView(self.tIconList[nIndex])
    			else
    				self.tIconList[nIndex]:removeLockedState()
    				self.tIconList[nIndex]:setCurData(tCurData)
    				self.tIconList[nIndex]:showHeroTalent(self.bShow)	
    			end
    			self.tIconList[nIndex].nCliskTy = nil --英雄icon不需要这个数据
				self.tIconList[nIndex]:setIconClickedCallBack(handler(self, self.onViewClicked))
    			if self.tIconList[nIndex] then
    				self.tIconList[nIndex]:setHeroType()
    			end
    		else
    			if not self.tIconList[nIndex] then
    				self.tIconList[nIndex] = IconGoods.new(TypeIconGoods.HADMORE,type_icongoods_show.hero)
    				self.tIconList[nIndex].nCliskTy = tCurData
    				if tCurData == TypeIconHero.ADD then
						self.tIconList[nIndex]:removeLockedState()
						self.tIconList[nIndex]:setAddState()
    				else
    					self.tIconList[nIndex]:setLockedState()
    				end
					self.tIconList[nIndex]:setIconClickedCallBack(handler(self, self.onClickState))

					--如果没有可上阵武将.将加号变灰
					if not Player:getHeroInfo():bHaveHeroUp() then 
						self.tIconList[nIndex]:stopAddImgAction()
					end
    				self.tIconList[nIndex].nIndex = nIndex
    				self.tIconList[nIndex]:setPosition(self:getPosByIndex(nIndex))
    				self.pLyIconList:addView(self.tIconList[nIndex])
    			else
    				self.tIconList[nIndex].nCliskTy = tCurData
    				self.tIconList[nIndex].nIndex = nIndex
    				if tCurData == TypeIconHero.ADD then
						self.tIconList[nIndex]:removeLockedState()
						self.tIconList[nIndex]:setAddState()
    				else
    					self.tIconList[nIndex]:setLockedState()
    				end
					--如果没有可上阵武将.将加号变灰
					if not Player:getHeroInfo():bHaveHeroUp() then 
						self.tIconList[nIndex]:stopAddImgAction()
					end
					self.tIconList[nIndex]:setIconClickedCallBack(handler(self, self.onClickState))
    			end

    		end
    	else
    		if not self.tIconList[nIndex] then
    			self.tIconList[nIndex] = IconGoods.new(TypeIconGoods.HADMORE,type_icongoods_show.hero)
				self.tIconList[nIndex]:setPosition(self:getPosByIndex(nIndex))
				self.tIconList[nIndex]:setCurData(tCurData)
				self.tIconList[nIndex]:showHeroTalent(self.bShow)
				self.pLyIconList:addView(self.tIconList[nIndex])
    		else
    			self.tIconList[nIndex]:setCurData(tCurData)
				self.tIconList[nIndex]:showHeroTalent(self.bShow)
				self.tIconList[nIndex]:setPosition(self:getPosByIndex(nIndex))
    		end
			if self.tIconList[nIndex] then
				self.tIconList[nIndex]:setHeroType()
			end
    	end
    	nIndex = nIndex + 1
    	if self ~= nil and self.nRefreshSchedule ~= nil and nIndex > nMax then
           self:cancelScheduleForOnce()
    	end
    end)
end

--取消每帧加载
function ItemShogunHero:cancelScheduleForOnce(  )
	-- body
	if self.nRefreshSchedule then
		MUI.scheduler.unscheduleGlobal(self.nRefreshSchedule)
		self.nRefreshSchedule = nil
	end
end

--设置数据 _data _bShow 是否显示资质
function ItemShogunHero:setCurData(_tData,_bShow)
	if not _tData then
		return
	end

	self.bShow = _bShow or false
	self.pData = _tData or {}
	--取消每帧加载
	self:cancelScheduleForOnce()

	if self.nIndex == 1 then
		--分帧加载
		self:scheduleForOnce(table.nums(self.pData))
	else
		if not self.bHadResetSize then
			self.bHadResetSize = true
			local nFlewH = self:getChangeH(table.nums(self.pData))
			self:setLayoutSize(self:getWidth(), self.nLyMainH+nFlewH)
			self.pLyTitle:setPositionY(self:getHeight()-self.pLyTitle:getHeight())
		end
		--分帧加载
		self:scheduleForOnce(table.nums(self.pData))
	end


	

end

--获取icon的位置
function ItemShogunHero:getPosByIndex(_nIndex)
	local  pos = cc.p(0,0)

	if (not _nIndex) or _nIndex == 0 then
		return pos
	end

	--因为iocn的宽度是108 所以直接拿 108做计算
	local nFlewX = (self.pLyIconList:getWidth() - 108*4)/3 --计算icon间的间隙
	pos.y = self:getChangeH(table.nums(self.pData)) - self:getChangeH(_nIndex)
	if _nIndex % 4 == 1 then
		pos.x  = 0
	elseif _nIndex % 4 == 2 then
		pos.x  = nFlewX + 108
	elseif _nIndex % 4 == 3 then
		pos.x  = (nFlewX + 108)*2
	elseif _nIndex % 4 == 0 then
		pos.x  = (nFlewX + 108)*3
	end

	return  pos

end

--点击响应
function ItemShogunHero:onViewClicked(_pData)
	if self.nIndex == 1 then --只有上阵武将才可以接受点击响应
		if  type(_pData) == "table"  then
			local tObject = {} 
			tObject.tData = _pData --当前武将数据
			tObject.nType = e_dlg_index.heromain --dlg类型
			sendMsg(ghd_show_dlg_by_type,tObject)
		else
			-- if _pData and _pData ==  TypeIconHero.ADD then
			-- 	if _pData <= Player:getHeroInfo().nOnlineNums then
			-- 		local tObject = {}
			-- 		tObject.nType = e_dlg_index.selecthero --dlg类型
			-- 		sendMsg(ghd_show_dlg_by_type,tObject)
			-- 	end
			-- end
		end
	end
end

--点击上阵响应
function ItemShogunHero:onClickState(pData,nIndex)


	if pData == TypeIconHero.ADD then
		local tObject = {}
		tObject.nType = e_dlg_index.selecthero --dlg类型
		sendMsg(ghd_show_dlg_by_type,tObject)
	elseif pData == TypeIconHero.LOCK then
		local nTnId = 1
		if nIndex == 3 then
			nTnId   =  3010 --初级科技id
		elseif nIndex == 4 then
			nTnId   =  3020 --中级科技id
		end
		if nTnId > 1 then
			if getGoodsByTidFromDB(nTnId) then
				nTnStr = getGoodsByTidFromDB(nTnId).sName
			end 
			if nTnStr and (nTnStr~= "") then
				nTnStr = string.format(getConvertedStr(5, 10102),nTnStr)
				TOAST(nTnStr)
			end
		end
	end

end


--获取需要调整的高度
--_nIndex 下标个数
function ItemShogunHero:getChangeH(_nIndex)
	local nH = 0
	if _nIndex and _nIndex > 0 then
		nH = (math.floor((((_nIndex +3) / 4)-1)) * self.pLyIconList:getHeight())
	end
	return nH
end



return ItemShogunHero