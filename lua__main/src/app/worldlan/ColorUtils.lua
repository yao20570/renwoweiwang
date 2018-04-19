-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-04-20 15:32:38 星期四
-- Description: 颜色管理器
-----------------------------------------------------

--系统字颜色
_cc = {
	white 	= 	"ffffff", 			--系统字颜色1（白色）
	pwhite  = 	"c6c7da", 			--系统字颜色2（紫白）
    lgray   =   "a5acc7",           --系统字颜色2（浅灰色）
	gray  	= 	"848484", 			--系统字颜色3（灰色）
	green  	= 	"31d840", 			--系统字颜色4（绿色）
	yellow  = 	"f5d93d", 			--系统字颜色5（黄色）
	blue  	= 	"77d4fd", 			--系统字颜色6（蓝色）
	red  	= 	"d72322", 			--系统字颜色7（红色）
    dblue   =   "729dca",           --系统字颜色8（深蓝色）
    purple  =   "bc46ff",           --系统字颜色8（紫色）
    brown   =   "655035",           --系统字颜色8 (棕色)
    gyellow =   "b7a58a",           --系统字颜色9 (灰黄)
    lbrown  =   "d8d1c0",           --浅褐色
    lyellow =   "dfd6b6",           --黄色2
    gjred   =   "fd7474",           --国家红
    gjyellow=   "fbfcae",           --国家黄
    gjgreen =   "a7ed92",           --国家绿
    gjblue  =   "8de0ef",           --国家蓝
	lwhite  =   "d7dac6",           --淡白色
    dyellow =   "ececd1",           --灰秋麒麟(偏暗淡黄色)
    myellow =   "d6cb9f",           --淡淡的黄色
	black   =   "000000",           --系统字体颜15色（黑色）
    mred    =   "822316",           --红色
    syellow =   "fa9e3b",           --橙色
    kyellow =   "fdf742",           --
    byellow =   "7b3618",           --
    vgray   =   "e0e8f9",           --vip灰
    vgreen  =   "91f7a3",           --vip绿
    vblue   =   "8bc5fe",           --vip蓝
    vpurple =   "fb8dff",           --vip紫
    vorange =   "fff68d",           --vip橙
    cred    =   "691200",           --国家圣旨红
    cblack  =   "3b120d",           --国家圣旨黑
}


--品质相关颜色
_ccq = {
	white  	= 	"ffffff", 			--品质（白）
	green  	= 	"31d840", 			--品质（绿）
	blue   	= 	"00d8ff", 			--品质（蓝）
	purple 	= 	"bc46ff", 			--品质（紫）
	orange 	= 	"feba29", 			--品质（橙）
	red    	= 	"d72322", 			--品质（红）
}

--设置文本颜色
function setTextCCColor( _pLabel, _sColor )
	-- body
	_pLabel:setTextColor(getC3B(_sColor))
end


--根据品质获取颜色 
function getColorByQuality(_nQuality)
    local str = _ccq.white
    if _nQuality == 1 then
       str =  _ccq.white
    elseif _nQuality == 2 then
       str =  _ccq.green
    elseif _nQuality == 3 then
        str = _ccq.blue
    elseif _nQuality == 4 then
        str = _ccq.purple
    elseif _nQuality == 5 then
        str = _ccq.orange
    elseif _nQuality == 6 then
        str = _ccq.red
    end
    return str
end

--根据品质获取文字
function getColorTextByQuality(_nQuality)
    -- body
    local str = getConvertedStr(7, 10210)
    if _nQuality == 1 then
       str =  getConvertedStr(7, 10210)
    elseif _nQuality == 2 then
       str =  getConvertedStr(7, 10211)
    elseif _nQuality == 3 then
        str = getConvertedStr(7, 10212)
    elseif _nQuality == 4 then
        str = getConvertedStr(7, 10213)
    elseif _nQuality == 5 then
        str =getConvertedStr(7, 10214)
    elseif _nQuality == 6 then
        str = getConvertedStr(7, 10215)
    end
    return str
