----------------------------------------------------- 
-- author: maheng
-- updatetime: 2018-1-31 17:03:14
-- Description: 主界面增益buff
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local HomeBuffsLayer = class("HomeBuffsLayer", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)


function HomeBuffsLayer:ctor(  )
	-- body
	self:myInit()
	parseView("layout_home_buffs", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function HomeBuffsLayer:myInit(  )
	-- body
	--动画特效

end

--解析布局回调事件
function HomeBuffsLayer:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("HomeBuffsLayer",handler(self, self.onDestroy))
end

--初始化控件
function HomeBuffsLayer:setupViews( )
	-- body
	self.pLayRoot = self:findViewByName("lay_default")
	self.pLbTip = self:findViewByName("lb_tip")
	self.pLbTip:setString(getConvertedStr(3, 10557), false) 
	
	--增益道具其本图片
	local sBuffItem = getDisplayParam("buffItem")
	local tBuffItem = luaSplit(sBuffItem, ";")
	local tImgBuff = {}
	local nX, nY = self.pLbTip:getWidth() + 6, 13
	local nOffsetX = 5
	for i=1,#tBuffItem do
		local nId = tonumber(tBuffItem[i])
		if nId then
			local tItem = getGoodsByTidFromDB(nId)
			if tItem then
				local nBuffId = tItem:getVipBuffId(Player:getPlayerInfo().nVip)
				if nBuffId then
					local tBuff = getBuffDataByIdFromDB(nBuffId)
					if tBuff then						
						local pImgBg = MUI.MImage.new("#v1_img_shuruA.png")
						pImgBg:setScale(0.8)
						pImgBg:setPosition(nX, nY)
						self.pLayRoot:addView(pImgBg, 10)
						local pImg = MUI.MImage.new(tBuff.sIcon)
						pImg:setScale(0.8)
						tImgBuff[nBuffId] = pImg
						self.pLayRoot:addView(pImg, 15)
						pImg:setPosition(nX, nY)
						nX = nX + pImg:getContentSize().width*0.8 + nOffsetX
					end
				end
			end
		end
	end
	self.tImgBuff = tImgBuff	


	self:setViewTouched(true)
	self:setIsPressedNeedScale(false)
	self:setIsPressedNeedColor(false)
	self:onMViewClicked(function ( _pView )
	    local tObject = {
		    nType = e_dlg_index.dlgbuffs, --dlg类型
		}
		sendMsg(ghd_show_dlg_by_type, tObject)
	end)	
end

-- 修改控件内容或者是刷新控件数据
function HomeBuffsLayer:updateViews( )
	-- body
	for nBuffId, pImg in pairs(self.tImgBuff) do
		local tVo = Player:getBuffData():getBuffVo(nBuffId)
		if tVo then
			pImg:setToGray(false)
		else
			pImg:setToGray(true)
		end
	end
end

--设置背景
function HomeBuffsLayer:setBgVisible(_bVisible)
	if _bVisible then
		self.pLayRoot:setBackgroundImage("#v1_img_black50.png",{scale9 = true,capInsets=cc.rect(10,10, 1, 1)})		
	else
		self.pLayRoot:setBackgroundImage("ui/daitu.png",{scale9 = true,capInsets=cc.rect(10,10, 1, 1)})
	end
	
end
-- 析构方法
function HomeBuffsLayer:onDestroy(  )
	-- body
end

function HomeBuffsLayer:regMsgs(  )
	--注册buff刷新消息
	regMsg(self, gud_buff_update_msg, handler(self, self.updateViews))
end

function HomeBuffsLayer:unregMsgs(  )
	--注销buff刷新消息
	unregMsg(self, gud_buff_update_msg)
end

function HomeBuffsLayer:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function HomeBuffsLayer:onPause(  )
	self:unregMsgs()
end

return HomeBuffsLayer


