package acms.sys.email;

import java.util.HashMap;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface EmailMapper {

	long getEmailFileSeq() throws Exception;

	List<EmailDTO> getLoadEmailGridData(HashMap<String, Object> param) throws Exception;

	HashMap<String, Object> getDownloadInfo(HashMap<String, Object> param) throws Exception;

	int insertEmail(HashMap<String, Object> param) throws Exception;

	int deleteEmail(HashMap<String, Object> param) throws Exception;

	int updateDownCnt(HashMap<String, Object> param) throws Exception;

	int getEmailDwDay() throws Exception;

	int getEmailDwCnt() throws Exception;

	List<HashMap<String, Object>> getEmailFilePathList(HashMap<String, Object> mapParam);

	HashMap<String, Object> getEmailSetting(HashMap<String, Object> param) throws Exception;

	int updateEmailSettingMailQuota(HashMap<String, Object> param) throws Exception;

	int updateEmailSettingDownCnt(HashMap<String, Object> param) throws Exception;

	int updateEmailSettingDownDay(HashMap<String, Object> param) throws Exception;

	List<EmailDTO> deleteEmailFileList(HashMap<String, Object> param) throws Exception;

	int updateStatus(HashMap<String, Object> param) throws Exception;
}
