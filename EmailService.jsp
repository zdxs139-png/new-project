package acms.sys.email;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import javax.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import acms.common.BaseService;
import acms.common.GC;
import acms.common.GF;
import acms.sys.file.FileService;
import acms.sys.mlang.SYS_MLANG;
import acms.sys.user.UserDTO;
import common.config.ApiDTO;
import lombok.extern.slf4j.Slf4j;


@Slf4j
@Service
public class EmailService extends BaseService<EmailDTO, EmailMapper> {

	public EmailService() {
		super(new EmailDTO());
	}

	@Autowired
	private EmailMapper emailMapper;
	@Autowired
	private FileService fileService;

	// 메인 그리드 조회
	public HashMap<String, Object> getLoadEmailGridData(HashMap<String, Object> mapParam,
			HttpServletRequest request) {
		HashMap<String, Object> mapReturn = new HashMap<String, Object>();

		if (GF.getLoginYn(request)) {
			mapReturn.put(GC.RESULT_CODE, GC.RESULT_OK);

			try {
				UserDTO loginUser = GF.getLoginUser(request);
				mapParam.put("loginUserSeq", loginUser.getUserSeq());

				// 공통코드 SYS_EMAIL_FILE 기준 설정값
				String emailDwDay = String.valueOf(emailMapper.getEmailDwDay());
				String emailDwCnt = String.valueOf(emailMapper.getEmailDwCnt());

				mapParam.put("maxDownloadCnt", emailDwCnt);
				mapParam.put("maxDownloadDay", emailDwDay);

				List<EmailDTO> list = emailMapper.getLoadEmailGridData(mapParam);
				mapReturn = GF.getGrid(list, request);

				mapReturn.put("emailDwDay", emailDwDay);
				mapReturn.put("emailDwCnt", emailDwCnt);


			} catch (Exception e) {
				mapReturn.put(GC.RESULT_CODE, GC.RESULT_ERROR);
				mapReturn.put(GC.RESULT_MESSAGE, SYS_MLANG.get("msg_DataError", request));
				GF.error(log, e);
			}

		} else {
			mapReturn.put(GC.RESULT_CODE, GC.RESULT_LOGOUT);
			mapReturn.put(GC.RESULT_MESSAGE, SYS_MLANG.get("msg_mLogout", request));
		}

		return mapReturn;
	}

	// 메인 그리드 저장
	public HashMap<String, Object> getSaveEmailGrid(HashMap<String, Object> mapParam,
			MultipartHttpServletRequest request) {
		HashMap<String, Object> mapReturn = new HashMap<String, Object>();

		if (GF.getLoginYn(request)) {
			UserDTO loginUser = GF.getLoginUser(request);
			mapParam.put("regUserSeq", loginUser.getUserSeq());

			try {
				long emailFileSeq = GF.getLong(mapParam.get("emailFileSeq"));

				// 공통코드 SYS_EMAIL_FILE 기준 설정값
				String emailDwDay = String.valueOf(emailMapper.getEmailDwDay());
				String emailDwCnt = String.valueOf(emailMapper.getEmailDwCnt());

				mapParam.put("maxDownloadCnt", emailDwCnt);
				mapParam.put("maxDownloadDay", emailDwDay);

				if (emailFileSeq <= 0) {
					emailFileSeq = emailMapper.getEmailFileSeq();
					mapParam.put("emailFileSeq", emailFileSeq);
				}

				HashMap<String, Object> mapFile = new HashMap<String, Object>();
				mapFile.put("파일경로", "/EMAIL/");
				mapFile.put("파일요소_컬럼", "emailFile");
				mapFile.put("파일ID_컬럼", "fileId");
				mapFile.put("파일그룹ID_컬럼", "fileGrpId");
				mapFile.put("세팅할_파일그룹SEQ_컬럼", "fileGrpSeq");
				mapFile.put("그리드여부", false);

				HashMap<String, Object> row = new HashMap<String, Object>();
				row.putAll(mapParam);

				fileService.setFileGrpSeq(row, mapFile, request);

				long fileGrpSeq = GF.getLong(row.get("fileGrpSeq"));


				if (fileGrpSeq <= 0) {
					mapReturn.put(GC.RESULT_CODE, GC.RESULT_FAIL);
					mapReturn.put(GC.RESULT_MESSAGE, "첨부파일 그룹 생성에 실패했습니다.");
					return mapReturn;
				}

				mapParam.put("fileGrpSeq", fileGrpSeq);

				if (GF.isEmpty(mapParam.get("status"))) {
					mapParam.put("status", "DW_Y");
				}

				emailMapper.insertEmail(mapParam);

				mapReturn.put(GC.RESULT_CODE, GC.RESULT_OK);
				mapReturn.put(GC.RESULT_MESSAGE, "저장되었습니다.");
				mapReturn.put("emailFileSeq", emailFileSeq);

			} catch (Exception e) {
				mapReturn.put(GC.RESULT_CODE, GC.RESULT_ERROR);
				mapReturn.put(GC.RESULT_MESSAGE, SYS_MLANG.get("msg_DataError", request));
				GF.error(log, e);
			}
		} else {
			mapReturn.put(GC.RESULT_CODE, GC.RESULT_LOGOUT);
			mapReturn.put(GC.RESULT_MESSAGE, SYS_MLANG.get("msg_mLogout", request));
		}

		return mapReturn;
	}



