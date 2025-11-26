package dev.ailuruslabs.emmaserver.incidents;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;

public record Coordinates(
    @NotNull(message = "Latitude is required")
    @DecimalMin(value = "-90", message = "Latitude cannot be less than -90")
    @DecimalMax(value = "90", message = "Latitude cannot be greater than 90")
    @Schema(description = "Latitude", example = "14.599")
    Double lat,

    @NotNull(message = "Longitude is required")
    @DecimalMin(value = "-180", message = "Longitude cannot be less than -180")
    @DecimalMax(value = "180", message = "Longitude cannot be greater than 180")
    @Schema(description = "Longitude", example = "120.984")
    Double lon
) {}
