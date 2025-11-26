package dev.ailuruslabs.emmaserver.incidents;

import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.Positive;
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
    Page<Incident> getIncidents(Pageable pageable) {
        return incidentService.getIncidents(pageable);
    }

    @GetMapping("/nearby")
    List<Incident> getNearbyIncidents(
        @Valid Coordinates coordinates,
        @RequestParam @Positive @DecimalMax(value = "2,500") double radius
    ) {
        return incidentService.getIncidentsWithinRadius(coordinates, radius);
    }

    @GetMapping("/viewport")
    List<Incident> getIncidentsWithinViewport(
        @Valid ViewportSearchRequest request
    ) {
        return incidentService.getIncidentsWithinBounds(request.topLeft(), request.bottomRight());
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    Incident reportIncident(@Valid @RequestBody IncidentReportRequest incidentReportRequest) {
        return incidentService.saveIncident(incidentReportRequest); // TODO: This should probably also trigger a SSE.
    }
}