	// 삭제
	@SuppressWarnings("unchecked")
	public HashMap<String, Object> getDeleteEmail(HashMap<String, Object> mapParam,
			HttpServletRequest request) {
		HashMap<String, Object> mapReturn = new HashMap<String, Object>();

		if (GF.getLoginYn(request)) {
			try {
				// 삭제 대상 이메일 첨부의 물리파일 경로 조회
				List<EmailDTO> deleteList = emailMapper.getEmailFilePathList(mapParam);

				if (deleteList == null) {
					deleteList = new ArrayList<EmailDTO>();
				}

				// 물리파일 삭제
				for (int i = 0; i < deleteList.size(); i++) {
					EmailDTO emailDto = deleteList.get(i);
					String 원본파일경로 = GF.getString(emailDto.getFilePath());

					if (GF.isEmpty(원본파일경로) == false) {
						ApiDTO apiParam = new ApiDTO();
						apiParam.setUrl(
								GC.FILE_SERVER_URL + "/sys/email/deletePhysicalFileInServer");
						apiParam.addParam("filePath", GF.encodeUrlBase64(원본파일경로));

						HashMap<String, Object> apiReturn = GF.sendApi(apiParam);
						if (GF.isResultOk(apiReturn)) {
							Object responseObj = apiReturn.get(GC.RESULT_RESPONSE);

							if (responseObj instanceof ResponseEntity<?>) {
								ResponseEntity<?> response = (ResponseEntity<?>) responseObj;

								if (response.getBody() instanceof HashMap) {
									apiReturn = (HashMap<String, Object>) response.getBody();
								}
							}
						}

						if (GF.isResultOk(apiReturn) == false) {
							mapReturn.put(GC.RESULT_CODE, GC.RESULT_FAIL);
							mapReturn.put(GC.RESULT_MESSAGE, "물리파일 삭제에 실패했습니다.");
							return mapReturn;
						}
					}
				}

				// DB 행 삭제
				int result = emailMapper.deleteEmail(mapParam);

				if (result > 0) {
					mapReturn.put(GC.RESULT_CODE, GC.RESULT_OK);
					mapReturn.put(GC.RESULT_MESSAGE, "삭제되었습니다.");
				} else {
					mapReturn.put(GC.RESULT_CODE, GC.RESULT_FAIL);
					mapReturn.put(GC.RESULT_MESSAGE, "삭제할 데이터가 없습니다.");
				}

				mapReturn.put("resultCnt", result);

			} catch (Exception e) {
				mapReturn.put(GC.RESULT_CODE, GC.RESULT_ERROR);
				mapReturn.put(GC.RESULT_MESSAGE, SYS_MLANG.get("msg_DataError", request));
				GF.error(log, e);
			}
		} else {
			mapReturn.put(GC.RESULT_CODE, GC.RESULT_LOGOUT);
			mapReturn.put(GC.RESULT_MESSAGE, SYS_MLANG.get("msg_mLogout", request));
		}

		return mapReturn;
	}



