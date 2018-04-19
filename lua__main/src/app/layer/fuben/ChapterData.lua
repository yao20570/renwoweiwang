--
-- Author: liangzhaowei
-- Date: 2016-04-12 15:41:16
-- 副本 章节数据

local ChapterData = class("ChapterData")

function ChapterData:ctor()
	-- body
	self:myInit()
end

function ChapterData:myInit()
--来自后端字段
	self.nId 				= nil 	        -- id	Integer	章节id                 
	self.nX                 = nil       	-- x	Integer	当前进度               
	self.nY                 = nil       	-- y	Integer	总进度               
	self.nS                 = nil       	-- s	Integer	星级               
	-- self.tSo                = {}        	-- so	Set<OutpostRsp>	特殊关卡入口    
	self.tCo                = {}            -- co   List<Integer>  还没开启的特殊关卡    
						
--配表中字段
	self.nId 				= nil  --章节唯一编号
	self.sName 				= ""  --章节名称
	self.nPrevious 			= nil  --上一章节
	self.nNext 				= nil  --下一章节
	self.nOpen				= nil   --开放等级
	self.sBackPic 			= "ui/daitu"  --背景图片	
	self.nFirshpost 	    = nil  	--该章节第一个关卡
	self.sPlot              = ""    --剧情

--自建字段
	self.tPost              = {}    --章节内所有关卡数据
	self.bOpen              = false  --章节是否开启 

end


function ChapterData:updateData( data )
	-- dump(data,"更新章节数据",20)
	self.nId 			= data.id or self.id 		--章节唯一编号
	self.nX             = data.x  or self.nX       	-- x	Integer	当前进度               
	self.nY             = data.y  or self.nY       	-- y	Integer	总进度               
	self.nS             = data.s  or self.nS       	-- s	Integer	星级

	--解析特殊关卡数据  
	if data.so and table.nums(data.so) > 0  then
		for k,v in pairs(data.so) do
			-- local tLevleList = {}
			for x,y in pairs(self.tPost) do
				if y.nId == v.id then
					y:updateData(v)
				end
			end			
		end
	end
	--还没开启的特殊关卡
	-- dump(data.co, "还没开启的特殊关卡 == ")
	self.tCo            = data.co or {}

end

function ChapterData:initDatasByDB( data )
	self.nId 				= data.id or self.id				--章节唯一编号
	self.sName 				= data.name or self.name  			--章节名称
	self.nPrevious 			= data.previous or self.previous	--上一章节
	self.nNext 				= data.next or self.next 			--下一章节
	self.nOpen				= data.open or self.open		--开放等级
	self.sPlot				= data.plot or self.sPlot		--剧情

	if data.backpic then
		self.sBackPic 			= "#"..data.backpic..".jpg" or self.sBackPic		--背景图片	
	end
	self.nFirshpost 	    = data.firshpost or self.firshpost 	--该章节第一个关卡

end


return ChapterData