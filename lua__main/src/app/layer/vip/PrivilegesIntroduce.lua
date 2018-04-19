-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-2-28 20:17:23 星期一
-- Description: 特权介绍分页
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local VipPrivilegesLayer = require("app.layer.vip.VipPrivilegesLayer")
local PrivilegesIntroduce = class("PrivilegesIntroduce", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)


function PrivilegesIntroduce:ctor(_tSize, _nDefIdx)
	-- body	
	self:setContentSize(_tSize)
	self:myInit(_nDefIdx)

	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("PrivilegesIntroduce",handler(self, self.onDestroy))	
end

--初始化参数
function PrivilegesIntroduce:myInit(_nDefIdx)
	-- body
	self.nDefualtIdx = _nDefIdx	
	self.tPagGroup = nil
	self.nPrevPage = 0
	self.nVipNums = 0		
	self.tPageDot = nil	
end

--初始化控件
function PrivilegesIntroduce:setupViews( )
	--body
	self.pLayRoot = MUI.MLayer.new(true)
	self.pLayRoot:setContentSize(self:getContentSize())
	self:addView(self.pLayRoot, 0)

    self.pLayLeft = MUI.MLayer.new(true)
	self.pLayLeft:setContentSize(cc.size(30, 200))
	self.pLayLeft:setPosition(28, self:getHeight() - 350)
	self.pLayLeft:setViewTouched(true)
	self.pLayLeft:onMViewClicked(handler(self, self.onTurnLeftClick))
	self.pLayRoot:addView(self.pLayLeft, 100)

	self.pLayRight = MUI.MLayer.new(true)
	self.pLayRight:setContentSize(cc.size(30, 200))
	self.pLayRight:setPosition(588, self:getHeight() - 350)
	self.pLayRight:setViewTouched(true)
	self.pLayRight:onMViewClicked(handler(self, self.onTurnRightClick))
	self.pLayRoot:addView(self.pLayRight, 100)

	self.pImgTurnLeft = MUI.MImage.new("#v1_btn_jiantou.png", {scale9=false})	
	self.pLayLeft:addView(self.pImgTurnLeft)
	centerInView(self.pLayLeft, self.pImgTurnLeft)

	self.pImgTurnRight = MUI.MImage.new("#v1_btn_jiantou.png", {scale9=false})
	self.pImgTurnRight:setFlippedX(true)	
	self.pLayRight:addView(self.pImgTurnRight)
	centerInView(self.pLayRight, self.pImgTurnRight)

	self.pPageView = MUI.MPageView.new({viewRect = cc.rect(0, 0, self.pLayRoot:getWidth(), self.pLayRoot:getHeight())})
	self.pPageView:setCirculatory(true)
	self.pLayRoot:addView(self.pPageView, 10)	

	self.nVipNums = getAvatarVIPNum()
	self.nCurVipLv = self.nDefualtIdx or Player:getPlayerInfo().nVip	
	self.tPagGroup = {}
	self.nPrevPage = 1
	self.pPageView:loadDataAsync(3, self.nPrevPage, function ( _pView, _index )
		-- body
		--print("_index=".._index)
		local item = self.pPageView:newFillItem()
		local nviplv = self.nCurVipLv
		if  _index == 2 then
			nviplv = nviplv + 1
		elseif _index == 3 then
			nviplv = nviplv - 1
		end
		nviplv = nviplv%self.nVipNums
		local tmplayer = VipPrivilegesLayer.new(nviplv, self:getContentSize())
		tmplayer:setName("VipPrivilegesLayer")
		item:addView(tmplayer, 10)
		centerInView(item, tmplayer)
		self.tPagGroup[_index] = tmplayer
		return item
	end,function ( _pView )
		-- body
		self:updateViews()
	end)	
	self.pPageView:onTouch(function ( event )
            --dump(event, "event=", 100)
            if event.name == "pageChange" then
            	self.bChanging = false
            	local nchange = event.pageIdx - self.nPrevPage            	            	
            	if nchange == 2 or nchange == -1 then--向左
            		self.nCurVipLv = (self.nCurVipLv - 1)%self.nVipNums
        		elseif nchange == -2 or nchange == 1 then--向右
					self.nCurVipLv = (self.nCurVipLv + 1)%self.nVipNums
				else
					return
        		end
    		    local leftlv = (self.nCurVipLv - 1)%self.nVipNums
        		local rightlv = (self.nCurVipLv + 1)%self.nVipNums
        		local nleftpage = event.pageIdx - 1
        		if nleftpage == 0 then
        			nleftpage = 3
        		end        		
        		
        		local nrightpage = event.pageIdx + 1
        		if nrightpage == 4 then
					nrightpage = 1 
        		end
        		self.tPagGroup[nleftpage]:setVipLevel(leftlv)
        		self.tPagGroup[nrightpage]:setVipLevel(rightlv)
				self.nPrevPage = event.pageIdx
				self:updatePageDot(self.nCurVipLv + 1)
				sendMsg(ghd_vip_turnpage_msg, self.nCurVipLv) 				
            end
        end)
	--换页点
	if not self.tPageDot then
		self.tPageDot = {}
		for i = 1, self.nVipNums do
			local pImgDot = MUI.MImage.new("#v1_img_huanyedian1.png", {scale9=false})
			if i == self.nCurVipLv + 1 then
				pImgDot:setCurrentImage("#v1_img_huanyedian2.png")
			end
			pImgDot:setPosition(320 + (i - math.ceil(self.nVipNums/2))*15, 195)
			self.tPageDot[i] = pImgDot
			self.pLayRoot:addView(pImgDot, 50)
		end
	end        		
