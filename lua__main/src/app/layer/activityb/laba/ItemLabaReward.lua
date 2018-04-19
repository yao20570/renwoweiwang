----------------------------------------------------- 
-- author: luwenjing
-- updatetime: 2018-01-15 10:01:20
-- Description: 拉霸奖励预览子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local IconGoods = require("app.common.iconview.IconGoods")

local ItemLabaReward = class("ItemLabaReward", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemLabaReward:ctor(  )
	--解析文件
	parseView("item_laba_reward", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemLabaReward:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	self:myInit()
	self:setupViews()

	--注册析构方法
	self:setDestroyHandler("ItemLabaReward", handler(self, self.onItemLabaRewardDestroy))
end

-- 析构方法
function ItemLabaReward:onItemLabaRewardDestroy(  )
end

function ItemLabaReward:setupViews(  )

	self.pImgTitle = self:findViewByName("img_title")

	for i=1,3 do
		local pLayIcon = self:findViewByName("lay_icon" .. i)
		table.insert(self.tLayIcons,pLayIcon)
	end

	self.pLayResult = self:findViewByName("lay_reault")
end

function ItemLabaReward:myInit(  )
	-- body
	-- self.sIcon = ""
	self.tLayIcons={} 
end

function ItemLabaReward:updateViews(  )
	-- body
	for i = 1,3 do
		self.tLayIcons[i]:setVisible(true)
	end
	local tParam = luaSplit(self.tData, ";")
	if tParam and #tParam>0 then
		local sIcon ="#"..tParam[3]..".png"
		local nIndex = 4 - tonumber(tParam[2])
		for i=1, nIndex do
			local pNewIcon = self.tLayIcons[i]:findViewByName("icon")
			if not pNewIcon then
				local pNewIcon =  MUI.MImage.new(sIcon)
				pNewIcon:setName("icon")
				pNewIcon:setPosition(self.tLayIcons[i]:getWidth()/2,self.tLayIcons[i]:getHeight()/2)
				self.tLayIcons[i]:addChild(pNewIcon)
			else
				pNewIcon:setCurrentImage(sIcon)
			end
			
		end
		for i = nIndex +1,3 do
			self.tLayIcons[i]:setVisible(false)
		end

	    local pResult = IconGoods.new(TypeIconGoods.NORMAL)
	    pResult:setAnchorPoint(0.5,0.5)
	    pResult:setPosition(self.pLayResult:getWidth()/2,self.pLayResult:getHeight()/2)
	   	-- centerInView(self.pLayResult,pResult)
	    self.pLayResult:addView(pResult)
	    pResult:setIconScale(0.8)
	    local tRewardData = luaSplit(tParam[4],":")
	    if tRewardData then

	    	local pItemData = getGoodsByTidFromDB(tRewardData[1])
		    if pItemData then
	            pResult:setCurData(pItemData)
	            -- pIcon:setMoreText(pItemData.sName)
	            -- pIcon:setMoreTextColor(_cc.pwhite)
	        end
	        pResult:setNumber(tonumber(tRewardData[2]))
	    end
	end
	
end

function ItemLabaReward:setData( _tData )
	-- body
	self.tData=_tData or self.tData
	self:updateViews()

end

return ItemLabaReward


