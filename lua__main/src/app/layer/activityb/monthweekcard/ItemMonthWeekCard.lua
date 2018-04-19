----------------------------------------------------- 
-- author: xiesite
-- updatetime: 2018-02-27 16:30:31
-- Description: 月卡周卡item
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
					
local ItemMonthWeekCard = class("ItemMonthWeekCard", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemMonthWeekCard:ctor( )
	-- body
	self:myInit()
	parseView("item_month_week_card", handler(self, self.onParseViewCallback))
end

--解析布局回调事件
function ItemMonthWeekCard:onParseViewCallback( pView )
	self.pView = pView
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemMonthWeekCard",handler(self, self.onDestroy))
end
--初始化成员变量
function ItemMonthWeekCard:myInit(  )
	-- body	 
end


function ItemMonthWeekCard:regMsgs(  )
    -- 注册玩家数据变化的消息
	regMsg(self, gud_refresh_playerinfo, handler(self, self.updateViews))	
end

function ItemMonthWeekCard:unregMsgs(  )
	-- 销毁玩家数据变化的消息
	unregMsg(self, gud_refresh_playerinfo)
end

function ItemMonthWeekCard:onResume(  )
	self:regMsgs()
end

function ItemMonthWeekCard:onPause(  )
	self:unregMsgs()
end


function ItemMonthWeekCard:onItemPeopleRebateGetRewardDestroy(  )
	self:onPause()
end

function ItemMonthWeekCard:setupViews( )

	self.pLyBg = self:findViewByName("ly_bg")
	self.pLyBg:setViewTouched(true)
	self.pLyBg:setIsPressedNeedScale(false)
	self.pLyBg:onMViewClicked(handler(self, self.clickTip))

 	self.pImgIcon = self:findViewByName("img_icon")
 	self.pImgTitle = self:findViewByName("img_title")

 	self.pLbTips1 = self:findViewByName("lb_tips_1")
 	self.pLbTips1:setString("pLbTips1")
 	setTextCCColor(self.pLbTips1, "e3d065")
    
    self.pLbTips2 = self:findViewByName("lb_tips_2")
    self.pLbTips2:setString("pLbTips2")
    self.pLbTips3 = self:findViewByName("lb_tips_3")
    self.pLbTips3:setString("pLbTips3")
 		
 	self.pLbCD = self:findViewByName("lb_cd")
 	self.pLbCD:setString("pLbCD")
 	self.pLbCD:setVisible(false)
 	--lb_cd 

 	self.pLyBtn = self:findViewByName("ly_btn")
 	self.pBtn = getCommonButtonOfContainer(self.pLyBtn, TypeCommonBtn.M_YELLOW, getConvertedStr(7, 10292))
 	self.pBtn:onCommonBtnClicked(handler(self, self.onClicked))

 	regUpdateControl(self, handler(self, self.updateCd))
end

function ItemMonthWeekCard:clickTip()
	local tObject = {}
	tObject.nType = e_dlg_index.cardTips --dlg类型
	tObject.tData = self.tData
	sendMsg(ghd_show_dlg_by_type,tObject)
end

function ItemMonthWeekCard:setImgInfo()
	local tData = Player:getActById(e_id_activity.monthweekcard)
	if not tData then
		return
	end
	local tImgs = luaSplitMuilt( tData.sRule,";",",")
	local tImg = {}
	if tImgs then
		for k, v in ipairs(tImgs) do
			if v[1] == self.tData.id or v[1] == self.tData.id.."" then
				tImg = v
				break;
			end
		end
	end

	if tImg[2] and tImg[3] then
		self.pImgIcon:setCurrentImage("#"..tImg[3]..".png")
		self.pImgTitle:setCurrentImage("#"..tImg[2]..".png")
	else
		self.pImgIcon:setCurrentImage("#v2_img_yueka.png")
		self.pImgTitle:setCurrentImage("#v2_fonts_huangjinyueka.png")
	end
end

function ItemMonthWeekCard:updateCd()
	local tData = Player:getActById(e_id_activity.monthweekcard)
	if not tData then
		return
	end
	local cd = tData:getCdLeft(self.tData.id)
	if cd and cd > 0 then
		self.pLbCD:setVisible(true)
		local str = string.format(getConvertedStr(1, 10371), getTimeLongStr(cd,false,true,false))
		self.pLbCD:setString(str)
	else
		self.pLbCD:setVisible(false)
	end
end

--析构方法
function ItemMonthWeekCard:onDestroy( )
	unregUpdateControl(self)
	self:onPause()
end


function ItemMonthWeekCard:updateViews(  )
	local tData = Player:getActById(e_id_activity.monthweekcard)
	if not self.tData or not tData then
		return
	end
 	self:setImgInfo()
 	self.pLbTips3:setString(string.format(getConvertedStr(1,10367), self.tData.day))
 	--对应商品项的数据
 	local tChargeInfo = getRechargeDataByKey(self.tData.pid)
 	self.pBtn:updateBtnText(string.format(getConvertedStr(7,10292), tChargeInfo.price))
 	self.pLbTips2:setString(string.format(getConvertedStr(1,10368), tChargeInfo.gold))


 	local bHave = tData:haveGetCar(self.tData.id)
 	if bHave then
 		self.pLbTips3:setVisible(false)
 		self.pBtn:updateBtnText(getConvertedStr(1,10178))
 	else
 		self.pLbTips3:setVisible(true)
 		self.pBtn:updateBtnText(string.format(getConvertedStr(7,10292), tChargeInfo.price))
 	end

 	self:updateCd()
 	self:updateGetBack()
end

--返利设置
function ItemMonthWeekCard:updateGetBack()
	if not self.tData then
		return
	end
	local tAwards = self.tData.awards
	local nLv = Player:getPlayerInfo().nLv
	local tAward = nil
	for k,v in ipairs(tAwards) do
		if v["start"] <= nLv and v["end"] >= nLv then
		 	tAward = v.award
		 	break
		end
	end
	local sAwardStr = ""

	if tAward then
		for index, value in ipairs(tAward) do
			local num = value.v*self.tData.day
			--黄金
			if value.k == e_type_resdata.money then
				sAwardStr = getConvertedStr(6, 10103)
			elseif value.k == e_type_resdata.energy then
				sAwardStr = getConvertedStr(1, 10378)
			elseif value.k == e_type_resdata.food then
				sAwardStr = getConvertedStr(3, 10578)
			elseif value.k == e_type_resdata.coin then
				sAwardStr = getConvertedStr(7, 10045)
			elseif value.k == e_type_resdata.wood then 
			 	sAwardStr = getConvertedStr(7, 10046)
			elseif value.k == e_type_resdata.iron then
				sAwardStr = getConvertedStr(3, 10547)
			elseif value.k == e_type_resdata.infantry then
				sAwardStr = getConvertedStr(1, 10081)
			elseif value.k == e_type_resdata.sowar then
				sAwardStr = getConvertedStr(1, 10082)
			elseif value.k == e_type_resdata.archer then
				sAwardStr = getConvertedStr(1, 10083)
			else
				if getBaseItemDataByID(value.k) and getBaseItemDataByID(value.k).sName then
					sAwardStr = getConvertedStr(1,10370)..getBaseItemDataByID(value.k).sName
				end
			end
			sAwardStr = num..sAwardStr
			if index < table.nums(tAward) then
				sAwardStr = sAwardStr.."," 
			end
		end
		local sStr = getConvertedStr(1,10369)..sAwardStr
		self.pLbTips1:setString(sStr) 
	end
end

function ItemMonthWeekCard:setCurData( _tData )
	self.tData = _tData
	self:updateViews()
end

function ItemMonthWeekCard:onClicked(  )
	local tData = Player:getActById(e_id_activity.monthweekcard)
	if not self.tData or not tData then
		return
	end
	--领取奖励
	local bHave = tData:haveGetCar(self.tData.id)
	if bHave then
		SocketManager:sendMsg("monthweekcard", {self.tData.pid}, function(__msg)
			-- dump(__msg, "__msg")
		    if  __msg.head.state == SocketErrorType.success then 
		        if __msg.head.type == MsgType.monthweekcard.id then
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
	else
		if self.tData.pid then
	 		local tData = getRechargeDataByKey(self.tData.pid)
			if tData then
				reqRecharge(tData)
			end
	 	end
	end


end

return ItemMonthWeekCard


