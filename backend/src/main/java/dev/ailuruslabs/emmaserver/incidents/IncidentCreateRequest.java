package dev.ailuruslabs.emmaserver.incidents;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record IncidentCreateRequest(
    @Valid
    Coordinates coordinates,

    @NotBlank
    @Size(min = 6, max = 64, message = "Title must be between 6 and 64 characters")
    String title,

    @NotBlank
    @Size(min = 6, max = 255, message = "Description must be between 6 and 255 characters")
    String description,

    IncidentType type
) {
}
