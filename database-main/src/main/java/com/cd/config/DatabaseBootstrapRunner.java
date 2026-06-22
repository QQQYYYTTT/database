package com.cd.config;

import jakarta.annotation.PostConstruct;
import java.nio.charset.StandardCharsets;
import javax.sql.DataSource;
import org.springframework.core.io.ClassPathResource;
import org.springframework.jdbc.datasource.init.ResourceDatabasePopulator;
import org.springframework.jdbc.datasource.init.ScriptException;
import org.springframework.stereotype.Component;

@Component
public class DatabaseBootstrapRunner {

    private final DataSource dataSource;

    public DatabaseBootstrapRunner(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    @PostConstruct
    public void initializeIfNecessary() {
        if (tableExists("user")) {
            return;
        }

        ResourceDatabasePopulator populator = new ResourceDatabasePopulator();
        populator.setSqlScriptEncoding(StandardCharsets.UTF_8.name());
        populator.addScripts(
                new ClassPathResource("schema.sql"),
                new ClassPathResource("schema-routines.sql"),
                new ClassPathResource("schema-post-data.sql")
        );
        try {
            populator.execute(dataSource);
        } catch (ScriptException ex) {
            throw new IllegalStateException("Failed to initialize database schema", ex);
        }
    }

    private boolean tableExists(String tableName) {
        try (var connection = dataSource.getConnection();
             var resultSet = connection.getMetaData().getTables(connection.getCatalog(), null, tableName, null)) {
            return resultSet.next();
        } catch (Exception ex) {
            throw new IllegalStateException("Failed to inspect database metadata", ex);
        }
    }
}
