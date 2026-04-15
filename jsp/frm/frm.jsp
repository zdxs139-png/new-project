<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%
/***********************************************************************************
* ○ 파일	: contract_management.jsp
* ● 설명	: 계약관리
***********************************************************************************/
%>
<!DOCTYPE html>
<html>
	<head>
		<jsp:directive.include file="../../common/page_head.jsp"/>
	</head>
	<style>
		.yellow {
			background-color: #FFFF00!important;
		}
		.contractInfoMemberGrid{
			margin-left: 10px!important;
		}
	</style>
	<body>
		<jsp:directive.include file="../../common/page_script.jsp"/>
		<script src="/acms/js/purchase/purchase.js"></script> <!-- 구매관리 공통 -->
		<script>

		// *************************************************************************************************
		// 상수
		// *************************************************************************************************

		const DEV_FLAG = false; // 개발모드
		let CURRENT_CLICK_GRID_ID = 0;
		let isAuth = false;



		// *************************************************************************************************
		// 화면 초기화
		// *************************************************************************************************

		$(document).ready(function() {
			setEditYn(false)
			getfrm();
		});



		// ********************************************************************************************
		// 레이아웃
		// ********************************************************************************************

		let layout = initLayout({
			 rows: [{
				 id: 'frmToolbar'
				 ,height: 'content'
			}
			,{
				id: 'frmGrid'
			}]
			,height: 'content'
		});



		// *************************************************************************************************
		// 메인 툴바
		// *************************************************************************************************
		let frmToolbar = setWidgetConfig({
			id: 'frmToolbar'
			,parent: layout.frmToolbar
			,items: [
				 {id: TOOLBAR_TITLE, text: mlang('lab_siteMaterialRequestForm')} //현장자재요청서
				,{id: '리비전자리'}
				,{type: 'space'}
				,{id: TOOLBAR_TEMP_FILE_DOWNLOAD} // 양식 다운로드
				,{id: TOOLBAR_INSERT} // 행추가
				//,{id: '추가', text: '추가', icon: '', tooltip: '추가', hidden: true}
				,{id: TOOLBAR_DELETE} // 삭제
				,{id: TOOLBAR_SAVE} // 저장
				//,{id: '저장', text: '저장', icon: '', tooltip: '저장', hidden: true}
				,{id: TOOLBAR_REFRESH} // 새로고침
				,{id: TOOLBAR_EXCEL} // 엑셀
				,{id: TOOLBAR_FILTER} // 필터
				/*,{id: '편집', text: '편집', icon: '', tooltip: '편집'}*/
			]
		});
		frmToolbar[TOOLBAR_REFRESH].onClick = function() {
			getfrm()
		};
		frmToolbar[TOOLBAR_TEMP_FILE_DOWNLOAD].onClick = function(){
			fileDownload();
		};
		frmToolbar[TOOLBAR_INSERT].onClick = function() {
			frmGrid.addRow();
		};
		/*frmToolbar['편집'].onClick = function() {
			setEditYn(true);
		};*/
		frmToolbar[TOOLBAR_SAVE].onClick = function() {
			savefrm();
		};
		frmToolbar = initToolbar(frmToolbar);

		/* 
			1. 구매관리 사업단 체크 (ex. '저장' 버튼 체크 여부)
			- isEmpty(frmToolbar[id].hidden) : true = 버튼 권한 체크 (O), false = 버튼 권한 체크 (X)
		*/
		if (isEmpty(frmToolbar[TOOLBAR_SAVE].hidden)) {
			isAuth = true;
		}



		// *************************************************************************************************
		// 메인 그리드
		// *************************************************************************************************
		let frmGrid = setWidgetConfig({
			id: 'frmGrid'
			,parent: layout.frmGrid
			,items: [
				 {id: 'no'                 , hidden: false    , width: 40  , text: mlang('col_no')}
				,{id: 'frmSeq'             , hidden: true     , width: 80  , text: mlang('lab_mgtNo')} //관리번호
				,{id: 'purchaseRequestNo'  , hidden: false    , width: 200 , text: mlang('col_purchaseRequestNo'), edit: true, required:true} //구매요구번호<br>(구매요청번호)
				,{id: 'attachFileGrpNm'    , hidden: false    , width: 230 , text: mlang('col_atta'), edit: true, fileGrpId: 'attachFileGrpId', type: 'file', multiple: true}
				,{id: 'attachFileGrpId'	   , hidden: true}
				,{id: 'requestDt'          , hidden: false    , width: 140 , text: mlang('col_regDt2'), edit: true, type: 'date'} //요청일자
				,{id: 'specNo'             , hidden: false    , width: 140 , text: mlang('col_specNo'), edit: true} //SPEC NO
				,{id: 'qtClassCd'          , hidden: false    , width: 80  , text: mlang('col_qualityRate'), edit: true, type: 'combo', codeGroupCd : 'QAM_QT_CLASS'} //품질등급
				,{id: 'receiptNo'          , hidden: false    , width: 140 , text: mlang('col_receiptNo'), edit: true} //접수번호
				,{id: 'receiptDt'          , hidden: false    , width: 140 , text: mlang('lab_receiptDt'), edit: true, type: 'date'} //접수일자
				,{id: 'contractDt'         , hidden: false    , width: 140 , text: mlang('col_contractDt'), edit: true, type: 'date'} //계약일자
				,{id: 'siteDeliveryDt'     , hidden: false    , width: 140 , text: mlang('col_siteDeliveryDt'), edit: true, type: 'date'} //현장도착예정일자
				,{id: 'remark'             , hidden: false    , width: 475 , text: mlang('col_remark'), edit: true}
			]
			,toolbar: frmToolbar
			,multiselection: true
			,hideTotal: true
		});

		// 그리드 클릭 이벤트
		frmGrid.onClick = function(rowId, colId, beforeRowId, rowIndex, colIndex) {
		};

		frmGrid.onDblClick = function(rowId, colId, beforeRowId, rowIndex, colIndex) {
		};

		// 검토요청 그리드 생성
		frmGrid = initGrid(frmGrid);



		// *************************************************************************************************
		// 함수
		// *************************************************************************************************

		function authChk(){
			setEditYn(false);

			if (isAuth) {
				setEditYn(true);
			}

			/* let autoParam = {};
			autoParam.url = '/ctm/contract/contractor/list';
			autoParam.authCd = 'PVC08'
			readData(autoParam, (response) => {
				let list = response[GC.RESULT_LIST]
				setEditYn(false)
				for(let obj of list){
					if(obj.USER_SEQ == GLOBAL.LOGIN_USER.userSeq){
						setEditYn(true);
					}
				}
			}); */
		}

		function savefrm(){
			let saveParam = frmGrid.getSaveJson();
			if(isEmpty(frmGrid.getUpdatedRows())){
				alert(mlang('msg_wNoData'));
				return;
			}
			if(!validateGrid(frmGrid)){
				return;
			}
			saveParam.url = '/pcm/frm/save';

			let confirmMsg = multiLangText(MLANG.lab_qSave); // 저장하시겠습니까?
			confirm(confirmMsg, function() {
				loading();
				saveData(saveParam, (response) => {
					alert(mlang('msg_mSave'), () => {
						hideLoading();
						getfrm()
					});
				});
			});
		}

		function getfrm(){
			let searchParam = {};
			searchParam.url = '/pcm/frm/query';
			//조회
			readData(searchParam, (response) => {
				gridParsing(frmGrid, response, () => {
					authChk();
				});
			});
		}

		function setEditYn(editYn){
			frmGrid.setEditable(editYn);
			if(editYn){
				frmToolbar.show(TOOLBAR_DELETE);
				//frmToolbar.hide('편집');
				frmToolbar.show(TOOLBAR_INSERT);
				frmToolbar.show(TOOLBAR_SAVE);
			}else{
				frmToolbar.hide(TOOLBAR_DELETE);
				//frmToolbar.show('편집');
				frmToolbar.hide(TOOLBAR_INSERT);
				frmToolbar.hide(TOOLBAR_SAVE);
			}
		}

		function validateGrid(grid){
			let validateFlag = true;
			let checkedItem = '';
			for (const item of grid.getUpdatedRows()) { // 필수값 체크
				if(item.purchaseRequestNo == ''){
					alert(mlang('msg_needPurchaseNo'));
					validateFlag = false;
					break;
				}
			};
			return validateFlag;
		}

		// 양식 다운로드 (한글 파일)
		function fileDownload() {
			let tempCd = 'PCM001'
			post({
				url: '/sys/file/selectFile'
				,param: {
					tempCd: tempCd // 양식 ID
				}
				,success : function(data) {
					if (data[GC.RESULT_CODE] == GC.RESULT_OK) {
						let fileData = data.list[0];
						download({
							param: {
								tempCd: tempCd
								,fileId: fileData.fileId
							}
						});
					} else {
						alert(data[GC.RESULT_MESSAGE]);
					}
				}
			});
		}
		</script>
	</body>
</html>