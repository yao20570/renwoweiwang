--
-- Author: liangzhaowei
-- Date: 2017-06-28 14:32:11
-- 红点展示

local MRedNums = require("app.common.rednums.MRedNums")



-- 显示红点提示 (26*26)
-- pView（MView）：当前用于存放红点布局的父控件
-- nType（int）：0代表不需要显示数量，1代表需要显示数量
-- nCount（int）：当前显示多少数量，当为0时不展示
-- nPosTy(int) : 1代表父层的中心(默认) 2代表父层的右上角(只允许没有扩大点击范围的按钮上用) 3红点中心方在父层右上角
-- return (MRedNums): 返回红点提示的布局
function showRedTips( pView,nType,nCount,nPosTy)

	local nCenTy = 1
	local pRedNums = nil
	--位置类型
	if not nPosTy then
		nCenTy = 1
	else
		nCenTy = nPosTy
	end

	if(pView) then
		local nTag = 91974
		pRedNums = pView:findViewByTag(nTag)
		if(not pRedNums) then
			pRedNums = MRedNums.new(nType)
			pView:addView(pRedNums,99)
			pRedNums:setTag(nTag)
			if nCenTy == 2 then				
				pRedNums:setPosition(pView:getWidth()-pRedNums:getWidth(), pView:getHeight()-pRedNums:getHeight())
			elseif nCenTy == 3 then
				pRedNums:setPosition(pView:getWidth()-pRedNums:getWidth()/2, pView:getHeight()-pRedNums:getHeight()/2)
			else
				centerInView(pView,pRedNums)
			end
		end
		pRedNums:setCurData(nType,nCount)
	end
	
	return pRedNums
end
