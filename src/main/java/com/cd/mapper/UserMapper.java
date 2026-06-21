package com.cd.mapper;

import com.cd.dto.UserResponse;
import com.cd.entity.UserEntity;
import java.time.LocalDateTime;
import java.util.List;
import org.apache.ibatis.annotations.Param;

public interface UserMapper {

    long countByUserName(@Param("userName") String userName);

    List<UserResponse> selectPage(@Param("userName") String userName,
                                  @Param("offset") int offset,
                                  @Param("size") int size);

    UserResponse selectViewById(@Param("id") Long id);

    UserEntity selectEntityById(@Param("id") Long id);

    UserEntity selectEntityByUserName(@Param("userName") String userName);

    int insert(UserEntity entity);

    int updateById(UserEntity entity);

    int updateLastLoginTime(@Param("id") Long id, @Param("lastLoginTime") LocalDateTime lastLoginTime);

    int updatePasswordById(@Param("id") Long id, @Param("userPwd") String userPwd);

    int deleteById(@Param("id") Long id);

    List<Long> selectRoleIdsByUserId(@Param("userId") Long userId);

    int deleteUserRolesByUserId(@Param("userId") Long userId);

    int insertUserRoles(@Param("userId") Long userId, @Param("roleIds") List<Long> roleIds);
}
