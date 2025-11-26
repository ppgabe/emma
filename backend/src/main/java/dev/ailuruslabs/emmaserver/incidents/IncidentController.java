package dev.ailuruslabs.emmaserver.incidents;

import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
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

    @PostMapping
    Incident reportIncident(@Valid @RequestBody IncidentReportRequest incidentReportRequest) {
        return incidentService.saveIncident(incidentReportRequest); // TODO: This should probably also trigger a SSE.
    }
}