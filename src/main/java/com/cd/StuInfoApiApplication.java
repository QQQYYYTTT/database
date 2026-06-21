package com.cd;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.cd.mapper")
public class StuInfoApiApplication {

    public static void main(String[] args) {
        SpringApplication.run(StuInfoApiApplication.class, args);
    }

}
