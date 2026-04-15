<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%
/***********************************************************************************
* ○ 파일 : email.jsp
* ● 설명 : 시스템관리 > 이메일 대용량 첨부 관리
***********************************************************************************/
%>
<!DOCTYPE html>
<html>
<head>
<jsp:directive.include file="../../common/page_head.jsp" />
<style>
</style>
</head>
<body>
	<jsp:directive.include file="../../common/page_script.jsp" />
	<script>

			//**********************************************************************************
			// 변수 선언
			//**********************************************************************************

	
			$(document).ready(function() {
				emailToolbar.click(TOOLBAR_REFRESH); // 페이지 로드 시 대용량 이메일 첨부 목록 조회
			});
		

			// ********************************************************************************************
			// 레이아웃
			// ******************************************************************************************** 
			let layout = initLayout({
				cols: [
					{
					id: 'layout'
					,resize: true
					,rows: [
						{ // 대용량 이메일 첨부 목록 영역
						id: 'email'
						,resize: true
						,rows: [
						{ // 대용량 이메일 첨부 목록 툴바
							id: 'emailToolbar'
							,height: 'content'
						},
					{ // 대용량 이메일 첨부 목록 그리드
						id: 'emailGrid'
						,css: 'emailGrid'
									}
								]
							}
						]
					}
				]
			});

			// ********************************************************************************************
			// 대용량 첨부 정보 목록 툴바 
			// ********************************************************************************************
			let emailToolbar = setWidgetConfig({
				id: 'emailToolbar'
				,parent: layout.emailToolbar
				,items: [
					{id: TOOLBAR_TITLE, text: '대용량 첨부 정보'} // 대용량 첨부 파일 목록
					,{id: 'guideText', type: 'html', html: '<span id="emailGuideText" style="color:red; font-size:12px;"></span>'}// 다운로드 가능 기간 및 횟수 안내문구
					,{type: 'space'}
					,{id: TOOLBAR_CREATE} // 생성
					,{id: TOOLBAR_DELETE} // 삭제
					,{id: TOOLBAR_SAVE} // 저장
					,{id: TOOLBAR_REFRESH} // 새로고침
					,{id: TOOLBAR_EXCEL} // 엑셀 다운로드
					,{id: TOOLBAR_FILTER} // 필터
				]
			});

			emailToolbar[TOOLBAR_CREATE].onClick = function() { // 생성 (팝업창)
				openEmailPopup(); 
			};

			emailToolbar[TOOLBAR_DELETE].onClick = function() { // 삭제			
				emailGrid.deleteRow();  
			};
				
			emailToolbar[TOOLBAR_SAVE].onClick = function() { // 저장
				deleteEmail(); // 그리드 저장
			};
			
			emailToolbar[TOOLBAR_REFRESH].onClick = function() { //새로고침
				loadEmailGridData();
			};
		
			emailToolbar[TOOLBAR_EXCEL].onClick = function() { // 엑셀 다운로드 
			        emailGrid.toExcel();  
			    };
		
			emailToolbar = initToolbar(emailToolbar); // 툴바 생성 

			// ********************************************************************************************
			// 이메일 대용랑 첨부관리 목록 그리드 
			// ********************************************************************************************    
				let emailGrid = setWidgetConfig({
					parent: layout.emailGrid
					,items: [
						{id: 'no', text: mlang('col_no'), width: 50} //번호
					    ,{id: 'fileNm', text: mlang('col_fileNm'), width: 300, type: 'file', fileGrpId: 'fileGrpId', fileId: 'fileId', fileExt: 'fileExt', fileSizeShow: 'fileSizeShow', readonly: true, btnShow: false} // 파일명
						,{id: 'filecopy', text: '대용량 링크', width: 100} //대용량 링크  
						,{id: 'status', text: mlang('col_status'), width: 100} // 상태
						,{id: 'regUserNm', text: mlang('col_regUser'), width: 100} // 등록자
						,{id: 'regDt', text: mlang('col_regDt'), width: 160} // 등록 일자
						,{id: 'delDt', text: '삭제 일자', width: 160} // 삭제 일자 
						,{id: 'maxDownCnt', text: '다운로드 횟수', width: 120, align: 'center'} // 다운로드 횟수
						,{id: 'rmk', text: mlang('col_remark'), width: 180, align: 'left'} //비고
											
						// 파일 (SYS_FILE)
						,{id: 'emailFileSeq', hidden: true} 
						,{id: 'fileGrpSeq', hidden: true} 
						,{id: 'fileGrpId', hidden: true} 
						,{id: 'fileExt', hidden: true} 
						,{id: 'fileSize', hidden: true} 
						,{id: 'fileSizeShow', hidden: true} 
						,{id: 'downCnt', hidden: true}
						,{id: 'changeFileNm', hidden: true}
						,{id: 'fileId', hidden: true}
					]
					,toolbar: emailToolbar 
					,multiselection: true
					,blockSelect: true
				});

			emailGrid['filecopy'].onSetValue = function(value, rowId, colId) { // 대용량 링크 컬럼에 링크복사 버튼 표시
				let rowData = emailGrid.getRowData(rowId); 
	
				if (isEmpty(rowData.fileNm) == false) {
					return `<div class="grid_btn_i_center"><button style="font-size:11px;">링크복사</button></div>`;  
				} else {
					return '';
				}
			}
	
			emailGrid.onClick = function(rowId, colId) { // 대용량 링크 컬럼 클릭 시 다운로드 URL 복사
				if (colId == 'filecopy') {
					let row = emailGrid.getRowData(rowId); 
					let textToCopy = buildEmailFilePopupUrl(row); 
	
					copyToClipboard(textToCopy);
	
					return false;
				}
				return true;
			};


			emailGrid = initGrid(emailGrid); // 이메일 그리드 생성 
	
			// 대용량 첨부파일 다운로드 기간 및 횟수 안내문구 설정
			function setGuideText(emailDwDay, emailDwCnt) { 
				let guideEl = document.getElementById('emailGuideText'); 
					
				if (guideEl) {
					guideEl.innerHTML =
					'* 대용량 파일은 등록일자 기준으로 <b style="color:blue;">'
					+ emailDwDay 
					+ '일</b> 지나면 삭제되며, 파일당 다운로드 횟수는 <b style="color:blue;">'
					+ emailDwCnt 
					+ '회</b> 입니다.';
				} else { 
					alert('emailGuideText 없음');
				}
			} 
			
			// 대용량 이메일 첨부 목록 데이터를 조회하는 함수 
			function loadEmailGridData() { 
			    emailGrid.search({ 
			        url: '/sys/email/loadEmailGridData', 
			        param: {
			            projSeq: PROJ_SEQ 
			        },
			        success: function(data) { 
			            if (data[GC.RESULT_CODE] === GC.RESULT_OK) { 
			            	console.log('loadEmailGridData result = ', data);  
			                emailGrid.parse(data.list);

			                if (!isEmpty(data.emailDwDay) && !isEmpty(data.emailDwCnt)) {
			                    setGuideText(data.emailDwDay, data.emailDwCnt); 
			                }

			                if (data.list != null && data.list.length > 0) { 
			                    emailGrid.selectRow(0); 
			                }
			            } else { 
			                alert(data[GC.RESULT_MESSAGE]); 
			            }
			        }
			    });
			}
			
			function refreshGrid() { // 대용량 이메일 첨부 목록을 다시 조회하는 함수
				loadEmailGridData(); // 대용량 이메일 첨부 목록 조회 함수를 실행한다
			}
			
			 // 신규 등록 및 수정용 이메일 첨부 팝업 호출
			function openEmailPopup(rowId) {
				let param = { 
					title: '이메일 첨부파일', 
					projSeq: PROJ_SEQ, 
					width: 850, 
					height: 240 
				};

				
				if (isEmpty(rowId) == false) { 
					let row = emailGrid.getRow(rowId); 
					param.crudType = GC.CRUD_UPDATE; 
					param.emailFileSeq = row.emailFileSeq; 
				} else { 
					param.crudType = GC.CRUD_INSERT; 
				}

				openPopup({ 
					url: '/sys/email/emailPopup', 
					param: param 
				});
			}

			function deleteEmail() { // 선택한 이메일 첨부 데이터를 삭제한 후 목록을 다시 조회한다
				emailGrid.save({
					url: '/sys/email/deleteEmail' // 이메일 첨부 삭제 API 주소를 url에 담는다
					,param: {
						
					}
					,success: function(data) {
						if(data[GC.RESULT_CODE] == GC.RESULT_OK) {
						alert(mlang('msg_mSave'), function() { // 저장되었습니다.
							loadEmailGridData('Y');
						});
					} else if(data[GC.RESULT_CODE] == GC.RESULT_ERROR){
						var str = getResultMessage(data);
						//에러
						if(str){
							alert(getResultMessage(data));
							return;
						}
					}
				}
				,fail: function(data) {
					alert(mlang('msg_mFailed'));
				}
			});
		}


			function buildEmailFilePopupUrl(row) { // 선택한 행 데이터를 이용해 대용량 이메일 파일 팝업 URL을 생성한다
				let popupUrl = '';

				popupUrl = FILE_SERVER_URL;
				popupUrl = popupUrl + '/common/emailFileListPopup?idx='; 

				let fileGrpId = row.fileGrpId; 
				popupUrl = popupUrl + fileGrpId + '-'; 

				let emailFileSeq = row.emailFileSeq; 
				popupUrl = popupUrl + emailFileSeq; 

				return popupUrl; 
			}

			// 전달받은 문자열을 클립보드에 복사하는 함수
			function copyToClipboard(textToCopy) {
				if (navigator.clipboard && navigator.clipboard.writeText) {
					navigator.clipboard.writeText(textToCopy).then(() => { 
						alert(multiLangText(MLANG.msg_mCopy)); 
					}).catch(err => { 
						fallbackCopyToClipboard(textToCopy); 
					});
				} else { 
					fallbackCopyToClipboard(textToCopy); 
				}
			}

			// 표준 복사가 안 될 때 우회 방식으로 복사하는 함수
			function fallbackCopyToClipboard(textToCopy) { 
				var textArea = document.createElement('textarea');
				textArea.value = textToCopy; 

				textArea.style.position = 'fixed'; 
				textArea.style.left = '-9999px'; 
				textArea.style.top = '0'; 
				document.body.appendChild(textArea); 

				textArea.select(); 

				try {
					var successful = document.execCommand('copy'); 

					if (successful) { 
						alert(multiLangText(MLANG.msg_mCopy)); 
					} else { 
						alert(multiLangText(MLANG.mSaceingFailed)); 
					}
				} catch (err) {
					alert(multiLangText(MLANG.mSaceingFailed)); 
				}
				document.body.removeChild(textArea); 
			}
			
		</script>
</body>
</html>