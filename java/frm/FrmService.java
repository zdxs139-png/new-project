package acms.pcm.frm;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import javax.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import acms.common.BaseService;
import acms.common.GC;
import acms.common.GF;
import acms.sys.file.FileService;
import acms.sys.user.UserDTO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class FrmService extends BaseService<FrmEntity, FrmMapper> {
	public FrmService() {
		super(new FrmEntity());
	}

	@Autowired private FrmMapper frmMapper;
	@Autowired private FileService fileService;

	public HashMap<String, Object> getFrmList(HashMap<String, Object> mapParam, HttpServletRequest request) {
		HashMap<String, Object> mapReturn = new HashMap<String, Object>();
		mapReturn.put(GC.RESULT_CODE, GC.RESULT_OK);
		try {
			List<String> fieldNames = FrmDTO.getConvertedFields();
			mapReturn = GF.getGrid(frmMapper.getFrmList(fieldNames), request);
		} catch (Exception e) {
			mapReturn.put(GC.RESULT_CODE, GC.RESULT_ERROR);
			mapReturn.put(GC.RESULT_MESSAGE, "네트워크 문제로 조회되지 않았습니다");
			GF.error(log, e);
		}
		return mapReturn;
	}

	public HashMap<String, Object> saveFrm(HashMap<String, Object> mapParam, MultipartHttpServletRequest request) {
		HashMap<String, Object> mapReturn = new HashMap<String, Object>();

		// 그리드 rows 커스터마이징
		List<HashMap<String, Object>> rows = this.getSaveGridList(mapParam, request);

		// 파일 그룹 설정
		HashMap<String, Object> mapFile = new HashMap<String, Object>();
		mapFile.put("파일경로", "/frm/"); // 파일 경로
		mapFile.put("그리드_파일컬럼", "attachFileGrpNm"); // 파일 그리드컬럼Id
		mapFile.put("그리드_파일그룹ID_컬럼", "attachFileGrpId"); // 파일그룹ID 그리드컬럼Id
		mapFile.put("세팅할_파일그룹SEQ_컬럼", "attachFileGrpSeq"); // 파일그룹SEQ 세팅할 DB컬럼명
		fileService.setFileGrpSeq(rows, mapFile, request);

		for (HashMap<String, Object> row : rows) {
			if (row.get("crudType").equals("C")) {
				createFrm(row, request);
			} else if (row.get("crudType").equals("U")) {
				updateFrm(row, request);
			} else if (row.get("crudType").equals("D")) {
				updateFrm(row, request);
			}
		}
		mapReturn = getFrmList(mapParam, request);
		return mapReturn;
	}

	public HashMap<String, Object> createFrm(HashMap<String, Object> mapParam, HttpServletRequest request) {
		HashMap<String, Object> mapReturn = new HashMap<String, Object>();
		mapReturn.put(GC.RESULT_CODE, GC.RESULT_OK);

		FrmEntity frmEntity = GF.getDto(mapParam, FrmEntity.class);
		UserDTO loginUser = GF.getLoginUser(request);

		frmEntity.setFrmSeq(frmMapper.getFrmSeq());
		frmEntity.setRegDt(frmMapper.getNow());
		frmEntity.setRegUserSeq(loginUser.getUserSeq());

		// 필드 이름과 값을 가져오기
		List<String> fieldNames = FrmEntity.getConvertedFields();
		List<Object> fieldValues = frmEntity.getFieldValues();

		// 값이 있는 필드만 필터링
		List<String> nonNullFieldNames = new ArrayList<>();
		List<Object> nonNullFieldValues = new ArrayList<>();
		//// System.out.println("contractDTO : " + contractDTO);
		for (int i = 0; i < fieldNames.size(); i++) {
			Object value = fieldValues.get(i);
			if (value != null && !(value instanceof String && ((String) value).isEmpty())) {
				nonNullFieldNames.add(fieldNames.get(i));
				nonNullFieldValues.add(value);
				//// System.out.println(nonNullFieldNames + " : " + nonNullFieldValues);
			}
		}
		try {
			// 인서트 수행
			frmMapper.insertFrm(nonNullFieldNames, nonNullFieldValues);
			mapReturn.put("frmSeq", frmEntity.getFrmSeq());
		} catch (Exception e) {
			mapReturn.put(GC.RESULT_CODE, GC.RESULT_ERROR);
			mapReturn.put(GC.RESULT_MESSAGE, "네트워크 문제로 저장되지 않았습니다");
			GF.error(log, e);
		}
		return mapReturn;
	}

	public HashMap<String, Object> updateFrm(HashMap<String, Object> mapParam, HttpServletRequest request) {
		HashMap<String, Object> mapReturn = new HashMap<String, Object>();
		mapReturn.put(GC.RESULT_CODE, GC.RESULT_OK);

		// System.out.println("mapParam : " + mapParam);

		FrmEntity frmEntity = GF.getDto(mapParam, FrmEntity.class);
		UserDTO loginUser = GF.getLoginUser(request);

		if (mapParam.get("crudType").equals("D")) {
			frmEntity.setDelDt(frmMapper.getNow());
			frmEntity.setDelUserSeq(loginUser.getUserSeq());
			frmEntity.setDelYn("Y");
		} else if (mapParam.get("crudType").equals("U")) {
			frmEntity.setModiDt(frmMapper.getNow());
			frmEntity.setModiUserSeq(loginUser.getUserSeq());
		}

		// 필드 이름과 값을 가져오기
		List<String> fieldNames = FrmEntity.getConvertedFields();
		List<Object> fieldValues = frmEntity.getFieldValues();

		// 값이 있는 필드만 필터링
		List<String> nonNullFieldNames = new ArrayList<>();
		List<Object> nonNullFieldValues = new ArrayList<>();
		//// System.out.println("contractDTO : " + contractDTO);
		for (int i = 0; i < fieldNames.size(); i++) {
			Object value = fieldValues.get(i);
			if (value != null) {
				nonNullFieldNames.add(fieldNames.get(i));
				nonNullFieldValues.add(value);
				//// System.out.println(nonNullFieldNames + " : " + nonNullFieldValues);
			}
		}
		try {
			// 업데이트 수행
			frmMapper.updateFrm(frmEntity.getFrmSeq(), nonNullFieldNames, nonNullFieldValues);
			mapReturn.put("frmSeq", frmEntity.getFrmSeq());
		} catch (Exception e) {
			mapReturn.put(GC.RESULT_CODE, GC.RESULT_ERROR);
			mapReturn.put(GC.RESULT_MESSAGE, "네트워크 문제로 저장되지 않았습니다");
			GF.error(log, e);
		}
		return mapReturn;
	}
}
