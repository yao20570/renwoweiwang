----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-20 10:03:45
-- Description: 复选框组(模拟单选)
-----------------------------------------------------
local CheckBoxGroup = class("CheckBoxGroup")

function CheckBoxGroup:ctor()
	self.pCheckBoxs = {}
end

--添加复选框
--pCheckBox:复选框控件
function CheckBoxGroup:addCheckBox( pCheckBox)
	pCheckBox:setSelected(false)
	pCheckBox:setSelectedHandler(handler(self, self.onCheckBoxClicked))
	table.insert(self.pCheckBoxs, pCheckBox)
end

--注册点击回调函数
--pFunc 回调方法
function CheckBoxGroup:setClickedCallBack( pFunc )
	self.clickedCallBack = pFunc
end

--设置点击
--nIndex:下标
function CheckBoxGroup:setClickedByIndex( nIndex)
	local pCheckBox = self.pCheckBoxs[nIndex]
	if pCheckBox then
		self:onCheckBoxClicked(pCheckBox)
	end
end

--点击
function CheckBoxGroup:onCheckBoxClicked( pCheckBox )
	self.pPrevCheckBox = pCheckBox
	--将其他设为负
	for i=1,#self.pCheckBoxs do
		local pOtherCheckBox = self.pCheckBoxs[i]
		if pOtherCheckBox ~= pCheckBox then
			pOtherCheckBox:setSelected(false)
		else
			self.nClikedIndex = i
			pCheckBox:setSelected(true)
		end
	end
	--回调
	if self.clickedCallBack then
		self.clickedCallBack(pCheckBox)
	end
end

--获取当前点击的下标
function CheckBoxGroup:getCurrentIndex(  )
	return self.nClikedIndex
end

return CheckBoxGroup