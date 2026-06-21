package com.cd.mapper;

import com.cd.dto.RoleOptionResponse;
import com.cd.entity.RoleEntity;
import java.util.List;
import org.apache.ibatis.annotations.Param;

public interface RoleMapper {

    List<RoleEntity> selectAll(@Param("roleName") String roleName);

    List<RoleOptionResponse> selectOptions();

    RoleEntity selectById(@Param("id") Long id);

    RoleEntity selectByCode(@Param("roleCode") String roleCode);

    int insert(RoleEntity entity);

    int updateById(RoleEntity entity);

    int deleteById(@Param("id") Long id);

    List<RoleOptionResponse> selectRolesByUserId(@Param("userId") Long userId);

    List<Long> selectPermissionIdsByRoleId(@Param("roleId") Long roleId);

    int deleteRolePermissionsByRoleId(@Param("roleId") Long roleId);

    int insertRolePermissions(@Param("roleId") Long roleId, @Param("permissionIds") List<Long> permissionIds);
}
