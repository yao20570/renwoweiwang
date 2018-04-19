----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-08-10 14:34:09
-- Description: 乱军动画封装
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local WildArmyArm = class("WildArmyArm", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--nGif:乱军动画id :剑，弓，骑，3x3
function WildArmyArm:ctor( nGif )
	self.nGif = nGif
	self:myInit()
end

function WildArmyArm:myInit(  )
	self.pArmMulits = {}
	self:setContentSize(102, 70)
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("WildArmyArm", handler(self, self.onWildArmyArmDestroy))
end

-- 析构方法
function WildArmyArm:onWildArmyArmDestroy(  )
    self:onPause()
end

function WildArmyArm:regMsgs(  )
end

function WildArmyArm:unregMsgs(  )
end

function WildArmyArm:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function WildArmyArm:onPause(  )
	self:unregMsgs()
end

function WildArmyArm:setupViews(  )
end

--nGif 乱军动画id
function WildArmyArm:setData( nGif )
	if self.nGif ~= nGif then
		self.nGif = nGif
		self:updateViews()
	end
end

--刷新
function WildArmyArm:updateViews(  )
	if not self.nGif then
		return
	end

	local tArmData = WorldFunc.getWildArmyArmData(self.nGif)
	if not tArmData then
		return
	end

	-- --如果是3x3
	-- if self.nGif == 4 then
	-- 	--隐藏单个乱军动画
	-- 	if self.pArmOne then
	-- 		self.pArmOne:setVisible(false)
	-- 	end

	-- 	--显示多个乱军动画(因为当前只有3x3的，所以不用重新设置数据)
	-- 	for i=1,#self.pArmMulits do
	-- 		self.pArmMulits[i]:setVisible(true)
	-- 	end
	-- 	--需要创建
	-- 	if #self.pArmMulits == 0 then
	-- 		for i=1,#tArmData do
	-- 			local pArm =  createMArmature(self, tArmData[i] ,function (pArm)
	-- 		    end,cc.p(102/2, 70/2))
	-- 		    if pArm then
	-- 		        pArm:play(-1)
	-- 		    end
	-- 		    table.insert(self.pArmMulits, pArm)
	-- 		end
	-- 	end
	-- else
	-- 	--隐藏多个乱军动画
	-- 	for i=1,#self.pArmMulits do
	-- 		self.pArmMulits[i]:setVisible(false)
	-- 	end

		--显示单个乱军动画
		if self.pArmOne then
			self.pArmOne:setData(tArmData)
			self.pArmOne:setVisible(true)
		else
			local pArm =  createMArmature(self, tArmData ,function (pArm)
		    end,cc.p(102/2, 70/2))
		    if pArm then
		        pArm:play(-1)
		    end
		    self.pArmOne = pArm
		end
	-- end
end

function WildArmyArm:play( nLoop )
	-- if self.nGif == 4 then
	-- 	for i=1,#self.pArmMulits do
	-- 		self.pArmMulits[i]:play(nLoop)
	-- 	end
	-- else
		if self.pArmOne then
			self.pArmOne:play(nLoop)
		end
	-- end
end

function WildArmyArm:stop( )
	-- if self.nGif == 4 then
	-- 	for i=1,#self.pArmMulits do
	-- 		self.pArmMulits[i]:stop()
	-- 	end
	-- else
		if self.pArmOne then
			self.pArmOne:stop()
		end
	-- end
end


return WildArmyArm

