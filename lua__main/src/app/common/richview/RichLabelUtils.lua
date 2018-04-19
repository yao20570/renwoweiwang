----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-08 16:01:55
-- Description: 经常用到的富文本封装
-----------------------------------------------------

local MRichLabel = require("app.common.richview.MRichLabel")

--用法
-- local tStr = {
-- 	{color=_cc.blue,text=tostring(self.tMine.crop)},
-- 	{color=_cc.pwhite,text="/"..getConvertedStr(3, 10121)},
-- }
-- getRichLabelOfContainer(self.pLayRichtextSpeed,tStr)

--pContainer :容器类
--tStr:字符串数组
--nFontSize:字体大小可不传，默认为20
--nRowWidth:宽度，可不传，默认为disply.width
function getRichLabelOfContainer(pContainer, tStr, nFontSize, nRowWidth)
	if not pContainer then
		return
	end
	if not tStr then
		return
	end
	local pRichLabel = pContainer:findViewByTag(20170508)
	if not pRichLabel then --如果不存在，创建
		pRichLabel = MRichLabel.new({str = tStr, fontSize = nFontSize or 20, rowWidth = nRowWidth or display.width})
	    pRichLabel:setTag(20170508)
	    pContainer:addView(pRichLabel)
	end
	return pRichLabel
end


--测试方法
function getRichTextOfContainer(pContainer, tStr, nFontSize, nWidth, nHeight)
	if not pContainer then
		return
	end
	local pRichText = pContainer:getChildByTag(2017050182148)
	if not pRichText then --如果不存在，创建
		local pRichText = ccui.RichText:create()  
	    pRichText:ignoreContentAdaptWithSize(false)  
	   	nWidth = nWidth or pContainer:getContentSize().width
	    nHeight = nHeight or pContainer:getContentSize().height
	    pRichText:setContentSize(cc.size(nWidth, nHeight))    
	  	fontSize = nFontSize or 20
	  	for i=1,#tStr do
	  		local sText = tStr[i].text
			local sColor = tStr[i].color or _cc.white
	  		local pText = ccui.RichElementText:create(i, getC3B(sColor), 255, sText, "微软雅黑", fontSize )
	  		pRichText:pushBackElement(pText)   
	  	end
	    pRichText:setTag(2017050182148)
	    pRichText:setAnchorPoint(cc.p(0, 0))
	    pRichText:setPosition(cc.p(nWidth/2 * -1, nHeight/2 * -1))
	    pRichText:setVerticalSpace(10)
	    pContainer:addChild(pRichText)
	end
	return pRichText
end


-- local tConTable = {}
-- --文本
-- tConTable.tLabel= {
-- 	{"content",getC3B(_cc.white)},
-- }
-- tConTable.img = "#v1_img_qianbi.png"
-- self.pText =  createGroupText(tConTable)
-- self.pLyTop:addView(self.pText,10)
-- self.pText:setPosition(300, 0)
-- 以下为刷新内容
-- self.pText:setLabelCnCr(1,"changeLb") 

-- 单行 复合的图片与文字
--  _table 设置内容 参考
function createGroupText(_table)

    if not _table then
        return
    end

    local tData = _table
    local MBtnExText = require("app.common.button.MBtnExText")
    return MBtnExText.new(tData)
end