	public HashMap<String, Object> checkAndIncreaseDownCnt(HashMap<String, Object> mapParam,
			HttpServletRequest request) {
		HashMap<String, Object> mapReturn = new HashMap<String, Object>();

		if (GF.getLoginYn(request)) {
			try {
				String emailDwCnt = String.valueOf(emailMapper.getEmailDwCnt());
				mapParam.put("maxDownloadCnt", emailDwCnt);

				HashMap<String, Object> fileInfo = emailMapper.getDownloadInfo(mapParam);

				int downCnt = Integer.parseInt(String.valueOf(fileInfo.get("downCnt")));
				int maxDownloadCnt =
						Integer.parseInt(String.valueOf(mapParam.get("maxDownloadCnt")));

				if (downCnt >= maxDownloadCnt) {
					mapReturn.put(GC.RESULT_CODE, GC.RESULT_ERROR);
					mapReturn.put(GC.RESULT_MESSAGE, "다운로드 가능 횟수를 초과했습니다.");
					return mapReturn;
				}

				mapParam.put("fileGrpSeq", fileInfo.get("fileGrpSeq"));
				emailMapper.updateDownCnt(mapParam);

				mapReturn.put(GC.RESULT_CODE, GC.RESULT_OK);
				mapReturn.put(GC.RESULT_MESSAGE, "다운로드 가능합니다.");

			} catch (Exception e) {
				mapReturn.put(GC.RESULT_CODE, GC.RESULT_ERROR);
				mapReturn.put(GC.RESULT_MESSAGE, SYS_MLANG.get("msg_DataError", request));
				GF.error(log, e);
			}
		} else {
			mapReturn.put(GC.RESULT_CODE, GC.RESULT_LOGOUT);
			mapReturn.put(GC.RESULT_MESSAGE, SYS_MLANG.get("msg_mLogout", request));
		}

		return mapReturn;
	}

	public HashMap<String, Object> getLoadEmailSetting(HashMap<String, Object> mapParam,
			HttpServletRequest request) {
		HashMap<String, Object> mapReturn = new HashMap<String, Object>();

		if (GF.getLoginYn(request)) {
			try {
				HashMap<String, Object> setting = emailMapper.getEmailSetting(mapParam);

				mapReturn.put(GC.RESULT_CODE, GC.RESULT_OK);
				mapReturn.put(GC.RESULT_DATA, setting);

			} catch (Exception e) {
				mapReturn.put(GC.RESULT_CODE, GC.RESULT_ERROR);
				mapReturn.put(GC.RESULT_MESSAGE, SYS_MLANG.get("msg_DataError", request));
				GF.error(log, e);
			}
		} else {
			mapReturn.put(GC.RESULT_CODE, GC.RESULT_LOGOUT);
			mapReturn.put(GC.RESULT_MESSAGE, SYS_MLANG.get("msg_mLogout", request));
		}

		return mapReturn;
	}

