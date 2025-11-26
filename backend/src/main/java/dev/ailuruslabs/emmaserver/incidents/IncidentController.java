package dev.ailuruslabs.emmaserver.incidents;

import io.swagger.v3.oas.annotations.Parameter;
import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import org.springdoc.core.annotations.ParameterObject;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/incidents")
class IncidentController {

    private final IncidentService incidentService;

    IncidentController(IncidentService incidentService) {this.incidentService = incidentService;}

    @GetMapping
    Page<Incident> getIncidents(@ParameterObject Pageable pageable) {
        return incidentService.getIncidents(pageable);
    }

    @GetMapping("/nearby")
    List<Incident> getNearbyIncidents(
        @ParameterObject @Valid Coordinates coordinates,

        @Parameter(description = "Radius in meters")
        @RequestParam @NotNull @Positive @DecimalMax(value = "100000") Double radius
    ) {
        return incidentService.getIncidentsWithinRadius(coordinates, radius);
    }

    @GetMapping("/viewport")
    List<Incident> getIncidentsWithinViewport(
        @ParameterObject @Valid ViewportSearchRequest request
    ) {
        return incidentService.getIncidentsWithinBounds(request.topLeft(), request.bottomRight());
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    Incident reportIncident(@Valid @RequestBody IncidentReportRequest incidentReportRequest) {
        return incidentService.saveIncident(incidentReportRequest); // TODO: This should probably also trigger a SSE.
    }
}