end

-- 修改控件内容或者是刷新控件数据
function PrivilegesIntroduce:updateViews()
	-- body		
	for k, v in pairs(self.tPagGroup) do
		v:updateViews()
	end
end

function PrivilegesIntroduce:updatePageDot( _index )
	-- body		
	for i = 1, self.nVipNums do
		if i == _index then
			self.tPageDot[i]:setCurrentImage("#v1_img_huanyedian2.png")
		else
			self.tPageDot[i]:setCurrentImage("#v1_img_huanyedian1.png")
		end
		--self.tPageDot[i]:setPosition(320 + (i - math.ceil(self.nVipNums/2))*15, 200)
	end
end

--左边翻页
function PrivilegesIntroduce:onTurnLeftClick( pview )
	-- body
	if self.bChanging then
		return
	end
	self.bChanging = true
	local nCurPageIdx = self.pPageView:getCurPageIdx()
	if nCurPageIdx - 1 == 0 then
		self.pPageView:gotoPage(3, true)
	else
		self.pPageView:gotoPage(nCurPageIdx - 1, true)
	end	
end

--右边翻页
function PrivilegesIntroduce:onTurnRightClick( pview )
	-- body	
	if self.bChanging then		
		return
	end
	self.bChanging = true
	local nCurPageIdx = self.pPageView:getCurPageIdx()
	if nCurPageIdx + 1 == 4 then
		self.pPageView:gotoPage(1, true)	
	else
		self.pPageView:gotoPage(nCurPageIdx + 1, true)
	end	
end
--析构方法
function PrivilegesIntroduce:onDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function PrivilegesIntroduce:regMsgs(  )
	-- body
	--注册玩家数据刷新消息
	regMsg(self, gud_refresh_playerinfo, handler(self, self.updateViews))	
	--vip礼包购买刷新
	regMsg(self, gud_vip_gift_bought_update_msg, handler(self, self.updateViews))	
end
--注销消息
function PrivilegesIntroduce:unregMsgs( )
	-- body
	--注销玩家数据刷新消息
	unregMsg(self, gud_refresh_playerinfo)	
	unregMsg(self, gud_vip_gift_bought_update_msg)	
end

--暂停方法
function PrivilegesIntroduce:onPause( )
	-- body
	self:unregMsgs()	
end

--继续方法
function PrivilegesIntroduce:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

return PrivilegesIntroduce