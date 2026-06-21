package com.cd.util;

import java.nio.charset.StandardCharsets;
import org.springframework.util.DigestUtils;

public final class Md5Utils {

    private Md5Utils() {
    }

    public static String encrypt(String source) {
        return DigestUtils.md5DigestAsHex(source.getBytes(StandardCharsets.UTF_8));
    }
}