end

--根据品质获取Icon背景框
function getIconBgByQuality(_nQuality)
    local str = "#v1_img_touxiangkuanghui.png"
    if _nQuality == 1 then
       str = "#v1_img_touxiangkuanghui.png"
    elseif _nQuality == 2 then
       str = "#v1_img_touxiangkuanglv.png"
    elseif _nQuality == 3 then
        str = "#v1_img_touxiangkuanglan.png"
    elseif _nQuality == 4 then
        str = "#v1_img_touxiangkuangzi.png"
    elseif _nQuality == 5 then
        str = "#v1_img_touxiangkuangcheng.png"
    elseif _nQuality == 6 then
        str = "#v1_img_touxiangkuanghong.png"
    end
    return str
end

--根据品质获取装备背景框(旧资源已移除)
-- function getEquipBgByQuality(_nQuality)
--     local str = "#v1_btn_zhuangbeihui.png"
--     if _nQuality == 1 then
--        str = "#v1_btn_zhuangbeihui.png"
--     elseif _nQuality == 2 then
--        str = "#v1_btn_zhuangbeilv.png"
--     elseif _nQuality == 3 then
--         str = "#v1_btn_zhuangbeilan.png"
--     elseif _nQuality == 4 then
--         str = "#v1_btn_zhuangbeizi.png"
--     elseif _nQuality == 5 then
--         str = "#v1_btn_zhuangbeicheng.png"
--     elseif _nQuality == 6 then
--         str = "#v1_btn_zhuangbeihong.png"
--     end
--     return str
-- end

--根据品质获取英雄半身像背景框
function getHeroBgByQuality(_nQuality)
    -- body
    local str = "#v1_img_kapaibai.png"
    if _nQuality == 1 then
       str = "#v1_img_kapaibai.png"
    elseif _nQuality == 2 then
       str = "#v1_img_kapailv.png"
    elseif _nQuality == 3 then
        str = "#v1_img_kapailan.png"
    elseif _nQuality == 4 then
        str = "#v1_img_kapaizi.png"
    elseif _nQuality == 5 then
        str = "#v1_img_kapaicheng.png"
    elseif _nQuality == 6 then
        str = "#v1_img_kapaihong.png"
    end
    return str 
end

--根据品质获得武将获得展示框
function getHeroGetBgByQuality(_nQuality)
    -- body
    local str = "#v1_img_gauqkapaibai.png"
    if _nQuality == 1 then
       str = "#v1_img_gauqkapaibai.png"
    elseif _nQuality == 2 then
       str = "#v1_img_gauqkapailv.png"
    elseif _nQuality == 3 then
        str = "#v1_img_gauqkapailan.png"
    elseif _nQuality == 4 then
        str = "#v1_img_gauqkapaizi.png"
    elseif _nQuality == 5 then
        str = "#v1_img_gauqkapaicheng.png"
    elseif _nQuality == 6 then
        str = "#v1_img_gauqkapaihong.png"
    end
    return str
end

--根据品质获得武将获得界面展示框
function getHeroKuangByQuality(_nQuality)
    -- body
    local str = "#v2_img_awfkaqtjh_ba.png"
    if _nQuality == 1 then
       str = "#v2_img_awfkaqtjh_ba.png"
    elseif _nQuality == 2 then
       str = "#v2_img_awfkaqtjh_lu.png"
    elseif _nQuality == 3 then
        str = "#v2_img_awfkaqtjh_lan.png"
    elseif _nQuality == 4 then
        str = "#v2_img_awfkaqtjh_zi.png"
    elseif _nQuality == 5 then
        str = "#v2_img_awfkaqtjh_zs.png"
    elseif _nQuality == 6 then
        str = "#v2_img_awfkaqtjh_ba.png"
    end
    return str
end

