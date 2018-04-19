----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-10 16:10:34
-- Description: 数学相关
-----------------------------------------------------

--判断线段是否相交
--pt1：线段A 起始点
--pt2：线段A 结束点
--pt3：线段B 超始点
--pt4：线段B 结束点
--return:bool 是否相交
function pIsSegmentIntersectEx(pt1,pt2,pt3,pt4)
    local s,t,ret = 0,0,false
    ret,s,t =cc.pIsLineIntersect(pt1, pt2, pt3, pt4,s,t)

    if ret and  s >= 0.0 and s <= 1.0 and t >= 0.0 and t <= 1.0 then
        return true, cc.p(pt1.x + s * (pt2.x - pt1.x), pt1.y + s * (pt2.y - pt1.y))
    end
    return false
end

--获取两点求角度360范围
--px1:a点坐标x
--py1:a点坐标y
--px2:b点坐标x
--py2:b点坐标y
--return: float 两点间的直角度数
function getAngle(px1, py1, px2, py2)
    --两点的x、y值 
    local x = px2 - px1; 
    local y = py2 - py1; 
    local hypotenuse = math.sqrt(math.pow(x, 2)+math.pow(y, 2)); 
    --斜边长度 
    local cos = x/hypotenuse; 
    local radian = math.acos(cos); 
    --求出弧度 
    local angle = 180/(math.pi/radian); 
    --用弧度算出角度 
    if (y<0) then 
        angle = -angle; 
    elseif ((y == 0) and (x<0)) then
        angle = 180; 
    end
    return 360 - angle;
end

--同一坐标系坐标是否在菱形内
--width:宽
--height:高
--px:坐标x
--py:坐标y
--return:bool 是否在菱形内
function pointInLingxingEx(width, height, px, py)
    local absoluteX = px
    local absoluteY = py
    if (absoluteY >= ((-height/width)*absoluteX+height/2) and
        absoluteY <= ((-height/width)*absoluteX+3*height/2) and
        absoluteY <= ((height/width)*absoluteX+height/2) and
        absoluteY >= ((height/width)*absoluteX-height/2)) then
        return true
    end
    return false
end


--毫秒转成秒
function milliSecondToSecond( nCd )
    if nCd then
        return math.ceil(nCd/1000)
    end
    return nCd
end

--只适用于凸多边形
-- 判断点是否在多边形内 
-- 求解通过该点的水平线与多边形各边的交点 
-- 单边交点为奇数，成立!
function ptInPolygon( p, ptPolygon)
    local nCross = 0
    local nCount = #ptPolygon
    for i=1,nCount do
        local p1 = ptPolygon[i]
        local i2 = i + 1
        if i2 > nCount then
            i2 = 1
        end
        local p2 = ptPolygon[i2]
        -- 求解 y=p.y 与 p1p2 的交点
        if ( p1.y == p2.y ) then--// p1p2 与 y=p0.y平行 
        elseif ( p.y < math.min(p1.y, p2.y) ) then -- 交点在p1p2延长线上
        elseif ( p.y >= math.max(p1.y, p2.y) ) then -- // 交点在p1p2延长线上
        else
            --求交点的 X 坐标 --------------------------------------------------------------
            local x = (p.y - p1.y) * (p2.x - p1.x) / (p2.y - p1.y) + p1.x
            if ( x > p.x ) then
                nCross = nCross + 1
            end
        end 
    end
    return (nCross % 2 == 1)
end

----------------------------------------------简单射线检测
--vect3 相减
function vec3Minus( a, b)
    return cc.vec3(a.x - b.x, a.y - b.y, a.z - b.z)
end

--vect3 相加
function vec3Add( a, b)
    return cc.vec3(a.x + b.x, a.y + b.y, a.z + b.z)
end

--计算两点间的距离
function vec3Distance( a, b)
    local dx = a.x - b.x;
    local dy = a.y - b.y;
    local dz = a.z - b.z;
    return math.sqrt(dx * dx + dy * dy + dz * dz);
end

--向量标准化
function vec3Normalize( a )
    local magSq = a.x*a.x + a.y*a.y + a.z*a.z;
    if magSq > 0.0 then--检查除零
        local oneOverMag = 1.0 / math.sqrt(magSq);
        a.x = a.x * oneOverMag;
        a.y = a.y * oneOverMag;
        a.z = a.z * oneOverMag;
    end
end

--向量点乘
function vec3Dot( a, b)
    return a.x * b.x + a.y * b.y + a.z * b.z;
end

function cSolveLinear( a_coefficient, a_solution)
    if a_coefficient[2] == 0 then
        return 0
    end
    a_solution[1] = - a_coefficient[1] / a_coefficient[2]
    return 1
end

--射线平面相交
function cIntersectionSegmentPlane( a_segmentPointA, a_segmentPointB, a_planePos, a_planeNormal)
    local d = vec3Minus(a_segmentPointB , a_segmentPointA)
    local p = a_segmentPointA
    local length = vec3Distance(a_segmentPointB, a_segmentPointA)
    --非0检测
    if length == 0 then
        return false
    end
    --向量标准化
    vec3Normalize(d)

    --compute intersection between segment and disk plan
    local c = {0, 0}
    local s = {0}

    c[1] = a_planeNormal.x*p.x - a_planeNormal.x*a_planePos.x +  
           a_planeNormal.y*p.y - a_planeNormal.y*a_planePos.y +  
           a_planeNormal.z*p.z - a_planeNormal.z*a_planePos.z;  
    c[2] = a_planeNormal.x*d.x + a_planeNormal.y*d.y + a_planeNormal.z*d.z;  

    local a_collisionPoint = nil
    local a_collisionNormal = nil

    local num = cSolveLinear(c, s)
    if num == 0 then
        return false
    else
        if s[1] >= 0 and s[1] <= length then
            -- p + s[1] * d
            local temp = cc.vec3(d.x * s[1], d.y * s[1], d.z * s[1])
            a_collisionPoint = vec3Add(p, temp)

            if vec3Dot(a_planeNormal, vec3Minus(a_segmentPointA, a_collisionPoint)) >= 0 then
                a_collisionNormal = a_planeNormal;  
            else
                a_collisionNormal = cc.vec3(a_planeNormal.x * -1, a_planeNormal.y * -1, a_planeNormal.z * -1);  
            end
            return true, a_collisionPoint
        else
            return false
        end
    end
end