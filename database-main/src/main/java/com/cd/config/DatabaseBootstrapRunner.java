package com.cd.config;

import jakarta.annotation.PostConstruct;
import java.nio.charset.StandardCharsets;
import javax.sql.DataSource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ClassPathResource;
import org.springframework.jdbc.datasource.init.ResourceDatabasePopulator;
import org.springframework.jdbc.datasource.init.ScriptException;
import org.springframework.stereotype.Component;

@Component
public class DatabaseBootstrapRunner {

    private static final Logger log = LoggerFactory.getLogger(DatabaseBootstrapRunner.class);

    private final DataSource dataSource;
    private final boolean initializeOnEmpty;
    private final boolean runtimeSyncOnStartup;

    public DatabaseBootstrapRunner(DataSource dataSource,
                                   @Value("${app.database.bootstrap.initialize-on-empty:false}") boolean initializeOnEmpty,
                                   @Value("${app.database.bootstrap.runtime-sync-on-startup:true}") boolean runtimeSyncOnStartup) {
        this.dataSource = dataSource;
        this.initializeOnEmpty = initializeOnEmpty;
        this.runtimeSyncOnStartup = runtimeSyncOnStartup;
    }

    @PostConstruct
    public void initializeIfNecessary() {
        boolean schemaInitialized = hasRequiredSchema();
        if (!schemaInitialized) {
            if (!initializeOnEmpty) {
                throw new IllegalStateException(
                        "Database schema is missing. Set app.database.bootstrap.initialize-on-empty=true to initialize it explicitly.");
            }
            initializeSchema();
            schemaInitialized = true;
        }

        if (schemaInitialized && runtimeSyncOnStartup) {
            runRuntimeSync();
        } else if (!runtimeSyncOnStartup) {
            log.info("Skipping runtime database sync because app.database.bootstrap.runtime-sync-on-startup=false");
        }
    }

    private void initializeSchema() {
        log.info("Initializing database schema because required tables are missing");
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

    private boolean hasRequiredSchema() {
        return tableExists("user")
                && tableExists("role")
                && tableExists("permission")
                && tableExists("student");
    }

    private void runRuntimeSync() {
        log.info("Running runtime database synchronization scripts");
        ResourceDatabasePopulator populator = new ResourceDatabasePopulator();
        populator.setSqlScriptEncoding(StandardCharsets.UTF_8.name());
        populator.addScripts(
                new ClassPathResource("schema-routines.sql"),
                new ClassPathResource("schema-runtime-sync.sql")
        );
        try {
            populator.execute(dataSource);
        } catch (ScriptException ex) {
            throw new IllegalStateException("Failed to synchronize runtime database metadata", ex);
        }
    }

    private boolean tableExists(String tableName) {
        String normalizedName = tableName == null ? null : tableName.trim();
        if (normalizedName == null || normalizedName.isEmpty()) {
            return false;
        }
        String sql = """
                SELECT COUNT(*)
                FROM information_schema.tables
                WHERE table_schema = DATABASE()
                  AND table_name = ?
                """;
        try (var connection = dataSource.getConnection();
             var statement = connection.prepareStatement(sql)) {
            statement.setString(1, normalizedName);
            try (var resultSet = statement.executeQuery()) {
                resultSet.next();
                return resultSet.getInt(1) > 0;
            }
        } catch (Exception ex) {
            throw new IllegalStateException("Failed to inspect database metadata", ex);
        }
    }
}
