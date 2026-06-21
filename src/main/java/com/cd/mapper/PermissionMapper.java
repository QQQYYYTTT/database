package com.cd.mapper;

import com.cd.entity.PermissionEntity;
import java.util.List;
import org.apache.ibatis.annotations.Param;

public interface PermissionMapper {

    List<PermissionEntity> selectAll();

    List<PermissionEntity> selectPermissionsByUserId(@Param("userId") Long userId);

    PermissionEntity selectById(@Param("id") Long id);

    PermissionEntity selectByCode(@Param("permissionCode") String permissionCode);

    int insert(PermissionEntity entity);

    int updateById(PermissionEntity entity);

    int deleteById(@Param("id") Long id);
}
