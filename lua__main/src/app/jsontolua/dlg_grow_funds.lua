local tTable = {}

tTable["texturesPng"] = {"ui/p1_commonse1.plist","ui/language/cn/p2_font_ac.plist","ui/p1_commmon3_sep.plist"}
tTable["index_1"] = {
default={classname="Panel",name="default@fill_layout",parName="root",childCount="3",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="1060",width="640",x="0",y="0",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="7",anchorPointX="0",anchorPointY="0",},
}
tTable["index_2"] = {
lay_top={classname="Panel",name="lay_top",parName="default",childCount="11",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="258",width="640",x="0",y="802",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="145",anchorPointX="0",anchorPointY="0",},
lay_content={classname="Panel",name="lay_content@fill_layout",parName="default",childCount="1",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="true",backGroundImage="#v1_bg_kelashen.png",capInsetsHeight="30",capInsetsWidth="30",capInsetsX="7",capInsetsY="7",height="782",width="600",x="22",y="20",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="171",anchorPointX="0",anchorPointY="0",},
lay_bottom={classname="Panel",name="lay_bottom",parName="default",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="20",width="640",x="0",y="0",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="147",anchorPointX="0",anchorPointY="0",},
}
tTable["index_3"] = {
lay_banner_bg={classname="Panel",name="lay_banner_bg",parName="lay_top",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="253",width="640",x="0",y="2",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="120",anchorPointX="0",anchorPointY="0",},
lay_btn_buy={classname="Panel",name="lay_btn_buy",parName="lay_top",ZOrder="1",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="50",width="130",x="483",y="22",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="20",anchorPointX="0",anchorPointY="0",},
lb_buy={classname="Label",name="lb_buy",parName="lay_top",ZOrder="1",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="已购买人数：",fontName="微软雅黑",fontSize="18",height="24",width="108",x="468",y="140",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="23",anchorPointX="0",anchorPointY="0.5",},
lb_playernum={classname="Label",name="lb_playernum",parName="lay_top",ZOrder="1",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="人数",fontName="微软雅黑",fontSize="18",height="24",width="36",x="575",y="140",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="28",anchorPointX="0",anchorPointY="0.5",},
lb_cost={classname="Label",name="lb_cost",parName="lay_top",ZOrder="1",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="购买花费：",fontName="微软雅黑",fontSize="18",height="24",width="90",x="468",y="99",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="25",anchorPointX="0",anchorPointY="0.5",},
img_huangjin={classname="ImageView",name="img_huangjin",parName="lay_top",ZOrder="1",fileName="#v1_img_qianbi.png",scale9Enable="false",scale9Height="36",scale9Width="36",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="0",capInsetsY="0",height="36",width="36",x="570",y="99",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="26",anchorPointX="0.5",anchorPointY="0.5",},
lb_money={classname="Label",name="lb_money",parName="lay_top",ZOrder="1",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="花费",fontName="微软雅黑",fontSize="18",height="24",width="36",x="587",y="99",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="30",anchorPointX="0",anchorPointY="0.5",},
lay_black={classname="Panel",name="lay_black",parName="lay_top",ZOrder="1",useMergedTexture="false",clipAble="false",backGroundScale9Enable="true",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="10",capInsetsY="10",height="28",width="580",x="0",y="225",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="32",anchorPointX="0",anchorPointY="0",},
txt_vip_tip={classname="CustomLabel",name="txt_vip_tip",parName="lay_top",ZOrder="1",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="20",height="27",width="95",x="626",y="179",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="122",anchorPointX="1",anchorPointY="0.5",},
img_tip={classname="CustomImageView",name="img_tip",parName="lay_top",ZOrder="1",fileName="#v2_fonts_czjj.png",scale9Enable="false",scale9Height="156",scale9Width="344",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="0",capInsetsY="0",height="156",width="344",x="191",y="105",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="124",anchorPointX="0.5",anchorPointY="0.5",},
lb_huangjin={classname="Label",name="lb_huangjin",parName="lay_top",ZOrder="2",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="15000",fontName="微软雅黑",fontSize="25",height="32",width="75",x="203",y="42",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="223",anchorPointX="0.5",anchorPointY="0.5",},
lay_list={classname="Panel",name="lay_list@fill_layout",parName="lay_content",ZOrder="2",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="782",width="600",x="0",y="0",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="10",anchorPointX="0",anchorPointY="0",},
}

return tTable