package dev.ailuruslabs.emmaserver.incidents;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import org.springframework.lang.NonNull;

public record Coordinates(
    @DecimalMin(value = "-90", message = "Latitude cannot be less than -90")
    @DecimalMax(value = "90", message = "Latitude cannot be greater than 90")
    double latitude,

    @DecimalMin(value = "-180", message = "Latitude cannot be less than -180")
    @DecimalMax(value = "180", message = "Latitude cannot be greater than 180")
    double longitude
) {}