--根据品质获得武将获得界面展示框
function getHeroTextByQuality(_nQuality)
    -- body
    local str = getConvertedStr(1,10332)
    if _nQuality == 1 then
        str = getConvertedStr(1,10332)
    elseif _nQuality == 2 then
        str = getConvertedStr(1,10333)
    elseif _nQuality == 3 then
        str = getConvertedStr(1,10334)
    elseif _nQuality == 4 then
        str = getConvertedStr(1,10335)
    elseif _nQuality == 5 then
        str = getConvertedStr(1,10336)
    elseif _nQuality == 6 then
        str = getConvertedStr(1,10337)
    end
    return str
end

function getEquipTextByQuality(_nQuality)
    -- body
    local str = getConvertedStr(1,10332)
    if _nQuality == 1 then
        str = getConvertedStr(1,10332)
    elseif _nQuality == 2 then
        str = getConvertedStr(1,10333)
    elseif _nQuality == 3 then
        str = getConvertedStr(1,10334)
    elseif _nQuality == 4 then
        str = getConvertedStr(1,10335)
    elseif _nQuality == 5 then
        str = getConvertedStr(1,10336)
    elseif _nQuality == 6 then
        str = getConvertedStr(1,10337)
    end
    return str
end

--获取文字的内容以及颜色
--88级:f5d93d;后可以招募高级武将
--return {text = "88级",color = "f5d93d" ...}
--默认颜色为 _cc.pwhite
function getTextColorByConfigure(_str, _defaultColor)
    _defaultColor = _defaultColor or _cc.pwhite
    local tStr = {}
    local tLb = luaSplit(_str, ";")
    if tLb and table.nums(tLb)> 0 then
        for k,v in pairs(tLb) do
            local bFind = string.find(v, ":%x%x%x%x%x%x") --是否带颜色
            local tS = {}
            if bFind then
                local tStr = luaSplit(v, ":")
                tS.text = ""
                tS.color = _defaultColor

                --Fix:带有“:”的内容
                local nNum = #tStr
                if nNum>2 then
                    tS.size = tonumber(tStr[nNum])
                    if tS.size then
                        nNum = nNum - 1
                    else
                        tS.size = 20 
                    end
                end
                if nNum>1 then                    
                    tS.color = tStr[nNum]
                    nNum = nNum - 1
                end
                tS.text = table.concat(tStr, ":", 1, nNum)
            else
                tS.text =   v or ""
                tS.color = _defaultColor
            end
            if tS.text ~= "" then
                table.insert(tStr,tS)
            end
        end
    end
    return tStr
end

--解析表情
 --local sStr = "d@开心#@开心#@开心#@开心#@开心#@XX#@开心"
local function _getTableParseEmo( sStr, nEmoWidth, nEmoHeight )
    local nStrLength = string.len(sStr)
    local tData = {}
    while true do
        local nIndex = 1
        local nBegin, nEnd = string.find(sStr, "@", nIndex)
        if nBegin then
            local nBegin2, nEnd2 = string.find(sStr, "#", nIndex)
            if nBegin and nBegin2 then
                local sKey = string.sub(sStr, nBegin + 1, nEnd2 - 1) 
                --是否是表情
                local tEmo = getChatEmoDataByCn(sKey)
                if tEmo then
                    --之前
                    if nBegin - 1 >= nIndex then
                        local sStrBefore = string.sub(sStr, nIndex, nBegin - 1)
                        table.insert(tData, {text = sStrBefore})
                    end
                    --中间
                    table.insert(tData, {img = tEmo.sImg, width = nEmoWidth, height = nEmoHeight })
                    --之后
                    if nEnd2 + 1 <= nStrLength then
                        sStr = string.sub(sStr, nEnd2 + 1, nStrLength)
                        if sStr == "" then
                            break
                        end
                    else
                        break
                    end
                else
                    --之前
                    local sStrBefore = string.sub(sStr, nIndex, nEnd2)
                    table.insert(tData, {text = sStrBefore})
                    --之后
                    if nEnd2 + 1 <= nStrLength then
                        sStr = string.sub(sStr, nEnd2 + 1, nStrLength)
                        if sStr == "" then
                            break
                        end
                    else
                        break
                    end
                end
            else
                sStr = string.sub(sStr, nIndex, nStrLength)
                if sStr ~= "" then
                    table.insert(tData, {text = sStr})
                end
                break
            end
        else
            sStr = string.sub(sStr, nIndex, nStrLength)
            if sStr ~= "" then
                table.insert(tData, {text = sStr})
            end
            break
        end
    end
    --合并字符串
    local tRes = nil
    if #tData > 1 then
        tRes = {tData[1]}
        for i=2,#tData do
            local nResIndex = #tRes
            if tRes[nResIndex].text and tData[i].text then
                tRes[nResIndex].text = tRes[nResIndex].text .. tData[i].text
            else
                table.insert(tRes, tData[i])
            end
        end
    else
        tRes = tData
    end
    return tRes
