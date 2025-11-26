package dev.ailuruslabs.emmaserver.incidents;

import jakarta.validation.Valid;

public record ViewportSearchRequest(
    @Valid Coordinates topLeft,
    @Valid Coordinates bottomRight
) {}
