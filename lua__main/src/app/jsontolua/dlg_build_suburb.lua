local tTable = {}

tTable["texturesPng"] = {"ui/v1_img_yindaotankuang.png","ui/p1_commmon1_sep.plist","ui/p1_button1.plist","ui/p1_commonse4.plist","ui/daitu.png"}
tTable["index_1"] = {
default={classname="Panel",name="default",parName="root",childCount="11",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="true",backGroundImage="#v1_img_yindaotankuang.png",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="125",capInsetsY="130",height="350",width="572",x="0",y="0",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="7",anchorPointX="0",anchorPointY="0",},
}
tTable["index_2"] = {
img_player={classname="ImageView",name="img_player",parName="default",ZOrder="1",fileName="#v1_bg_banshenyindao.png",scale9Enable="false",scale9Height="434",scale9Width="294",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="0",capInsetsY="0",height="434",width="294",x="-37",y="0",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="8",anchorPointX="0",anchorPointY="0",},
img_yindao={classname="ImageView",name="img_yindao",parName="default",ZOrder="0",fileName="#v1_img_yindaokuang2.png",scale9Enable="false",scale9Height="42",scale9Width="351",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="0",capInsetsY="0",height="42",width="351",x="397",y="0",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="10",anchorPointX="0.5",anchorPointY="1",},
lb_tip={classname="Label",name="lb_tip",parName="default",ZOrder="1",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="20",height="27",width="95",x="397",y="-21",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="11",anchorPointX="0.5",anchorPointY="0.5",},
img_close={classname="ImageView",name="img_close",parName="default",ZOrder="0",fileName="#v1_btn_closebig2.png",scale9Enable="false",scale9Height="50",scale9Width="50",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="0",capInsetsY="0",height="50",width="50",x="573",y="350",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="13",anchorPointX="1",anchorPointY="1",},
img_arrow={classname="ImageView",name="img_arrow",parName="default",ZOrder="0",fileName="#v1_img_scjtl.png",scale9Enable="false",scale9Height="18",scale9Width="89",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="0",capInsetsY="0",height="18",width="89",x="345",y="166",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="12",anchorPointX="0.5",anchorPointY="0.5",},
lb_cost={classname="Label",name="lb_cost",parName="default",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="20",height="27",width="95",x="345",y="135",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="17",anchorPointX="0.5",anchorPointY="0.5",},
lay_btn={classname="Panel",name="lay_btn",parName="default",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="50",width="130",x="283",y="21",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="20",anchorPointX="0",anchorPointY="0",},
lb_title={classname="Label",name="lb_title",parName="default",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="20",height="27",width="95",x="333",y="320",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="21",anchorPointX="0.5",anchorPointY="0.5",},
lb_des={classname="Label",name="lb_des",parName="default",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="20",height="27",width="95",x="340",y="273",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="26",anchorPointX="0.5",anchorPointY="0.5",},
lay_tuzi={classname="Panel",name="lay_tuzi",parName="default",childCount="2",ZOrder="5",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",backGroundImage="#v1_img_xsydk.png",height="143",width="143",x="153",y="95",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="27",anchorPointX="0",anchorPointY="0",},
lay_build={classname="Panel",name="lay_build",parName="default",childCount="2",ZOrder="5",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",backGroundImage="#v1_img_xsydk.png",height="143",width="143",x="393",y="95",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="28",anchorPointX="0",anchorPointY="0",},
}
tTable["index_3"] = {
img_tuzi={classname="ImageView",name="img_tuzi",parName="lay_tuzi",ZOrder="0",fileName="ui/daitu.png",scale9Enable="false",scale9Height="10",scale9Width="10",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="0",capInsetsY="0",height="10",width="10",x="72",y="72",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="29",anchorPointX="0.5",anchorPointY="0.5",},
lb_draw_name={classname="Label",name="lb_draw_name",parName="lay_tuzi",ZOrder="6",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="20",height="27",width="95",x="72",y="10",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="23",anchorPointX="0.5",anchorPointY="0",},
img_build={classname="ImageView",name="img_build",parName="lay_build",ZOrder="0",fileName="ui/daitu.png",scale9Enable="false",scale9Height="10",scale9Width="10",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="0",capInsetsY="0",height="10",width="10",x="72",y="72",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="19",anchorPointX="0.5",anchorPointY="0.5",},
lb_buildName={classname="Label",name="lb_buildName",parName="lay_build",ZOrder="6",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="20",height="27",width="95",x="72",y="10",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="18",anchorPointX="0.5",anchorPointY="0",},
}

return tTable