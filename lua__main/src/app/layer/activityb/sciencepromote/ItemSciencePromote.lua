----------------------------------------------------- 
-- author: xiesite
-- updatetime: 2018-03-06 10:30:31
-- Description: 科技兴国item
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local IconGoods = require("app.common.iconview.IconGoods")
					
local ItemSciencePromote = class("ItemSciencePromote", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemSciencePromote:ctor( )
	-- body
	self:myInit()
	parseView("item_science_promote", handler(self, self.onParseViewCallback))
end

--解析布局回调事件
function ItemSciencePromote:onParseViewCallback( pView )
	self.pView = pView
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemSciencePromote",handler(self, self.onDestroy))
end

--初始化成员变量
function ItemSciencePromote:myInit( )
end


function ItemSciencePromote:regMsgs( )
end

function ItemSciencePromote:unregMsgs( )
end

function ItemSciencePromote:onResume( )
	self:regMsgs()
end

function ItemSciencePromote:onPause( )
	self:unregMsgs()
end

function ItemSciencePromote:setupViews( )
 	self.pLbTitle = self:findViewByName("lb_title") --标题
 	self.pLyList = self:findViewByName("ly_list") --列表层

 	self.pLbState = self:findViewByName("lb_state") --列表层
 	self.pImgGet = self:findViewByName("img_get") --领取图标
 	self.pImgGet:setVisible(false)

 	self.pLyBtn = self:findViewByName("ly_btn") --按钮
 	self.pBtn = getCommonButtonOfContainer(self.pLyBtn, TypeCommonBtn.M_YELLOW)
 	self.pBtn:onCommonBtnClicked(handler(self, self.onClicked))
end

--析构方法
function ItemSciencePromote:onDestroy( )
	-- body
	self:onPause()
end

function ItemSciencePromote:updateViews(  )
	if not self.tData then
		return
	end
	if self.tData.aw then
		sortGoodsList(self.tData.aw)
		self:setGoodsListViewData(getRewardItemsFromSever(self.tData.aw))
	end

	-- 1为升级科技等级，2为升级科技院等级，3为升级主公等级，4为升级科技进度
	local sStr = ""
	if self.tData.type == 1 then
		if self.tData.scid then
			local tTnoly = getTnolyByIdFromDB(self.tData.scid)
			if tTnoly then
				sStr = string.format(getConvertedStr(1,10379),tTnoly.sName,self.tData.targe)
			end
		end
	elseif self.tData.type == 2 then
		sStr = string.format(getConvertedStr(1,10380),self.tData.targe)
	elseif self.tData.type == 3 then
		sStr = string.format(getConvertedStr(1,10381),self.tData.targe)
	elseif self.tData.type == 4 then
		if self.tData.scid then
			local tTnoly = getTnolyByIdFromDB(self.tData.scid)
			if tTnoly then
				sStr = string.format(getConvertedStr(1,10382),tTnoly.sName,self.tData.targe)
			end
		end
	end
	self.pLbTitle:setString(sStr)

	local tData = Player:getActById(e_id_activity.sciencepromote)
	local nCur = tData:getFiById(self.tData.i)
	self.pLbState:setString(nCur.."/"..self.tData.targe)


	--是否已经完成
	local bFinish = tData:isFinish(self.tData.i)
	self.pImgGet:setVisible(false)
	if bFinish then
		--是否已经领取
		if tData:isGet(self.tData.i) then
			self.pImgGet:setVisible(true)
			self.pBtn:setVisible(false)
			self.pLbState:setVisible(false)
		else
			self.pBtn:setVisible(true)
			self.pLbState:setVisible(true)
			self.pBtn:updateBtnType(TypeCommonBtn.M_YELLOW)
  			self.pBtn:updateBtnText(getConvertedStr(1,10137))
		end
	else
		self.pBtn:setVisible(true)
		self.pLbState:setVisible(true)
		self.pBtn:updateBtnType(TypeCommonBtn.M_BLUE)
  		self.pBtn:updateBtnText(getConvertedStr(3,10367))
	end
end

--列表项回调
function ItemSciencePromote:onGoodsListViewCallBack( _index, _pView )
	-- body
	local tTempData = self.tDropList[_index]
    local pTempView = _pView
	if pTempView == nil then
		pTempView = IconGoods.new(TypeIconGoods.HADMORE)--HADMORE
		pTempView:setIconIsCanTouched(true)
		
	end
	pTempView:setCurData(tTempData) 

	pTempView:setMoreTextColor(getColorByQuality(tTempData.nQuality))
	pTempView:setNumber(tTempData.nCt)
	pTempView:setScale(0.8)
	pTempView:setContentSize(cc.size(108*0.8, 108*0.8))
    return pTempView
end

--设置数据
-- tDropList:List<Pair<Integer,Long>>
function ItemSciencePromote:setGoodsListViewData( tDropList )
	if not tDropList then
		return
	end
 	
	self.tDropList = tDropList
	local nCurrCount = #self.tDropList
	--容错
	if not self.pListView then
		local pLayGoods = self.pLyList
		self.pListView = MUI.MListView.new {
		     	viewRect   = cc.rect(0, 0, pLayGoods:getContentSize().width, pLayGoods:getContentSize().height),
		        direction  = MUI.MScrollView.DIRECTION_HORIZONTAL,
		        itemMargin = {left = 0,
		            right = 10 ,
		            top = 17,
		            bottom = 0},
		}
		pLayGoods:addView(self.pListView)
		centerInView(pLayGoods, self.pListView )
		self.pListView:setItemCallback(handler(self, self.onGoodsListViewCallBack))
		self.pListView:setItemCount(nCurrCount)
		self.pListView:reload(true)
	else
		self.pListView:notifyDataSetChange(true, nCurrCount)
		local oldY = self.pListView.container:getPositionY()
		self.pListView:scrollTo(0, oldY, false)
	end

end

function ItemSciencePromote:setCurData( _tData )
	self.tData = _tData
	self:updateViews()
end

function ItemSciencePromote:onClicked( )
	local tData = Player:getActById(e_id_activity.sciencepromote)
	--是否已经完成
	local bFinish = tData:isFinish(self.tData.i)
	if bFinish then
		--还没领取
		if not tData:isGet(self.tData.i) then
			SocketManager:sendMsg("sciencepromote", {self.tData.i}, function(__msg)
				-- dump(__msg, "__msg")
				if  __msg.head.state == SocketErrorType.success then 
				    if __msg.head.type == MsgType.sciencepromote.id then
				       	if __msg.body.ob then
							--获取物品效果
							showGetItemsAction(__msg.body.ob)
				       	end
				    end
				else
				    --弹出错误提示语
				    TOAST(SocketManager:getErrorStr(__msg.head.state))
				end
			end)
		end
	else
		if self.tData.type == 1 or self.tData.type == 4 then
			local tBuildInfo = Player:getBuildData():getBuildByCell(e_build_cell.tnoly)
			if tBuildInfo and tBuildInfo:getIsLocked() then
				local tBuildData = getBuildDatasByTid(e_build_ids.tnoly)
				if tBuildData then
					TOAST(getConvertedStr(7, 10149))
				end
				return
			end
			local nScid = self.tData.scid
		    local tObject = {}
			tObject.nType = e_dlg_index.tnolytree 	--跳转到科技树界面, 相对应的科技
			tObject.tData = getGoodsByTidFromDB(nScid)
			sendMsg(ghd_show_dlg_by_type,tObject)

		elseif self.tData.type == 2 then
			local tBuildInfo = Player:getBuildData():getBuildByCell(e_build_cell.tnoly)
			if tBuildInfo and tBuildInfo:getIsLocked() then
				local tBuildData = getBuildDatasByTid(e_build_ids.tnoly)
				if tBuildData then
					TOAST(getConvertedStr(7, 10149))
				end
				return
			end
			closeDlgByType(e_dlg_index.sciencepromote)
			closeDlgByType(e_dlg_index.actmodelb)

			local tObject = {}
			tObject.nType = e_dlg_index.buildlvup --dlg类型
			tObject.nFromWhat = self.nFromWhat or 0 --1,2表示从左对联进来的
			tObject.nCell = 3
			sendMsg(ghd_show_dlg_by_type,tObject)
			--发送消息放大基地
			local tOb = {}
			tOb.nType = 1
			tOb.nCell = 3
			sendMsg(ghd_scale_for_buildup_dlg_msg,tOb)
			--发送hometop界面调整消息
			local tmsgObj = {}
			tmsgObj.nType = 1
			sendMsg(ghd_home_change_for_buildup_msg, tmsgObj)

		elseif self.tData.type == 3 then
			local bIsOpen = getIsReachOpenCon(2)
			if not bIsOpen then
				return
			end
			local tObject = {}
			tObject.nType = e_dlg_index.fubenmap 	--跳到副本
			sendMsg(ghd_show_dlg_by_type,tObject)

 		end
	end
end

return ItemSciencePromote


