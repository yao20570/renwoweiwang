-----------------------------------------------------
-- author: luwenjing
-- updatetime:  2017-12-09 15:56:17 星期六
-- Description: 武将游历队伍item
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local MBtnExText = require("app.common.button.MBtnExText")
local MImgLabel = require("app.common.button.MImgLabel")

local ItemHeroTravel = class("ItemHeroTravel", function ()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--构造
function ItemHeroTravel:ctor(_tData)
	-- body
	self.tTravelData=_tData
	parseView("item_hero_travel", handler(self, self.onParseViewCallback))
end
  
--解析布局回调事件
function ItemHeroTravel:onParseViewCallback( pView )
	-- body
	
	self:addView(pView)
	self:setupViews()
	self:updateViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("ItemHeroTravel",handler(self, self.onItemHeroTravelDestroy))
end

--初始化控件
function ItemHeroTravel:setupViews()
	-- body
	self.pLayHeroIcon=self:findViewByName("lay_hero_icon")
	self.pLayCostContent=self:findViewByName("lay_cost_content")
	self.pLayTimeContent=self:findViewByName("lay_time_content")
	self.pLayTimeContent:setVisible(false)
	self.pLayCost=self:findViewByName("lay_cost")
	self.pTxtDesc=self:findViewByName("txt_desc")
	setTextCCColor(self.pTxtDesc, _cc.pwhite)

	
	local pTxtCostTitle=self:findViewByName("txt_cost_title")
	pTxtCostTitle:setString(getConvertedStr(9,10044))
	setTextCCColor(pTxtCostTitle, _cc.pwhite)

	local pTxtRewardTitle=self:findViewByName("txt_reward_title")
	pTxtRewardTitle:setString(getConvertedStr(9,10041))
	setTextCCColor(pTxtRewardTitle, _cc.pwhite)
	-- self.pTxtRewardTitle2=self:findViewByName("txt_reward_title2")
	local pLayBtn=self:findViewByName("lay_btn")
	self.pLayRewardContent=self:findViewByName("lay_reward_content")
	self.pBtn = getCommonButtonOfContainer(pLayBtn, TypeCommonBtn.M_BLUE, getConvertedStr(9, 10042), false)
	self.pBtn:onCommonBtnClicked(handler(self, self.onBtnClick))
	
end

-- 修改控件内容或者是刷新控件数据
function ItemHeroTravel:updateViews()
	-- body
	if self.tTravelData and self.tTravelData.tHeroData then
		local tDbData=getHeroTravelData(self.tTravelData.nTaskId)
		local pLyHeroBg = creatHeroView(self.tTravelData.tHeroData.sImg,2)
    	self.pLayHeroIcon:addView(pLyHeroBg)
    	pLyHeroBg:adjustToScale(self.pLayHeroIcon)
    	if tDbData then
    		local sStr=string.format(tDbData.describe,self.tTravelData.tHeroData.sName,self.tTravelData.tHeroData.sName)  --配表有两个名字的情况
    		self.pTxtDesc:setString(sStr)

	    	local tReward=getGoodsByTidFromDB(tDbData.tDropItem.k)
	    	if tReward then
		    	--奖励文字
		    	if self.pRewardImgLabel then
		    		self.pRewardImgLabel:remove()
		    		self.pRewardImgLabel=nil
		    	end
		  --   	if not self.pRewardImgLabel then
		    		
				-- end
				self.pRewardImgLabel = MImgLabel.new({text="", size = 18, parent = self.pLayRewardContent,color = getC3B(getColorByQuality(tReward.nQuality))})
		    	self.pRewardImgLabel:followPos("left", 0, self.pLayRewardContent:getContentSize().height/2, 5)
				local pTempImg=MUI.MImage.new(tReward.sIcon)  		--只为了拿icon的宽高
				local nScale=29/pTempImg:getHeight()
				self.pRewardImgLabel:setImg(tReward.sIcon, nScale, "left")
				self.pRewardImgLabel:setString(string.format("%s *%s",tReward.sName,getResourcesStr(tDbData.tDropItem.v)))
			end
			local tCost=getGoodsByTidFromDB(tDbData.tCostItem.k)
			if tCost then
		    	--花费文字
		    	self.pLayCost:setVisible(true)
		    	if not self.pCostImgLabel then

					self.pCostImgLabel = MImgLabel.new({text="", size = 18, parent = self.pLayCostContent})
					
					
				end
				self.pCostImgLabel:showImg()
				if tonumber(tDbData.tCostItem.v) >0 then
					self.pCostImgLabel:followPos("left", 0, self.pLayCostContent:getContentSize().height/2, 5)
					self.pCostImgLabel:setImg(tCost.sIcon, 0.4, "left")
					self.pCostImgLabel:setString(tostring(getResourcesStr(tDbData.tCostItem.v)))
				else
					self.pCostImgLabel:hideImg()
					self.pCostImgLabel:setString(getConvertedStr(9,10052))
					self.pCostImgLabel:followPos("left", 0, self.pLayCostContent:getContentSize().height/2,0)
				end
				
			end
			if Player:getHeroTravelData():getTraveLeftTime(self.tTravelData.nQueueId) >0 then
				self.pBtn:updateBtnType(TypeCommonBtn.M_BLUE)

				self.pBtn:updateBtnText(getConvertedStr(9,10043))
				self.pBtn:setBtnEnable(false)
				self.pLayCost:setVisible(false)
				self.pLayTimeContent:setVisible(true)
				regUpdateControl(self, handler(self, self.onUpdateTime))		--注册更新倒计时
			elseif self.tTravelData.nCd == 0 or Player:getHeroTravelData():getTraveLeftTime(self.tTravelData.nQueueId) ==0 then 
				self.pBtn:updateBtnType(TypeCommonBtn.M_YELLOW)
				self.pBtn:updateBtnText(getConvertedStr(5,10208))
				self.pBtn:setBtnEnable(true)

				
				self.pLayTimeContent:setVisible(false)
				self.pLayCost:setVisible(false)

				unregUpdateControl(self)
			else 
				self.pBtn:updateBtnType(TypeCommonBtn.M_BLUE)
				self.pBtn:updateBtnText(getConvertedStr(9,10042))
				self.pBtn:setBtnEnable(true)

				self.pLayCost:setVisible(true)
				self.pLayTimeContent:setVisible(false)
			end
		end
	end

end
function ItemHeroTravel:setData( _tData )
	-- body
	self.tTravelData=_tData or self.tTravelData
	self:updateViews()
end
function ItemHeroTravel:onBtnClick( pView )
	-- body
	
	if self.tTravelData.nCd <0 then 		--未开始游历
		local tDbData=getHeroTravelData(self.tTravelData.nTaskId)
		if not getIsResourceEnough(tDbData.tCostItem.k,tDbData.tCostItem.v ) then
			local tResList = {}
			tResList[e_resdata_ids.lc] = 0
			tResList[e_resdata_ids.bt] = 0
			tResList[e_resdata_ids.mc] = 0
			tResList[e_resdata_ids.yb] = 0
			tResList[tonumber(tDbData.tCostItem.k)] = tonumber(tDbData.tCostItem.v)
			goToBuyRes(tonumber(tDbData.tCostItem.k), tResList)
			return
		end
		SocketManager:sendMsg("startHeroTravel", {tonumber(self.tTravelData.tHeroData.nId),tonumber(self.tTravelData.nQueueId)})
	elseif self.tTravelData.nCd == 0 or Player:getHeroTravelData():getTraveLeftTime(self.tTravelData.nQueueId) ==0 then
		SocketManager:sendMsg("HeroTravelFinish", {tonumber(self.tTravelData.nQueueId)})
	end

end

function ItemHeroTravel:onUpdateTime( )
	-- body
	if Player:getHeroTravelData():getTraveLeftTime(self.tTravelData.nQueueId) >0 then
		if not self.pTimeImgLabel then
			self.pTimeImgLabel = MImgLabel.new({text="", size = 18, parent = self.pLayTimeContent})
					
			self.pTimeImgLabel:followPos("left", 0, self.pLayTimeContent:getContentSize().height/2, 5)
		end
		self.pTimeImgLabel:setImg("#v1_img_shizhong.png", 1, "left")
		self.pTimeImgLabel:setString(formatTimeToHms(Player:getHeroTravelData():getTraveLeftTime(self.tTravelData.nQueueId)),false)
	else
		self:updateViews()
		unregUpdateControl(self)--停止计时刷新
	end
end

function ItemHeroTravel:onUpdateData( sMsgName, pMsgObj )
	-- body
	local nQid =pMsgObj.nQid
	if nQid then
		if nQid== self.tTravelData.nQueueId then
			self.tTravelData=Player:getHeroTravelData():getTraveDataByQId(nQid)
			self:updateViews()
		end
	end
end

--析构方法
function ItemHeroTravel:onItemHeroTravelDestroy()
	
end

-- 注册消息
function ItemHeroTravel:regMsgs( )
	-- body
	regMsg(self, ghd_hero_travel_update, handler(self, self.onUpdateData))


end

-- 注销消息
function ItemHeroTravel:unregMsgs(  )
	-- body
	unregMsg(self, ghd_hero_travel_update)

end


--暂停方法
function ItemHeroTravel:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function ItemHeroTravel:onResume( )
	-- body
	self:regMsgs()
end



return ItemHeroTravel
