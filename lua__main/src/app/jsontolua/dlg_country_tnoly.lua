local tTable = {}

tTable["texturesPng"] = {"ui/p1_commmon3_sep.plist","ui/p1_commmon2_sep.plist","ui/p1_commonse1.plist","ui/p2_commonse1.plist"}
tTable["index_1"] = {
default={classname="Panel",name="default@fill_layout",parName="root",childCount="2",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="1060",width="640",x="0",y="0",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="6",anchorPointX="0",anchorPointY="0",},
}
tTable["index_2"] = {
lay_main={classname="Panel",name="lay_main@fill_layout",parName="default",childCount="3",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="true",backGroundImage="#v1_bg_kelashen.png",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="22",capInsetsY="22",height="976",width="640",x="0",y="84",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="7",anchorPointX="0",anchorPointY="0",},
lay_bot={classname="Panel",name="lay_bot",parName="default",childCount="1",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="84",width="640",x="0",y="0",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="11",anchorPointX="0",anchorPointY="0",},
}
tTable["index_3"] = {
lay_top={classname="Panel",name="lay_top",parName="lay_main",childCount="3",ZOrder="1",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",backGroundImage="#v1_img_changtiaoqian2.png",height="42",width="258",x="0",y="934",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="8",anchorPointX="0",anchorPointY="0",},
lay_space={classname="Panel",name="lay_space",parName="lay_main",ZOrder="1",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="33",width="640",x="0",y="900",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="36",anchorPointX="0",anchorPointY="0",},
lay_con={classname="Panel",name="lay_con",parName="lay_main",ZOrder="1",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="901",width="640",x="0",y="0",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="10",anchorPointX="0",anchorPointY="0",},
lay_edit={classname="Panel",name="lay_edit",parName="lay_bot",childCount="1",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="90",width="100",x="260",y="0",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="114",anchorPointX="0",anchorPointY="0",},
}
tTable["index_4"] = {
lb_contribution={classname="Label",name="lb_contribution",parName="lay_top",ZOrder="1",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="国家贡献：",fontName="微软雅黑",fontSize="20",height="27",width="100",x="24",y="21",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="9",anchorPointX="0",anchorPointY="0.5",},
img_res={classname="ImageView",name="img_res",parName="lay_top",ZOrder="0",fileName="#v1_img_tongqian.png",scale9Enable="false",scale9Height="26",scale9Width="25",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="0",capInsetsY="0",height="26",width="25",x="137",y="21",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="39",anchorPointX="0.5",anchorPointY="0.5",},
lb_donate={classname="Label",name="lb_donate",parName="lay_top",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="9999",fontName="微软雅黑",fontSize="20",height="27",width="48",x="161",y="21",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="40",anchorPointX="0",anchorPointY="0.5",},
img_edit={classname="ImageView",name="img_edit",parName="lay_edit",ZOrder="0",fileName="#v2_img_bianjituijian.png",scale9Enable="false",scale9Height="89",scale9Width="95",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="0",capInsetsY="0",height="89",width="95",x="50",y="45",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="115",anchorPointX="0.5",anchorPointY="0.5",},
}

return tTable