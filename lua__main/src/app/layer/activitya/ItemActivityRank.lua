-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-05-17 15:05:40 星期三
-- Description: 排行单项层
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local ItemActivityRank = class("ItemActivityRank", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

local const_img_name = { "#v1_img_paixingbang1.png", "#v1_img_paixingbang2.png", "#v1_img_paixingbang3.png" }

-- bIsUseImg : 是否用图片代替排名
function ItemActivityRank:ctor(nHeight, nWidth, bIsUseImg)
	-- body	
	self:myInit()	
    self.bIsUseImg = bIsUseImg or false
	self.nItemHeight = nHeight or 50
	self.nItemWidth = nWidth or 522 
	parseView("item_activity_rank", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemActivityRank:myInit()
	-- body		
	self.nIndex 			= 	nIndex or 1      --
	self.tCurData 			= 	nil 				--当前数据	
	self.tLabels 			= 	nil
	self.nHandler 			= 	nil
    self.nCurrRankType      =   nil             --设置当前排行榜类型(默认为nil, 则读取Player:getRankInfo().nRankType)
end

--解析布局回调事件
function ItemActivityRank:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemActivityRank",handler(self, self.onItemActivityRankDestroy))
end

--初始化控件
function ItemActivityRank:setupViews( )
	-- body
	self.pLayRoot = self:findViewByName("root")
	self.pImgLine = self:findViewByName("img_line")	
	self:createLabels()
	self.pImgLine:setPositionX(self.nItemWidth/2)
	self.pImgLine:setLayoutSize(self.nItemWidth - 56, self.pImgLine:getHeight())
	self:setLayoutSize(self.nItemWidth, self.nItemHeight)
	self.pLayRoot:setLayoutSize(self.nItemWidth, self.nItemHeight)
	self:onMViewClicked(handler(self, self.onClick))
end

function ItemActivityRank:setRankType( _nRankType )
    self.nCurrRankType = _nRankType
end

-- 修改控件内容或者是刷新控件数据
function ItemActivityRank:updateViews( )
	-- body
	local nranktype = self.nCurrRankType or Player:getRankInfo().nRankType
	if self.tCurData then
		--排名
		setTextCCColor(self.tLabels[1], _cc.pwhite)--排名
		setTextCCColor(self.tLabels[3], _cc.pwhite)--玩家名字
		setTextCCColor(self.tLabels[4], _cc.pwhite)--国家次数	
		--位置更新		
		local tpos = getRankSetTypePos(nranktype)
		local bwidth = self.pLayRoot:getWidth()
		local rankdata = getRankData( nranktype )
		local ttypes = luaSplit(rankdata.sort, ";")
		for i = 1, 5 do
			if tpos[i] and ttypes[i] then				
				self.tLabels[i]:setVisible(true)
				self.tLabels[i]:setPositionX(tpos[i]*bwidth)	
                

				if ttypes[i] == "c" then--国家
					setTextCCColor(self.tLabels[i], getColorByCountry(self.tCurData[ttypes[i]]))
					self.tLabels[i]:setString(getCountryName(self.tCurData[ttypes[i]]))
				elseif ttypes[i] == "ph" then					
					local value = getClassifyName(self.tCurData[ttypes[i]])
					setTextCCColor(self.tLabels[i], value.color)
					self.tLabels[i]:setString(value.text)
				elseif ttypes[i] == "jw" then
					local nLv = self.tCurData[ttypes[i]]
					local pBanneret = getBanneretByLv(nLv)
					if pBanneret then
						self.tLabels[i]:setString(pBanneret.name)
					else
						self.tLabels[i]:setString(getConvertedStr(3, 10139))
					end
				else
					if i == 4 then
						if self.tCurData[ttypes[i]] >= 10000 then
							local sStr = getResourcesStr(self.tCurData[ttypes[i]])
							self.tLabels[i]:setString(sStr)
						else
							self.tLabels[i]:setString(self.tCurData[ttypes[i]])	
						end
					else
						self.tLabels[i]:setString(self.tCurData[ttypes[i]])	
					end
				end

                if i==1 and ttypes[i] == "x" and self.bIsUseImg then
                    self:updateImage(self.tCurData[ttypes[i]], self.tLabels[i])
                end
			else
				self.tLabels[i]:setVisible(false)
			end	    
		end	 

	end
end

function ItemActivityRank:updateImage(_nRank, _pNode)
    if _nRank > 3 then
        if self.pImgRank then
            self.pImgRank:setVisible(false)
            _pNode:setVisible(true)
        end
        return
    end
    if self.pImgRank == nil then
        local posX, posY = _pNode:getPosition()
        self.pImgRank = MUI.MImage.new(const_img_name[_nRank])
        self.pImgRank:setPosition(posX, posY)
        self.pImgRank:setScale(0.4)
        _pNode:getParent():addView(self.pImgRank)
    else
        self.pImgRank:setCurrentImage(const_img_name[_nRank])        
    end
    self.pImgRank:setVisible(true)
    _pNode:setVisible(false)
end

-- 析构方法
function ItemActivityRank:onItemActivityRankDestroy( )
	-- body
end

function ItemActivityRank:setCurData( _data )
	-- body	
	self.tCurData = _data
	self:updateViews()
end

function ItemActivityRank:createLabels(  )
	-- body
	self.tLabels = {}
	for i = 1, 5 do
		local pLabel = MUI.MLabel.new({
        text="",
        size=20,
        anchorpoint=cc.p(0.5, 0.5)})
        pLabel:setPosition(self.pLayRoot:getWidth()/10*(i*2-1), self.nItemHeight/2)
        setTextCCColor(pLabel, _cc.pwhite)
        self.pLayRoot:addView(pLabel, 10)    
        self.tLabels[i] = pLabel
	end
end

function ItemActivityRank:setHandler( _nhandler )
	-- body
	self.nHandler = _nhandler
end

function ItemActivityRank:onClick(  )
	-- body
	if self.nHandler then
		self.nHandler(self.tCurData)
	end
end
return ItemActivityRank