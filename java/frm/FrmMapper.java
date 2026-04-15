package acms.pcm.frm;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface FrmMapper {
    long getFrmSeq();
    String getNow();
    List<FrmDTO> getFrmList(@Param("fieldNames") List<String> fieldNames);
    void insertFrm(@Param("fieldNames") List<String> fieldNames, @Param("fieldValues") List<Object> fieldValues);
    void updateFrm(@Param("frmSeq") long frmSeq, @Param("fieldNames") List<String> fieldNames, @Param("fieldValues") List<Object> fieldValues);
}
