<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%
/***********************************************************************************
* ○ 파일    : outlookSettingPopup.jsp
* ● 설명    :  Outlook 설정 안내 팝업
***********************************************************************************/
%>
<!DOCTYPE html>
<html>
	<head>
		<jsp:directive.include file="page_head.jsp"/>
		<style>
		.popup_header {background: #5189ae;padding: 10px 25px;}
		.popup_ul{list-style: none;display: flex;justify-content: space-between; margin: 0px; padding: 0px;}
		.popup_title{color: #ffffff;font-weight: bold;font-size: 20px; line-height: 50px;}
		.dhx_button--view_flat.dhx_button--color_primary {background-color: #dddddd;outline-width: 0;color: #2f3031;border: 1px solid #616161;border-radius: 5px;}
		.dhx_button--view_flat.dhx_button--color_primary:hover{background-color: #f3f3f3;outline-width: 0;color: #2f3031;border: 1px solid #616161;border-radius: 5px;}
		.dhx_button--view_flat.dhx_button--color_primary:active
		,.dhx_button--view_flat.dhx_button--color_primary:focus
		 {background-color: #dddddd;outline-width: 0;color: #2f3031;border: 1px solid #616161;border-radius: 5px;}
		.manual_box{width: 80%; text-align: center; margin: 0 auto; padding: 20px 0;}
		.manual_box img{width: 900px; max-width: 100%; height: auto;}
		</style>
	</head>
	<body>
		<jsp:directive.include file="page_script.jsp" />
		<script>
		
		
		// *************************************************************************************************
		// 변수 선언
		// *************************************************************************************************
		
			$(document).ready(function() {
				let toolbarTitle = POPUP_PARAM.toolbarTitle;
				$('.popup_title').html(toolbarTitle);
			});
			// ********************************************************************************************
			// 레이아웃
			// ********************************************************************************************
				let layout = initLayout({
				    rows: [
				        {
				            id: 'layout',
				            rows: [
				                { // 탭바
				                    id: 'tabbar',
				                    height: 'content'
				                },
				                {
				                    cols: [
				                        {
				                            id: 'outlook_classic',
				                            html: `
				                            	<div class="manual_box">
				                            		<img src="../../acms/image/login/outlook_manual_classic.jpg">
				                            	</div>
				                            `
				                        },
				                        {
				                            id: 'outlook_2016',
				                            html: `
				                            	<div class="manual_box">
				                            		<img src="../../acms/image/login/outlook_manual_2016.jpg">
				                            	</div>
				                            `
				                        }
				                    ]
				                }
				            ]
				        }
				    ]
				});		
			
			//**********************************************************************************
			// 탭 세팅
			//**********************************************************************************
			let tabbar = setWidgetConfig({
				parent: layout.tabbar,
				items: [
					{id: 'outlook_classic', text: 'Outlook (Classic)', target: layout.outlook_classic},
					{id: 'outlook_2016', text: 'Outlook (2016)', target: layout.outlook_2016}
				]
			});

			tabbar = initTabbar(tabbar);
			
		</script>
		<div class="popup_header">
			<nav>
				<ul class="popup_ul">
					<li class="">
						<span class="popup_title"></span>
					</li>
				</ul>
			</nav>
		</div>
	</body>
</html>
