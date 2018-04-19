-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-06-26 19:44:32 星期一
-- Description: 数学工具类
-----------------------------------------------------


local PlgVectorObj = require("app.utils.PlgVectorObj")

--[[
	判断同向
	判断点C,P是否都在向量AB的同侧
--]]
local function sameSide( pvA, pvB, pvC, pvP )
	-- body

	local pvAB = pvB:opMinus(pvA)
	local pvAC = pvC:opMinus(pvA)
	local pvAP = pvP:opMinus(pvA)

	local v1 = pvAB:cross(pvAC)
	local v2 = pvAB:cross(pvAP)

	-- 判断v1和v2是否同向
	return v1 * v2 >= 0 

end

--[[
	判断点是否在三角形内，
--]]
local function pointInTriangleP( pvA, pvB, pvC, pvP )
	-- body 

	--[[
		若C、P在向量AB同侧，且A、P在向量BC同侧，B、P在向量CA同侧，
		则点P在四边形内。
	--]]
	return sameSide(pvA, pvB, pvC, pvP) and 
	   	   sameSide(pvB, pvC, pvA, pvP) and 
	   	   sameSide(pvC, pvA, pvB, pvP)
end

--[[
	判断点是否在四边形内，
--]]
local function pointInQuadrilateralP( pvA, pvB, pvC, pvD, pvP )
	-- body 

	--[[
		若C、P在向量AB同侧，且D、P在向量BC同侧，A、P在向量CD同侧，B、P在向量DA同侧，
		则点P在四边形内。
	--]]
	return sameSide(pvA, pvB, pvC, pvP) and 
	   	   sameSide(pvB, pvC, pvD, pvP) and 
	   	   sameSide(pvC, pvD, pvA, pvP) and
	   	   sameSide(pvD, pvA, pvB, pvP)
end

--[[
	判断点是否在六边形内，
--]]
local function pointInHexagonP( pvA, pvB, pvC, pvD, pvE, pvF, pvG, pvH, pvP )
	-- body 

	--[[
		若C、P在向量AB同侧，且D、P在向量BC同侧，E、P在向量CD同侧，F、P在向量DE同侧，
		G、P在向量EF同侧，H、P在向量FG同侧，A、P在向量GH同侧，B、P在向量HA同侧，
		则点P在六边形内。
	--]]
	return sameSide(pvA, pvB, pvC, pvP) and 
	   	   sameSide(pvB, pvC, pvD, pvP) and 
	   	   sameSide(pvC, pvD, pvE, pvP) and
	   	   sameSide(pvD, pvE, pvF, pvP) and
	   	   sameSide(pvE, pvF, pvG, pvP) and
	   	   sameSide(pvF, pvG, pvH, pvP) and
	   	   sameSide(pvG, pvH, pvA, pvP) and
	   	   sameSide(pvH, pvA, pvB, pvP)
end


--[[
	==================================================================
	========= End of local method=====================================
	==================================================================
--]]