	public HashMap<String, Object> getSaveEmailSetting(HashMap<String, Object> mapParam,
			HttpServletRequest request) {
		HashMap<String, Object> mapReturn = new HashMap<String, Object>();

		if (GF.getLoginYn(request)) {
			try {
				UserDTO loginUser = GF.getLoginUser(request);

				int mailQuota = GF.getInt(mapParam.get("mailQuota"));
				int fileDownCnt = GF.getInt(mapParam.get("fileDownCnt"));
				int downDay = GF.getInt(mapParam.get("downDay"));

				if (mailQuota <= 0 || fileDownCnt <= 0 || downDay <= 0) {
					mapReturn.put(GC.RESULT_CODE, GC.RESULT_FAIL);
					mapReturn.put(GC.RESULT_MESSAGE, "입력값은 양의 정수만 가능합니다.");
					return mapReturn;
				}

				if (mailQuota > 20) {
					mapReturn.put(GC.RESULT_CODE, GC.RESULT_FAIL);
					mapReturn.put(GC.RESULT_MESSAGE, "해당 설정 값의 Max 값은 20 입니다.");
					return mapReturn;
				}

				if (fileDownCnt > 20) {
					mapReturn.put(GC.RESULT_CODE, GC.RESULT_FAIL);
					mapReturn.put(GC.RESULT_MESSAGE, "해당 설정 값의 Max 값은 20 입니다.");
					return mapReturn;
				}

				if (downDay > 30) {
					mapReturn.put(GC.RESULT_CODE, GC.RESULT_FAIL);
					mapReturn.put(GC.RESULT_MESSAGE, "해당 설정 값의 Max 값은 30 입니다.");
					return mapReturn;
				}

				mapParam.put("modiUserSeq", loginUser.getUserSeq());

				emailMapper.updateEmailSettingMailQuota(mapParam);
				emailMapper.updateEmailSettingDownCnt(mapParam);
				emailMapper.updateEmailSettingDownDay(mapParam);

				mapReturn.put(GC.RESULT_CODE, GC.RESULT_OK);
				mapReturn.put(GC.RESULT_MESSAGE, "저장되었습니다.");

			} catch (Exception e) {
				mapReturn.put(GC.RESULT_CODE, GC.RESULT_ERROR);
				mapReturn.put(GC.RESULT_MESSAGE, SYS_MLANG.get("msg_DataError", request));
				GF.error(log, e);
			}
		} else {
			mapReturn.put(GC.RESULT_CODE, GC.RESULT_LOGOUT);
			mapReturn.put(GC.RESULT_MESSAGE, SYS_MLANG.get("msg_mLogout", request));
		}

		return mapReturn;
	}


	public HashMap<String, Object> deletePhysicalFileInServer(HashMap<String, Object> mapParam,
			HttpServletRequest request) {
		HashMap<String, Object> mapReturn = new HashMap<String, Object>();

		try {
			String filePath = GF.decodeUrlBase64(GF.getString(mapParam.get("filePath")));
			if (GF.isEmpty(filePath)) {
				mapReturn.put(GC.RESULT_CODE, GC.RESULT_FAIL);
				mapReturn.put(GC.RESULT_MESSAGE, "삭제할 파일경로가 없습니다.");
				return mapReturn;
			}

			filePath = filePath.replace("\\", "/");
			if (GF.left(filePath, 1).equals("/") == false) {
				filePath = "/" + filePath;
			}

			String fileFullPath = GC.FILE_ROOT + filePath;

			File checkFile = new File(fileFullPath);
			if (checkFile.exists() == false) {
				mapReturn.put(GC.RESULT_CODE, GC.RESULT_OK);
				mapReturn.put(GC.RESULT_MESSAGE, "이미 삭제된 파일입니다.");
				return mapReturn;
			}

			boolean deleteYn = GF.deleteFile(fileFullPath);

			if (deleteYn) {
				mapReturn.put(GC.RESULT_CODE, GC.RESULT_OK);
				mapReturn.put(GC.RESULT_MESSAGE, "삭제되었습니다.");
			} else {
				mapReturn.put(GC.RESULT_CODE, GC.RESULT_FAIL);
				mapReturn.put(GC.RESULT_MESSAGE, "물리파일 삭제에 실패했습니다.");
			}

		} catch (Exception e) {
			mapReturn.put(GC.RESULT_CODE, GC.RESULT_ERROR);
			mapReturn.put(GC.RESULT_MESSAGE, "네트워크 문제로 삭제되지 않았습니다.");
			GF.error(log, e);
		}

		return mapReturn;
	}




}