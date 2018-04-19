----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-22 18:01:30
-- Description: 侦查邮件 武将列表
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemDetectMailCityHero = require("app.layer.mail.ItemDetectMailCityHero")

local DetectMailCityHero = class("DetectMailCityHero", function( pSize )
	local pView = MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
	pView:setContentSize(pSize)
	return pView
end)

--tScoutHeroInfos
function DetectMailCityHero:ctor( pSize, tScoutHeroInfos )
	self.tScoutHeroInfos = tScoutHeroInfos

	self.pListView = MUI.MListView.new {
		viewRect   = cc.rect(0, 0, pSize.width, pSize.height - 10),
		direction  = MUI.MScrollView.DIRECTION_VERTICAL,
		itemMargin = {left = 0,
             right =  0,
             top =  0,
             bottom =  10},
    }
    self:addView(self.pListView)
	
	self.pListView:setItemCallback(function ( _index, _pView ) 
	    local pTempView = _pView
	    local pTempData = self.tScoutHeroInfos[_index]
	    if pTempView == nil then
	    	pTempView   = ItemDetectMailCityHero.new()
		end
		pTempView:setData(pTempData)
	    return pTempView
	end)

	--数量
	self.pListView:setItemCount(#self.tScoutHeroInfos)
	-- 载入所有展示的item
	self.pListView:reload()
end

-- 析构方法
function DetectMailCityHero:onDetectMailCityHeroDestroy(  )
    self:onPause()
end

function DetectMailCityHero:regMsgs(  )
end

function DetectMailCityHero:unregMsgs(  )
end

function DetectMailCityHero:onResume(  )
	self:regMsgs()
end

function DetectMailCityHero:onPause(  )
	self:unregMsgs()
end

function DetectMailCityHero:setupViews(  )
end

function DetectMailCityHero:updateViews(  )
end

return DetectMailCityHero