end


--表文字转文本
--tStr：getTextColorByConfigure（）的结果，再转换
local n_img_width = 60 * 0.5
local n_img_height = 55 * 0.5
function getTableParseEmo( tStr, nEmoWidth, nEmoHeight )
    if not tStr then
        return
    end
    nEmoWidth = nEmoWidth or n_img_width
    nEmoHeight = nEmoHeight or n_img_height
    if type(tStr) == "table" then
        --倒序插入
        for i=#tStr, 1, -1 do
            local tStrData = tStr[i]
            if tStrData.text and tStrData.text ~= "" then
                --文本需要颜色
                local sColor = tStrData.color
                local sStr = tStrData.text
                --先删除原位置，再倒序插入
                table.remove(tStr, i)
                local tCrossData = _getTableParseEmo(sStr, nEmoWidth, nEmoHeight)
                for j = #tCrossData, 1, -1 do
                    local sSubData = tCrossData[j]
                    if sSubData.text then --补充文本颜色
                        sSubData.color = sColor
                    end
                    table.insert(tStr, i, sSubData)
                end
            end
        end
    end
    return tStr
end

--去掉emo系统符
function removeSysEmo( _sStr )
    local sStr = string.gsub(_sStr, "%[.-%]", function ( sSubStr )
        local sKey = string.sub(sSubStr,2,-2)
        local value = tonumber(sKey, 16)
        if value then --如果能传换的就是emo系统符
            return "*"
        end
        return sSubStr
    end)
    return sStr
end

--去掉emo系统字符
--tStr：getTextColorByConfigure（）的结果
function removeSysEmoInTable( tStr )
    for i=1,#tStr do
        if tStr[i].text then
            local sStr = removeSysEmo(tStr[i].text)
            tStr[i].text = sStr
        end
    end
    return tStr
end

--根据品质设置文本颜色
--_pLbText：文本控件
--_nQuality：品质
function setLbTextColorByQuality( _pLbText, _nQuality )
    -- body
    if not _pLbText then
        print("文本控件不能为 nil")
        return
    end
    _nQuality = _nQuality or 1
    local sColor = getColorByQuality(_nQuality)
    _pLbText:setTextColor(getC3B(sColor))
end

--根据国家获取颜色 
function getColorByCountry( nCountry)
    local str = _cc.gjyellow
    if nCountry == e_type_country.qunxiong then
       str = _cc.gjyellow
    elseif nCountry == e_type_country.shuguo then
       str = _cc.gjred
    elseif nCountry == e_type_country.weiguo then
        str = _cc.gjblue
    elseif nCountry == e_type_country.wuguo then
        str = _cc.gjgreen
    end
    return str
end

--根据vip等级获取颜色
function getVipColor( _nVip )
    -- body
    if not _nVip then
        return
    end
    local str = _cc.vgray
    if _nVip == 0 then
        str = _cc.vgray
    elseif _nVip >= 1 and _nVip <= 3 then
        str = _cc.vgreen
    elseif _nVip >= 4 and _nVip <= 6 then
        str = _cc.vblue
    elseif _nVip >= 7 and _nVip <= 9 then
        str = _cc.vpurple
    elseif _nVip >= 10 and _nVip <= 12 then
        str = _cc.vorange
    end
    return str
end

  


 