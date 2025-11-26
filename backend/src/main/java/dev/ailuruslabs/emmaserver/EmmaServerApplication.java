package dev.ailuruslabs.emmaserver;

import dev.ailuruslabs.emmaserver.common.geo.GeoJsonPointSchema;
import org.locationtech.jts.geom.Point;
import org.springdoc.core.utils.SpringDocUtils;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class EmmaServerApplication {

    static {
        SpringDocUtils.getConfig().replaceWithClass(Point.class, GeoJsonPointSchema.class);
    }

    public static void main(String[] args) {
        SpringApplication.run(EmmaServerApplication.class, args);
    }

}