--[[
		     A
   N*—————————*—————*M
	|				|
  	|				|
	|				|
	|				|
	|				|
   K*———————————————*L
	     
 
	判断点p是否在建筑的三角形有效点击区域内。
	设定建筑的图片为矩形。
	如上图K、L、M、N为图片的四个顶点，
	K、L、A为建筑的有效点击区域--三角形的顶点。
	参数：
	cx: 		图片的中心坐标x
	cy: 		图片的中心坐标y
	width: 		图片的宽
	height: 	图片的高
	frhTop: 	frhTop = NA : NM ( 0 =< frhTop <= 1, ）
	px:			P点的坐标x
	py:			P点的坐标y
--]]
function pointInTriangle( px, py, cx, cy, width, height, frhTop)
	-- body
	frhTop = frhTop or 0.5 -- 默认值是中点

	-- 图片宽高不能小于或等于零，点击坐标不能为空
	if width <= 0 or height <= 0 or not px or not py then
		return false
	end

	if frhTop < 0 or frhTop > 1 then
		frhTop = 0.5
	end
	
	-- 计算图片左下角坐标
	local fx0 = cx - width / 2
	local fy0 = cy - height / 2


	-- 提取有效区域三角形的三个顶点坐标和点击p点的坐标
	local pvK = PlgVectorObj.new(fx0, fy0)
	local pvL = PlgVectorObj.new(fx0 + width, fy0)
	local pvA = PlgVectorObj.new(fx0 + width * frhTop, fy0 + height)
	local pvP = PlgVectorObj.new(px, py)

	return pointInTriangleP(pvK, pvL, pvA, pvP)

end


--[[
		     
   N*———————————*M
	|			|
  	|			|
	|			|
	|			|
	|			|
   K*——————————*L
	     
 
	判断点p是否在四边形有效点击区域内。
	设定建筑的图片为矩形。
	如上图K、L、M、N为图片的四个顶点，
	参数：
	cx: 		图片的中心坐标x
	cy: 		图片的中心坐标y
	width: 		图片的宽
	height: 	图片的高
	px:			P点的坐标x
	py:			P点的坐标y
--]]
function pointInRect( px, py, cx, cy, width, height )
	-- body
	-- 图片宽高不能小于或等于零，点击坐标不能为空
	if width <= 0 or height <= 0 or not px or not py then
		return false
	end

	if px >= cx - width / 2 
		and px <= cx + width / 2 
		and py >= cy - height / 2 
		and py <= cy + height / 2 then
		return true
	else
		return false
	end

end

--[[
		     D
   N*————————*——*M
	|			|
  A*|			|
	|			|
	|			|*C
	|			|
   K*————*——————*L
	     B
 
	判断点p是否在建筑的四边形有效点击区域内。
	设定建筑的图片为矩形。
	如上图K、L、M、N为图片的四个顶点，
	A、B、C、D为建筑的有效点击区域--四边形的顶点。
	参数：
	cx: 		图片的中心坐标x
	cy: 		图片的中心坐标y
	width: 		图片的宽
	height: 	图片的高
	frvLeft: 	frvLeft = KA : KN ( 0 =< frvLeft <= 1, ）
	frvRight: 	frvRight = LC : LM ( 0 =< frvRight <= 1, ）
	frhTop: 	frhTop = ND : NM ( 0 =< frhTop <= 1, ）
	frhBottom: 	frhBottom = KB: KL ( 0 =< frhBottom <= 1, ）
	px:			P点的坐标x
	py:			P点的坐标y
--]]
function pointInQuadrilateral(  px, py, cx, cy, width, height, frvLeft, frvRight, frhTop, frhBottom)
	-- body
	frvLeft = frvLeft or 0.5 -- 默认值是中点
	frvRight = frvRight or 0.5 -- 默认值是中点
	frhTop = frhTop or 0.5 -- 默认值是中点
	frhBottom = frhBottom or 0.5 -- 默认值是中点

	-- 图片宽高不能小于或等于零，点击坐标不能为空
	if width <= 0 or height <= 0 or not px or not py then
		return false
	end


	if frvLeft < 0 or frvLeft > 1 then
		frvLeft = 0.5
	end
	if frvRight < 0 or frvRight > 1 then
		frvRight = 0.5
	end
	if frhTop < 0 or frhTop > 1 then
		frhTop = 0.5
	end
	if frhBottom < 0 or frhBottom > 1 then
		frhBottom = 0.5
	end
	
	-- 计算图片左下角坐标
	local fx0 = cx - width / 2
	local fy0 = cy - height / 2


	-- 提取有效区域四边形的四个顶点坐标和点击p点的坐标
	local pvA = PlgVectorObj.new(fx0, fy0 + height * frvLeft)
	local pvB = PlgVectorObj.new(fx0 + width * frhBottom, fy0)
	local pvC = PlgVectorObj.new(fx0 + width, fy0 + height * frvRight)
	local pvD = PlgVectorObj.new(fx0 + width * frhTop, fy0 + height)
	local pvP = PlgVectorObj.new(px, py)

	return pointInQuadrilateralP(pvA, pvB, pvC, pvD, pvP)

end


--[[
			 H	 G
		     * d *
   N*——————————*————*M
	|				|
  A*|				|
   a*				|
  B*|				|*F
	|				*c
	|				|*E
	|				|
   K*—————*—————————*L
	    * b *
		C   D

	四边形的扩充，参数参考四边形：pointInQuadrilateral
	s: 四边形上下预留的距离。s为空时默认为10

	a、b、c、d对应函数pointInQuadrilateral（四边形）里的A、B、C、D四个顶点
	A、B为顶点a上下移动距离s得到,同样：C、D,E、F,G、H分别为顶点b、c、d上下移动距离s得到

--]]
function pointInHexagon( px, py, cx, cy, width, height, frvLeft, frvRight, frhTop, frhBottom, s)
	-- body
	frvLeft = frvLeft or 0.5 -- 默认值是中点
	frvRight = frvRight or 0.5 -- 默认值是中点
	frhTop = frhTop or 0.5 -- 默认值是中点
	frhBottom = frhBottom or 0.5 -- 默认值是中点
	s = s or 10 -- 默认距离是10

	-- 图片宽高不能小于或等于零，点击坐标不能为空
	if width <= 0 or height <= 0 or not px or not py then
		return false
	end

	
	if frvLeft < 0 or frvLeft > 1 then
		frvLeft = 0.5
	end
	if frvRight < 0 or frvRight > 1 then
		frvRight = 0.5
	end
	if frhTop < 0 or frhTop > 1 then
		frhTop = 0.5
	end
	if frhBottom < 0 or frhBottom > 1 then
		frhBottom = 0.5
	end

	if not s then
		s = 10
	end
	

	-- 计算图片左下角坐标
	local fx0 = cx - width / 2
	local fy0 = cy - height / 2

	-- 提取有效区域四边形的四个顶点坐标和点击p点的坐标
	local pvA = PlgVectorObj.new(fx0, fy0 + height * frvLeft + s)
	local pvB = PlgVectorObj.new(fx0, fy0 + height * frvLeft - s)
	local pvC = PlgVectorObj.new(fx0 + width * frhBottom - s, fy0)
	local pvD = PlgVectorObj.new(fx0 + width * frhBottom + s, fy0)
	local pvE = PlgVectorObj.new(fx0 + width, fy0 + height * frvRight - s)
	local pvF = PlgVectorObj.new(fx0 + width, fy0 + height * frvRight + s)
	local pvG = PlgVectorObj.new(fx0 + width * frhTop + s, fy0 + height)
	local pvH = PlgVectorObj.new(fx0 + width * frhTop - s, fy0 + height)
	local pvP = PlgVectorObj.new(px, py)

	return pointInHexagonP(pvA, pvB, pvC, pvD, pvE, pvF, pvG, pvH, pvP)

end

--[[
	判断点是否在圆内（包括圆和椭圆）
	参数：
	cx: 图片中心坐标x
	cy:	图片中心坐标y 
	width: 图片宽度
	height: 图片高度
	px: 点击位置坐标x
	py: 点击位置坐标y
--]]
function pointInCircle ( px, py, cx, cy, width, height )

	-- 图片宽高不能小于或等于零，点击坐标不能为空
	if width <= 0 or height <= 0 or not px or not py then
		return false
	end


	local result = (px - cx) * (px - cx) / (width * width) + (py - cy) * (py - cy) / (height * height) - 0.25

	return result <= 0
end
-- 判断是否在菱形的范围内
-- tw(float): 菱形的宽度
-- th(float): 菱形的高度
-- px(float): 检测坐标点
-- py(float): 检测的坐标点
function pointInLingxing( tw, th, px, py )
	if(tLxPP1 == nil) then
		tLxPP1 = ccp(tw/2, 0)
		tLxPP2 = ccp(tw, th/2)
		tLxPP3 = ccp(tw/2, th)
		tLxPP4 = ccp(0, th/2)
		tLxAA1 = (tLxPP2.y - tLxPP1.y) / (tLxPP1.x - tLxPP2.x)
		tLxBB1 = 1
		tLxCC1 = -(tLxPP1.y+tLxAA1*tLxPP1.x)
		tLxAA2 = (tLxPP3.y - tLxPP2.y) / (tLxPP2.x - tLxPP3.x)
		tLxBB2 = 1
		tLxCC2 = -(tLxPP2.y+tLxAA2*tLxPP2.x)
		tLxAA3 = (tLxPP4.y - tLxPP3.y) / (tLxPP3.x - tLxPP4.x)
		tLxBB3 = 1
		tLxCC3 = -(tLxPP3.y+tLxAA3*tLxPP3.x)
		tLxAA4 = (tLxPP1.y - tLxPP4.y) / (tLxPP4.x - tLxPP1.x)
		tLxBB4 = 1
		tLxCC4 = -(tLxPP4.y+tLxAA4*tLxPP4.x)
	end
	local d1 = (tLxAA1*px+tLxBB1*py+tLxCC1)/math.sqrt(tLxAA1*tLxAA1+tLxBB1*tLxBB1)
	local d2 = (tLxAA2*px+tLxBB2*py+tLxCC2)/math.sqrt(tLxAA2*tLxAA2+tLxBB2*tLxBB2)
	local d3 = (tLxAA3*px+tLxBB3*py+tLxCC3)/math.sqrt(tLxAA3*tLxAA3+tLxBB3*tLxBB3)
	local d4 = (tLxAA4*px+tLxBB4*py+tLxCC4)/math.sqrt(tLxAA4*tLxAA4+tLxBB4*tLxBB4)
	if(d1 >= 60 and d2 <= -60 and d3 <= -60 and d4 >= 60) then
		return true
	end
	return false
end
-- 判断是否在菱形的范围内
-- mx(float): 菱形中心点位置
-- my(float): 菱形中心点位置
-- tw(float): 菱形的宽度
-- th(float): 菱形的高度
-- px(float): 检测坐标点
-- py(float): 检测的坐标点
function pointInLingxing2( mx, my, tw, th, px, py )
	local tLxPP1 = ccp(mx, my-th/2)
	local tLxPP2 = ccp(mx+tw/2, my)
	local tLxPP3 = ccp(mx, my+th/2)
	local tLxPP4 = ccp(mx-tw/2, my)
	local tLxAA1 = (tLxPP2.y - tLxPP1.y) / (tLxPP1.x - tLxPP2.x)
	local tLxBB1 = 1
	local tLxCC1 = -(tLxPP1.y+tLxAA1*tLxPP1.x)
	local tLxAA2 = (tLxPP3.y - tLxPP2.y) / (tLxPP2.x - tLxPP3.x)
	local tLxBB2 = 1
	local tLxCC2 = -(tLxPP2.y+tLxAA2*tLxPP2.x)
	local tLxAA3 = (tLxPP4.y - tLxPP3.y) / (tLxPP3.x - tLxPP4.x)
	local tLxBB3 = 1
	local tLxCC3 = -(tLxPP3.y+tLxAA3*tLxPP3.x)
	local tLxAA4 = (tLxPP1.y - tLxPP4.y) / (tLxPP4.x - tLxPP1.x)
	local tLxBB4 = 1
	local tLxCC4 = -(tLxPP4.y+tLxAA4*tLxPP4.x)
	local d1 = (tLxAA1*px+tLxBB1*py+tLxCC1)/math.sqrt(tLxAA1*tLxAA1+tLxBB1*tLxBB1)
	local d2 = (tLxAA2*px+tLxBB2*py+tLxCC2)/math.sqrt(tLxAA2*tLxAA2+tLxBB2*tLxBB2)
	local d3 = (tLxAA3*px+tLxBB3*py+tLxCC3)/math.sqrt(tLxAA3*tLxAA3+tLxBB3*tLxBB3)
	local d4 = (tLxAA4*px+tLxBB4*py+tLxCC4)/math.sqrt(tLxAA4*tLxAA4+tLxBB4*tLxBB4)
	if(d1 >= 0 and d2 <= 0 and d3 <= 0 and d4 >= 0) then
		return true
	end
	return false
end






