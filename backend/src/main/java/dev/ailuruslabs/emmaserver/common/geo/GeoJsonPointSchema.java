package dev.ailuruslabs.emmaserver.common.geo;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

@Schema(name = "GeoJsonPoint", description = "GeoJSON Point geometry")
public record GeoJsonPointSchema(
    @Schema(description = "Type of geometry", example = "Point")
    String type,

    @Schema(description = "Coordinates [lon, lat]", example = "[120.984, 14.599]")
    List<Double> coordinates
) {}
